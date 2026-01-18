from sqlalchemy.orm import Session
from models.user import User

def get_all_users(db: Session):
    return (
        db.query(User)
        .filter(User.role == "user")
        .order_by(User.created_at.desc())
        .all()
    )


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
