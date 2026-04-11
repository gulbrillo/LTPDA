"""
Internal submit logic for the LTPDA repository.

Mirrors the SQL insert sequence in MATLAB's ltpda_uo/submit.m.
Called by LTPDARepository.submit() — not part of the public API.
"""

from __future__ import annotations

import hashlib
import io
import platform
import socket
import uuid as _uuid
from datetime import datetime, timedelta
from typing import TYPE_CHECKING

import h5py

if TYPE_CHECKING:
    from pyda.repo.models import SubmitResult


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _get_hostname() -> str:
    try:
        return socket.gethostname()
    except Exception:
        return "unknown"


def _get_ip() -> str:
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return "127.0.0.1"


def _get_os() -> str:
    return platform.platform()


def _to_hdf5_bytes(obj) -> bytes:
    """Serialize a pyda object to HDF5 bytes in-memory (no temp file)."""
    buf = io.BytesIO()
    with h5py.File(buf, "w", driver="core", backing_store=False) as f:
        obj._add_to_hd5f_structure(f)
    return buf.getvalue()


def _infer_obj_type(obj) -> str:
    """Map a pyda class to the LTPDA obj_type enum value."""
    from pyda.pzmodel import PZModel
    from pyda.tsdata import TSData
    from pyda.fsdata import FSData
    from pyda.xydata import XYData
    from pyda.ydata import YData

    if isinstance(obj, (TSData, FSData, XYData, YData)):
        return "ao"
    if isinstance(obj, PZModel):
        return "pzmodel"
    return "ao"


def _infer_data_type(obj) -> str | None:
    """Map a pyda class to the LTPDA data_type enum value used in the ao table."""
    from pyda.tsdata import TSData
    from pyda.fsdata import FSData
    from pyda.xydata import XYData
    from pyda.ydata import YData

    if isinstance(obj, TSData):
        return "tsdata"
    if isinstance(obj, FSData):
        return "fsdata"
    if isinstance(obj, XYData):
        return "xydata"
    if isinstance(obj, YData):
        return "cdata"
    return None


def _make_keywords(obj, extra_kw: str) -> str:
    """
    Build the keywords string stored in objmeta.keywords.

    When the object is a TSData with a known t0, the timespan is embedded as
    XML in the same format MATLAB uses, so that MATLAB's XPath-based time-range
    search (ExtractValue) will find pyda-submitted objects too.

    Example result:
        "noise, test <ltpda_uoh><timespan><start>2024-01-15 00:00:00</start>
        <stop>2024-01-15 01:00:00</stop></timespan></ltpda_uoh>"
    """
    parts = [extra_kw.strip()] if extra_kw.strip() else []

    from pyda.tsdata import TSData
    if isinstance(obj, TSData) and obj.t0 is not None:
        t_start = obj.t0.strftime("%Y-%m-%d %H:%M:%S")
        t_stop = (obj.t0 + timedelta(seconds=obj.nsecs())).strftime(
            "%Y-%m-%d %H:%M:%S"
        )
        parts.append(
            f"<ltpda_uoh><timespan>"
            f"<start>{t_start}</start>"
            f"<stop>{t_stop}</stop>"
            f"</timespan></ltpda_uoh>"
        )

    return " ".join(parts)


# ---------------------------------------------------------------------------
# Core insert
# ---------------------------------------------------------------------------

