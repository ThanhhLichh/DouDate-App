from pydantic import BaseModel
from datetime import datetime, date
from typing import Optional, List

class AdminMemoryOut(BaseModel):
    id: int
    couple_id: int
    created_by: int
    title: Optional[str] = None
    description: Optional[str] = None
    image_url: Optional[str] = None
    memory_date: Optional[date] = None
    created_at: datetime

    model_config = {
        "from_attributes": True
    }


class AdminMemoryPage(BaseModel):
    items: List[AdminMemoryOut]
    total: int
    page: int
    limit: int
