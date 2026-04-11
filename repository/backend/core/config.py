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
    if public_url:
        data["public_url"] = public_url.rstrip("/")
    data["ssh_sync_enabled"] = ssh_sync_enabled
    if ssh_sync_url:
        data["ssh_sync_url"] = ssh_sync_url
    if ssh_sync_secret:
        data["ssh_sync_secret"] = ssh_sync_secret
    CONFIG_FILE.write_text(json.dumps(data, indent=2))


def update_public_url(public_url: str) -> None:
    """Update only the public_url field in an existing config."""
    data = _load()
    data["public_url"] = public_url.rstrip("/")
    CONFIG_FILE.write_text(json.dumps(data, indent=2))


def get_public_url() -> str | None:
    return _load().get("public_url")


def ensure_ssh_sync_config() -> None:
    """
    Auto-generate missing SSH sync credentials for bundled-mode installations that
    were set up before SSH sync support was added. Writes to config.json if anything
    was missing. The sshgateway daemon's wait loop picks up the new secret
    automatically within ~5 seconds — no manual container restart needed.
    """
    data = _load()
    if not data.get("configured"):
        return  # Setup hasn't run yet
    if data.get("mysql_mode") != "bundled":
        return  # External mode — no SSH gateway container

    changed = False
    if not data.get("ssh_sync_enabled"):
        data["ssh_sync_enabled"] = True
        changed = True
    # Rewrite host.docker.internal URLs — hairpin NAT is unreliable on Linux Docker.
    # Direct container-to-container via the shared Docker network always works.
    _url = data.get("ssh_sync_url", "")
    if not _url or "host.docker.internal" in _url:
        data["ssh_sync_url"] = "http://sshgateway:9922"
        changed = True
    if not data.get("ssh_sync_secret"):
        data["ssh_sync_secret"] = secrets.token_hex(32)
        changed = True
    if changed:
        CONFIG_FILE.write_text(json.dumps(data, indent=2))


def get_ssh_sync_config() -> dict:
    """Return SSH sync configuration if enabled."""
    data = _load()
    if not data.get("ssh_sync_enabled"):
        return {}
    return {
        "enabled": True,
        "url": data.get("ssh_sync_url"),
        "secret": data.get("ssh_sync_secret"),
    }


ACCESS_TOKEN_EXPIRE_MINUTES = 8 * 60  # 8 hours
