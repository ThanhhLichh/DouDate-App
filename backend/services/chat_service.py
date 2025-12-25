from sqlalchemy.orm import Session

from models.message import Message


def save_message(
    db: Session,
    couple_id: int,
    sender_id: int,
    content: str,
) -> Message:
    message = Message(
        couple_id=couple_id,
        sender_id=sender_id,
        content=content,
    )
    db.add(message)
    db.commit()
    db.refresh(message)
    return message
