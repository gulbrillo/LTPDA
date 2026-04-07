import hashlib
import hmac
import json

import httpx
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from core.config import get_ssh_sync_config
from core.database import get_admin_connection, get_session
from core.security import hash_password
from models.user import User
from routers.auth import require_admin
from schemas.user import UserCreate, UserOut, UserUpdate

router = APIRouter(prefix="/api/users", tags=["users"])


async def _call_ssh_sync(action: str, payload: dict) -> dict:
    """Send a webhook to the SSH sync daemon. Returns {"ok": bool, "error": str|None}."""
    cfg = get_ssh_sync_config()
    if not cfg["enabled"] or cfg["mode"] != "bundled":
        return {"ok": True, "skipped": True}

    url = cfg["url"].rstrip("/")
    secret = cfg["secret"]
    body = json.dumps(payload).encode()
    sig = "sha256=" + hmac.new(secret.encode(), body, hashlib.sha256).hexdigest()
    headers = {"X-LTPDA-Signature": sig, "Content-Type": "application/json"}

    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            if action == "delete":
                r = await client.delete(
                    f"{url}/sync/user/{payload['username']}", headers=headers, content=body
                )
            elif action == "create":
                r = await client.post(f"{url}/sync/user/create", headers=headers, content=body)
            else:  # update
                r = await client.post(f"{url}/sync/user/update", headers=headers, content=body)
        if r.status_code in (200, 201, 204):
            return {"ok": True}
        return {"ok": False, "error": f"Daemon returned HTTP {r.status_code}: {r.text[:200]}"}
    except httpx.ConnectError:
        return {"ok": False, "error": "Cannot reach SSH sync daemon"}
    except Exception as e:
        return {"ok": False, "error": str(e)}


@router.get("", response_model=list[UserOut])
async def list_users(
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(select(User).order_by(User.username))
    return result.scalars().all()


@router.post("", status_code=status.HTTP_201_CREATED)
async def create_user(
    body: UserCreate,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    existing = await session.execute(select(User).where(User.username == body.username))
    if existing.scalar_one_or_none():
        raise HTTPException(status.HTTP_409_CONFLICT, "Username already exists")

    # Capture plaintext password for SSH sync before hashing
    plaintext_pw = body.password

    user = User(
        username=body.username,
        password_hash=hash_password(plaintext_pw),
        mysql_password=body.mysql_password,
        first_name=body.first_name,
        last_name=body.last_name,
        email=body.email,
        institution=body.institution,
        is_admin=body.is_admin,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)

    # Create matching MySQL user account (for MATLAB JDBC access)
    if body.mysql_password:
        try:
            conn = await get_admin_connection()
            async with conn:
                async with conn.cursor() as cur:
                    await cur.execute(
                        f"CREATE USER IF NOT EXISTS '{body.username}'@'%' IDENTIFIED BY %s",
                        (body.mysql_password,),
                    )
                    await cur.execute("FLUSH PRIVILEGES")
        except Exception as e:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                f"App user created but MySQL user creation failed: {e}",
            )

    sync = await _call_ssh_sync("create", {"username": body.username, "password": plaintext_pw})
    return {"user": UserOut.model_validate(user).model_dump(mode="json"), "ssh_sync": sync}


@router.put("/{user_id}", response_model=UserOut)
async def update_user(
    user_id: int,
    body: UserUpdate,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    if body.first_name is not None:
        user.first_name = body.first_name
    if body.last_name is not None:
        user.last_name = body.last_name
    if body.email is not None:
        user.email = body.email
    if body.institution is not None:
        user.institution = body.institution
    if body.is_admin is not None:
        user.is_admin = body.is_admin
    if body.password:
        user.password_hash = hash_password(body.password)
    if body.mysql_password:
        user.mysql_password = body.mysql_password
        # Update MySQL account password as well
        try:
            conn = await get_admin_connection()
            async with conn:
                async with conn.cursor() as cur:
                    await cur.execute(
                        f"ALTER USER IF EXISTS '{user.username}'@'%' IDENTIFIED BY %s",
                        (body.mysql_password,),
                    )
                    await cur.execute("FLUSH PRIVILEGES")
        except Exception as e:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                f"App user updated but MySQL password change failed: {e}",
            )

    await session.commit()
    await session.refresh(user)

    sync = {"ok": True, "skipped": True}
    if body.password:
        sync = await _call_ssh_sync("update", {"username": user.username, "password": body.password})
    return {"user": UserOut.model_validate(user).model_dump(mode="json"), "ssh_sync": sync}


@router.delete("/{user_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_user(
    user_id: int,
    current: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    if current.id == user_id:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, "Cannot delete your own account")

    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    username = user.username
    await session.delete(user)
    await session.commit()

    # Drop matching MySQL user account
    try:
        conn = await get_admin_connection()
        async with conn:
            async with conn.cursor() as cur:
                await cur.execute(f"DROP USER IF EXISTS '{username}'@'%'")
                await cur.execute("FLUSH PRIVILEGES")
    except Exception:
        pass  # MySQL user removal is best-effort; app record is already gone

    await _call_ssh_sync("delete", {"username": username})
