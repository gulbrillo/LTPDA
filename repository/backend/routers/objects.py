import re
from datetime import datetime, timedelta

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.responses import Response

from core.config import get_config
from core.database import get_admin_connection
from models.user import User
from routers.auth import get_current_user, require_admin
from schemas.repo import (
    DeleteObjectsRequest,
    ObjectDetail,
    ObjectListItem,
    ObjectListResponse,
    TransactionEntry,
    TypeDataCdata,
    TypeDataFilter,
    TypeDataFsdata,
    TypeDataTsdata,
    TypeDataXydata,
)

router = APIRouter(prefix="/api/repos/{db_name}/objects", tags=["objects"])

_DB_NAME_RE = re.compile(r"^[a-z0-9_]+$")

OBJ_TYPE_CHOICES = [
    "ao", "collection", "filterbank", "matrix", "mfir", "miir",
    "parfrac", "pest", "plist", "pzmodel", "rational", "smodel", "ssm", "timespan",
]


def _validate_db_name(db_name: str) -> None:
    if not _DB_NAME_RE.match(db_name):
        raise HTTPException(
            status.HTTP_422_UNPROCESSABLE_ENTITY,
            "db_name must contain only lowercase letters, digits, and underscores",
        )


async def _check_access(db_name: str, user: User) -> None:
    """Raise 403 if user has no SELECT grant on this database (admins always pass)."""
    if user.is_admin:
        return
    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(
                "SELECT Select_priv FROM mysql.db WHERE User = %s AND Db = %s AND Host = '%%'",
                (user.username, db_name),
            )
            row = await cur.fetchone()
    if not row or row[0] != "Y":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Access denied")


# ── List / search objects ──────────────────────────────────────────────────────

@router.get("", response_model=ObjectListResponse)
async def list_objects(
    db_name: str,
    name: str | None = None,
    obj_type: str | None = None,
    author: str | None = None,
    date_from: str | None = None,
    date_to: str | None = None,
    page: int = 1,
    page_size: int = 50,
    current: User = Depends(get_current_user),
):
    _validate_db_name(db_name)
    await _check_access(db_name, current)

    if page < 1:
        page = 1
    if page_size < 1 or page_size > 200:
        page_size = 50
    offset = (page - 1) * page_size

    conditions = ["1=1"]
    params: list = []

    if name:
        conditions.append("m.name LIKE %s")
        params.append(f"%{name}%")
    if obj_type:
        conditions.append("m.obj_type = %s")
        params.append(obj_type)
    if author:
        conditions.append("m.author LIKE %s")
        params.append(f"%{author}%")
    if date_from:
        conditions.append("m.submitted >= %s")
        params.append(date_from)
    if date_to:
        conditions.append("m.submitted <= %s")
        params.append(date_to)

    where = " AND ".join(conditions)

    base_query = f"""
        FROM `{db_name}`.objs o
        LEFT JOIN `{db_name}`.objmeta m ON o.id = m.obj_id
        LEFT JOIN `{db_name}`.ao a ON o.id = a.obj_id
        LEFT JOIN `{db_name}`.bobjs b ON o.id = b.obj_id
        WHERE {where}
    """

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(f"SELECT COUNT(*) {base_query}", params)
            total_row = await cur.fetchone()
            total = total_row[0] if total_row else 0

            await cur.execute(
                f"""
                SELECT o.id, m.obj_type, m.name, m.author, m.submitted,
                       a.data_type,
                       (b.obj_id IS NOT NULL) AS has_binary
                {base_query}
                ORDER BY m.submitted DESC
                LIMIT %s OFFSET %s
                """,
                params + [page_size, offset],
            )
            rows = await cur.fetchall()

    items = [
        ObjectListItem(
            id=r[0],
            obj_type=r[1],
            name=r[2],
            author=r[3],
            submitted=r[4],
            data_type=r[5],
            has_binary=bool(r[6]),
        )
        for r in rows
    ]
    return ObjectListResponse(items=items, total=total, page=page, page_size=page_size)


# ── Object detail ──────────────────────────────────────────────────────────────

