from datetime import datetime, date
from pydantic import BaseModel
from typing import Literal, Optional



# CREATE QR


class QrCreateResponse(BaseModel):
    token: str
    expires_at: datetime


# SCAN QR


class QrScanRequest(BaseModel):
    token: str


class QrScanResponse(BaseModel):
    from_user_id: int
    from_user_name: str
    created_at: datetime
    expires_at: datetime
    status: Literal["pending", "accepted", "rejected", "expired"]



# RESPOND QR (ACCEPT / REJECT)


class QrRespondRequest(BaseModel):
    token: str
    action: Literal["accept", "reject"]


class CoupleResponse(BaseModel):
    id: int
    user1_id: int
    user2_id: int
    start_date: date

    model_config = {
        "from_attributes": True
    }
