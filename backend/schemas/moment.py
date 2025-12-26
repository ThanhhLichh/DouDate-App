from datetime import datetime
from pydantic import BaseModel
from typing import Optional


class MomentCreate(BaseModel):
    image_url: str
    caption: Optional[str] = None


class MomentResponse(BaseModel):
    id: int
    couple_id: int
    created_by: int
    image_url: str
    caption: Optional[str]
    created_at: datetime

    model_config = {
        "from_attributes": True
    }
