from sqlalchemy import (
    Column,
    BigInteger,
    String,
    DateTime,
    Boolean,
    ForeignKey,
)
from sqlalchemy.sql import func

from models.base import Base


class QrToken(Base):
    __tablename__ = "qr_tokens"

    id = Column(BigInteger, primary_key=True, index=True)

    user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    token = Column(String(36), unique=True, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    is_used = Column(Boolean, default=False, nullable=False)

    created_at = Column(DateTime, server_default=func.now())
