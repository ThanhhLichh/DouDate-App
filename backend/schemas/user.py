from datetime import date, datetime
from pydantic import BaseModel, EmailStr
from typing import Optional

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

class UserPublic(BaseModel):
    id: int
    full_name: str
    avatar_url: str | None


class UserProfileResponse(BaseModel):
    id: int
    full_name: str
    avatar_url: Optional[str] = None
    birth_date: Optional[date] = None
    bio: Optional[str] = None

    model_config = {
        "from_attributes": True
    }


class UserProfileUpdate(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    birth_date: Optional[date] = None
    bio: Optional[str] = None

class UserMeResponse(BaseModel):
    id: int
    email: str
    full_name: str
    avatar_url: Optional[str]
    birth_date: Optional[date]
    gender: Optional[str]
    partner_name: Optional[str]

class UserMeUpdate(BaseModel):
    full_name: Optional[str] = None
    avatar_url: Optional[str] = None
    birth_date: Optional[date] = None
    gender: Optional[str] = None

