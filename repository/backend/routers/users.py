from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from core.database import get_admin_connection, get_session
from core.security import hash_password
from models.user import User
from routers.auth import require_admin
from schemas.user import UserCreate, UserOut, UserUpdate

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

    user = User(
        username=body.username,
        password_hash=hash_password(body.password),
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
                        f"CREATE USER IF NOT EXISTS '{body.username}'@'%%' IDENTIFIED BY %s",
                        (body.mysql_password,),
                    )
                    await cur.execute("FLUSH PRIVILEGES")
        except Exception as e:
            raise HTTPException(
                status.HTTP_500_INTERNAL_SERVER_ERROR,
                f"App user created but MySQL user creation failed: {e}",
            )

    return UserOut.model_validate(user).model_dump(mode="json")


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
    if body.mysql_password:
        user.mysql_password = body.mysql_password
        # Update MySQL account password as well
        try:
            conn = await get_admin_connection()
            async with conn:
                async with conn.cursor() as cur:
                    await cur.execute(
                        f"ALTER USER IF EXISTS '{user.username}'@'%%' IDENTIFIED BY %s",
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
    return UserOut.model_validate(user).model_dump(mode="json")


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
                await cur.execute(f"DROP USER IF EXISTS '{username}'@'%%'")
                await cur.execute("FLUSH PRIVILEGES")
    except Exception:
        pass

    return {"ok": True}
