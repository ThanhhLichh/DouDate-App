from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from sqlalchemy import or_
from jose import jwt, JWTError
from datetime import date
from models.user import User


from core.db import get_db
from core.config import settings
from core.security import get_current_user_id


from models.couple import Couple
from schemas.couple import CoupleMeResponse, CoupleInfo
from models.message import Message
from models.moment import Moment
from models.memory import Memory
from schemas.couple import CoupleStatsResponse
from schemas.couple import ChatSettingsResponse, ChatSettingsUpdate
from routers.chat import manager
from fastapi import BackgroundTasks








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

@router.get(
    "/stats",
    response_model=CoupleStatsResponse,
)
def get_couple_stats(
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    # tìm couple đang active
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
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User has no active couple",
        )

    # xác định bạn & partner
    if couple.user1_id == user_id:
        your_id = couple.user1_id
        partner_id = couple.user2_id
    else:
        your_id = couple.user2_id
        partner_id = couple.user1_id

    your_user = db.query(User).filter(User.id == your_id).first()
    partner_user = db.query(User).filter(User.id == partner_id).first()

    message_count = (
        db.query(Message)
        .filter(Message.couple_id == couple.id)
        .count()
    )

    moment_count = (
        db.query(Moment)
        .filter(Moment.couple_id == couple.id)
        .count()
    )

    memory_count = (
        db.query(Memory)
        .filter(Memory.couple_id == couple.id)
        .count()
    )

    return {
        "couple_id": couple.id, 

        "your_name": your_user.full_name if your_user else None,
        "your_avatar": your_user.avatar_url if your_user else None,
        "partner_name": partner_user.full_name if partner_user else None,
        "partner_avatar": partner_user.avatar_url if partner_user else None,
        "start_date": couple.start_date,
        
        "message_count": message_count,
        "moment_count": moment_count,
        "memory_count": memory_count,
    }


# break couple endpoint 
@router.post(
    "/break",
    status_code=status.HTTP_200_OK,
)
def break_couple(
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
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active couple to break",
        )

    couple.end_date = date.today()
    db.commit()

    return {
        "message": "Couple ended successfully"
    }

@router.get(
    "/{couple_id}/chat-settings",
    response_model=ChatSettingsResponse,
)
def get_chat_settings(
    couple_id: int,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):
    couple = db.query(Couple).filter(Couple.id == couple_id).first()
    if not couple:
        raise HTTPException(status_code=404, detail="Couple not found")

    if user_id not in [couple.user1_id, couple.user2_id]:
        raise HTTPException(status_code=403, detail="Forbidden")

    if user_id == couple.user1_id:
        your_nickname = couple.nickname_1 or ""
        partner_nickname = couple.nickname_2 or ""
    else:
        your_nickname = couple.nickname_2 or ""
        partner_nickname = couple.nickname_1 or ""

    return {
        "couple_id": couple.id,
        "bubble_color": couple.bubble_color,
        "quick_emoji": couple.quick_emoji,
        "background_theme": couple.background_theme,
        "your_nickname": your_nickname,
        "partner_nickname": partner_nickname,
    }


@router.put(
    "/{couple_id}/chat-settings",
)
def update_chat_settings(
    couple_id: int,
    payload: ChatSettingsUpdate,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
    user_id: int = Depends(get_current_user_id),
):

    couple = db.query(Couple).filter(Couple.id == couple_id).first()
    if not couple:
        raise HTTPException(status_code=404, detail="Couple not found")

    if user_id not in [couple.user1_id, couple.user2_id]:
        raise HTTPException(status_code=403, detail="Forbidden")

    # map nickname theo user hiện tại
    if user_id == couple.user1_id:
        couple.nickname_1 = payload.your_nickname
        couple.nickname_2 = payload.partner_nickname
    else:
        couple.nickname_2 = payload.your_nickname
        couple.nickname_1 = payload.partner_nickname

    if payload.bubble_color is not None:
        couple.bubble_color = payload.bubble_color
    if payload.quick_emoji is not None:
        couple.quick_emoji = payload.quick_emoji
    if payload.background_theme is not None:
        couple.background_theme = payload.background_theme

    db.commit()

# 🔔 notify realtime cho cả couple
    background_tasks.add_task(
        manager.broadcast,
        couple_id,
        {
            "type": "chat_settings_updated",
            "couple_id": couple_id,
        }
    )

    return {"success": True}







