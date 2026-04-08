import hashlib
import hmac
import json
import logging

import httpx
from fastapi import APIRouter, Depends

from core.config import get_ssh_sync_config
from models.user import User
from routers.auth import require_admin

log = logging.getLogger("ltpda.sync")
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
    if not cfg["secret"]:
        return {"ok": False, "error": "No shared secret is configured"}

    url = cfg["url"].rstrip("/") + "/sync/health"
    body = b"{}"
    sig = _sign(cfg["secret"], body)
    log.info("Testing SSH sync daemon at %s", url)
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.request("GET", url, headers={"X-LTPDA-Signature": sig, "Content-Type": "application/json"}, content=body)
        log.info("Daemon responded: HTTP %d", r.status_code)
        if r.status_code == 200:
            data = r.json()
            return {"ok": True, "daemon_version": data.get("version")}
        if r.status_code == 403:
            return {"ok": False, "error": "Daemon rejected the request — shared secret mismatch"}
        return {"ok": False, "error": f"Daemon returned HTTP {r.status_code}: {r.text[:200]}"}
    except httpx.ConnectError as e:
        msg = str(e) or f"TCP connection refused on {url}"
        log.warning("ConnectError reaching %s: %s", url, msg)
        return {"ok": False, "error": f"Cannot reach daemon at {url} — is it running? ({msg})"}
    except httpx.TimeoutException:
        log.warning("Timeout reaching %s", url)
        return {"ok": False, "error": f"Connection timed out after 5 s — daemon at {url} did not respond"}
    except Exception as e:
        msg = str(e) or type(e).__name__
        log.exception("Unexpected error testing SSH sync: %s", msg)
        return {"ok": False, "error": f"Unexpected error ({type(e).__name__}): {msg}"}
