from pydantic import BaseModel
from datetime import datetime

class AdminUserOut(BaseModel):
    id: int
    email: str
    full_name: str | None
    is_active: bool
    created_at: datetime

    class Config:
        orm_mode = True


class UpdateUserStatus(BaseModel):
    is_active: bool
