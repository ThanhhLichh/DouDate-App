from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core.db import get_db
from core.security import get_current_user_id

from models.user import User
from schemas.user import (
    UserPublic,
    UserProfileResponse,
    UserProfileUpdate,
)

router = APIRouter(
    prefix="/users",
    tags=["Users"],
)

# =========================
# GET /users/me (PROFILE)
# =========================
@router.get(
    "/me",
    response_model=UserProfileResponse,
)
def get_my_profile(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


# =========================
# PUT /users/me (UPDATE PROFILE)
# =========================
@router.put(
    "/me",
    response_model=UserProfileResponse,
)
def update_my_profile(
    data: UserProfileUpdate,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if data.full_name is not None:
        user.full_name = data.full_name

    if data.avatar_url is not None:
        user.avatar_url = data.avatar_url

    if data.birth_date is not None:
        user.birth_date = data.birth_date

    if data.bio is not None:
        user.bio = data.bio

    db.commit()
    db.refresh(user)
    return user


# =========================
# GET /users/{id} (PUBLIC USER)
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
