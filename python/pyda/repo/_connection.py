"""
MySQL connection wrapper for LTPDA repository access.

No SSH tunnel logic lives here. If the MySQL server is on a remote host,
establish the tunnel externally (e.g. ``ssh -L 3307:db.host:3306 gateway``)
and then pass ``hostname='localhost', port=3307`` to RepoConnection.
"""

from __future__ import annotations

import pymysql
import pymysql.cursors


class RepoConnection:
    """
    Thin wrapper around a PyMySQL connection.

    Parameters mirror MATLAB's DATABASE_CONNECTION_PLIST:

    hostname
        MySQL server hostname.  Pass ``'localhost'`` (with a custom *port*)
        when the database is accessed via an externally established SSH tunnel.
    database
        MySQL database (schema) name of the repository.
    username
        MySQL username — the same as the web UI login name.
    password
        MySQL password — the **mysql_password** set in the repository web UI
        when the user account was created or edited.  This is a *separate*
        credential from the web-login password.
    port
        MySQL TCP port (default 3306).  Set this to the local forwarded port
        when using an SSH tunnel.
    """

    def __init__(
        self,
        hostname: str,
        database: str,
        username: str,
        password: str,
        port: int = 3306,
    ) -> None:
        self._cfg: dict = dict(
            host=hostname,
            port=int(port),
            user=username,
            password=password,
            database=database,
            autocommit=False,
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
        )
        self._conn: pymysql.Connection | None = None

    # ------------------------------------------------------------------
    # Lifecycle
    # ------------------------------------------------------------------

    def open(self) -> None:
        """Open the MySQL connection."""
        self._conn = pymysql.connect(**self._cfg)

    def close(self) -> None:
        """Close the MySQL connection if open."""
        if self._conn is not None:
            try:
                self._conn.close()
            except Exception:
                pass
            self._conn = None

    def __enter__(self) -> "RepoConnection":
        self.open()
        return self

    def __exit__(self, *_) -> None:
        self.close()

    # ------------------------------------------------------------------
    # Transaction helpers
    # ------------------------------------------------------------------

    def cursor(self) -> pymysql.cursors.DictCursor:
        if self._conn is None:
            raise RuntimeError("Connection is not open. Call open() first.")
        return self._conn.cursor()

    def commit(self) -> None:
        if self._conn is not None:
            self._conn.commit()

    def rollback(self) -> None:
        if self._conn is not None:
            self._conn.rollback()
