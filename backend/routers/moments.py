from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.security import get_current_user_id

from models.moment import Moment
from models.couple import Couple
from schemas.moment import MomentCreate, MomentResponse

router = APIRouter(
    prefix="/moments",
    tags=["Moments"],
)


@router.post(
    "",
    response_model=MomentResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_moment(
    data: MomentCreate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    # Check user có couple không
    couple = (
        db.query(Couple)
        .filter(
            or_(
                Couple.user1_id == user_id,
                Couple.user2_id == user_id,
            ),
            Couple.end_date.is_(None),
        )
        .first()
    )
    if not couple:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User has no active couple",
        )

    moment = Moment(
        couple_id=couple.id,
        created_by=user_id,
        image_url=data.image_url,
        caption=data.caption,
    )

    db.add(moment)
    db.commit()
    db.refresh(moment)

    return moment

@router.get(
    "",
    response_model=list[MomentResponse],
)
def get_moments(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    couple = (
        db.query(Couple)
        .filter(
            or_(
                Couple.user1_id == user_id,
                Couple.user2_id == user_id,
            ),
            Couple.end_date.is_(None),
        )
        .first()
    )
    if not couple:
        return []

    moments = (
        db.query(Moment)
        .filter(Moment.couple_id == couple.id)
        .order_by(Moment.created_at.desc())
        .all()
    )

    return moments

