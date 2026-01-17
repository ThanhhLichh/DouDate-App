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
from schemas.message import MarkReadRequest, UpdateMessageRequest
from routers.chat import manager
from datetime import timedelta


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
    limit: int = 5,
    before_id: int | None = None,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    # Check user thuộc couple (GIỮ NGUYÊN)
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

    q = (
        db.query(Message)
        .options(joinedload(Message.reactions))
        .filter(Message.couple_id == couple_id)
    )

    if before_id:
        q = q.filter(Message.id < before_id)

    messages = (
        q.order_by(Message.id.desc())
         .limit(limit)
         .all()
    )

    # FE cần message theo thứ tự cũ → mới
    return list(reversed(messages))


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


@router.put("/{message_id}")
async def update_message(
    message_id: int,
    data: UpdateMessageRequest,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    msg = db.query(Message).filter(Message.id == message_id).first()
    if not msg:
        raise HTTPException(404)

    if msg.sender_id != user_id:
        raise HTTPException(403)

    if msg.type != "text":
        raise HTTPException(400, "Cannot edit this message")

    if datetime.utcnow() - msg.created_at > timedelta(minutes=10):
        raise HTTPException(400, "Edit time expired")

    msg.content = data.content
    msg.edited_at = datetime.utcnow()
    db.commit()

    await manager.broadcast(
        msg.couple_id,
        {
            "type": "message_updated",
            "message_id": msg.id,
            "content": msg.content,
            "edited_at": msg.edited_at.isoformat(),
        }
    )

    return {"status": "ok"}

@router.delete("/{message_id}")
async def delete_message(
    message_id: int,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    msg = db.query(Message).filter(Message.id == message_id).first()
    if not msg:
        raise HTTPException(404)

    if msg.sender_id != user_id:
        raise HTTPException(403)

    if datetime.utcnow() - msg.created_at > timedelta(minutes=10):
        raise HTTPException(400, "Delete time expired")

    msg.is_deleted = True
    db.commit()

    await manager.broadcast(
        msg.couple_id,
        {
            "type": "message_deleted",
            "message_id": msg.id,
        }
    )

    return {"status": "ok"}

