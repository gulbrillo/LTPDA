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
    public_url: str | None = None,
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
    if public_url:
        data["public_url"] = public_url.rstrip("/")
    CONFIG_FILE.write_text(json.dumps(data, indent=2))


def update_public_url(public_url: str) -> None:
    """Update only the public_url field in an existing config."""
    data = _load()
    data["public_url"] = public_url.rstrip("/")
    CONFIG_FILE.write_text(json.dumps(data, indent=2))


def get_public_url() -> str | None:
    return _load().get("public_url")


ACCESS_TOKEN_EXPIRE_MINUTES = 8 * 60  # 8 hours
