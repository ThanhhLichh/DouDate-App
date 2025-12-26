from sqlalchemy import (
    Column,
    BigInteger,
    String,
    Text,
    Date,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func

from models.base import Base


class Memory(Base):
    __tablename__ = "memories"

    id = Column(BigInteger, primary_key=True, index=True)

    couple_id = Column(
        BigInteger,
        ForeignKey("couples.id", ondelete="CASCADE"),
        nullable=False,
    )

    created_by = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    title = Column(String(120), nullable=False)
    description = Column(Text, nullable=True)
    image_url = Column(String(1024), nullable=True)
    memory_date = Column(Date, nullable=True)

    created_at = Column(DateTime, server_default=func.now())
