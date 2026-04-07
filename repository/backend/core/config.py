import json
import secrets
from pathlib import Path

CONFIG_FILE = Path("/app/config/config.json")


def _load() -> dict:
    if CONFIG_FILE.exists():
        try:
            return json.loads(CONFIG_FILE.read_text())
        except Exception:
            pass
    return {}


def is_configured() -> bool:
    data = _load()
    return bool(
        data.get("configured")
        and data.get("mysql_admin_user")
        and data.get("secret_key")
    )


def get_config() -> dict:
    return _load()


def get_secret_key() -> str:
    data = _load()
    return data.get("secret_key") or secrets.token_hex(32)


def write_config(
    mysql_mode: str,
    mysql_host: str,
    mysql_port: int,
    admin_db: str,
    mysql_admin_user: str,
    mysql_admin_password: str,
    secret_key: str,
    ssh_sync_enabled: bool = False,
    ssh_sync_url: str | None = None,
    ssh_sync_secret: str | None = None,
) -> None:
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    data: dict = {
        "configured": True,
        "mysql_mode": mysql_mode,
        "mysql_host": mysql_host,
        "mysql_port": mysql_port,
        "admin_db": admin_db,
        "mysql_admin_user": mysql_admin_user,
        "mysql_admin_password": mysql_admin_password,
        "secret_key": secret_key,
    }
    if ssh_sync_enabled:
        data["ssh_sync_enabled"] = True
        data["ssh_sync_url"] = ssh_sync_url or "http://host.docker.internal:9922"
        data["ssh_sync_secret"] = ssh_sync_secret or ""
    CONFIG_FILE.write_text(json.dumps(data, indent=2))


def get_ssh_sync_config() -> dict:
    cfg = _load()
    return {
        "enabled": cfg.get("ssh_sync_enabled", False),
        "url": cfg.get("ssh_sync_url", "http://host.docker.internal:9922"),
        "secret": cfg.get("ssh_sync_secret", ""),
        "mode": cfg.get("mysql_mode", "external"),
    }


ACCESS_TOKEN_EXPIRE_MINUTES = 8 * 60  # 8 hours
