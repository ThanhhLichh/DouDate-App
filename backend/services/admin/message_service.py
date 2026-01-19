from sqlalchemy.orm import Session
from datetime import datetime
from models.message import Message

def get_messages_by_couple(
    db: Session,
    couple_id: int,
    page: int = 1,
    limit: int = 10,
):
    offset = (page - 1) * limit

    query = (
        db.query(Message)
        .filter(
            Message.couple_id == couple_id,
            Message.is_deleted == 0
        )
    )

    total = query.count()

    items = (
        query
        .order_by(Message.created_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )

    return items, total




def delete_message(db: Session, message_id: int):
    message = (
        db.query(Message)
        .filter(
            Message.id == message_id,
            Message.is_deleted == 0
        )
        .first()
    )

    if not message:
        return None

    message.is_deleted = 1
    message.edited_at = datetime.utcnow()
    db.commit()
    db.refresh(message)

    return message
