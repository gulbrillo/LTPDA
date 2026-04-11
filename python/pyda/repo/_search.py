"""
Search, find, and utility queries for the LTPDA repository.

Mirrors the functions in MATLAB's utils/repository/:
    search(), getLatestObject(), findDuplicates(), getObjectMetaData(),
    getUUIDfromID(), getIDfromUUID(), report().

Called by LTPDARepository — not part of the public API.
"""

from __future__ import annotations

import csv
from datetime import datetime
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from pyda.repo.models import ObjectMeta, SearchResult


# ---------------------------------------------------------------------------
# Search / find
# ---------------------------------------------------------------------------

def find(
    cursor,
    name: str = "%",
    timespan: tuple | None = None,
    author: str | None = None,
    date_from: str | datetime | None = None,
    date_to: str | datetime | None = None,
    obj_type: str | None = None,
) -> list["SearchResult"]:
    """
    Search the repository for objects matching the given criteria.

    Mirrors MATLAB's utils.repository.search().

    name
        SQL LIKE pattern applied to objmeta.name (default ``'%'`` = all).
    timespan
        ``(t0, t1)`` — only return objects whose stored timespan overlaps
        the requested interval.  Uses MySQL's ``ExtractValue`` on the XML
        embedded in the keywords field (same approach as MATLAB).
    author
        LIKE pattern applied to objmeta.author.
    date_from / date_to
        ISO date strings or datetime objects to filter by submission date.
    obj_type
        Exact match on objmeta.obj_type ('ao', 'pzmodel', …).
    """
    from pyda.repo.models import SearchResult

    conditions = ["m.name LIKE %s"]
    params: list = [name]

    if author:
        conditions.append("m.author LIKE %s")
        params.append(f"%{author}%")
    if obj_type:
        conditions.append("m.obj_type = %s")
        params.append(obj_type)
    if date_from:
        conditions.append("m.submitted >= %s")
        params.append(str(date_from))
    if date_to:
        conditions.append("m.submitted <= %s")
        params.append(str(date_to))

    if timespan is not None:
        t0, t1 = timespan
        # Three-condition overlap check — same XPath as MATLAB:
        #   object starts before t1 AND object ends after t0
        conditions.append(
            "(ExtractValue(m.keywords, '/ltpda_uoh/timespan/start') <= %s "
            "AND ExtractValue(m.keywords, '/ltpda_uoh/timespan/stop') >= %s)"
        )
        params.append(str(t1))
        params.append(str(t0))

    cursor.execute(
        f"""
        SELECT o.id, o.uuid, m.name, m.experiment_title, m.submitted,
               ExtractValue(m.keywords, '/ltpda_uoh/timespan/start') AS t_start,
               ExtractValue(m.keywords, '/ltpda_uoh/timespan/stop')  AS t_stop
        FROM   objs o
        LEFT JOIN objmeta m ON m.obj_id = o.id
        WHERE  {" AND ".join(conditions)}
        ORDER  BY m.submitted DESC
        """,
        params,
    )

    results = []
    for row in cursor.fetchall():
        t_start = _parse_dt(row["t_start"])
        t_stop = _parse_dt(row["t_stop"])
        results.append(
            SearchResult(
                id=row["id"],
                uuid=row["uuid"],
                name=row["name"],
                experiment_title=row["experiment_title"],
                submitted=row["submitted"],
                t_start=t_start,
                t_stop=t_stop,
            )
        )
    return results


# ---------------------------------------------------------------------------
# Metadata retrieval (no binary download)
# ---------------------------------------------------------------------------

