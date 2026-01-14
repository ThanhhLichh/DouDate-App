from pydantic import BaseModel
from typing import Optional


class ReactionRequest(BaseModel):
    emoji: Optional[str]  # null = xoá reaction

class ReactionResponse(BaseModel):
    user_id: int
    emoji: str

    model_config = {
        "from_attributes": True
    }
