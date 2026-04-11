import os

from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from core import ssh_sync
from core.config import get_config, get_ssh_sync_config, update_public_url
from core.phpmyadmin import write_pma_config
from models.user import User
from routers.auth import require_admin

_SSH_LOG_PATH = "/app/config/sshgateway.log"
_SSH_LOG_TAIL = 60

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
        "public_url": cfg.get("public_url") or "",
    }


class PublicUrlUpdate(BaseModel):
    public_url: str


@router.put("/public-url", status_code=204)
async def set_public_url(body: PublicUrlUpdate, _: User = Depends(require_admin)):
    update_public_url(body.public_url)
    write_pma_config()


@router.get("/ssh-sync/health")
async def ssh_sync_health(_: User = Depends(require_admin)):
    """Ping the SSH sync daemon and return its health status."""
    cfg = get_ssh_sync_config()
    if not cfg.get("enabled"):
        return {"enabled": False}
    result = await ssh_sync._call("GET", "/sync/health")
    return {
        "enabled": True,
        "ok": result.get("ok", False),
        "version": result.get("version"),
        "error": result.get("error"),
    }


@router.get("/ssh-sync/logs")
async def ssh_sync_logs(_: User = Depends(require_admin)):
    """Return the last N lines of the SSH sync daemon log (written to shared volume)."""
    cfg = get_ssh_sync_config()
    if not cfg.get("enabled"):
        raise HTTPException(404, "SSH sync is not enabled in bundled mode")
    if not os.path.exists(_SSH_LOG_PATH):
        return {"lines": [], "note": "Log file not found — daemon may not have started yet or the volume is not mounted"}
    try:
        with open(_SSH_LOG_PATH, "r", encoding="utf-8", errors="replace") as fh:
            lines = fh.readlines()
        return {"lines": [ln.rstrip() for ln in lines[-_SSH_LOG_TAIL:]]}
    except OSError as exc:
        raise HTTPException(500, f"Could not read log file: {exc}") from exc

