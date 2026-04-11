"""
Data classes for LTPDA repository operations.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class ObjectMeta:
    """Full metadata record for one repository object."""

    id: int
    uuid: str | None
    obj_type: str | None        # 'ao', 'pzmodel', 'mfir', etc.
    data_type: str | None       # 'tsdata', 'fsdata', 'xydata', 'cdata' (for ao)
    name: str | None
    author: str | None
    created: datetime | None
    submitted: datetime | None
    experiment_title: str | None
    experiment_desc: str | None
    analysis_desc: str | None
    quantity: str | None
    keywords: str | None
    reference_ids: str | None
    additional_comments: str | None
    additional_authors: str | None
    validated: bool
    has_binary: bool
    # type-specific fields (populated for tsdata / fsdata)
    fs: float | None = None
    nsecs: float | None = None
    t0: datetime | None = None
    xunits: str | None = None
    yunits: str | None = None


@dataclass
class SubmitResult:
    """Return value from LTPDARepository.submit()."""

    id: int           # auto-increment object ID assigned by MySQL
    uuid: str         # UUID of the object (from obj.id or newly generated)
    cid: int | None = None   # collection ID when multiple objects are submitted together


@dataclass
class SearchResult:
    """One row returned by LTPDARepository.find()."""

    id: int
    uuid: str | None
    name: str | None
    experiment_title: str | None
    submitted: datetime | None
    t_start: datetime | None = None   # extracted from keywords XML timespan
    t_stop: datetime | None = None
