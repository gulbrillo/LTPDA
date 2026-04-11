import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from core import ssh_sync
from core.database import get_admin_connection, get_session
from core.security import hash_password
from models.user import User
from routers.auth import get_current_user, require_admin
from schemas.user import UserCreate, UserOut, UserSelfUpdate, UserUpdate

log = logging.getLogger("ltpda.users")

router = APIRouter(prefix="/api/users", tags=["users"])


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

    # Use explicit mysql_password if given, otherwise fall back to the web password.
    # Every user needs a MySQL account so MATLAB/JDBC access works.
    mysql_pw = body.mysql_password or body.password

    user = User(
        username=body.username,
        password_hash=hash_password(body.password),
        mysql_password=mysql_pw,
        first_name=body.first_name,
        last_name=body.last_name,
        email=body.email,
        institution=body.institution,
        is_admin=body.is_admin,
    )
    session.add(user)
    await session.commit()
    await session.refresh(user)

    # Always create a matching MySQL user account (required for MATLAB JDBC access)
    try:
        conn = await get_admin_connection()
        async with conn:
            async with conn.cursor() as cur:
                await cur.execute(
                    f"CREATE USER IF NOT EXISTS '{body.username}'@'%%' IDENTIFIED BY %s",
                    (mysql_pw,),
                )
                await cur.execute("FLUSH PRIVILEGES")
    except Exception as e:
        raise HTTPException(
            status.HTTP_500_INTERNAL_SERVER_ERROR,
            f"App user created but MySQL user creation failed: {e}",
        )

    result = UserOut.model_validate(user).model_dump(mode="json")
    ssh = await ssh_sync.sync_create(body.username, body.password)
    if not ssh.get("ok") and not ssh.get("skipped"):
        log.warning("SSH sync failed for new user %s: %s", body.username, ssh.get("error"))
        result["ssh_sync_warning"] = ssh.get("error")
    return result


@router.put("/me")
async def update_self(
    body: UserSelfUpdate,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    """Allow any authenticated user to update their own profile and passwords."""
    result = await session.execute(select(User).where(User.id == current.id))
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
    if body.password:
        user.password_hash = hash_password(body.password)
    new_mysql_pw = body.mysql_password or (body.password if body.password else None)
    if new_mysql_pw:
        user.mysql_password = new_mysql_pw
        try:
            conn = await get_admin_connection()
            async with conn:
                async with conn.cursor() as cur:
                    await cur.execute(
                        f"CREATE USER IF NOT EXISTS '{user.username}'@'%%' IDENTIFIED BY %s",
                        (new_mysql_pw,),
                    )
                    await cur.execute(
                        f"ALTER USER '{user.username}'@'%%' IDENTIFIED BY %s",
                        (new_mysql_pw,),
                    )
                    await cur.execute("FLUSH PRIVILEGES")
        except Exception as e:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                f"Profile updated but MySQL password sync failed: {e}",
            )

    await session.commit()
    await session.refresh(user)
    result = UserOut.model_validate(user).model_dump(mode="json")
    if body.password:
        ssh = await ssh_sync.sync_create(user.username, body.password)
        if not ssh.get("ok") and not ssh.get("skipped"):
            log.warning("SSH sync failed for user %s: %s", user.username, ssh.get("error"))
            result["ssh_sync_warning"] = ssh.get("error")
    return result


@router.put("/{user_id}")
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
    # Determine the new MySQL password (explicit override takes precedence; fall back to web password)
    new_mysql_pw = body.mysql_password or (body.password if body.password else None)
    if new_mysql_pw:
        user.mysql_password = new_mysql_pw
        # Create-or-update the MySQL account
        try:
            conn = await get_admin_connection()
            async with conn:
                async with conn.cursor() as cur:
                    # CREATE IF NOT EXISTS handles users who slipped through without a MySQL account
                    await cur.execute(
                        f"CREATE USER IF NOT EXISTS '{user.username}'@'%%' IDENTIFIED BY %s",
                        (new_mysql_pw,),
                    )
                    await cur.execute(
                        f"ALTER USER '{user.username}'@'%%' IDENTIFIED BY %s",
                        (new_mysql_pw,),
                    )
                    await cur.execute("FLUSH PRIVILEGES")
        except Exception as e:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                f"App user updated but MySQL password sync failed: {e}",
            )

    await session.commit()
    await session.refresh(user)
    result = UserOut.model_validate(user).model_dump(mode="json")
    if body.password:
        ssh = await ssh_sync.sync_create(user.username, body.password)
        if not ssh.get("ok") and not ssh.get("skipped"):
            log.warning("SSH sync failed for user %s: %s", user.username, ssh.get("error"))
            result["ssh_sync_warning"] = ssh.get("error")
    return result


@router.delete("/{user_id}")
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

    # Drop matching MySQL user account (best-effort)
    try:
        conn = await get_admin_connection()
        async with conn:
            async with conn.cursor() as cur:
                await cur.execute(f"DROP USER IF EXISTS '{username}'@'%'")
                await cur.execute("FLUSH PRIVILEGES")
    except Exception:
        pass

    result: dict = {"ok": True}
    ssh = await ssh_sync.sync_delete(username)
    if not ssh.get("ok") and not ssh.get("skipped"):
        log.warning("SSH sync delete failed for %s: %s", username, ssh.get("error"))
        result["ssh_sync_warning"] = ssh.get("error")
    return result
