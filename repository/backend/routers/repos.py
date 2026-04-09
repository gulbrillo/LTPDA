import re
from pathlib import Path

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import AsyncSession

from core.config import get_config
from core.database import get_admin_connection, get_session
from models.repo import AvailableDb
from models.user import User
from routers.auth import get_current_user, require_admin
from schemas.repo import AccessEntry, GrantRequest, RepoCreate, RepoOut, RepoUpdate

router = APIRouter(prefix="/api/repos", tags=["repos"])

_DB_NAME_RE = re.compile(r"^[a-z0-9_]+$")
_SCHEMA_FILE = Path("/app/aorepo_db.sql")


def _validate_db_name(db_name: str) -> None:
    if not _DB_NAME_RE.match(db_name):
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            "db_name must contain only lowercase letters, digits, and underscores",
        )


async def _obj_count(db_name: str) -> int:
    try:
        conn = await get_admin_connection()
        async with conn:
            async with conn.cursor() as cur:
                await cur.execute(f"SELECT COUNT(*) FROM `{db_name}`.objs")
                row = await cur.fetchone()
                return row[0] if row else 0
    except Exception:
        return 0


# ── Repository CRUD ────────────────────────────────────────────────────────────

@router.get("", response_model=list[RepoOut])
async def list_repos(
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    if current.is_admin:
        result = await session.execute(
            select(AvailableDb).order_by(AvailableDb.name)
        )
        repos = list(result.scalars().all())
    else:
        # Find which databases this user has SELECT access to
        conn = await get_admin_connection()
        async with conn:
            async with conn.cursor() as cur:
                await cur.execute(
                    "SELECT Db FROM mysql.db WHERE User = %s AND Select_priv = 'Y'",
                    (current.username,),
                )
                rows = await cur.fetchall()
        accessible = {r[0] for r in rows}
        if not accessible:
            return []
        result = await session.execute(
            select(AvailableDb)
            .where(AvailableDb.db_name.in_(accessible))
            .order_by(AvailableDb.name)
        )
        repos = list(result.scalars().all())

    out = []
    for repo in repos:
        count = await _obj_count(repo.db_name)
        d = RepoOut.model_validate(repo)
        d.obj_count = count
        out.append(d)
    return out


@router.post("", status_code=status.HTTP_201_CREATED, response_model=RepoOut)
async def create_repo(
    body: RepoCreate,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(body.db_name)

    existing = await session.execute(
        select(AvailableDb).where(AvailableDb.db_name == body.db_name)
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status.HTTP_409_CONFLICT, "Repository already exists")

    cfg = get_config()
    admin_db = cfg["admin_db"]

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            # Create the database
            await cur.execute(
                f"CREATE DATABASE `{body.db_name}` CHARACTER SET utf8 COLLATE utf8_general_ci"
            )
            await cur.execute(f"USE `{body.db_name}`")

            # Execute the v2.5 schema (aorepo_db.sql)
            schema_sql = _SCHEMA_FILE.read_text()
            for stmt in schema_sql.split(";"):
                stmt = stmt.strip()
                if stmt:
                    await cur.execute(stmt)

            # Create the users VIEW (MATLAB compatibility — queries this view internally)
            await cur.execute(
                f"CREATE VIEW `{body.db_name}`.`users` "
                f"AS SELECT id, username FROM `{admin_db}`.users"
            )

    # Register in available_dbs
    repo = AvailableDb(
        db_name=body.db_name,
        name=body.name,
        description=body.description,
        version=2,
    )
    session.add(repo)
    await session.commit()
    await session.refresh(repo)

    out = RepoOut.model_validate(repo)
    out.obj_count = 0
    return out


@router.get("/{db_name}", response_model=RepoOut)
async def get_repo(
    db_name: str,
    current: User = Depends(get_current_user),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(db_name)

    result = await session.execute(
        select(AvailableDb).where(AvailableDb.db_name == db_name)
    )
    repo = result.scalar_one_or_none()
    if not repo:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Repository not found")

    if not current.is_admin:
        conn = await get_admin_connection()
        async with conn:
            async with conn.cursor() as cur:
                await cur.execute(
                    "SELECT Select_priv FROM mysql.db WHERE User = %s AND Db = %s AND Host = '%%'",
                    (current.username, db_name),
                )
                row = await cur.fetchone()
        if not row or row[0] != "Y":
            raise HTTPException(status.HTTP_403_FORBIDDEN, "Access denied")

    out = RepoOut.model_validate(repo)
    out.obj_count = await _obj_count(db_name)
    return out


@router.put("/{db_name}", response_model=RepoOut)
async def update_repo(
    db_name: str,
    body: RepoUpdate,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(db_name)

    result = await session.execute(
        select(AvailableDb).where(AvailableDb.db_name == db_name)
    )
    repo = result.scalar_one_or_none()
    if not repo:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Repository not found")

    if body.name is not None:
        repo.name = body.name
    if body.description is not None:
        repo.description = body.description

    await session.commit()
    await session.refresh(repo)

    out = RepoOut.model_validate(repo)
    out.obj_count = await _obj_count(db_name)
    return out


@router.delete("/{db_name}")
async def delete_repo(
    db_name: str,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(db_name)

    result = await session.execute(
        select(AvailableDb).where(AvailableDb.db_name == db_name)
    )
    repo = result.scalar_one_or_none()
    if not repo:
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Repository not found")

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(f"DROP DATABASE IF EXISTS `{db_name}`")
            # Clean up any residual per-database grants from mysql.db
            await cur.execute("DELETE FROM mysql.db WHERE Db = %s", (db_name,))
            await cur.execute("FLUSH PRIVILEGES")

    await session.delete(repo)
    await session.commit()
    return {"ok": True}


# ── Per-repo access management ─────────────────────────────────────────────────

@router.get("/{db_name}/access", response_model=list[AccessEntry])
async def list_access(
    db_name: str,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(db_name)

    # Confirm repo exists
    result = await session.execute(
        select(AvailableDb).where(AvailableDb.db_name == db_name)
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Repository not found")

    cfg = get_config()
    admin_db = cfg["admin_db"]

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(
                f"""
                SELECT u.username,
                       COALESCE(d.Select_priv, 'N') AS can_read,
                       COALESCE(d.Insert_priv, 'N') AS can_write
                FROM `{admin_db}`.users u
                LEFT JOIN mysql.db d
                       ON d.User = u.username AND d.Db = %s AND d.Host = '%%'
                ORDER BY u.username
                """,
                (db_name,),
            )
            rows = await cur.fetchall()

    return [
        AccessEntry(
            username=r[0],
            can_read=(r[1] == "Y"),
            can_write=(r[2] == "Y"),
        )
        for r in rows
    ]


@router.post("/{db_name}/access/{username}")
async def grant_access(
    db_name: str,
    username: str,
    body: GrantRequest,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(db_name)

    # Confirm repo and user exist
    result = await session.execute(
        select(AvailableDb).where(AvailableDb.db_name == db_name)
    )
    if not result.scalar_one_or_none():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "Repository not found")

    from models.user import User as UserModel
    user_result = await session.execute(
        select(UserModel).where(UserModel.username == username)
    )
    if not user_result.scalar_one_or_none():
        raise HTTPException(status.HTTP_404_NOT_FOUND, "User not found")

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            if body.can_read:
                # SELECT on entire database (for MATLAB to browse objects)
                await cur.execute(
                    f"GRANT SELECT ON `{db_name}`.* TO '{username}'@'%%'"
                )
                # INSERT on transactions always granted alongside SELECT (legacy privs.inc.php behaviour)
                await cur.execute(
                    f"GRANT INSERT ON `{db_name}`.transactions TO '{username}'@'%%'"
                )
                if body.can_write:
                    # INSERT on entire database (for MATLAB to submit new objects)
                    await cur.execute(
                        f"GRANT INSERT ON `{db_name}`.* TO '{username}'@'%%'"
                    )
                else:
                    # Revoke broad INSERT if was previously granted, keep transactions INSERT
                    try:
                        await cur.execute(
                            f"REVOKE INSERT ON `{db_name}`.* FROM '{username}'@'%%'"
                        )
                    except Exception:
                        pass
                    # Re-grant the transactions INSERT after the broad revoke
                    await cur.execute(
                        f"GRANT INSERT ON `{db_name}`.transactions TO '{username}'@'%%'"
                    )
            else:
                # Revoke all access
                try:
                    await cur.execute(
                        f"REVOKE ALL PRIVILEGES ON `{db_name}`.* FROM '{username}'@'%%'"
                    )
                except Exception:
                    pass

            await cur.execute("FLUSH PRIVILEGES")

    return {"ok": True}


@router.delete("/{db_name}/access/{username}")
async def revoke_access(
    db_name: str,
    username: str,
    _: User = Depends(require_admin),
    session: AsyncSession = Depends(get_session),
):
    _validate_db_name(db_name)

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            try:
                await cur.execute(
                    f"REVOKE ALL PRIVILEGES ON `{db_name}`.* FROM '{username}'@'%%'"
                )
            except Exception:
                pass
            await cur.execute("FLUSH PRIVILEGES")

    return {"ok": True}
