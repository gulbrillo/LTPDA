from sqlalchemy import Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from core.database import Base


class AvailableDb(Base):
    __tablename__ = "available_dbs"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    db_name: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(128), nullable=False)
    description: Mapped[str | None] = mapped_column(Text)
    version: Mapped[int] = mapped_column(Integer, default=2)
