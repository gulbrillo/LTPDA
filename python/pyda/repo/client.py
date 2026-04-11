"""
LTPDARepository — Python client for the LTPDA repository server.

Connects directly to MySQL (the same way the MATLAB toolbox does via JDBC).
No REST API is used; all data operations are plain SQL.

SSH tunnelling is NOT handled here.  If the MySQL server is on a remote host,
create the tunnel externally::

    ssh -L 3307:db.internal:3306 gateway.host

then pass ``hostname='localhost', port=3307`` to the constructor.

Quick start::

    from pyda.repo import LTPDARepository

    with LTPDARepository('db.host.com', 'my_repo', 'alice', 'mysql_secret') as repo:
        # Submit
        result = repo.submit(
            ts,
            experiment_title='Noise floor run',
            experiment_desc='Accelerometer noise at rest on optical bench',
            analysis_desc='No processing applied — raw data submission',
        )
        print(f'Stored as object {result.id}')

        # Retrieve
        ts_back = repo.retrieve(result.id)

        # Time-range query
        ts_slice = repo.get('ACC_X',
                            t0=datetime(2024, 1, 15, 0, 0),
                            t1=datetime(2024, 1, 15, 6, 0))
"""

from __future__ import annotations

import os
from datetime import datetime
from typing import TYPE_CHECKING

from pyda.repo._connection import RepoConnection
from pyda.repo._retrieve import get_collection_ids, get_in_timerange, retrieve_one
from pyda.repo._search import (
    find as _find,
    find_duplicates as _find_duplicates,
    get_id as _get_id,
    get_latest as _get_latest,
    get_metadata as _get_metadata,
    get_uuid as _get_uuid,
    list_databases as _list_databases,
    report as _report,
)
from pyda.repo._submit import create_collection, submit_one
from pyda.repo.models import ObjectMeta, SearchResult, SubmitResult

if TYPE_CHECKING:
    pass


