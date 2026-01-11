from pydantic import BaseModel
from typing import Optional


class ReactionRequest(BaseModel):
    emoji: Optional[str]  # null = xoá reaction
