from sqlalchemy import (
    Column,
    BigInteger,
    Text,
    DateTime,
    ForeignKey,
    Enum,
)
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
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

    content = Column(Text, nullable=True)        # text
    img_url = Column(Text, nullable=True)        # image original
    thumbnail_url = Column(Text, nullable=True)  # image preview

    type = Column(
        Enum("text", "image", "system"),
        nullable=False,
        default="text",
    )

    created_at = Column(DateTime, server_default=func.now())

    reactions = relationship(
        "MessageReaction",
        backref="message",
        cascade="all, delete-orphan"
    )