def get_metadata(cursor, *ids: int) -> list["ObjectMeta"]:
    """
    Retrieve full metadata for one or more object IDs without downloading
    the binary payload.  Returns a list of ObjectMeta dataclasses.
    Mirrors MATLAB's utils.repository.getObjectMetaData().
    """
    from pyda.repo.models import ObjectMeta

    if not ids:
        return []

    placeholders = ", ".join(["%s"] * len(ids))
    cursor.execute(
        f"""
        SELECT
            o.id, o.uuid,
            m.obj_type, m.name, m.author, m.created, m.submitted,
            m.experiment_title, m.experiment_desc, m.analysis_desc,
            m.quantity, m.keywords, m.reference_ids,
            m.additional_comments, m.additional_authors,
            m.validated,
            (SELECT COUNT(*) FROM bobjs b WHERE b.obj_id = o.id) AS has_binary,
            a.data_type,
            t.fs    AS ts_fs,    t.nsecs AS ts_nsecs,
            t.t0    AS ts_t0,    t.xunits AS ts_xunits, t.yunits AS ts_yunits,
            fs.fs   AS fs_fs,    fs.xunits AS fs_xunits, fs.yunits AS fs_yunits
        FROM   objs o
        LEFT JOIN objmeta m  ON m.obj_id  = o.id
        LEFT JOIN ao      a  ON a.obj_id  = o.id
        LEFT JOIN tsdata  t  ON t.obj_id  = o.id
        LEFT JOIN fsdata  fs ON fs.obj_id = o.id
        WHERE  o.id IN ({placeholders})
        """,
        ids,
    )

    results = []
    for row in cursor.fetchall():
        data_type = row["data_type"]
        if data_type == "tsdata":
            fs_val    = row["ts_fs"]
            nsecs_val = row["ts_nsecs"]
            t0_val    = row["ts_t0"]
            xunits    = row["ts_xunits"]
            yunits    = row["ts_yunits"]
        elif data_type == "fsdata":
            fs_val    = row["fs_fs"]
            nsecs_val = None
            t0_val    = None
            xunits    = row["fs_xunits"]
            yunits    = row["fs_yunits"]
        else:
            fs_val = nsecs_val = t0_val = xunits = yunits = None

        results.append(
            ObjectMeta(
                id=row["id"],
                uuid=row["uuid"],
                obj_type=row["obj_type"],
                data_type=data_type,
                name=row["name"],
                author=row["author"],
                created=row["created"],
                submitted=row["submitted"],
                experiment_title=row["experiment_title"],
                experiment_desc=row["experiment_desc"],
                analysis_desc=row["analysis_desc"],
                quantity=row["quantity"],
                keywords=row["keywords"],
                reference_ids=row["reference_ids"],
                additional_comments=row["additional_comments"],
                additional_authors=row["additional_authors"],
                validated=bool(row["validated"]),
                has_binary=bool(row["has_binary"]),
                fs=float(fs_val) if fs_val is not None else None,
                nsecs=float(nsecs_val) if nsecs_val is not None else None,
                t0=t0_val if isinstance(t0_val, datetime) else _parse_dt(str(t0_val)) if t0_val else None,
                xunits=xunits,
                yunits=yunits,
            )
        )
    return results


# ---------------------------------------------------------------------------
# get_latest
# ---------------------------------------------------------------------------

def get_latest(cursor, name: str) -> "ObjectMeta | None":
    """
    Return the ObjectMeta for the tsdata object with the most recent end
    time (t0 + nsecs) matching *name*.

    Mirrors MATLAB's utils.repository.getLatestObject().
    """
    cursor.execute(
        """
        SELECT m.obj_id
        FROM   objmeta m
        JOIN   ao      a ON a.obj_id = m.obj_id
        JOIN   tsdata  t ON t.obj_id = m.obj_id
        WHERE  m.name LIKE %s
        ORDER  BY DATE_ADD(t.t0, INTERVAL t.nsecs SECOND) DESC
        LIMIT  1
        """,
        (name,),
    )
    row = cursor.fetchone()
    if row is None:
        return None
    results = get_metadata(cursor, row["obj_id"])
    return results[0] if results else None


