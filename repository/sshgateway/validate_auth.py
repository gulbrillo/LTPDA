#!/usr/bin/env python3
"""
LTPDA SSH Gateway — PAM auth script.

Called by pam_exec with expose_authtok: reads PAM_USER from the environment
and the entered password from stdin, then attempts a MySQL connection as that
user. If MySQL accepts the connection, exit 0 (auth OK). Otherwise exit 1.

This script also ensures a minimal stub Linux account exists for PAM_USER so
that sshd can look up the account. Stub accounts have no shell and no home
directory — they exist only to satisfy sshd's account lookup.

Environment variables injected by docker-compose:
  MYSQL_HOST  — hostname of the MySQL container (default: db)
  MYSQL_PORT  — MySQL port (default: 3306)
  MYSQL_DB    — database to connect to for the auth check (default: ltpda_admin)
"""

import os
import subprocess
import sys

import pymysql

MYSQL_HOST = os.environ.get("MYSQL_HOST", "db")
MYSQL_PORT = int(os.environ.get("MYSQL_PORT", "3306"))
MYSQL_DB = os.environ.get("MYSQL_DB", "ltpda_admin")

pam_user = os.environ.get("PAM_USER", "")
if not pam_user:
    sys.exit(1)

# Only alphanumeric + hyphen + underscore — reject anything else immediately
if not pam_user.replace("-", "").replace("_", "").isalnum():
    sys.exit(1)

try:
    password = sys.stdin.read().rstrip("\n")
except Exception:
    sys.exit(1)

if not password:
    sys.exit(1)

# Validate credentials against MySQL
try:
    conn = pymysql.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=pam_user,
        password=password,
        database=MYSQL_DB,
        connect_timeout=5,
    )
    conn.close()
except Exception:
    sys.exit(1)

# Auth succeeded. Ensure a stub Linux account exists so sshd can look up the user.
# The account has no home directory and no shell — it exists only to satisfy sshd.
result = subprocess.run(
    ["getent", "passwd", pam_user],
    capture_output=True,
)
if result.returncode != 0:
    subprocess.run(
        ["adduser", "-D", "-H", "-s", "/bin/false", "-G", "ltpda-users", pam_user],
        capture_output=True,
    )

sys.exit(0)
