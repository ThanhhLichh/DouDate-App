from datetime import datetime
from pydantic import BaseModel
from typing import List
from schemas.message_reaction import ReactionResponse

class MessageResponse(BaseModel):
    id: int
    couple_id: int
    sender_id: int
    content: str
    created_at: datetime
    reactions: List[ReactionResponse] = []

    model_config = {
        "from_attributes": True
    }
