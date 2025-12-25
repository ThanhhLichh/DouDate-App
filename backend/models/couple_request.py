from sqlalchemy import (
    Column,
    BigInteger,
    String,
    Enum,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func

from models.base import Base


class CoupleRequest(Base):
    __tablename__ = "couple_requests"

    id = Column(BigInteger, primary_key=True, index=True)

    from_user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    to_user_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True,
    )

    qr_token = Column(
        String(36),
        ForeignKey("qr_tokens.token", ondelete="CASCADE"),
        nullable=False,
    )

    status = Column(
        Enum("pending", "accepted", "rejected", "expired"),
        default="pending",
        nullable=False,
    )

    created_at = Column(DateTime, server_default=func.now())