def submit_one(cursor, obj, meta: dict, username: str) -> "SubmitResult":
    """
    Insert one pyda object into the repository database.

    Writes to: objs, bobjs, objmeta, ao (if applicable),
    tsdata / fsdata / xydata (if applicable), transactions.

    Returns a SubmitResult with the assigned id and uuid.
    """
    from pyda.repo.models import SubmitResult

    obj_uuid = str(obj.id) if obj.id else str(_uuid.uuid4())
    hdf5_bytes = _to_hdf5_bytes(obj)
    md5_hash = hashlib.md5(hdf5_bytes).hexdigest()  # noqa: S324
    now = datetime.utcnow()

    obj_type = meta.get("obj_type") or _infer_obj_type(obj)
    data_type = meta.get("data_type") or _infer_data_type(obj)

    # 1. objs — sentinel xml value marks this as a pyda binary object
    cursor.execute(
        "INSERT INTO objs (xml, uuid, hash) VALUES (%s, %s, %s)",
        ("binary_pyda", obj_uuid, md5_hash),
    )
    obj_id: int = cursor.lastrowid

    # 2. bobjs — HDF5 binary payload
    cursor.execute(
        "INSERT INTO bobjs (obj_id, mat) VALUES (%s, %s)",
        (obj_id, hdf5_bytes),
    )

    # 3. objmeta — all metadata + system fields
    cursor.execute(
        """
        INSERT INTO objmeta
            (obj_id, obj_type, name, created, version, ip, hostname, os,
             submitted, experiment_title, experiment_desc, analysis_desc,
             quantity, additional_authors, additional_comments,
             keywords, reference_ids, author)
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """,
        (
            obj_id,
            obj_type,
            obj.name,
            now,
            "pyda-0.1.0",
            _get_ip(),
            _get_hostname(),
            _get_os(),
            now,
            meta["experiment_title"],
            meta["experiment_desc"],
            meta["analysis_desc"],
            meta.get("quantity", ""),
            meta.get("additional_authors", ""),
            meta.get("additional_comments", ""),
            _make_keywords(obj, meta.get("keywords", "")),
            meta.get("reference_ids", ""),
            username,
        ),
    )

    # 4. type-specific tables
    if obj_type == "ao":
        cursor.execute(
            "INSERT INTO ao (obj_id, data_type, description) VALUES (%s, %s, %s)",
            (obj_id, data_type, obj.description or ""),
        )

        from pyda.tsdata import TSData
        from pyda.fsdata import FSData
        from pyda.xydata import XYData

        if data_type == "tsdata" and isinstance(obj, TSData):
            t0_dt = obj.t0 if obj.t0 is not None else datetime(1970, 1, 1)
            t0_str = t0_dt.strftime("%Y-%m-%d %H:%M:%S")
            toffset = int((t0_dt.microsecond / 1e6) * 1000)
            cursor.execute(
                """
                INSERT INTO tsdata (obj_id, xunits, yunits, fs, nsecs, t0, toffset)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    obj_id,
                    str(obj.xaxis.units),
                    str(obj.yaxis.units),
                    float(obj.fs()),
                    float(obj.nsecs()),
                    t0_str,
                    toffset,
                ),
            )

        elif data_type == "fsdata" and isinstance(obj, FSData):
            # fs for FSData = highest frequency in x-axis
            f_max = float(obj.xaxis.data[-1]) if len(obj.xaxis.data) > 0 else 0.0
            cursor.execute(
                "INSERT INTO fsdata (obj_id, xunits, yunits, fs) VALUES (%s, %s, %s, %s)",
                (obj_id, str(obj.xaxis.units), str(obj.yaxis.units), f_max),
            )

        elif data_type == "xydata" and isinstance(obj, XYData):
            cursor.execute(
                "INSERT INTO xydata (obj_id, xunits, yunits) VALUES (%s, %s, %s)",
                (obj_id, str(obj.xaxis.units), str(obj.yaxis.units)),
            )

    # 5. transaction log
    cursor.execute(
        "INSERT INTO transactions (obj_id, user_id, transdate, direction) "
        "VALUES (%s, NULL, NOW(), 'submit')",
        (obj_id,),
    )

    return SubmitResult(id=obj_id, uuid=obj_uuid)


# ---------------------------------------------------------------------------
# Collection helpers
# ---------------------------------------------------------------------------

def create_collection(cursor, obj_ids: list[int]) -> int:
    """
    Create a collection entry and link it to the given object IDs.
    Returns the new collection ID (cid).
    Mirrors MATLAB's createCollection() in utils/repository.
    """
    cursor.execute("INSERT INTO collections VALUES ()")
    cid: int = cursor.lastrowid
    cursor.executemany(
        "INSERT INTO collections2objs (id, obj_id) VALUES (%s, %s)",
        [(cid, oid) for oid in obj_ids],
    )
    return cid
