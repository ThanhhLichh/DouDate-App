from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.security import get_current_user_id

from models.message import Message
from models.couple import Couple
from schemas.message import MessageResponse
from sqlalchemy.orm import joinedload
from datetime import datetime
from schemas.message import MarkReadRequest
from routers.chat import manager


router = APIRouter(
    prefix="/messages",
    tags=["Messages"],
)


@router.get(
    "/{couple_id}",
    response_model=list[MessageResponse],
)
def get_messages(
    couple_id: int,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    # Check user thuộc couple
    couple = (
        db.query(Couple)
        .filter(
            Couple.id == couple_id,
            or_(
                Couple.user1_id == user_id,
                Couple.user2_id == user_id,
            ),
        )
        .first()
    )
    if not couple:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You are not a member of this couple",
        )

    messages = (
        db.query(Message)
        .options(joinedload(Message.reactions))
        .filter(Message.couple_id == couple_id)
        .order_by(Message.created_at.asc())
        .all()
    )

    return messages

@router.post("/read")
async def mark_messages_read(
    data: MarkReadRequest,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    now = datetime.utcnow()

    db.query(Message).filter(
        Message.couple_id == data.couple_id,
        Message.sender_id != user_id,
        Message.id <= data.last_message_id,
        Message.is_read == False,
    ).update(
        {
            "is_read": True,
            "read_at": now,
        },
        synchronize_session=False,
    )

    db.commit()

    # 🔥 BẮN REALTIME CHO NGƯỜI GỬI
    await manager.broadcast(
        data.couple_id,
        {
            "type": "read",
            "user_id": user_id,                # người vừa đọc
            "last_message_id": data.last_message_id,
            "read_at": now.isoformat(),
        }
    )

    return {
        "status": "ok",
        "read_at": now.isoformat(),
    }
