import hashlib
import hmac
import json

import httpx
from fastapi import APIRouter, Depends

from core.config import get_ssh_sync_config
from models.user import User
from routers.auth import require_admin

router = APIRouter(prefix="/api/sync", tags=["sync"])


def _sign(secret: str, body: bytes) -> str:
    return "sha256=" + hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()


@router.get("/status")
async def sync_status(_: User = Depends(require_admin)):
    cfg = get_ssh_sync_config()
    return {
        "enabled": cfg["enabled"],
        "mode": cfg["mode"],
        "url": cfg["url"] if cfg["enabled"] else None,
    }


@router.post("/test")
async def test_sync(_: User = Depends(require_admin)):
    cfg = get_ssh_sync_config()
    if not cfg["enabled"]:
        return {"ok": False, "error": "SSH sync is not enabled"}
    if cfg["mode"] != "bundled":
        return {"ok": False, "error": "SSH sync is only available in bundled MySQL mode"}

    url = cfg["url"].rstrip("/") + "/sync/health"
    body = b"{}"
    sig = _sign(cfg["secret"], body)
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.get(url, headers={"X-LTPDA-Signature": sig})
        if r.status_code == 200:
            data = r.json()
            return {"ok": True, "daemon_version": data.get("version")}
        return {"ok": False, "error": f"Daemon returned HTTP {r.status_code}"}
    except httpx.ConnectError:
        return {"ok": False, "error": f"Cannot reach daemon at {url}"}
    except Exception as e:
        return {"ok": False, "error": str(e)}
