#!/usr/bin/env python3
"""
LTPDA SSH Sync Daemon
=====================
Listens for webhooks from the LTPDA Docker container and manages Linux SSH
accounts on the host machine. Run as root via systemd.

Accounts created by this daemon are tagged with GECOS comment "ltpda-managed".
The daemon will refuse to modify or delete accounts it did not create.

Config: /app/config/config.json (shared with backend)
  { "ssh_sync_enabled": true, "ssh_sync_secret": "..." }
"""

import hashlib
import hmac
import json
import logging
import os
import subprocess
import sys
import time
from pathlib import Path

from flask import Flask, abort, jsonify, request

# ── Config ────────────────────────────────────────────────────────────────────

CONFIG_PATH = Path("/app/config/config.json")  # Shared with backend
LOG_PATH = Path("/app/config/sshgateway.log")   # Accessible from host via volume mount
VERSION = "1.0.0"
LTPDA_MARKER = "ltpda-managed"
LTPDA_GROUP = "ltpda-users"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler(LOG_PATH, encoding="utf-8"),
    ],
)
log = logging.getLogger("ltpda-ssh-sync")


def load_config() -> dict:
    """Block until config.json is present and contains the SSH sync secret."""
    while True:
        if not CONFIG_PATH.exists():
            log.info("Waiting for config.json at %s ...", CONFIG_PATH)
            time.sleep(5)
            continue
        try:
            cfg = json.loads(CONFIG_PATH.read_text())
        except Exception as e:
            log.error("Cannot parse config.json: %s — retrying in 5s", e)
            time.sleep(5)
            continue
        secret = cfg.get("ssh_sync_secret")
        if not secret:
            log.info("ssh_sync_secret not present in config yet, waiting...")
            time.sleep(5)
            continue
        if not cfg.get("ssh_sync_enabled"):
            log.warning("SSH sync is disabled in config (ssh_sync_enabled is false/missing)")
        return {"secret": secret, "enabled": cfg.get("ssh_sync_enabled", False)}


cfg = load_config()
PORT: int = 9922  # Fixed port
SECRET: str = cfg["secret"]

# ── Flask app ─────────────────────────────────────────────────────────────────

app = Flask(__name__)


def _verify_signature(body: bytes) -> bool:
    sig_header = request.headers.get("X-LTPDA-Signature", "")
    if not sig_header.startswith("sha256="):
        return False
    expected = "sha256=" + hmac.new(SECRET.encode(), body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, sig_header)


def _require_sig():
    body = request.get_data()
    if not _verify_signature(body):
        log.warning("Rejected request with invalid signature from %s", request.remote_addr)
        abort(403, "Invalid signature")
    return body


def _run(*args) -> tuple[bool, str]:
    """Run a subprocess command. Returns (success, output)."""
    try:
        result = subprocess.run(list(args), capture_output=True, text=True, timeout=10)
        if result.returncode != 0:
            return False, (result.stderr or result.stdout).strip()
        return True, result.stdout.strip()
    except Exception as e:
        return False, str(e)


def _chpasswd(username: str, password: str) -> tuple[bool, str]:
    """Set a user's password via chpasswd."""
    try:
        proc = subprocess.run(
            ["chpasswd"],
            input=f"{username}:{password}\n",
            capture_output=True, text=True, timeout=10,
        )
        if proc.returncode != 0:
            return False, (proc.stderr or proc.stdout).strip()
        return True, ""
    except Exception as e:
        return False, str(e)


def _account_status(username: str) -> tuple[bool, bool]:
    """
    Returns (exists, is_ltpda_managed).
    Checks /etc/passwd via getent to read the GECOS field.
    """
    result = subprocess.run(
        ["getent", "passwd", username], capture_output=True, text=True
    )
    if result.returncode != 0:
        return False, False  # account does not exist
    # Format: username:x:uid:gid:GECOS:home:shell
    parts = result.stdout.strip().split(":")
    gecos = parts[4] if len(parts) >= 5 else ""
    return True, LTPDA_MARKER in gecos


def _validate_username(username: str) -> bool:
    """Reject anything other than alphanumeric + hyphen + underscore."""
    return bool(username) and username.replace("-", "").replace("_", "").isalnum()


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get("/sync/health")
def health():
    # Verify signature so the test button confirms the shared secret is correct
    body = request.get_data()
    if not _verify_signature(body):
        log.warning("Health check with invalid signature from %s", request.remote_addr)
        abort(403, "Invalid signature")
    return jsonify({"ok": True, "version": VERSION})


