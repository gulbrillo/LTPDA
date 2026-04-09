from datetime import datetime

from pydantic import BaseModel


# ── Repository schemas ─────────────────────────────────────────────────────────

class RepoCreate(BaseModel):
    db_name: str
    name: str
    description: str | None = None


class RepoUpdate(BaseModel):
    name: str | None = None
    description: str | None = None


class RepoOut(BaseModel):
    id: int
    db_name: str
    name: str
    description: str | None
    version: int
    obj_count: int = 0

    model_config = {"from_attributes": True}


# ── Access schemas ─────────────────────────────────────────────────────────────

class AccessEntry(BaseModel):
    username: str
    is_admin: bool
    first_name: str | None
    last_name: str | None
    institution: str | None
    can_read: bool
    can_write: bool


class GrantRequest(BaseModel):
    can_read: bool = True
    can_write: bool = False


# ── Object schemas ─────────────────────────────────────────────────────────────

class ObjectListItem(BaseModel):
    id: int
    obj_type: str | None
    name: str | None
    author: str | None
    submitted: datetime | None
    data_type: str | None
    has_binary: bool


class ObjectListResponse(BaseModel):
    items: list[ObjectListItem]
    total: int
    page: int
    page_size: int


class TypeDataTsdata(BaseModel):
    xunits: str | None
    yunits: str | None
    fs: float | None
    nsecs: float | None
    t0: datetime | None
    t0_adjusted: datetime | None
    toffset: int | None


class TypeDataFsdata(BaseModel):
    xunits: str | None
    yunits: str | None
    fs: float | None


class TypeDataXydata(BaseModel):
    xunits: str | None
    yunits: str | None


class TypeDataCdata(BaseModel):
    yunits: str | None


class TypeDataFilter(BaseModel):
    in_file: str | None
    fs: float | None


class TransactionEntry(BaseModel):
    username: str | None
    transdate: datetime | None
    direction: str | None


class ObjectDetail(BaseModel):
    id: int
    obj_type: str | None
    name: str | None
    author: str | None
    created: datetime | None
    version: str | None
    ip: str | None
    hostname: str | None
    os: str | None
    submitted: datetime | None
    experiment_title: str | None
    experiment_desc: str | None
    analysis_desc: str | None
    quantity: str | None
    additional_authors: str | None
    additional_comments: str | None
    keywords: str | None
    reference_ids: str | None
    validated: int | None
    vdate: datetime | None
    has_xml: bool
    has_binary: bool
    data_type: str | None
    type_data: TypeDataTsdata | TypeDataFsdata | TypeDataXydata | TypeDataCdata | TypeDataFilter | None
    transactions: list[TransactionEntry]


class DeleteObjectsRequest(BaseModel):
    ids: list[int]
