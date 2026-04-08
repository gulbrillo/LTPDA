import hashlib
import hmac
import logging

import httpx
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

log = logging.getLogger("ltpda.settings")

from core.config import get_config, get_ssh_sync_config, update_ssh_sync_config
from models.user import User
from routers.auth import require_admin

router = APIRouter(prefix="/api/settings", tags=["settings"])


def _sign(secret: str, body: bytes) -> str:
    return "sha256=" + hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()


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


class TestSshSyncRequest(BaseModel):
    port: int = 9922
    secret: str | None = None  # None = use saved config secret


@router.post("/test-ssh-sync")
async def test_ssh_sync(body: TestSshSyncRequest, _: User = Depends(require_admin)):
    """Test connectivity to the SSH sync daemon using the provided (or saved) credentials."""
    secret = body.secret
    if not secret:
        secret = get_ssh_sync_config().get("secret", "")
    if not secret:
        return {"ok": False, "error": "No shared secret configured — enter a secret and try again."}

    url = f"http://host.docker.internal:{body.port}/sync/health"
    request_body = b"{}"
    sig = _sign(secret, request_body)
    log.info("Settings: testing SSH sync daemon at %s", url)
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.request("GET", url, headers={"X-LTPDA-Signature": sig, "Content-Type": "application/json"}, content=request_body)
        log.info("Settings: daemon responded HTTP %d", r.status_code)
        if r.status_code == 200:
            data = r.json()
            return {"ok": True, "daemon_version": data.get("version")}
        if r.status_code == 403:
            return {"ok": False, "error": "Daemon rejected the request — shared secret mismatch"}
        return {"ok": False, "error": f"Daemon returned HTTP {r.status_code}: {r.text[:200]}"}
    except httpx.ConnectError as e:
        msg = str(e) or f"TCP connection refused on {url}"
        log.warning("Settings: ConnectError reaching %s: %s", url, msg)
        return {"ok": False, "error": f"Cannot reach daemon at {url} — is it running? ({msg})"}
    except httpx.TimeoutException:
        log.warning("Settings: timeout reaching %s", url)
        return {"ok": False, "error": f"Connection timed out after 5 s — daemon at {url} did not respond"}
    except Exception as e:
        msg = str(e) or type(e).__name__
        log.exception("Settings: unexpected error testing SSH sync: %s", msg)
        return {"ok": False, "error": f"Unexpected error ({type(e).__name__}): {msg}"}
