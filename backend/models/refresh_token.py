from sqlalchemy import (
    Column,
    BigInteger,
    ForeignKey,
    DateTime,
    Boolean,
    String,
)
from sqlalchemy.sql import func

from models.base import Base


class RefreshToken(Base):
    __tablename__ = "refresh_tokens"

    id = Column(BigInteger, primary_key=True, index=True)

    user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    token_hash = Column(String(64), unique=True, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_revoked = Column(Boolean, default=False, nullable=False)

    created_at = Column(DateTime, server_default=func.now())
