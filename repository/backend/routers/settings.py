from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from core.config import get_config, get_ssh_sync_config, update_ssh_sync_config
from models.user import User
from routers.auth import require_admin

router = APIRouter(prefix="/api/settings", tags=["settings"])


@router.get("")
async def get_settings(_: User = Depends(require_admin)):
    cfg = get_config()
    ssh = get_ssh_sync_config()
    # Parse port from stored URL (http://host.docker.internal:9922)
    port = 9922
    url = cfg.get("ssh_sync_url", "")
    if url and ":" in url.rsplit(":", 1)[-1]:
        try:
            port = int(url.rsplit(":", 1)[-1])
        except ValueError:
            pass
    return {
        "mysql_mode": cfg.get("mysql_mode", "bundled"),
        "mysql_host": cfg.get("mysql_host", ""),
        "mysql_port": cfg.get("mysql_port", 3306),
        "admin_db": cfg.get("admin_db", ""),
        "mysql_admin_user": cfg.get("mysql_admin_user", ""),
        "ssh_sync_enabled": ssh["enabled"],
        "ssh_sync_port": port,
        "ssh_sync_secret_set": bool(ssh["secret"]),
    }


class SshSyncUpdate(BaseModel):
    enabled: bool
    port: int = 9922
    secret: str | None = None  # None = keep existing


@router.put("/ssh-sync")
async def update_ssh_sync(body: SshSyncUpdate, _: User = Depends(require_admin)):
    if body.enabled:
        existing = get_ssh_sync_config()
        if not body.secret and not existing["secret"]:
            raise HTTPException(400, "A shared secret is required to enable SSH sync.")
    update_ssh_sync_config(enabled=body.enabled, port=body.port, secret=body.secret)
    return {"ok": True}
