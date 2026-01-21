from sqlalchemy.orm import Session
from models.memory import Memory

def get_memories_by_couple(
    db: Session,
    couple_id: int,
    page: int = 1,
    limit: int = 10,
):
    offset = (page - 1) * limit

    query = (
        db.query(Memory)
        .filter(Memory.couple_id == couple_id)
    )

    total = query.count()

    items = (
        query
        .order_by(Memory.created_at.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )

    return items, total
