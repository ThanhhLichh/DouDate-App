from sqlalchemy.orm import Session
from sqlalchemy import func
from models.user import User
from models.couple import Couple
from models.message import Message
from datetime import date, timedelta


def get_dashboard_data(db: Session):
    # ===== USERS =====
    total_users = db.query(func.count(User.id)).scalar()

    # ===== COUPLES =====
    total_couples = db.query(func.count(Couple.id)).scalar()

    active_couples = (
        db.query(func.count(Couple.id))
        .filter(Couple.end_date.is_(None))
        .scalar()
    )

    ended_couples = total_couples - active_couples

    # ===== SINGLE USERS =====
    subquery_active_users = (
        db.query(Couple.user1_id)
        .filter(Couple.end_date.is_(None))
        .union(
            db.query(Couple.user2_id)
            .filter(Couple.end_date.is_(None))
        )
        .subquery()
    )

    single_users = (
        db.query(func.count(User.id))
        .filter(User.id.not_in(subquery_active_users))
        .scalar()
    )

    # ===== MESSAGES BY DAY (7 DAYS) =====
    seven_days_ago = date.today() - timedelta(days=6)

    messages_by_day = (
        db.query(
            func.date(Message.created_at).label("day"),
            func.count(Message.id).label("total"),
        )
        .filter(
            Message.created_at >= seven_days_ago,
            Message.is_deleted == 0,
        )
        .group_by(func.date(Message.created_at))
        .order_by(func.date(Message.created_at))
        .all()
    )

    messages_by_day_result = [
        {"day": str(row.day), "total": row.total}
        for row in messages_by_day
    ]

    # ===== TOP COUPLES BY MESSAGES =====
    top_couples = (
        db.query(
            Message.couple_id,
            func.count(Message.id).label("total_messages"),
        )
        .filter(Message.is_deleted == 0)
        .group_by(Message.couple_id)
        .order_by(func.count(Message.id).desc())
        .limit(5)
        .all()
    )

    top_couples_result = [
        {
            "couple_id": row.couple_id,
            "total_messages": row.total_messages,
        }
        for row in top_couples
    ]

    return {
        "stats": {
            "total_users": total_users,
            "total_couples": total_couples,
            "active_couples": active_couples,
            "ended_couples": ended_couples,
            "single_users": single_users,
        },
        "messages_by_day": messages_by_day_result,
        "top_couples": top_couples_result,
    }
