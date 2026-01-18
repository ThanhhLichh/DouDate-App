from sqlalchemy.orm import Session
from models.couple import Couple
from datetime import datetime

def get_all_couples(db: Session):
    return (
        db.query(Couple)
        .order_by(Couple.id.asc())
        .all()
    )

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
