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

Persistence: /app/config/ssh_users.json stores a username→pw_hash map.
  On startup _restore_users() recreates any accounts missing from the
  container filesystem (e.g. after a docker compose up --build).
"""

import crypt  # SHA-512 crypt; available on Python 3.11/3.12 (Alpine 3.19)
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
USERS_DB    = Path("/app/config/ssh_users.json")  # Persistent user store
LOG_PATH    = Path("/app/config/sshgateway.log")  # Accessible from host via volume mount
VERSION = "1.1.0"
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
    first_missing = True
    first_no_secret = True
    while True:
        if not CONFIG_PATH.exists():
            if first_missing:
                log.info("config.json not found at %s — waiting for API to write it ...", CONFIG_PATH)
                first_missing = False
            time.sleep(5)
            continue
        first_missing = True  # reset so re-disappearance is logged again
        try:
            cfg = json.loads(CONFIG_PATH.read_text())
        except Exception as e:
            log.error("Cannot parse config.json: %s — retrying in 5s", e)
            time.sleep(5)
            continue

        secret = cfg.get("ssh_sync_secret")
        if not secret:
            if first_no_secret:
                log.info(
                    "config.json found but ssh_sync_secret is missing — "
                    "waiting for the backend to generate it (this happens automatically on API startup)"
                )
                first_no_secret = False
            time.sleep(5)
            continue

        enabled = cfg.get("ssh_sync_enabled", False)
        log.info(
            "Config loaded — ssh_sync_enabled=%s  mysql_mode=%s  secret=%.8s…(%d chars)",
            enabled,
            cfg.get("mysql_mode", "unknown"),
            secret,
            len(secret),
        )
        if not enabled:
            log.warning(
                "ssh_sync_enabled is false — daemon will run but the LTPDA backend "
                "won't call it. Re-run setup or set ssh_sync_enabled=true in config.json."
            )
        return {"secret": secret, "enabled": enabled}


cfg = load_config()
PORT: int = 9922  # Fixed port
SECRET: str = cfg["secret"]

# ── Persistent user store ─────────────────────────────────────────────────────

def _hash_password(password: str) -> str:
    """Hash a password with SHA-512 crypt for persistent storage."""
    return crypt.crypt(password, crypt.mksalt(crypt.METHOD_SHA512))


def _load_users_db() -> dict:
    """Load the persistent user database (username → pw_hash)."""
    if USERS_DB.exists():
        try:
            return json.loads(USERS_DB.read_text())
        except Exception as e:
            log.error("Cannot parse ssh_users.json: %s", e)
    return {}


def _save_users_db(db: dict) -> None:
    """Persist the user database."""
    try:
        USERS_DB.write_text(json.dumps(db, indent=2))
    except Exception as e:
        log.error("Failed to write ssh_users.json: %s", e)


def _restore_users() -> None:
    """
    Recreate SSH accounts from the persistent database after a container restart.
    Called once at daemon startup before the Flask server begins accepting requests.
    """
    db = _load_users_db()
    if not db:
        log.info("No persistent users to restore.")
        return
    log.info("Restoring %d SSH user(s) from %s ...", len(db), USERS_DB)
    _run("groupadd", "--force", LTPDA_GROUP)
    restored = 0
    for username, pw_hash in db.items():
        exists, _ = _account_status(username)
        if exists:
            log.info("  %s already exists — skipping", username)
            continue
        ok, err = _run(
            "useradd", "-m",
            "-g", LTPDA_GROUP,
            "-s", "/bin/false",
            "-c", LTPDA_MARKER,
            username,
        )
        if not ok:
            log.error("  Failed to restore %s: %s", username, err)
            continue
        try:
            proc = subprocess.run(
                ["chpasswd", "-e"],
                input=f"{username}:{pw_hash}\n",
                capture_output=True, text=True, timeout=10,
            )
            if proc.returncode != 0:
                log.error("  chpasswd -e failed for %s: %s", username, (proc.stderr or proc.stdout).strip())
            else:
                log.info("  Restored: %s", username)
                restored += 1
        except Exception as e:
            log.error("  chpasswd -e exception for %s: %s", username, e)
    log.info("Restore complete — %d/%d account(s) recreated.", restored, len(db))


# ── Flask app ─────────────────────────────────────────────────────────────────

app = Flask(__name__)

# Suppress Werkzeug's ANSI-coloured startup banner and per-request noise.
# We provide our own after_request logger so requests still appear in the log.
logging.getLogger("werkzeug").disabled = True


@app.after_request
def _log_request(response):
    log.info("%-6s %s  ->  %d", request.method, request.path, response.status_code)
    return response


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
        # Update the persistent store with the new password hash
        db = _load_users_db()
        db[username] = _hash_password(password)
        _save_users_db(db)
        return jsonify({"ok": True, "updated": True})

    # Ensure the shared LTPDA group exists
    _run("groupadd", "--force", LTPDA_GROUP)

    # Account does not exist — create it in the shared group
    ok, err = _run(
        "useradd", "-m",
        "-g", LTPDA_GROUP,
        "-s", "/bin/false",
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

    # Persist so account survives container restarts
    db = _load_users_db()
    db[username] = _hash_password(password)
    _save_users_db(db)

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

    db = _load_users_db()
    db[username] = _hash_password(password)
    _save_users_db(db)

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
        # Remove from persistent store in case the record is stale
        db = _load_users_db()
        db.pop(username, None)
        _save_users_db(db)
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

    # Remove from persistent store
    db = _load_users_db()
    db.pop(username, None)
    _save_users_db(db)

    log.info("Deleted SSH account: %s", username)
    return jsonify({"ok": True})


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    if os.geteuid() != 0:
        log.warning("Not running as root — useradd/userdel/chpasswd will fail")
    log.info(
        "LTPDA SSH Sync Daemon v%s starting on :%d  "
        "(ssh_sync_enabled=%s)",
        VERSION, PORT, cfg["enabled"],
    )
    _restore_users()
    try:
        app.run(host="0.0.0.0", port=PORT, debug=False)
    except OSError as exc:
        log.error("Cannot bind to port %d: %s", PORT, exc)
    except Exception as exc:
        log.error("Flask crashed: %s", exc)
    finally:
        log.warning("Daemon process exiting — entrypoint.sh will restart it in 5 s")