@app.post("/sync/user/create")
def user_create():
    body = _require_sig()
    try:
        data = json.loads(body)
        username: str = data["username"]
        password: str = data["password"]
    except (json.JSONDecodeError, KeyError) as e:
        abort(400, f"Invalid payload: {e}")

    if not _validate_username(username):
        abort(400, "Invalid username — only alphanumeric characters, hyphens, and underscores allowed")

    exists, is_managed = _account_status(username)

    if exists and not is_managed:
        # A non-LTPDA system account with the same name already exists — this is a conflict
        msg = (
            f"A system account named '{username}' already exists on this host and was "
            f"not created by LTPDA (no '{LTPDA_MARKER}' marker in GECOS). "
            f"Choose a different username or remove the conflicting account manually."
        )
        log.warning("Account conflict for user %s: %s", username, msg)
        return jsonify({"ok": False, "conflict": True, "error": msg}), 409

    if exists and is_managed:
        # Already managed by LTPDA — just update the password
        log.info("User %s already ltpda-managed, updating password", username)
        ok, err = _chpasswd(username, password)
        if not ok:
            log.error("chpasswd failed for %s: %s", username, err)
            return jsonify({"ok": False, "error": f"Password update failed: {err}"}), 500
        return jsonify({"ok": True, "updated": True})

    # Ensure the shared LTPDA group exists
    _run("groupadd", "--force", LTPDA_GROUP)

    # Account does not exist — create it in the shared group
    ok, err = _run(
        "useradd", "-m",
        "-g", LTPDA_GROUP,
        "-s", "/usr/sbin/nologin",
        "-c", LTPDA_MARKER,
        username,
    )
    if not ok:
        log.error("useradd failed for %s: %s", username, err)
        return jsonify({"ok": False, "error": f"useradd failed: {err}"}), 500

    ok, err = _chpasswd(username, password)
    if not ok:
        log.error("chpasswd failed for %s: %s", username, err)
        # Account exists but has no password set — still usable with key auth
        return jsonify({
            "ok": False,
            "error": f"Account created but password could not be set: {err}",
        }), 500

    log.info("Created SSH account: %s", username)
    return jsonify({"ok": True})


@app.post("/sync/user/update")
def user_update():
    body = _require_sig()
    try:
        data = json.loads(body)
        username: str = data["username"]
        password: str = data["password"]
    except (json.JSONDecodeError, KeyError) as e:
        abort(400, f"Invalid payload: {e}")

    if not _validate_username(username):
        abort(400, "Invalid username")

    exists, is_managed = _account_status(username)

    if not exists:
        log.warning("Update requested for non-existent account: %s", username)
        return jsonify({"ok": False, "error": f"Account '{username}' does not exist"}), 404

    if not is_managed:
        msg = (
            f"Account '{username}' exists but was not created by LTPDA "
            f"(no '{LTPDA_MARKER}' marker). Refusing to modify it."
        )
        log.warning(msg)
        return jsonify({"ok": False, "error": msg}), 403

    ok, err = _chpasswd(username, password)
    if not ok:
        log.error("chpasswd failed for %s: %s", username, err)
        return jsonify({"ok": False, "error": err}), 500

    log.info("Updated SSH password: %s", username)
    return jsonify({"ok": True})


@app.delete("/sync/user/<username>")
def user_delete(username: str):
    _require_sig()

    if not _validate_username(username):
        abort(400, "Invalid username")

    exists, is_managed = _account_status(username)

    if not exists:
        log.info("Delete requested for non-existent account %s — already gone", username)
        return jsonify({"ok": True})

    if not is_managed:
        msg = (
            f"Account '{username}' exists but was not created by LTPDA "
            f"(no '{LTPDA_MARKER}' marker). Refusing to delete it."
        )
        log.warning(msg)
        return jsonify({"ok": False, "error": msg}), 403

    ok, err = _run("userdel", "-r", username)
    if not ok:
        log.error("userdel failed for %s: %s", username, err)
        return jsonify({"ok": False, "error": f"userdel failed: {err}"}), 500

    log.info("Deleted SSH account: %s", username)
    return jsonify({"ok": True})


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    if os.geteuid() != 0:
        log.warning("Not running as root — useradd/userdel will fail")
    log.info("LTPDA SSH Sync Daemon v%s starting on port %d", VERSION, PORT)
    app.run(host="0.0.0.0", port=PORT, debug=False)
