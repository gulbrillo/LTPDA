"""
Internal retrieve logic for the LTPDA repository.

Mirrors MATLAB's ltpda_uo/retrieve.m and getObjectIdInTimespan().
Called by LTPDARepository — not part of the public API.
"""

from __future__ import annotations

import io
from datetime import datetime
from typing import TYPE_CHECKING

import numpy

if TYPE_CHECKING:
    pass

# HDF5 magic bytes (first 8 bytes of every HDF5 file)
_HDF5_MAGIC = b"\x89HDF\r\n\x1a\n"

# Top-level group names written by pyda's _add_to_hd5f_structure methods
_PYDA_GROUPS = {"YData", "XYData"}


# ---------------------------------------------------------------------------
# Binary format detection and loading
# ---------------------------------------------------------------------------

def _load_binary(data: bytes):
    """
    Detect the binary format and deserialize into a pyda object.

    Priority:
    1. HDF5 with a recognised pyda group → load as the appropriate pyda class.
    2. HDF5 without a pyda group → MATLAB v7.3 .mat (HDF5-based); best-effort
       via scipy.io.loadmat.
    3. Starts with 'MATLAB 5.0 MAT-file' → MATLAB v5 .mat; best-effort via
       scipy.io.loadmat.
    4. Otherwise → ValueError.
    """
    if data[:8] == _HDF5_MAGIC:
        buf = io.BytesIO(data)
        import h5py
        with h5py.File(buf, "r") as f:
            top_keys = set(f.keys())
        if top_keys & _PYDA_GROUPS:
            return _load_pyda_hdf5(data)
        else:
            return _load_matlab_mat(data)
    elif data[:10].startswith(b"MATLAB 5.0"):
        return _load_matlab_mat(data)
    else:
        raise ValueError(
            "Unknown binary format — cannot deserialize. "
            "Expected HDF5 (pyda or MATLAB v7.3) or MATLAB v5 .mat."
        )


def _load_pyda_hdf5(data: bytes):
    """Load a pyda-serialized HDF5 blob and return the correct pyda object."""
    import h5py
    from pyda.tsdata import TSData
    from pyda.fsdata import FSData
    from pyda.xydata import XYData
    from pyda.ydata import YData

    buf = io.BytesIO(data)
    with h5py.File(buf, "r") as f:
        if "XYData" in f:
            pyda_class = f["XYData"].attrs.get("pyda_class", "XYData")
            if pyda_class == "TSData":
                return TSData._from_hd5f_structure(f)
            elif pyda_class == "FSData":
                return FSData._from_hd5f_structure(f)
            else:
                return XYData._from_hd5f_structure(f)
        elif "YData" in f:
            return YData._from_hd5f_structure(f)
        else:
            raise ValueError("Unrecognised pyda HDF5 structure — cannot load.")


def _load_matlab_mat(data: bytes):
    """
    Best-effort loading of a MATLAB .mat file using scipy.io.loadmat.

    Works reliably for simple numeric data stored in MATLAB structs.
    Complex LTPDA class hierarchies (ao, tsdata, etc.) may not reconstruct
    correctly — full MATLAB XML deserialization is future work.
    """
    import scipy.io

    buf = io.BytesIO(data)
    try:
        mat = scipy.io.loadmat(buf)
        return mat
    except Exception as exc:
        raise ValueError(
            f"Failed to load MATLAB .mat binary: {exc}\n"
            "For MATLAB-submitted LTPDA objects, use binary=False to retrieve "
            "the XML representation instead (XML deserialization is not yet "
            "implemented and will raise NotImplementedError)."
        ) from exc


# ---------------------------------------------------------------------------
# Single-object retrieval
# ---------------------------------------------------------------------------

def retrieve_one(cursor, obj_id: int, binary: bool = True):
    """
    Retrieve one object from the repository by its ID.

    binary=True (default): download the HDF5 binary from bobjs.
    binary=False: download the XML from objs (MATLAB objects only;
                  raises NotImplementedError for pyda XML stubs).
    """
    if binary:
        cursor.execute(
            "SELECT mat FROM bobjs WHERE obj_id = %s", (obj_id,)
        )
        row = cursor.fetchone()
        if row is None:
            raise ValueError(
                f"Object {obj_id} has no binary data in bobjs. "
                "Try binary=False to retrieve the XML representation."
            )
        data = bytes(row["mat"])
        return _load_binary(data)

    else:
        cursor.execute("SELECT xml FROM objs WHERE id = %s", (obj_id,))
        row = cursor.fetchone()
        if row is None:
            raise ValueError(f"Object {obj_id} not found.")
        xml = row["xml"]
        if not xml or str(xml).startswith("binary"):
            raise ValueError(
                f"Object {obj_id} has no XML representation. Use binary=True."
            )
        raise NotImplementedError(
            "XML deserialization is not yet implemented. "
            "Use binary=True (works for pyda-submitted objects)."
        )


