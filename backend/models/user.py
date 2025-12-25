from sqlalchemy import (
    Column,
    BigInteger,
    String,
    Date,
    Boolean,
    Enum,
    DateTime,
)
from sqlalchemy.sql import func

from models.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(BigInteger, primary_key=True, index=True)

    email = Column(String(255), unique=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(120), nullable=False)

    avatar_url = Column(String(1024), nullable=True)
    birth_date = Column(Date, nullable=True)
    bio = Column(String(255), nullable=True)

    role = Column(Enum("user", "admin"), default="user", nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)

    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(
        DateTime,
        server_default=func.now(),
        onupdate=func.now(),
    )
