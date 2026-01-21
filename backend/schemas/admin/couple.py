from pydantic import BaseModel
from datetime import datetime, date
from typing import List

class AdminCoupleOut(BaseModel):
    id: int
    user1_id: int
    user2_id: int
    nickname_1: str | None
    nickname_2: str | None
    start_date: date
    end_date: date | None
    bubble_color: str | None
    quick_emoji: str | None
    background_theme: str | None
    created_at: datetime

    model_config = {
        "from_attributes": True
    }


class AdminCouplePage(BaseModel):
    items: List[AdminCoupleOut]
    total: int
    page: int
    limit: int