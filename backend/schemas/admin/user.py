from pydantic import BaseModel
from datetime import datetime
from typing import List

class AdminUserOut(BaseModel):
    id: int
    email: str
    full_name: str | None
    is_active: bool
    created_at: datetime

    model_config = {
        "from_attributes": True
    }


class AdminUserPage(BaseModel):
    items: List[AdminUserOut]
    total: int
    page: int
    limit: int


class UpdateUserStatus(BaseModel):
    is_active: bool
