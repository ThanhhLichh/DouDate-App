from datetime import datetime
from pydantic import BaseModel
from typing import List, Optional, Literal
from schemas.message_reaction import ReactionResponse


class MessageResponse(BaseModel):
    id: int
    couple_id: int
    sender_id: int
    content: Optional[str]
    img_url: Optional[str]
    thumbnail_url: Optional[str]
    type: Literal["text", "image", "system"]
    created_at: datetime

    is_read: bool
    read_at: Optional[datetime]
    
    reactions: List[ReactionResponse] = []

    model_config = {
        "from_attributes": True
    }


class MarkReadRequest(BaseModel):
    couple_id: int
    last_message_id: int
