from firebase_admin import messaging
from firebase_admin._messaging_utils import UnregisteredError
from core.db import SessionLocal
from models.user import User
import logging

logger = logging.getLogger(__name__)

def send_push_notification(
    fcm_token: str,
    title: str,
    body: str,
    data: dict | None = None,
):
    message = messaging.Message(
        token=fcm_token,
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        data=data or {},
    )

    try:
        messaging.send(message)

    except UnregisteredError:
        #  Token đã chết → xóa khỏi DB
        logger.warning(f"FCM token unregistered: {fcm_token}")

        db = SessionLocal()
        user = db.query(User).filter(User.fcm_token == fcm_token).first()
        if user:
            user.fcm_token = None
            db.commit()
        db.close()

    except Exception as e:
        #  Không cho push làm sập websocket
        logger.error(f"FCM send error: {e}")
