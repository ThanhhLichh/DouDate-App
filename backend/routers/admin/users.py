from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from schemas.admin.user import AdminUserOut, UpdateUserStatus
from services.admin.user_service import get_all_users, update_user_status
from services.auth_service import get_current_user

router = APIRouter(prefix="/admin/users", tags=["Admin Users"])


@router.get("", response_model=list[AdminUserOut])
def list_users(
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    return get_all_users(db)


@router.patch("/{user_id}/status", response_model=AdminUserOut)
def change_status(
    user_id: int,
    payload: UpdateUserStatus,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    user = update_user_status(db, user_id, payload.is_active)
    if not user:
        raise HTTPException(status_code=404)

    return user
