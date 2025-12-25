from sqlalchemy import (
    Column,
    BigInteger,
    Text,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func

from models.base import Base


class Message(Base):
    __tablename__ = "messages"

    id = Column(BigInteger, primary_key=True, index=True)

    couple_id = Column(
        BigInteger,
        ForeignKey("couples.id", ondelete="CASCADE"),
        nullable=False,
    )

    sender_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    content = Column(Text, nullable=False)

    created_at = Column(DateTime, server_default=func.now())
