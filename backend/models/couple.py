from sqlalchemy import (
    Column,
    BigInteger,
    String,
    Date,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func

from models.base import Base


class Couple(Base):
    __tablename__ = "couples"

    id = Column(BigInteger, primary_key=True, index=True)

    user1_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    user2_id = Column(
        BigInteger,
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
    )

    cover_image = Column(String(1024), nullable=True)
    nickname_1 = Column(String(120), nullable=True)
    nickname_2 = Column(String(120), nullable=True)

    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)

    created_at = Column(DateTime, server_default=func.now())
