from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.security import get_current_user_id

from models.message import Message
from models.couple import Couple
from schemas.message import MessageResponse

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
        .filter(Message.couple_id == couple_id)
        .order_by(Message.created_at.asc())
        .all()
    )

    return messages

