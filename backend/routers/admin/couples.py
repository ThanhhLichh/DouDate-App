from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from schemas.admin.couple import AdminCoupleOut, AdminCouplePage
from services.admin.couple_service import break_couple, get_couples_paginated
from services.auth_service import get_current_user

router = APIRouter(
    prefix="/admin/couples",
    tags=["Admin Couples"]
)

@router.get("", response_model=AdminCouplePage)
def list_couples(
    page: int = 1,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")

    items, total = get_couples_paginated(db, page, limit)

    return {
        "items": items,
        "total": total,
        "page": page,
        "limit": limit,
    }

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
