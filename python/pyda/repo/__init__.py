"""
pyda.repo — LTPDA repository connectivity.

Provides direct MySQL access to LTPDA repository databases using the same
connection pattern as the MATLAB toolbox (JDBC/PyMySQL, not the REST API).

Quick start::

    from pyda.repo import LTPDARepository

    with LTPDARepository('db.host.com', 'my_repo', 'alice', 'mysql_secret') as repo:
        result = repo.submit(
            ts,
            experiment_title='Noise floor run',
            experiment_desc='Accelerometer noise at rest on optical bench',
            analysis_desc='No processing applied — raw data submission',
        )
        ts_back = repo.retrieve(result.id)

See ``LTPDARepository`` for the full API.
"""

from .client import LTPDARepository

__all__ = ["LTPDARepository"]
