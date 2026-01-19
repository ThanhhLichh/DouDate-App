from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from schemas.admin.message import AdminMessageOut
from services.admin.message_service import (
    get_messages_by_couple,
    delete_message,
)
from services.auth_service import get_current_user

router = APIRouter(
    prefix="/admin",
    tags=["Admin Messages"]
)

# 🔹 GET messages theo couple
@router.get("/couples/{couple_id}/messages")
def list_messages_by_couple(
    couple_id: int,
    page: int = 1,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    items, total = get_messages_by_couple(db, couple_id, page, limit)

    return {
        "items": items,
        "total": total,
        "page": page,
        "limit": limit
    }




# 🔹 DELETE (soft) message
@router.delete("/messages/{message_id}")
def admin_delete_message(
    message_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403, detail="Forbidden")

    message = delete_message(db, message_id)
    if not message:
        raise HTTPException(status_code=404, detail="Message not found")

    return {"success": True}
