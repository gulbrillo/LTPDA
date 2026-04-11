import hashlib
import hmac
import json
import secrets
from typing import Literal

import aiomysql
import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from core.config import is_configured, write_config
from core.security import hash_password

router = APIRouter(prefix="/api/setup", tags=["setup"])


class SetupRequest(BaseModel):
    mode: Literal["bundled", "external"] = "bundled"

    # MySQL connection — host is "mysql" for bundled, user-supplied for external
    mysql_host: str = "mysql"
    mysql_port: int = 3306
    admin_db: str = "ltpda_admin"

    # Admin MySQL account (root or equivalent: needs CREATE DATABASE, CREATE USER, GRANT)
    mysql_admin_user: str = "root"
    mysql_admin_password: str

    # First application admin user
    app_admin_username: str
    app_admin_password: str           # web UI password (bcrypt)
    app_admin_mysql_password: str     # MySQL account password (for MATLAB JDBC)
    app_admin_first_name: str | None = None
    app_admin_last_name: str | None = None
    app_admin_email: str | None = None

    # SSH sync is automatically enabled in bundled mode, disabled in external mode
    # These fields are ignored — included only for API documentation
    ssh_sync_enabled: bool = True  # Auto-enabled in bundled mode
    ssh_sync_port: int = 9922      # Fixed port in bundled mode

    # Public URL of this installation (no trailing slash) — used for phpMyAdmin sub-path routing
    public_url: str | None = None


def _make_sig(secret: str, body: bytes) -> str:
    return "sha256=" + hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()


async def _call_daemon(port: int, secret: str, method: str, path: str, payload: dict | None = None) -> dict:
    """Make a signed call to the SSH sync daemon. Returns {"ok": bool, "error": str|None}."""
    url = f"http://host.docker.internal:{port}{path}"
    body = json.dumps(payload).encode() if payload is not None else b"{}"
    sig = _make_sig(secret, body)
    headers = {"X-LTPDA-Signature": sig, "Content-Type": "application/json"}
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            if method == "GET":
                r = await client.get(url, headers=headers, content=body)
            else:
                r = await client.post(url, headers=headers, content=body)
        if r.status_code in (200, 201):
            return {"ok": True, **r.json()}
        return {"ok": False, "error": f"Daemon returned HTTP {r.status_code}: {r.text[:200]}"}
    except httpx.ConnectError:
        return {"ok": False, "error": f"Cannot reach SSH sync daemon at {url}"}
    except Exception as e:
        return {"ok": False, "error": str(e)}


@router.get("/status")
async def setup_status():
    return {"configured": is_configured()}


