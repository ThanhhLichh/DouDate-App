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

from models.user import User
from services.push_service import send_push_notification


import json
from starlette.websockets import WebSocketDisconnect

router = APIRouter()



# WebSocket Manager


class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[int, List[WebSocket]] = {}
        self.online_users: Dict[int, set[int]] = {}  # couple_id -> set(user_id)

    async def connect(self, couple_id: int, user_id: int, websocket: WebSocket):
        await websocket.accept()

        self.active_connections.setdefault(couple_id, []).append(websocket)
        self.online_users.setdefault(couple_id, set())

        # 🔔 gửi trạng thái online hiện tại cho user mới
        for uid in self.online_users[couple_id]:
            await websocket.send_json({
                "type": "user_presence",
                "user_id": uid,
                "status": "online",
            })

        # thêm user hiện tại vào online list
        self.online_users[couple_id].add(user_id)

        # 🔔 báo user này online cho người khác
        await self.broadcast(
            couple_id,
            {
                "type": "user_presence",
                "user_id": user_id,
                "status": "online",
            }
        )

    def disconnect(self, couple_id: int, user_id: int, websocket: WebSocket):
        if couple_id in self.active_connections:
            self.active_connections[couple_id] = [
                ws for ws in self.active_connections[couple_id]
                if ws != websocket
            ]

            if not self.active_connections[couple_id]:
                del self.active_connections[couple_id]

        # remove khỏi online list
        if couple_id in self.online_users:
            self.online_users[couple_id].discard(user_id)

        # 🔔 báo offline
        import asyncio
        asyncio.create_task(
            self.broadcast(
                couple_id,
                {
                    "type": "user_presence",
                    "user_id": user_id,
                    "status": "offline",
                }
            )
        )

    async def broadcast(self, couple_id: int, message: dict):
        if couple_id not in self.active_connections:
            return

        alive = []
        for ws in self.active_connections[couple_id]:
            try:
                if ws.application_state == WebSocketState.CONNECTED:
                    await ws.send_json(message)
                    alive.append(ws)
            except:
                pass

        self.active_connections[couple_id] = alive



manager = ConnectionManager()



# AUTH FOR WEBSOCKET


def get_user_id_from_token(token: str) -> int | None:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=["HS256"],
        )

        # 1️ Check subject (app)
        if payload.get("sub") != "doudate-app":
            return None

        # 2️ Lấy user_id ĐÚNG CHỖ
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

    await manager.connect(couple_id, user_id, websocket)

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

            msg_type = data.get("type", "text")
            content = data.get("content")
            img_url = data.get("img_url")
            thumbnail_url = data.get("thumbnail_url")

            # validate
            if msg_type == "text" and not content:
                continue

            if msg_type == "image" and not img_url:
                continue

            message = save_message(
                db=db,
                couple_id=couple_id,
                sender_id=user_id,
                content=content,
                img_url=img_url,
                thumbnail_url=thumbnail_url,
                type=msg_type,
            )

            # xác định người nhận
            if couple.user1_id == user_id:
                receiver_id = couple.user2_id
            else:
                receiver_id = couple.user1_id

            # kiểm tra người nhận có online không
            online_set = manager.online_users.get(couple_id, set())

            if receiver_id not in online_set:
                receiver = db.query(User).filter(User.id == receiver_id).first()

                if receiver and receiver.fcm_token:
                    send_push_notification(
                        fcm_token=receiver.fcm_token,
                        title="Tin nhắn mới",
                        body=content or "Bạn có tin nhắn mới",
                        data={
                            "type": "chat",
                            "couple_id": str(couple_id),
                            "sender_id": str(user_id),
                        }
                    )

            await manager.broadcast(
                couple_id,
                {
                    "id": message.id,
                    "couple_id": couple_id,
                    "sender_id": user_id,
                    "content": message.content,
                    "img_url": message.img_url,
                    "thumbnail_url": message.thumbnail_url,
                    "type": message.type,
                    "created_at": message.created_at.isoformat(),
                },
            )

    except WebSocketDisconnect:
        pass
    finally:
        manager.disconnect(couple_id, user_id, websocket)