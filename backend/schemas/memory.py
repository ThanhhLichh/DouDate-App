from datetime import datetime, date
from pydantic import BaseModel
from typing import Optional


class MemoryCreate(BaseModel):
    title: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    memory_date: Optional[date] = None


class MemoryResponse(BaseModel):
    id: int
    couple_id: int
    created_by: int
    title: str
    description: Optional[str]
    image_url: Optional[str]
    memory_date: Optional[date]
    created_at: datetime

    model_config = {
        "from_attributes": True
    }


class MemoryUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    memory_date: Optional[date] = None
