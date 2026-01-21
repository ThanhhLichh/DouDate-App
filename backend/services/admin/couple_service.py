from sqlalchemy.orm import Session
from models.couple import Couple
from datetime import datetime

def get_couples_paginated(
    db: Session,
    page: int = 1,
    limit: int = 10,
):
    offset = (page - 1) * limit

    query = db.query(Couple)

    total = query.count()

    items = (
        query
        .order_by(Couple.id.asc())   #  ID nhỏ → lớn
        .offset(offset)
        .limit(limit)
        .all()
    )

    return items, total

def break_couple(db: Session, couple_id: int):
    couple = (
        db.query(Couple)
        .filter(Couple.id == couple_id)
        .first()
    )

    if not couple:
        return None

    # Nếu đã break rồi thì không làm lại
    if couple.end_date is not None:
        return couple

    couple.end_date = datetime.utcnow()
    db.commit()
    db.refresh(couple)

    return couple