class LTPDARepository:
    """
    Client for an LTPDA repository database.

    Parameters
    ----------
    hostname : str
        MySQL server hostname.  Pass ``'localhost'`` (with a custom *port*)
        when accessing via an externally established SSH tunnel.
    database : str
        MySQL database (schema) name of the repository.
    username : str
        MySQL username — the same as the web UI login name.
    password : str
        MySQL password — the **mysql_password** configured in the web UI.
        This is *separate* from the web-login password.
    port : int, optional
        MySQL TCP port (default 3306).  Set this to the local tunnel port
        when using SSH port-forwarding.
    """

    def __init__(
        self,
        hostname: str,
        database: str,
        username: str,
        password: str,
        port: int = 3306,
    ) -> None:
        self._conn = RepoConnection(hostname, database, username, password, port)
        self._username = username

    # ------------------------------------------------------------------
    # Alternative constructors
    # ------------------------------------------------------------------

    @classmethod
    def from_env(cls) -> "LTPDARepository":
        """
        Construct from environment variables.

        Required variables
        ------------------
        LTPDA_HOST
            MySQL server hostname (``localhost`` when tunnelled).
        LTPDA_DB
            Database (schema) name.
        LTPDA_USER
            MySQL username.
        LTPDA_PASS
            MySQL password (the ``mysql_password`` from the web UI).

        Optional variables
        ------------------
        LTPDA_PORT
            MySQL port (default ``3306``).

        Raises
        ------
        EnvironmentError
            If any required variable is missing; the message lists all
            absent variables.

        Examples
        --------
        Shell::

            export LTPDA_HOST=db.host.com
            export LTPDA_DB=my_repo
            export LTPDA_USER=alice
            export LTPDA_PASS=mysql_secret

        Python::

            repo = LTPDARepository.from_env()

        With SSH tunnel (tunnel already running on local port 3307)::

            export LTPDA_HOST=localhost
            export LTPDA_PORT=3307
            repo = LTPDARepository.from_env()
        """
        required = ("LTPDA_HOST", "LTPDA_DB", "LTPDA_USER", "LTPDA_PASS")
        missing = [v for v in required if not os.environ.get(v)]
        if missing:
            raise EnvironmentError(
                f"Missing required environment variable(s): {', '.join(missing)}\n"
                "Set LTPDA_HOST, LTPDA_DB, LTPDA_USER, LTPDA_PASS "
                "(and optionally LTPDA_PORT)."
            )
        return cls(
            hostname=os.environ["LTPDA_HOST"],
            database=os.environ["LTPDA_DB"],
            username=os.environ["LTPDA_USER"],
            password=os.environ["LTPDA_PASS"],
            port=int(os.environ.get("LTPDA_PORT", 3306)),
        )

    # ------------------------------------------------------------------
    # Context manager / lifecycle
    # ------------------------------------------------------------------

    def __enter__(self) -> "LTPDARepository":
        self._conn.open()
        return self

    def __exit__(self, *_) -> None:
        self._conn.close()

    def connect(self) -> "LTPDARepository":
        """Open the database connection and return self (for chaining)."""
        self._conn.open()
        return self

    def close(self) -> None:
        """Close the database connection."""
        self._conn.close()

    # ------------------------------------------------------------------
    # Submit
    # ------------------------------------------------------------------

    def submit(
        self,
        *objs,
        experiment_title: str,
        experiment_desc: str,
        analysis_desc: str,
        quantity: str = "",
        keywords: str = "",
        reference_ids: str = "",
        additional_comments: str = "",
        additional_authors: str = "",
    ) -> SubmitResult | list[SubmitResult]:
        """
        Submit one or more pyda objects to the repository.

        All inserts are wrapped in a single MySQL transaction; on error the
        whole submission is rolled back.

        If multiple objects are given, a collection is created automatically
        and the returned ``SubmitResult.cid`` contains the collection ID.

        Parameters
        ----------
        *objs
            One or more pyda data objects (TSData, FSData, XYData, …).
        experiment_title : str
            Short title for the experiment (required, > 4 characters).
        experiment_desc : str
            Description of the experiment (required, > 10 characters).
        analysis_desc : str
            Description of the analysis performed (required, > 10 characters).
        quantity : str, optional
            Physical quantity represented (e.g. ``'acceleration'``).
        keywords : str, optional
            Comma-separated keyword list.
        reference_ids : str, optional
            Comma-separated IDs of related objects already in the repository.
        additional_comments : str, optional
            Free-form notes.
        additional_authors : str, optional
            Co-author names.

        Returns
        -------
        SubmitResult or list[SubmitResult]
            Single SubmitResult when one object is submitted; list when
            multiple objects are submitted (each with the same ``cid``).
        """
        if not objs:
            raise ValueError("At least one object must be supplied to submit().")

        # Validate mandatory field lengths (mirrors MATLAB validation)
        if len(experiment_title.strip()) < 5:
            raise ValueError("experiment_title must be at least 5 characters.")
        if len(experiment_desc.strip()) < 10:
            raise ValueError("experiment_desc must be at least 10 characters.")
        if len(analysis_desc.strip()) < 10:
            raise ValueError("analysis_desc must be at least 10 characters.")

        meta = dict(
            experiment_title=experiment_title,
            experiment_desc=experiment_desc,
            analysis_desc=analysis_desc,
            quantity=quantity,
            keywords=keywords,
            reference_ids=reference_ids,
            additional_comments=additional_comments,
            additional_authors=additional_authors,
        )

        with self._conn.cursor() as cur:
            try:
                results = [submit_one(cur, obj, meta, self._username) for obj in objs]

                if len(results) > 1:
                    cid = create_collection(cur, [r.id for r in results])
                    for r in results:
                        r.cid = cid

                self._conn.commit()
            except Exception:
                self._conn.rollback()
                raise

        return results[0] if len(results) == 1 else results

    # ------------------------------------------------------------------
    # Retrieve
    # ------------------------------------------------------------------

    def retrieve(
        self,
        *ids: int,
        cid: int | None = None,
        binary: bool = True,
    ):
        """
        Retrieve objects by ID(s) or by collection ID.

        Parameters
        ----------
        *ids : int
            One or more object IDs to retrieve.
        cid : int, optional
            Collection ID — retrieves all objects belonging to the collection.
        binary : bool, optional
            If True (default), download the HDF5 binary from ``bobjs``.
            If False, download the XML from ``objs`` (MATLAB objects only;
            raises NotImplementedError for pyda-submitted stubs).

        Returns
        -------
        object or list
            Single object when one ID is requested; list otherwise.
        """
        if cid is not None and ids:
            raise ValueError("Pass either positional IDs or cid=, not both.")

        with self._conn.cursor() as cur:
            if cid is not None:
                ids = tuple(get_collection_ids(cur, cid))
            if not ids:
                raise ValueError("No object IDs to retrieve.")
            objects = [retrieve_one(cur, oid, binary=binary) for oid in ids]

        return objects[0] if len(objects) == 1 else objects

    def get(
        self,
        name: str,
        t0: datetime | str,
        t1: datetime | str,
        author: str | None = None,
    ):
        """
        Retrieve all tsdata segments overlapping the time window [t0, t1]
        by channel name, then concatenate and crop to the exact window.

        This is the primary method for retrieving long continuous time-series
        stored as multiple shorter segments in the repository — the same
        pattern used by the MATLAB toolbox's time-range queries.

        Parameters
        ----------
        name : str
            SQL LIKE pattern for objmeta.name (e.g. ``'ACC_X'`` or ``'ACC%'``).
        t0 : datetime or ISO string
            Start of the requested window.
        t1 : datetime or ISO string
            End of the requested window.
        author : str, optional
            Filter by author (LIKE pattern).

        Returns
        -------
        TSData or None
            A single TSData object spanning [t0, t1], or None if no matching
            segments were found.
        """
        t0_dt = _parse_dt_arg(t0)
        t1_dt = _parse_dt_arg(t1)

        with self._conn.cursor() as cur:
            return get_in_timerange(cur, name, t0_dt, t1_dt, author=author)

    # ------------------------------------------------------------------
    # Search / find
    # ------------------------------------------------------------------

    def find(
        self,
        name: str = "%",
        timespan: tuple | None = None,
        author: str | None = None,
        date_from: str | datetime | None = None,
        date_to: str | datetime | None = None,
        obj_type: str | None = None,
    ) -> list[SearchResult]:
        """
        Search the repository for objects matching the given criteria.

        Parameters
        ----------
        name : str, optional
            SQL LIKE pattern applied to objmeta.name (default ``'%'`` = all).
        timespan : (t0, t1), optional
            Only return objects whose stored timespan overlaps [t0, t1].
            Uses MySQL ExtractValue on the XML timespan embedded in keywords.
        author : str, optional
            LIKE pattern applied to objmeta.author.
        date_from / date_to : str or datetime, optional
            Filter by submission date range.
        obj_type : str, optional
            Exact match on obj_type (e.g. ``'ao'``, ``'pzmodel'``).

        Returns
        -------
        list[SearchResult]
            Ordered by submission date, most recent first.
        """
        with self._conn.cursor() as cur:
            return _find(
                cur,
                name=name,
                timespan=timespan,
                author=author,
                date_from=date_from,
                date_to=date_to,
                obj_type=obj_type,
            )

    # ------------------------------------------------------------------
    # Utility methods
    # ------------------------------------------------------------------

    def get_metadata(self, *ids: int) -> list[ObjectMeta]:
        """
        Retrieve full metadata for one or more object IDs without
        downloading binary data.
        """
        with self._conn.cursor() as cur:
            return _get_metadata(cur, *ids)

    def get_collection_ids(self, cid: int) -> list[int]:
        """Return the object IDs that belong to collection *cid*."""
        with self._conn.cursor() as cur:
            return get_collection_ids(cur, cid)

    def create_collection(self, ids: list[int]) -> int:
        """
        Group existing objects into a new collection.
        Returns the new collection ID (cid).
        """
        with self._conn.cursor() as cur:
            try:
                cid = create_collection(cur, ids)
                self._conn.commit()
            except Exception:
                self._conn.rollback()
                raise
        return cid

    def find_duplicates(self) -> list[tuple[int, str]]:
        """
        Return (id, uuid) pairs for objects whose UUID appears more than once.
        Mirrors MATLAB's findDuplicates().
        """
        with self._conn.cursor() as cur:
            return _find_duplicates(cur)

    def get_latest(self, name: str) -> ObjectMeta | None:
        """
        Return metadata for the tsdata object with *name* whose end time
        (t0 + nsecs) is most recent.  Returns None if no match found.
        Mirrors MATLAB's getLatestObject().
        """
        with self._conn.cursor() as cur:
            return _get_latest(cur, name)

    def get_uuid(self, obj_id: int) -> str:
        """Return the UUID string for the given object ID."""
        with self._conn.cursor() as cur:
            return _get_uuid(cur, obj_id)

    def get_id(self, uuid: str) -> int:
        """Return the integer ID for the given UUID."""
        with self._conn.cursor() as cur:
            return _get_id(cur, uuid)

    def list_databases(self) -> list[str]:
        """
        Return the names of all MySQL databases visible to the current user.
        Useful for discovering which repositories are accessible.
        """
        with self._conn.cursor() as cur:
            return _list_databases(cur)

    def report(
        self,
        filename: str,
        date_from: str | datetime | None = None,
        date_to: str | datetime | None = None,
        max_rows: int = 10_000,
    ) -> None:
        """
        Dump object metadata to a CSV file.
        Mirrors MATLAB's utils.repository.report().

        Parameters
        ----------
        filename : str
            Output CSV file path.
        date_from / date_to : str or datetime, optional
            Limit rows to objects submitted in this date range.
        max_rows : int, optional
            Safety cap on rows written (default 10 000).
        """
        with self._conn.cursor() as cur:
            _report(cur, filename, date_from=date_from, date_to=date_to, max_rows=max_rows)

    # ------------------------------------------------------------------
    # Static helpers
    # ------------------------------------------------------------------

    @staticmethod
    def available_databases(
        hostname: str,
        username: str,
        password: str,
        port: int = 3306,
    ) -> list[str]:
        """
        Connect, run ``SHOW DATABASES``, disconnect.
        Useful for discovering accessible repositories without holding a
        persistent connection.
        """
        conn = RepoConnection(hostname, "__no_db__", username, password, port)
        # Connect without selecting a database
        import pymysql
        raw = pymysql.connect(
            host=hostname,
            port=int(port),
            user=username,
            password=password,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
        )
        try:
            with raw.cursor() as cur:
                return _list_databases(cur)
        finally:
            raw.close()


# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

def _parse_dt_arg(v: datetime | str) -> datetime:
    """Coerce a datetime-or-ISO-string argument to a datetime."""
    if isinstance(v, datetime):
        return v
    try:
        return datetime.fromisoformat(str(v))
    except (ValueError, TypeError) as exc:
        raise ValueError(
            f"Cannot parse {v!r} as a datetime. "
            "Pass a datetime object or an ISO 8601 string "
            "(e.g. '2024-01-15 06:00:00')."
        ) from exc
