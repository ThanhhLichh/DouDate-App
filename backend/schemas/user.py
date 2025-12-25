from datetime import date, datetime
from pydantic import BaseModel, EmailStr


class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    avatar_url: str | None = None
    birth_date: date | None = None
    bio: str | None = None


class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str


class UserResponse(UserBase):
    id: int
    role: str
    is_active: bool
    created_at: datetime

    model_config = {
        "from_attributes": True
    }
