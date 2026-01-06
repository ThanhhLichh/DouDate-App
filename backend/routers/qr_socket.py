from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from jose import jwt, JWTError

from core.config import settings

router = APIRouter()


class QRConnectionManager:
    def __init__(self):
        # user_id -> websocket
        self.active_connections: dict[int, WebSocket] = {}

    async def connect(self, user_id: int, websocket: WebSocket):
        await websocket.accept()
        self.active_connections[user_id] = websocket

    def disconnect(self, user_id: int):
        if user_id in self.active_connections:
            del self.active_connections[user_id]

    async def notify_qr_scanned(self, user_id: int, payload: dict):
        websocket = self.active_connections.get(user_id)
        if websocket:
            await websocket.send_json(payload)


qr_manager = QRConnectionManager()


def get_user_id_from_token(token: str) -> int | None:
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=["HS256"],
        )
        return int(payload.get("sub"))
    except JWTError:
        return None


@router.websocket("/ws/qr-status")
async def qr_status_ws(websocket: WebSocket, token: str):
    user_id = get_user_id_from_token(token)
    if not user_id:
        await websocket.close(code=1008)
        return

    await qr_manager.connect(user_id, websocket)

    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        qr_manager.disconnect(user_id)
