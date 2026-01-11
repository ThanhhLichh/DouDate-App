# models/message_reaction.py

from sqlalchemy import (
    Column,
    String,
    DateTime,
    ForeignKey,
    UniqueConstraint,
)
from sqlalchemy.sql import func
from sqlalchemy.dialects.mysql import BIGINT 
from models.base import Base


class MessageReaction(Base):
    __tablename__ = "message_reactions"

    id = Column(
        BIGINT(unsigned=True),
        primary_key=True,
        autoincrement=True,
    )

    message_id = Column(
        BIGINT(unsigned=True),
        ForeignKey("messages.id", ondelete="CASCADE"),
        nullable=False,
    )

    user_id = Column(
        BIGINT(unsigned=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    emoji = Column(String(16), nullable=False)

    created_at = Column(DateTime, server_default=func.now())

    __table_args__ = (
        UniqueConstraint(
            "message_id",
            "user_id",
            name="uniq_message_user_reaction",
        ),
    )