@router.get("/{obj_id}", response_model=ObjectDetail)
async def get_object(
    db_name: str,
    obj_id: int,
    current: User = Depends(get_current_user),
):
    _validate_db_name(db_name)
    await _check_access(db_name, current)

    cfg = get_config()
    admin_db = cfg["admin_db"]

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            # Core metadata
            await cur.execute(
                f"""
                SELECT obj_type, name, created, version, ip, hostname, os,
                       submitted, experiment_title, experiment_desc, analysis_desc,
                       quantity, additional_authors, additional_comments, keywords,
                       reference_ids, validated, vdate, author
                FROM `{db_name}`.objmeta WHERE obj_id = %s
                """,
                (obj_id,),
            )
            meta = await cur.fetchone()
            if not meta:
                raise HTTPException(status.HTTP_404_NOT_FOUND, "Object not found")

            (obj_type, name, created, version, ip, hostname, os_,
             submitted, experiment_title, experiment_desc, analysis_desc,
             quantity, additional_authors, additional_comments, keywords,
             reference_ids, validated, vdate, author) = meta

            # has_xml: xml column starts with 'binary' means only .mat is available
            await cur.execute(
                f"SELECT SUBSTR(xml, 1, 6) FROM `{db_name}`.objs WHERE id = %s",
                (obj_id,),
            )
            xml_prefix = await cur.fetchone()
            has_xml = bool(
                xml_prefix
                and xml_prefix[0]
                and xml_prefix[0].lower() != "binary"
            )

            # has_binary
            await cur.execute(
                f"SELECT COUNT(*) FROM `{db_name}`.bobjs WHERE obj_id = %s",
                (obj_id,),
            )
            brow = await cur.fetchone()
            has_binary = bool(brow and brow[0] > 0)

            # Type-specific sub-table
            data_type = None
            type_data = None

            if obj_type == "ao":
                await cur.execute(
                    f"SELECT data_type FROM `{db_name}`.ao WHERE obj_id = %s",
                    (obj_id,),
                )
                ao_row = await cur.fetchone()
                if ao_row:
                    data_type = ao_row[0]

                    if data_type == "tsdata":
                        await cur.execute(
                            f"""
                            SELECT xunits, yunits, fs, nsecs, t0,
                                   DATE_SUB(t0, INTERVAL ROUND(toffset / 1000) SECOND) AS t0_adjusted,
                                   toffset
                            FROM `{db_name}`.tsdata WHERE obj_id = %s
                            """,
                            (obj_id,),
                        )
                        td = await cur.fetchone()
                        if td:
                            type_data = TypeDataTsdata(
                                xunits=td[0], yunits=td[1], fs=td[2],
                                nsecs=td[3], t0=td[4], t0_adjusted=td[5],
                                toffset=td[6],
                            )

                    elif data_type == "fsdata":
                        await cur.execute(
                            f"SELECT xunits, yunits, fs FROM `{db_name}`.fsdata WHERE obj_id = %s",
                            (obj_id,),
                        )
                        td = await cur.fetchone()
                        if td:
                            type_data = TypeDataFsdata(xunits=td[0], yunits=td[1], fs=td[2])

                    elif data_type == "xydata":
                        await cur.execute(
                            f"SELECT xunits, yunits FROM `{db_name}`.xydata WHERE obj_id = %s",
                            (obj_id,),
                        )
                        td = await cur.fetchone()
                        if td:
                            type_data = TypeDataXydata(xunits=td[0], yunits=td[1])

                    elif data_type == "cdata":
                        await cur.execute(
                            f"SELECT yunits FROM `{db_name}`.cdata WHERE obj_id = %s",
                            (obj_id,),
                        )
                        td = await cur.fetchone()
                        if td:
                            type_data = TypeDataCdata(yunits=td[0])

            elif obj_type in ("mfir", "miir"):
                table = obj_type
                await cur.execute(
                    f"SELECT in_file, fs FROM `{db_name}`.`{table}` WHERE obj_id = %s",
                    (obj_id,),
                )
                td = await cur.fetchone()
                if td:
                    type_data = TypeDataFilter(in_file=td[0], fs=td[1])

            # Transaction history (last 15)
            await cur.execute(
                f"""
                SELECT u.username, t.transdate, t.direction
                FROM `{admin_db}`.users u
                JOIN `{db_name}`.transactions t ON u.id = t.user_id
                WHERE t.obj_id = %s
                ORDER BY t.transdate DESC
                LIMIT 15
                """,
                (obj_id,),
            )
            tx_rows = await cur.fetchall()

    transactions = [
        TransactionEntry(username=r[0], transdate=r[1], direction=r[2])
        for r in tx_rows
    ]

    return ObjectDetail(
        id=obj_id,
        obj_type=obj_type,
        name=name,
        author=author,
        created=created,
        version=version,
        ip=ip,
        hostname=hostname,
        os=os_,
        submitted=submitted,
        experiment_title=experiment_title,
        experiment_desc=experiment_desc,
        analysis_desc=analysis_desc,
        quantity=quantity,
        additional_authors=additional_authors,
        additional_comments=additional_comments,
        keywords=keywords,
        reference_ids=reference_ids,
        validated=validated,
        vdate=vdate,
        has_xml=has_xml,
        has_binary=has_binary,
        data_type=data_type,
        type_data=type_data,
        transactions=transactions,
    )


