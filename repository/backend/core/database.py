import aiomysql
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from core.config import get_config

_engine = None
_session_factory = None
_last_url = None


def _build_admin_url() -> str:
    cfg = get_config()
    if not cfg.get("mysql_admin_user"):
        return ""
    host = cfg["mysql_host"]
    port = cfg.get("mysql_port", 3306)
    user = cfg["mysql_admin_user"]
    pw = cfg["mysql_admin_password"]
    db = cfg["admin_db"]
    return f"mysql+aiomysql://{user}:{pw}@{host}:{port}/{db}"


def _get_engine():
    global _engine, _session_factory, _last_url
    url = _build_admin_url()
    if not url:
        return None, None
    if _engine is None or url != _last_url:
        _engine = create_async_engine(url, echo=False, pool_pre_ping=True)
        _session_factory = async_sessionmaker(_engine, expire_on_commit=False)
        _last_url = url
    return _engine, _session_factory


class Base(DeclarativeBase):
    pass


async def get_session() -> AsyncSession:
    _, factory = _get_engine()
    if factory is None:
        raise RuntimeError("Database not configured")
    async with factory() as session:
        yield session


async def get_admin_connection(db: str | None = None):
    """Return a raw aiomysql connection using stored admin credentials.

    If db is given, selects that database after connecting. Caller is
    responsible for closing the connection.
    """
    cfg = get_config()
    conn = await aiomysql.connect(
        host=cfg["mysql_host"],
        port=cfg.get("mysql_port", 3306),
        user=cfg["mysql_admin_user"],
        password=cfg["mysql_admin_password"],
        db=db or "",
        autocommit=True,
    )
    return conn
