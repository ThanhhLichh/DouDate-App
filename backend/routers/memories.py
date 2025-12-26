from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_

from core.db import get_db
from core.security import get_current_user_id

from models.memory import Memory
from models.couple import Couple
from schemas.memory import MemoryCreate, MemoryResponse

router = APIRouter(
    prefix="/memories",
    tags=["Memories"],
)

@router.post(
    "",
    response_model=MemoryResponse,
    status_code=status.HTTP_201_CREATED,
)
def create_memory(
    data: MemoryCreate,
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
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User has no active couple",
        )

    memory = Memory(
        couple_id=couple.id,
        created_by=user_id,
        title=data.title,
        description=data.description,
        image_url=data.image_url,
        memory_date=data.memory_date,
    )

    db.add(memory)
    db.commit()
    db.refresh(memory)

    return memory

@router.get(
    "",
    response_model=list[MemoryResponse],
)
def get_memories(
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

    memories = (
    db.query(Memory)
    .filter(Memory.couple_id == couple.id)
    .order_by(
        Memory.memory_date.is_(None),
        Memory.memory_date.desc()
    )
    .all()
)


    return memories

