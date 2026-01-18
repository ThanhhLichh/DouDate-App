from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from schemas.admin.couple import AdminCoupleOut
from services.admin.couple_service import get_all_couples, break_couple
from services.auth_service import get_current_user

router = APIRouter(
    prefix="/admin/couples",
    tags=["Admin Couples"]
)

@router.get("", response_model=list[AdminCoupleOut])
def list_couples(
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")

    return get_all_couples(db)

@router.post("/{couple_id}/break", response_model=AdminCoupleOut)
def break_couple_api(
    couple_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")

    couple = break_couple(db, couple_id)

    if not couple:
        raise HTTPException(status_code=404, detail="Couple not found")

    return couple
