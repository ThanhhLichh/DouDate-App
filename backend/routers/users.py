from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.security import get_current_user_id

from models.user import User
from models.couple import Couple
from schemas.user_fcm import SaveFCMTokenRequest


from schemas.user import (
    UserPublic,
    UserMeResponse,
    UserMeUpdate,
)

router = APIRouter(
    prefix="/users",
    tags=["Users"],
)

# =========================
# GET /users/me
# =========================
@router.get(
    "/me",
    response_model=UserMeResponse,
)
def get_my_profile(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

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

    partner_name = None
    if couple:
        partner_id = (
            couple.user2_id if couple.user1_id == user_id else couple.user1_id
        )
        partner = db.query(User).filter(User.id == partner_id).first()
        partner_name = partner.full_name if partner else None

    return {
        "id": user.id,
        "email": user.email,
        "full_name": user.full_name,
        "avatar_url": user.avatar_url,
        "birth_date": user.birth_date,
        "gender": user.gender,
        "partner_name": partner_name,
    }


# =========================
# PUT /users/me
# =========================
@router.put(
    "/me",
    response_model=UserMeResponse,
)
def update_my_profile(
    data: UserMeUpdate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    for field, value in data.dict(exclude_unset=True).items():
        setattr(user, field, value)

    db.commit()
    db.refresh(user)

    return get_my_profile(db, user_id)


# =========================
# GET /users/{id}
# =========================
@router.get(
    "/{user_id}",
    response_model=UserPublic,
)
def get_user(
    user_id: int,
    db: Session = Depends(get_db),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.post("/fcm-token")
def save_fcm_token(
    data: SaveFCMTokenRequest,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.fcm_token = data.fcm_token
    db.commit()

    return {
        "success": True
    }
