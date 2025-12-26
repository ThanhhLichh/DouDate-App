from sqlalchemy import (
    Column,
    BigInteger,
    String,
    DateTime,
    ForeignKey,
)
from sqlalchemy.sql import func

from models.base import Base


class Moment(Base):
    __tablename__ = "moments"

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

    image_url = Column(String(1024), nullable=False)
    caption = Column(String(255), nullable=True)

    created_at = Column(DateTime, server_default=func.now())
