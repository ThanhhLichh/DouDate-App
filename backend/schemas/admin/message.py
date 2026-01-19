from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class AdminMessageOut(BaseModel):
    id: int
    couple_id: int
    sender_id: int
    type: str              # "text" | "image"
    content: Optional[str]
    img_url: Optional[str]
    created_at: datetime

    model_config = {
        "from_attributes": True
    }