# ---------------------------------------------------------------------------
# Duplicate detection
# ---------------------------------------------------------------------------

def find_duplicates(cursor) -> list[tuple[int, str]]:
    """
    Return (id, uuid) pairs for objects whose UUID appears more than once.
    Mirrors MATLAB's utils.repository.findDuplicates().
    """
    cursor.execute(
        """
        SELECT o.id, o.uuid
        FROM   objs o
        WHERE  o.uuid IN (
            SELECT uuid FROM objs
            GROUP BY uuid
            HAVING COUNT(*) > 1
        )
        ORDER  BY o.uuid, o.id
        """
    )
    return [(row["id"], row["uuid"]) for row in cursor.fetchall()]


# ---------------------------------------------------------------------------
# ID ↔ UUID conversions
# ---------------------------------------------------------------------------

def get_uuid(cursor, obj_id: int) -> str:
    """Return the UUID for the given object ID."""
    cursor.execute("SELECT uuid FROM objs WHERE id = %s", (obj_id,))
    row = cursor.fetchone()
    if row is None:
        raise ValueError(f"Object {obj_id} not found.")
    return row["uuid"]


def get_id(cursor, uuid: str) -> int:
    """Return the integer ID for the given UUID."""
    cursor.execute("SELECT id FROM objs WHERE uuid = %s", (uuid,))
    row = cursor.fetchone()
    if row is None:
        raise ValueError(f"No object with UUID {uuid!r}.")
    return row["id"]


# ---------------------------------------------------------------------------
# List databases
# ---------------------------------------------------------------------------

def list_databases(cursor) -> list[str]:
    """
    Return the names of all databases visible to the current MySQL user.
    Mirrors MATLAB's utils.repository.listDatabases().
    """
    cursor.execute("SHOW DATABASES")
    return [row[next(iter(row))] for row in cursor.fetchall()]


# ---------------------------------------------------------------------------
# CSV report
# ---------------------------------------------------------------------------

def report(
    cursor,
    filename: str,
    date_from: str | datetime | None = None,
    date_to: str | datetime | None = None,
    max_rows: int = 10_000,
) -> None:
    """
    Dump object metadata to a CSV file.
    Mirrors MATLAB's utils.repository.report().

    filename
        Path to write the CSV file.
    date_from / date_to
        Optional ISO strings or datetimes to filter by submission date.
    max_rows
        Safety cap on the number of rows written (default 10 000).
    """
    conditions = ["1=1"]
    params: list = []
    if date_from:
        conditions.append("m.submitted >= %s")
        params.append(str(date_from))
    if date_to:
        conditions.append("m.submitted <= %s")
        params.append(str(date_to))

    cursor.execute(
        f"""
        SELECT
            o.id, o.uuid,
            m.obj_type, m.name, m.author,
            m.created, m.submitted,
            m.experiment_title, m.experiment_desc, m.analysis_desc,
            m.quantity, m.keywords, m.additional_comments,
            a.data_type,
            t.fs, t.nsecs, t.t0, t.xunits AS xunits, t.yunits AS yunits
        FROM   objs o
        LEFT JOIN objmeta m  ON m.obj_id  = o.id
        LEFT JOIN ao      a  ON a.obj_id  = o.id
        LEFT JOIN tsdata  t  ON t.obj_id  = o.id
        WHERE  {" AND ".join(conditions)}
        ORDER  BY m.submitted DESC
        LIMIT  %s
        """,
        params + [max_rows],
    )
    rows = cursor.fetchall()

    if not rows:
        print(f"No objects found; CSV not written.")
        return

    with open(filename, "w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)

    print(f"Report written to {filename} ({len(rows)} rows).")


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _parse_dt(s: str | None) -> datetime | None:
    """Parse a datetime string returned by MySQL ExtractValue / queries."""
    if not s:
        return None
    try:
        return datetime.fromisoformat(str(s))
    except (ValueError, TypeError):
        return None