@router.post("/run")
async def run_setup(req: SetupRequest):
    if is_configured():
        raise HTTPException(400, "Already configured. Delete config/config.json to re-run setup.")

    # For bundled mode, force host to "mysql" (internal Docker network)
    host = "mysql" if req.mode == "bundled" else req.mysql_host

    # SSH sync is auto-enabled in bundled mode, auto-disabled in external mode
    ssh_sync_enabled = (req.mode == "bundled")
    ssh_sync_port = 9922  # Fixed port in bundled mode
    ssh_sync_secret = secrets.token_hex(16)  # Auto-generated, internal only

    # Try to connect to the SSH sync daemon if enabled
    daemon_ok = False
    if ssh_sync_enabled:
        result = await _call_daemon(ssh_sync_port, ssh_sync_secret, "GET", "/sync/health", None)
        if not result["ok"]:
            raise HTTPException(400, f"Cannot connect to SSH sync daemon: {result['error']}")
        daemon_ok = True

    try:
        conn = await aiomysql.connect(
            host=host,
            port=req.mysql_port,
            user=req.mysql_admin_user,
            password=req.mysql_admin_password,
            autocommit=True,
        )
    except Exception as e:
        raise HTTPException(400, f"Cannot connect to MySQL: {e}")

    try:
        async with conn:
            async with conn.cursor() as cur:
                # Create admin database
                db = req.admin_db
                await cur.execute(
                    f"CREATE DATABASE IF NOT EXISTS `{db}` "
                    "CHARACTER SET utf8 COLLATE utf8_general_ci"
                )
                await cur.execute(f"USE `{db}`")

                # Create v2.5-compatible admin schema
                await _create_admin_schema(cur)

                # Create first admin user (app record + MySQL account)
                pw_hash = hash_password(req.app_admin_password)
                await cur.execute(
                    """INSERT INTO users
       (username, password_hash, mysql_password,
          first_name, last_name, email, is_admin)
             VALUES (%s, %s, %s, %s, %s, %s, TRUE)
             ON DUPLICATE KEY UPDATE
       password_hash = VALUES(password_hash),
       mysql_password = VALUES(mysql_password)""",
                    (
                        req.app_admin_username,
                        pw_hash,
                        req.app_admin_mysql_password,
                        req.app_admin_first_name,
                        req.app_admin_last_name,
                        req.app_admin_email,
                    ),
                )

                # Create MySQL account for the first admin user
                uname = req.app_admin_username
                mpw = req.app_admin_mysql_password
                await cur.execute(
                    f"CREATE USER IF NOT EXISTS '{uname}'@'%%' IDENTIFIED BY %s",
                    (mpw,),
                )
                await cur.execute("FLUSH PRIVILEGES")
    except Exception as e:
        raise HTTPException(400, f"Database setup failed: {e}")

    # Sync admin user to SSH daemon (use web UI password — that's what SSH auth uses)
    if daemon_ok:
        sync_result = await _call_daemon(
            ssh_sync_port, ssh_sync_secret, "POST", "/sync/user/create",
            {"username": req.app_admin_username, "password": req.app_admin_password}
        )
        if not sync_result["ok"]:
            raise HTTPException(400, f"SSH sync daemon rejected admin user creation: {sync_result.get('error')}")

    secret_key = secrets.token_hex(32)
    try:
        write_config(
            mysql_mode=req.mode,
            mysql_host=host,
            mysql_port=req.mysql_port,
            admin_db=req.admin_db,
            mysql_admin_user=req.mysql_admin_user,
            mysql_admin_password=req.mysql_admin_password,
            secret_key=secret_key,
            public_url=req.public_url,
            ssh_sync_enabled=ssh_sync_enabled,
            ssh_sync_url=f"http://host.docker.internal:{ssh_sync_port}" if ssh_sync_enabled else None,
            ssh_sync_secret=ssh_sync_secret,
        )
    except Exception as e:
        raise HTTPException(500, f"Config write failed: {e}")

    return {"ok": True, "message": "Setup complete. You can now log in.", "ssh_sync_verified": daemon_ok}


async def _create_admin_schema(cur) -> None:
    """Create the v2.5-compatible admin database tables."""

    # Application users table (web UI auth + MySQL account tracking)
    await cur.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id             INT AUTO_INCREMENT PRIMARY KEY,
            username       VARCHAR(64) UNIQUE NOT NULL,
            password_hash  VARCHAR(255) NOT NULL,
            mysql_password VARCHAR(255),
            first_name     VARCHAR(128),
            last_name      VARCHAR(128),
            email          VARCHAR(255),
            institution    VARCHAR(255),
            telephone      VARCHAR(50),
            is_admin       TINYINT(1) NOT NULL DEFAULT 0,
            created_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    """)

    # Registry of repository databases (one row per repo DB)
    await cur.execute("""
        CREATE TABLE IF NOT EXISTS available_dbs (
            id          INT AUTO_INCREMENT PRIMARY KEY,
            db_name     VARCHAR(64) UNIQUE NOT NULL,
            name        VARCHAR(128) NOT NULL,
            description TEXT,
            version     INT DEFAULT 2
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    """)

    # Global options/settings store
    await cur.execute("""
        CREATE TABLE IF NOT EXISTS options (
            name  VARCHAR(50) PRIMARY KEY,
            value TEXT NOT NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    """)

