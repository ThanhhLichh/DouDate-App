from datetime import datetime
from pydantic import BaseModel


class MessageResponse(BaseModel):
    id: int
    couple_id: int
    sender_id: int
    content: str
    created_at: datetime

    model_config = {
        "from_attributes": True
    }
