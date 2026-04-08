from fastapi import APIRouter, Depends

from core.config import get_config
from models.user import User
from routers.auth import require_admin

router = APIRouter(prefix="/api/settings", tags=["settings"])


@router.get("")
async def get_settings(_: User = Depends(require_admin)):
    cfg = get_config()
    return {
        "mysql_mode": cfg.get("mysql_mode", "bundled"),
        "mysql_host": cfg.get("mysql_host", ""),
        "mysql_port": cfg.get("mysql_port", 3306),
        "admin_db": cfg.get("admin_db", ""),
        "mysql_admin_user": cfg.get("mysql_admin_user", ""),
    }
