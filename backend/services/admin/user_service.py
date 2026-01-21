from sqlalchemy.orm import Session
from models.user import User


def get_users_paginated(
    db: Session,
    page: int = 1,
    limit: int = 10,
):
    offset = (page - 1) * limit

    query = (
        db.query(User)
        .filter(User.role == "user")
    )

    total = query.count()

    items = (
        query
        .order_by(User.id.asc())   # 👈 ID nhỏ → lớn
        .offset(offset)
        .limit(limit)
        .all()
    )


    return items, total



def update_user_status(db: Session, user_id: int, is_active: bool):
    user = (
        db.query(User)
        .filter(User.id == user_id, User.role == "user")
        .first()
    )

    if not user:
        return None

    user.is_active = is_active
    db.commit()
    db.refresh(user)
    return user
