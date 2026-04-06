from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from core.config import get_database_url

_engine = None
_session_factory = None


def _get_engine():
    global _engine, _session_factory
    url = get_database_url()
    if not url:
        return None, None
    if _engine is None or _engine.url != url:
        _engine = create_async_engine(url, echo=False, pool_pre_ping=True)
        _session_factory = async_sessionmaker(_engine, expire_on_commit=False)
    return _engine, _session_factory


class Base(DeclarativeBase):
    pass


async def get_session() -> AsyncSession:
    _, factory = _get_engine()
    if factory is None:
        raise RuntimeError("Database not configured")
    async with factory() as session:
        yield session


def get_engine():
    engine, _ = _get_engine()
    return engine