# ── Delete objects ─────────────────────────────────────────────────────────────

@router.delete("")
async def delete_objects(
    db_name: str,
    body: DeleteObjectsRequest,
    current: User = Depends(require_admin),
):
    _validate_db_name(db_name)

    cfg = get_config()
    admin_db = cfg["admin_db"]

    # Look up numeric user id for transaction logging
    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(
                f"SELECT id FROM `{admin_db}`.users WHERE username = %s",
                (current.username,),
            )
            uid_row = await cur.fetchone()
            user_id = uid_row[0] if uid_row else None

            for obj_id in body.ids:
                # Log before delete (transaction record survives the CASCADE)
                await cur.execute(
                    f"INSERT INTO `{db_name}`.transactions "
                    f"(obj_id, user_id, transdate, direction) "
                    f"VALUES (%s, %s, NOW(), 'delete')",
                    (obj_id, user_id),
                )
                # CASCADE on objs deletes objmeta, bobjs, ao, cdata, tsdata, etc.
                await cur.execute(
                    f"DELETE FROM `{db_name}`.objs WHERE id = %s",
                    (obj_id,),
                )

    return {"ok": True, "deleted": len(body.ids)}


# ── Download XML ───────────────────────────────────────────────────────────────

@router.get("/{obj_id}/xml")
async def download_xml(
    db_name: str,
    obj_id: int,
    current: User = Depends(get_current_user),
):
    _validate_db_name(db_name)
    await _check_access(db_name, current)

    cfg = get_config()
    admin_db = cfg["admin_db"]

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(
                f"SELECT xml FROM `{db_name}`.objs WHERE id = %s",
                (obj_id,),
            )
            row = await cur.fetchone()
            if not row or not row[0]:
                raise HTTPException(status.HTTP_404_NOT_FOUND, "XML not available")

            xml_data = row[0]
            if isinstance(xml_data, str) and xml_data.lower().startswith("binary"):
                raise HTTPException(status.HTTP_404_NOT_FOUND, "XML not available for binary-only object")

            # Look up user_id for transaction log
            await cur.execute(
                f"SELECT id FROM `{admin_db}`.users WHERE username = %s",
                (current.username,),
            )
            uid_row = await cur.fetchone()
            user_id = uid_row[0] if uid_row else None

            await cur.execute(
                f"INSERT INTO `{db_name}`.transactions "
                f"(obj_id, user_id, transdate, direction) VALUES (%s, %s, NOW(), 'download')",
                (obj_id, user_id),
            )

    content = xml_data.encode() if isinstance(xml_data, str) else xml_data
    return Response(
        content=content,
        media_type="text/xml",
        headers={"Content-Disposition": f'attachment; filename="{db_name}_{obj_id}.xml"'},
    )


# ── Download binary (.mat) ─────────────────────────────────────────────────────

@router.get("/{obj_id}/binary")
async def download_binary(
    db_name: str,
    obj_id: int,
    current: User = Depends(get_current_user),
):
    _validate_db_name(db_name)
    await _check_access(db_name, current)

    cfg = get_config()
    admin_db = cfg["admin_db"]

    conn = await get_admin_connection()
    async with conn:
        async with conn.cursor() as cur:
            await cur.execute(
                f"SELECT mat FROM `{db_name}`.bobjs WHERE obj_id = %s",
                (obj_id,),
            )
            row = await cur.fetchone()
            if not row or row[0] is None:
                raise HTTPException(status.HTTP_404_NOT_FOUND, "Binary data not available")

            mat_data = row[0]

            await cur.execute(
                f"SELECT id FROM `{admin_db}`.users WHERE username = %s",
                (current.username,),
            )
            uid_row = await cur.fetchone()
            user_id = uid_row[0] if uid_row else None

            await cur.execute(
                f"INSERT INTO `{db_name}`.transactions "
                f"(obj_id, user_id, transdate, direction) VALUES (%s, %s, NOW(), 'download')",
                (obj_id, user_id),
            )

    return Response(
        content=bytes(mat_data) if not isinstance(mat_data, bytes) else mat_data,
        media_type="application/octet-stream",
        headers={"Content-Disposition": f'attachment; filename="{db_name}_{obj_id}.mat"'},
    )
