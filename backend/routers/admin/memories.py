from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from core.db import get_db
from schemas.admin.memory import AdminMemoryPage
from services.admin.memory_service import get_memories_by_couple
from services.auth_service import get_current_user
from services.admin.memory_service import delete_memory

router = APIRouter(
    prefix="/admin",
    tags=["Admin Memories"]
)

@router.get(
    "/couples/{couple_id}/memories",
    response_model=AdminMemoryPage
)
def list_memories_by_couple(
    couple_id: int,
    page: int = 1,
    limit: int = 10,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    items, total = get_memories_by_couple(db, couple_id, page, limit)

    return {
        "items": items,
        "total": total,
        "page": page,
        "limit": limit,
    }

@router.delete("/memories/{memory_id}")
def admin_delete_memory(
    memory_id: int,
    db: Session = Depends(get_db),
    current_user = Depends(get_current_user),
):
    if current_user.role != "admin":
        raise HTTPException(status_code=403)

    success = delete_memory(db, memory_id)
    if not success:
        raise HTTPException(status_code=404, detail="Memory not found")

    return {"success": True}
