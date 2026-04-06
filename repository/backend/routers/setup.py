import secrets

import aiomysql
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from core.config import is_configured, write_config
from core.security import hash_password

router = APIRouter(prefix="/api/setup", tags=["setup"])


class SetupRequest(BaseModel):
    # MySQL connection (admin creds used once)
    mysql_host: str
    mysql_port: int = 3306
    mysql_database: str = "ltpda_repo"
    admin_username: str
    admin_password: str
    # Service account (stored in config, used for all ongoing DB access)
    service_username: str
    service_password: str
    # First admin user for the app
    app_admin_username: str
    app_admin_password: str
    app_admin_given_name: str | None = None
    app_admin_family_name: str | None = None
    app_admin_email: str | None = None


@router.get("/status")
async def setup_status():
    return {"configured": is_configured()}


@router.post("/run")
async def run_setup(req: SetupRequest):
    if is_configured():
        raise HTTPException(400, "Already configured. Delete config/config.json to re-run setup.")

    # 1. Connect with admin credentials (no database selected yet)
    try:
        conn = await aiomysql.connect(
            host=req.mysql_host,
            port=req.mysql_port,
            user=req.admin_username,
            password=req.admin_password,
            autocommit=True,
        )
    except Exception as e:
        raise HTTPException(400, f"Cannot connect to MySQL with admin credentials: {e}")

    async with conn:
        async with conn.cursor() as cur:
            # 2. Create database
            db = req.mysql_database
            await cur.execute(f"CREATE DATABASE IF NOT EXISTS `{db}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")

            # 3. Create service account and grant limited privileges
            svc = req.service_username
            svc_pw = req.service_password
            host_pattern = "%"
            await cur.execute(
                f"CREATE USER IF NOT EXISTS '{svc}'@'{host_pattern}' IDENTIFIED BY %s",
                (svc_pw,),
            )
            await cur.execute(
                f"GRANT SELECT, INSERT, UPDATE, DELETE ON `{db}`.* TO '{svc}'@'{host_pattern}'"
            )
            await cur.execute("FLUSH PRIVILEGES")

            # 4. Create the users table using the service account connection
            await cur.execute(f"USE `{db}`")
            await cur.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id            INT AUTO_INCREMENT PRIMARY KEY,
                    username      VARCHAR(64) UNIQUE NOT NULL,
                    password_hash VARCHAR(255) NOT NULL,
                    given_name    VARCHAR(128),
                    family_name   VARCHAR(128),
                    email         VARCHAR(255),
                    institution   VARCHAR(255),
                    is_admin      BOOLEAN NOT NULL DEFAULT FALSE,
                    created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
            """)

            # 5. Insert first admin user
            pw_hash = hash_password(req.app_admin_password)
            await cur.execute(
                """INSERT INTO users (username, password_hash, given_name, family_name, email, is_admin)
                   VALUES (%s, %s, %s, %s, %s, TRUE)
                   ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash)""",
                (req.app_admin_username, pw_hash, req.app_admin_given_name,
                 req.app_admin_family_name, req.app_admin_email),
            )

    # 6. Write config.json with service account DATABASE_URL
    database_url = (
        f"mysql+aiomysql://{req.service_username}:{req.service_password}"
        f"@{req.mysql_host}:{req.mysql_port}/{req.mysql_database}"
    )
    secret_key = secrets.token_hex(32)
    write_config(database_url, secret_key)

    return {"ok": True, "message": "Setup complete. You can now log in."}
