from sqlalchemy.orm import Session
from models.message import Message


def save_message(
    db: Session,
    couple_id: int,
    sender_id: int,
    content: str | None = None,
    img_url: str | None = None,
    thumbnail_url: str | None = None,
    type: str = "text",
) -> Message:
    message = Message(
        couple_id=couple_id,
        sender_id=sender_id,
        content=content,
        img_url=img_url,
        thumbnail_url=thumbnail_url,
        type=type,
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message
