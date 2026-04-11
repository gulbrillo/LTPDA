"""
Shared SSH sync client for LTPDA backend.

Makes signed HTTP calls to the ssh_sync_daemon running in the sshgateway
container. Returns {"ok": True, "skipped": True} when SSH sync is disabled,
so callers don't need to check the enabled flag themselves.
"""

import hashlib
import hmac
import json
import logging

import httpx

from core.config import get_ssh_sync_config

log = logging.getLogger("ltpda.ssh_sync")


def _make_sig(secret: str, body: bytes) -> str:
    return "sha256=" + hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()


async def _call(method: str, path: str, payload: dict | None = None) -> dict:
    """Make a signed request to the SSH sync daemon."""
    cfg = get_ssh_sync_config()
    if not cfg.get("enabled"):
        return {"ok": True, "skipped": True}

    url = cfg["url"] + path
    # Always send a body so the HMAC can be computed consistently on both sides.
    # The daemon reads request.get_data() regardless of HTTP method.
    body = json.dumps(payload).encode() if payload is not None else b"{}"

    try:
        # _make_sig is inside try so a missing/None secret returns {"ok": False} rather
        # than propagating an AttributeError up to the FastAPI exception handler.
        sig = _make_sig(cfg["secret"], body)
        headers = {"X-LTPDA-Signature": sig, "Content-Type": "application/json"}
        async with httpx.AsyncClient(timeout=5.0) as client:
            r = await client.request(method, url, headers=headers, content=body)
        if r.status_code in (200, 201):
            return {"ok": True, **r.json()}
        return {"ok": False, "error": f"Daemon HTTP {r.status_code}: {r.text[:200]}"}
    except httpx.ConnectError:
        return {"ok": False, "error": f"Cannot reach SSH sync daemon at {url}"}
    except Exception as e:
        return {"ok": False, "error": str(e) or f"{type(e).__name__} (no detail)"}


async def sync_create(username: str, password: str) -> dict:
    """Create SSH account, or update its password if it already exists."""
    return await _call("POST", "/sync/user/create", {"username": username, "password": password})


async def sync_delete(username: str) -> dict:
    """Delete SSH account (no-op if it doesn't exist)."""
    return await _call("DELETE", f"/sync/user/{username}")
