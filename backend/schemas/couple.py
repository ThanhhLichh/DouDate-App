from datetime import date
from pydantic import BaseModel
from typing import Optional


class CoupleInfo(BaseModel):
    id: int
    user1_id: int
    user2_id: int
    start_date: date

    model_config = {
        "from_attributes": True
    }


class CoupleMeResponse(BaseModel):
    has_couple: bool
    couple: Optional[CoupleInfo] = None
