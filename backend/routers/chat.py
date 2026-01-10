from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Depends
from jose import jwt, JWTError
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.config import settings
from models.couple import Couple
from services.chat_service import save_message

from typing import Dict, List
from fastapi import WebSocket
from starlette.websockets import WebSocketState

import json
from starlette.websockets import WebSocketDisconnect

router = APIRouter()



# WebSocket Manager


class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, List[WebSocket]] = {}

    async def connect(self, couple_id: int, websocket: WebSocket):
        await websocket.accept()

        if couple_id not in self.active_connections:
            self.active_connections[couple_id] = []

        self.active_connections[couple_id].append(websocket)

    def disconnect(self, couple_id: int, websocket: WebSocket):
        if couple_id not in self.active_connections:
            return

        self.active_connections[couple_id] = [
            ws for ws in self.active_connections[couple_id]
            if ws != websocket
        ]

        if not self.active_connections[couple_id]:
            del self.active_connections[couple_id]

    async def broadcast(self, couple_id: int, message: dict):
        if couple_id not in self.active_connections:
            return

        alive_connections = []

        for ws in self.active_connections[couple_id]:
            try:
                if ws.application_state == WebSocketState.CONNECTED:
                    await ws.send_json(message)
                    alive_connections.append(ws)
            except:
                # socket đã chết → bỏ
                pass

        self.active_connections[couple_id] = alive_connections


manager = ConnectionManager()



# AUTH FOR WEBSOCKET


def get_user_id_from_token(token: str) -> int | None:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=["HS256"],
        )

        # 1️⃣ Check subject (app)
        if payload.get("sub") != "doudate-app":
            return None

        # 2️⃣ Lấy user_id ĐÚNG CHỖ
        user_id = payload.get("user_id")
        if not user_id:
            return None

        return int(user_id)

    except JWTError:
        return None




# WEBSOCKET ENDPOINT


@router.websocket("/ws/chat/{couple_id}")
async def chat_ws(
    websocket: WebSocket,
    couple_id: int,
    db: Session = Depends(get_db),
):
    # LẤY TOKEN TỪ QUERY PARAM
    token = websocket.query_params.get("token")
    if not token:
        await websocket.close(code=1008)
        return

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
            msg = await websocket.receive()

            # Client đóng socket
            if msg["type"] == "websocket.disconnect":
                break

            # Không phải text (ping, pong, binary, keepalive)
            if "text" not in msg:
                continue

            text = msg["text"]

            # Không phải JSON (ping, empty frame...)
            try:
                data = json.loads(text)
            except json.JSONDecodeError:
                continue

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