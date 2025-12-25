from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.config import settings
from models.couple import Couple
from services.chat_service import save_message


router = APIRouter()



# WebSocket Manager


class ConnectionManager:
    def __init__(self):
        self.active_connections: dict[int, list[WebSocket]] = {}

    async def connect(self, couple_id: int, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.setdefault(couple_id, []).append(websocket)

    def disconnect(self, couple_id: int, websocket: WebSocket):
        self.active_connections[couple_id].remove(websocket)

    async def broadcast(self, couple_id: int, message: dict):
        for connection in self.active_connections.get(couple_id, []):
            await connection.send_json(message)


manager = ConnectionManager()



# AUTH FOR WEBSOCKET


def get_user_id_from_token(token: str) -> int:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=["HS256"],
        )
        return int(payload.get("sub"))
    except JWTError:
        return None



# WEBSOCKET ENDPOINT


@router.websocket("/ws/chat/{couple_id}")
async def chat_ws(
    websocket: WebSocket,
    couple_id: int,
    token: str,
    db: Session = Depends(get_db),
):
    user_id = get_user_id_from_token(token)
    if not user_id:
        await websocket.close(code=1008)
        return

    # Check user thuộc couple
    couple = (
        db.query(Couple)
        .filter(
            Couple.id == couple_id,
            or_(
                Couple.user1_id == user_id,
                Couple.user2_id == user_id,
            ),
            Couple.end_date.is_(None),
        )
        .first()
    )
    if not couple:
        await websocket.close(code=1008)
        return

    await manager.connect(couple_id, websocket)

    try:
        while True:
            data = await websocket.receive_json()
            content = data.get("content")

            if not content:
                continue

            message = save_message(
                db=db,
                couple_id=couple_id,
                sender_id=user_id,
                content=content,
            )

            await manager.broadcast(
                couple_id,
                {
                    "id": message.id,
                    "couple_id": couple_id,
                    "sender_id": user_id,
                    "content": message.content,
                    "created_at": message.created_at.isoformat(),
                },
            )
    except WebSocketDisconnect:
        manager.disconnect(couple_id, websocket)
