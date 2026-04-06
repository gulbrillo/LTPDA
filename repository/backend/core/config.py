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
    return bool(data.get("configured") and data.get("database_url") and data.get("secret_key"))


def get_database_url() -> str:
    return _load().get("database_url", "")


def get_secret_key() -> str:
    data = _load()
    return data.get("secret_key") or secrets.token_hex(32)


def write_config(database_url: str, secret_key: str) -> None:
    CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
    CONFIG_FILE.write_text(json.dumps({
        "configured": True,
        "database_url": database_url,
        "secret_key": secret_key,
    }, indent=2))


ACCESS_TOKEN_EXPIRE_MINUTES = 8 * 60  # 8 hours