# ---------------------------------------------------------------------------
# Collection retrieval
# ---------------------------------------------------------------------------

def get_collection_ids(cursor, cid: int) -> list[int]:
    """
    Return the object IDs that belong to a collection.
    Supports both the current (collections2objs) and legacy (CSV string) schemas.
    Mirrors MATLAB's getCollectionIDs().
    """
    # New schema: collections2objs table
    cursor.execute(
        "SELECT obj_id FROM collections2objs WHERE id = %s ORDER BY obj_id",
        (cid,),
    )
    rows = cursor.fetchall()
    if rows:
        return [r["obj_id"] for r in rows]

    # Legacy schema: collections table with a string column of CSV ids
    # (rarely encountered in practice with v3 repos, kept for compatibility)
    cursor.execute("SELECT * FROM collections WHERE id = %s", (cid,))
    row = cursor.fetchone()
    if row is None:
        raise ValueError(f"Collection {cid} not found.")

    # Try to find a string column with comma-separated IDs
    for val in row.values():
        if isinstance(val, str) and "," in val:
            return [int(x.strip()) for x in val.split(",") if x.strip().isdigit()]

    raise ValueError(
        f"Collection {cid} exists but contains no object references."
    )


# ---------------------------------------------------------------------------
# Time-range retrieval
# ---------------------------------------------------------------------------

def get_in_timerange(
    cursor,
    name: str,
    t0: datetime,
    t1: datetime,
    author: str | None = None,
) -> object | None:
    """
    Find all tsdata objects whose stored time span overlaps [t0, t1],
    retrieve each one, sort by t0, concatenate, and crop to the exact window.

    Mirrors MATLAB's getObjectIdInTimespan() + retrieve() workflow.

    Returns a TSData, or None if no matching segments are found.
    """
    conditions = [
        "m.name LIKE %s",
        "a.data_type = 'tsdata'",
        "t.t0 <= %s",
        "DATE_ADD(t.t0, INTERVAL t.nsecs SECOND) >= %s",
    ]
    params: list = [name, t1.strftime("%Y-%m-%d %H:%M:%S"), t0.strftime("%Y-%m-%d %H:%M:%S")]

    if author:
        conditions.append("m.author LIKE %s")
        params.append(f"%{author}%")

    cursor.execute(
        f"""
        SELECT m.obj_id, t.t0, t.nsecs, t.fs
        FROM   objmeta m
        JOIN   ao      a ON a.obj_id = m.obj_id
        JOIN   tsdata  t ON t.obj_id = m.obj_id
        WHERE  {" AND ".join(conditions)}
        ORDER  BY t.t0
        """,
        params,
    )
    rows = cursor.fetchall()
    if not rows:
        return None

    segments = []
    for row in rows:
        seg = retrieve_one(cursor, row["obj_id"], binary=True)
        # Attach t0 from the database if not already set on the object
        if hasattr(seg, "t0") and seg.t0 is None and row["t0"] is not None:
            seg.t0 = row["t0"] if isinstance(row["t0"], datetime) else datetime.fromisoformat(str(row["t0"]))
        segments.append(seg)

    return _concatenate_and_crop(segments, t0, t1)


def _concatenate_and_crop(segments: list, t_start: datetime, t_end: datetime):
    """
    Merge a list of TSData objects (each with a .t0 attribute) into one
    continuous TSData cropped to [t_start, t_end].

    Assumes segments are already sorted by t0 ascending.
    """
    from pyda.tsdata import TSData
    from pyda.utils.axis import Axis

    # Sort by absolute start time, fall back to epoch for None
    segments.sort(key=lambda s: s.t0 if s.t0 is not None else datetime(1970, 1, 1))

    base: datetime = segments[0].t0 or datetime(1970, 1, 1)

    all_t: list = []
    all_y: list = []

    for seg in segments:
        seg_t0 = seg.t0 if seg.t0 is not None else datetime(1970, 1, 1)
        offset = (seg_t0 - base).total_seconds()
        all_t.append(seg.xaxis.data + offset)
        all_y.append(seg.yaxis.data)

    t_all = numpy.concatenate(all_t)
    y_all = numpy.concatenate(all_y)

    # Crop to the requested window (relative to base)
    t0_off = (t_start - base).total_seconds()
    t1_off = (t_end - base).total_seconds()
    mask = (t_all >= t0_off) & (t_all <= t1_off)

    result = TSData()
    result.xaxis = Axis(
        data=t_all[mask] - t0_off,
        units=segments[0].xaxis.units,
        name=segments[0].xaxis.name,
    )
    result.yaxis = Axis(
        data=y_all[mask],
        units=segments[0].yaxis.units,
        name=segments[0].yaxis.name,
    )
    result.t0 = t_start
    result.name = segments[0].name

    return result
