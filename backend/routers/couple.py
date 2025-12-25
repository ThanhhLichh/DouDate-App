from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from sqlalchemy import or_
from jose import jwt, JWTError

from core.db import get_db
from core.config import settings
from core.security import get_current_user_id


from models.couple import Couple
from schemas.couple import CoupleMeResponse, CoupleInfo



router = APIRouter(
    prefix="/couple",
    tags=["Couple"],
)

@router.get(
    "/me",
    response_model=CoupleMeResponse,
)
def get_my_couple(
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
        return {
            "has_couple": False,
            "couple": None,
        }

    return {
        "has_couple": True,
        "couple": couple,
    }
