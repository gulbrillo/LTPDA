# LTPDA Repository v3.0

Docker-based replacement for the legacy PHP repository server. Compatible with the v2.5 database
schema — MATLAB connects via JDBC exactly as before, no toolbox changes required.

---

## Features

- **Repository management** — create, edit, and delete MySQL repository databases through the web UI
- **Per-user access control** — grant or revoke read/write access per repository per user; toggles take effect immediately
- **Data browsing** — search and filter objects by name, type, author, and date; paginated object list; per-object detail view with full metadata
- **Data downloads** — download stored XML representations or binary `.mat` files directly from the browser
- **MATLAB compatibility** — identical v2.5 database schema; `users` VIEW per repository; per-user MySQL grants with `SELECT` + `INSERT on transactions` matching the legacy privilege model; JDBC connections work without any MATLAB-side changes
- **SSH tunnel gateway** — built-in SSH container on port 2222 authenticates MATLAB users with their MySQL credentials; no Linux host accounts needed; stub accounts created automatically inside the container on first connect
- **User management** — create/edit/delete users; separate web UI password (bcrypt) and MySQL/MATLAB password; admin role assignment
- **Setup wizard** — web-based first-run setup supporting bundled MySQL container or external dedicated MySQL server
- **JWT authentication** — 8-hour Bearer tokens; global route protection in the SPA
- **phpMyAdmin** — bundled in the Docker stack (bundled mode only); accessible from Admin → Settings; auto-logged in as MySQL root; gated behind an active admin session

---

## Architecture

```
Apache (your existing web server)
  └── reverse proxy → Docker (port 8088, localhost only)
        ├── nginx  →  Nuxt 4 SPA  (static files, client-side rendering)
        ├── nginx  →  FastAPI REST API  (Python 3, uvicorn)
        │                  └── MySQL
        │                        ├── ltpda_admin        ← users, repo registry, options
        │                        ├── myrepo             ← per-repository database (v2.5 schema)
        │                        └── anotherrepo
        └── nginx  →  phpMyAdmin  (bundled mode only; admin-session gated)
```

MySQL can be **bundled** (a container in the same Compose stack) or **external** (a dedicated server
you manage separately). The choice is made once in the setup wizard and stored in `config/config.json`.

---

## Requirements

**Server:**
- Linux VPS or dedicated server
- Docker Engine 24+ and Docker Compose v2 (`docker compose`)
- Apache 2.4+ (or Nginx) as the front-facing web server
- A domain or subdomain pointing to the server (e.g. `repo.yourdomain.com`)
- MySQL: bundled container (no extra install) or external dedicated MySQL 5.7+ / MariaDB 10.5+

> **Shared hosting not supported.** The repository creates and drops MySQL databases and user
> accounts dynamically. It requires a dedicated MySQL server.

**Build machine** (to compile the frontend — can be done on your laptop):
- Node.js 20+ and npm

---

## Installation

### 1. Clone the repo and enter the repository directory

```bash
git clone https://github.com/gulbrillo/LTPDA.git
cd LTPDA/repository
```

### 2. Install Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER   # re-login after this
```

Verify: `docker compose version` should show v2.x.

### 3. Build the Nuxt frontend

```bash
cd frontend
npm install
npm run generate        # outputs static files to frontend/.output/public/
cd ..
```

You must re-run `npm run generate` and restart the containers whenever frontend source changes.

### 4. Configure the Apache vhost

```apache
<VirtualHost *:80>
    ServerName repo.yourdomain.com
    Redirect permanent / https://repo.yourdomain.com/
</VirtualHost>

<VirtualHost *:443>
    ServerName repo.yourdomain.com

    SSLEngine on
    SSLCertificateFile    /etc/letsencrypt/live/repo.yourdomain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/repo.yourdomain.com/privkey.pem

    ProxyPreserveHost On
    ProxyPass        / http://127.0.0.1:8088/
    ProxyPassReverse / http://127.0.0.1:8088/
</VirtualHost>
```

```bash
sudo a2enmod proxy proxy_http ssl
sudo systemctl reload apache2
sudo certbot --apache -d repo.yourdomain.com
```

### 5. Start Docker

**Option A — Bundled MySQL** (recommended for new deployments):

```bash
cat > .env <<'EOF'
MYSQL_ROOT_PASSWORD=choose_a_strong_password
LTPDA_PUBLIC_URL=https://repo.yourdomain.com
EOF
docker compose --profile bundled up -d
```

`MYSQL_ROOT_PASSWORD` is required for the bundled MySQL container. `LTPDA_PUBLIC_URL` is required
for phpMyAdmin's internal page links to render correctly — set it to the public URL of your server
(no trailing slash). An `.env.example` is included for reference.

This starts five containers: `mysql`, `api`, `nginx`, `sshgateway`, and `phpmyadmin`. The `api`,
`sshgateway`, and `phpmyadmin` containers wait for MySQL to pass its healthcheck before starting.

**Option B — External dedicated MySQL server:**

```bash
docker compose up -d
```

This starts only `api` and `nginx`. You will enter the MySQL host and credentials in the setup
wizard.

> **External MySQL — allow Docker connections:** By default MySQL binds to `127.0.0.1` only. If
> MySQL is on the same host as Docker, add `bind-address = 0.0.0.0` to
> `/etc/mysql/mysql.conf.d/mysqld.cnf` and restart MySQL. Keep port 3306 firewalled from external
> traffic.

Check that containers are running: `docker compose ps`

### 6. Run the setup wizard

Open `https://repo.yourdomain.com` in a browser. You are redirected to the setup page.

**Bundled MySQL** — Enter the root password from your `.env` file. Admin database defaults to
`ltpda_admin`.

**External MySQL** — Enter the host, port, and admin credentials (needs `CREATE DATABASE`,
`CREATE USER`, `GRANT` — does not need to be root).

Both modes require a first admin user with:
- **Web UI password** — bcrypt, used to log into the web interface
- **MySQL / MATLAB password** — creates a MySQL account; MATLAB connects via JDBC with these
  credentials

Click **Run Setup**. The wizard creates the admin database schema, the first MySQL user account,
and writes `config/config.json`. You are redirected to the login page.

### 7. Verify

- Log in with the admin credentials from the wizard.
- The dashboard appears. Create a repository from **Admin → Repositories** to get started.
- `GET https://repo.yourdomain.com/api/health` → `{"status":"ok","configured":true}`

---

## Repository management

Log in as admin and navigate to **Admin → Repositories**.

### Create a repository

Click **New repository**. Enter:
- **Display name** — shown in the UI
- **Database name** — the MySQL database name (lowercase letters, digits, underscores only; cannot be changed after creation)
- **Description** (optional)

> **Reserved names:** The following MySQL system database names are blocked and cannot be used as
> repository names: `mysql`, `information_schema`, `performance_schema`, `sys`.

Clicking **Create repository** creates the MySQL database, initialises it with the v2.5 schema
(all standard LTPDA tables), creates the `users` VIEW for MATLAB compatibility, and registers the
database in the admin registry.

### Edit a repository

Click **Edit** next to a repository to update its display name or description. The MySQL database
name is immutable.

### Delete a repository

Click **Delete**. You will be asked to confirm. This permanently drops the MySQL database and all
its data, removes the admin registry entry, and cleans up all MySQL user grants for that database.

### Manage user access

Click **Access** next to a repository to expand the access management panel. Every user is shown
with two toggles:

| Toggle | What it grants |
|--------|---------------|
| **Read** | `SELECT` on all tables in the repository + `INSERT` on the `transactions` table (required for MATLAB to log data access) |
| **Write** | `INSERT` on all tables in the repository (required for MATLAB to submit new objects) |

Write access requires Read. Toggling immediately fires a `GRANT` or `REVOKE` against MySQL.

---

## Data browsing

Click a repository card on the dashboard to open its browse page.

### Searching and filtering

Use the filter bar at the top to search by:
- **Name** — partial match against object name
- **Type** — exact match against object type enum (`ao`, `tsdata`, `collection`, etc.)
- **Author** — partial match
- **Date range** — filter by submission date

Click **Search** to apply. Click **Clear** to reset all filters.

### Object list

The table shows: ID, name, type, data type (for `ao` objects), author, submission date, and download buttons. Click any row to open the detail panel.

### Object detail

The right-side panel shows:
- All metadata from `objmeta`: type, name, author, creation/submission timestamps, version, hostname, experiment title/description, quantity, keywords, validation status
- Type-specific signal data: sample rate (`fs`), duration (`nsecs`), start time (`t0`), units — for `tsdata`, `fsdata`, `xydata`, `cdata` objects
- Transaction history: the last 15 operations logged (downloads, uploads, deletes)
- Download buttons for XML and binary (`.mat`) formats

### Downloading data

Click the **XML** or **.mat** button in the table row or detail panel. Each download is logged to the `transactions` table with `direction = 'download'`.

### Deleting objects (admin only)

Select objects using the checkboxes and click **Delete (n)**. A confirmation is required. Each deletion is logged to the `transactions` table before the row is removed, so the audit trail is preserved.

---

## User management

Navigate to **Admin → Users**.

### Create a user

Click **New user**. Enter:
- **Username** — alphanumeric, hyphens, underscores
- **Password** — web UI login password (stored as bcrypt hash)
- **MySQL / MATLAB password** — creates a MySQL account (`username`@`%`); MATLAB uses this password for JDBC
- Optional profile: first/last name, email, institution

### Edit a user

Click **Edit** to update profile fields or change passwords. If a new MySQL password is entered, the MySQL account is updated via `ALTER USER`.

### Delete a user

Click **Remove**. The app record is deleted and the MySQL account is dropped. You cannot delete your own account.

---

## phpMyAdmin (bundled mode only)

phpMyAdmin is included in the bundled Docker stack and is accessible from **Admin → Settings →
Open phpMyAdmin**. It opens in a new tab and is automatically logged in as the MySQL root account.

**Security model:** `/pma/` is not directly accessible. Every request is checked by nginx against
`GET /api/auth/pma-auth`. When you click the button, the frontend calls `POST /api/auth/pma-token`
first — this exchanges your active Bearer JWT for a short-lived HttpOnly cookie (`pma_access`,
scoped to `Path=/pma/`, valid for 8 hours). nginx passes that cookie to the auth endpoint on every
phpMyAdmin request. If you are not logged in as an admin, or the cookie has expired, nginx
redirects to `/`.

The `pma_access` cookie is `HttpOnly` (no JavaScript access), `SameSite=Lax` (CSRF protection),
and scoped to `Path=/pma/` only — the browser never sends it to the LTPDA API.

**Requirement:** `LTPDA_PUBLIC_URL` must be set in `.env` for phpMyAdmin's internal page links
(CSS, pagination, exports) to work correctly.

---

## Configuring MATLAB

MATLAB connects to MySQL via JDBC through an **SSH tunnel**. There are two ways to set this up —
both work simultaneously and you can use whichever suits your environment.

---

### Option A — SSH gateway container (recommended, port 2222)

The `sshgateway` container starts automatically with `docker compose --profile bundled up`. Users
authenticate using their existing MySQL/MATLAB credentials — no Linux host accounts needed. On the
first successful connection, a minimal stub account is created **inside the container** — no
changes to the host machine.

```bash
# On your local machine — keep this open while using MATLAB
ssh -L 3306:db:3306 -p 2222 your_username@repo.yourdomain.com
```

This forwards your local port 3306 → SSH gateway container → MySQL container.

**Firewall:** port 2222 must be open on the server:

```bash
sudo ufw allow 2222/tcp
```

In **LTPDAprefs**, set:
- **Hostname** — `localhost`
- **Port** — `3306`
- **Username / Password** — the MySQL/MATLAB credentials set when the account was created

**How authentication works:** when a user connects, PAM calls `validate_auth.py` inside the
container, which opens a MySQL connection as that user to `ltpda_admin`. If MySQL accepts it, SSH
auth succeeds immediately — no pre-registration or host account creation needed.

**Why port 2222?** SSH has no equivalent to HTTP's `Host` header — there is no way to route port
22 by hostname the way a web server does with virtual hosts. Port 2222 avoids conflicts with the
host's own SSH service.

---

### Option B — Manual host SSH accounts (fallback, port 22)

If port 2222 cannot be opened, you can use the host's existing SSH service (port 22) instead.
MySQL container port 3306 is bound to `127.0.0.1:3307` on the host, so a host SSH tunnel reaches it.

```bash
# On your local machine — keep this open while using MATLAB
ssh -L 3306:localhost:3307 your_linux_username@repo.yourdomain.com
```

**Linux account required.** Each user needs a tunnel-only account on the server host:

```bash
sudo useradd -m -s /usr/sbin/nologin your_username
sudo passwd your_username
```

These accounts are managed manually — the web UI does not create or remove them.

**Optional — ssh-sync-daemon:** An optional host daemon (`ssh-sync-daemon/`) can automate host
account creation/deletion in sync with the web UI. It exposes a local webhook API secured with
HMAC-SHA256. See `ssh-sync-daemon/README` for installation instructions. This is only needed for
Option B; Option A does not require it.

---

### LTPDAprefs summary

Both options use the same MATLAB settings:

| Setting | Value |
|---------|-------|
| Hostname | `localhost` |
| Port | `3306` |
| Database | repository database name (e.g. `myrepo`) |
| Username | the user's username |
| Password | the user's **MySQL/MATLAB** password (not the web UI password) |

---

## API overview

All endpoints are prefixed with `/api/`. Authentication uses Bearer tokens obtained from `POST /api/auth/login`.

### Setup

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/setup/status` | — | Returns `{"configured": bool}` |
| POST | `/api/setup/run` | — | Run first-time setup wizard |

### Authentication

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/api/auth/login` | — | Login; returns JWT Bearer token |
| GET | `/api/auth/me` | user | Current user info |
| POST | `/api/auth/pma-token` | admin | Issues `pma_access` HttpOnly cookie granting nginx access to `/pma/` |
| GET | `/api/auth/pma-auth` | — (cookie) | nginx `auth_request` sub-endpoint; validates `pma_access` cookie; never called directly |

### Users (admin only)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/users` | admin | List all users |
| POST | `/api/users` | admin | Create user (also creates MySQL account) |
| PUT | `/api/users/{id}` | admin | Update user (also updates MySQL password if provided) |
| DELETE | `/api/users/{id}` | admin | Delete user (also drops MySQL account) |

### Settings (admin only)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/settings` | admin | MySQL connection config (passwords not exposed) |

### Repositories

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/repos` | user | List accessible repos (admin: all; user: SELECT-granted only) |
| POST | `/api/repos` | admin | Create repo (CREATE DATABASE + v2.5 schema + users VIEW) |
| GET | `/api/repos/{db_name}` | user | Repo details + object count |
| PUT | `/api/repos/{db_name}` | admin | Update display name / description |
| DELETE | `/api/repos/{db_name}` | admin | Drop database + remove registry entry + clean grants |

### Repository access (admin only)

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/repos/{db_name}/access` | admin | List all users with read/write state |
| POST | `/api/repos/{db_name}/access/{username}` | admin | Grant or revoke SELECT/INSERT; body: `{"can_read": bool, "can_write": bool}` |
| DELETE | `/api/repos/{db_name}/access/{username}` | admin | Revoke all privileges |

### Objects

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/api/repos/{db_name}/objects` | user | List objects; filters: `name`, `obj_type`, `author`, `date_from`, `date_to`, `page`, `page_size` |
| GET | `/api/repos/{db_name}/objects/{id}` | user | Full object detail (all metadata + type-specific + transactions) |
| DELETE | `/api/repos/{db_name}/objects` | admin | Delete objects by ID array; body: `{"ids": [...]}` |
| GET | `/api/repos/{db_name}/objects/{id}/xml` | user | Download XML; logs download transaction |
| GET | `/api/repos/{db_name}/objects/{id}/binary` | user | Download binary `.mat`; logs download transaction |

---

## Database structure

### Admin database (`ltpda_admin` by default)

| Table | Purpose |
|-------|---------|
| `users` | Web UI accounts (bcrypt password), MySQL account credentials (plaintext for `CREATE USER`), admin flag |
| `available_dbs` | Registry of repository databases (db_name, display name, description, schema version) |
| `options` | Global key-value settings |

### Per-repository databases (v2.5 schema)

Each repository database is initialised from `backend/aorepo_db.sql` — identical to the legacy v2.5 schema:

| Table | Purpose |
|-------|---------|
| `objs` | Core object storage (XML, UUID, hash) |
| `bobjs` | Binary MATLAB data (LONGBLOB; FK cascade from `objs`) |
| `objmeta` | Object metadata (type, name, author, timestamps, experiment info, validation) |
| `collections` | Collection groupings |
| `collections2objs` | Collection membership |
| `transactions` | Audit log (user_id, timestamp, direction: `download`/`delete`) |
| `ao` | Analysis Object sub-table (data_type enum) |
| `cdata` | Complex data (yunits) |
| `fsdata` | Frequency series (xunits, yunits, fs) |
| `tsdata` | Time series (xunits, yunits, fs, nsecs, t0, toffset) |
| `xydata` | XY data (xunits, yunits) |
| `mfir` | FIR filter (in_file, fs) |
| `miir` | IIR filter (in_file, fs) |
| `users` (VIEW) | `SELECT id, username FROM ltpda_admin.users` — MATLAB queries this view internally |

Every application user has two independent passwords:

| Password | Purpose | Storage |
|----------|---------|---------|
| Web UI password | Log in to the web interface | bcrypt hash in `users` table |
| MySQL / MATLAB password | MySQL account for JDBC access | Plaintext in `users` table — required to pass to `CREATE USER` |

### MySQL privilege model

When a user is granted read access to a repository, the following grants are applied:

```sql
GRANT SELECT ON `{db_name}`.* TO '{username}'@'%'
GRANT INSERT ON `{db_name}`.transactions TO '{username}'@'%'
```

The `INSERT on transactions` grant is always paired with `SELECT` — it allows MATLAB to record data accesses without needing broad write access.

When write access is additionally granted:

```sql
GRANT INSERT ON `{db_name}`.* TO '{username}'@'%'
```

---

## Updating

Two update scripts are included that automate the full sequence: git pull → frontend rebuild → containers restart.

```bash
# Make the scripts executable (one-time, after first clone)
chmod +x update-bundled.sh update-external.sh

# Bundled MySQL:
./update-bundled.sh

# External MySQL:
./update-external.sh
```

Or run the steps manually:

```bash
# 1. Pull the latest code
git pull

# 2. Rebuild the frontend (only needed if frontend source changed)
cd frontend && npm install && npm run generate && cd ..

# 3. Rebuild and restart containers
#    Bundled MySQL:
docker compose --profile bundled down && docker compose --profile bundled up -d --build
#    External MySQL:
docker compose down && docker compose up -d --build
```

`--build` tells Compose to rebuild the `api` container image from the updated `Dockerfile` and
`requirements.txt`. The `mysql` and `nginx` containers use upstream images and are pulled
automatically if a newer version is available.

**Zero-downtime note:** `up -d --build` replaces containers one at a time. There will be a brief
interruption (a few seconds) while the `api` container is replaced. The MySQL data volume is
preserved across updates.

**Config is preserved:** `config/config.json` lives in the `./config` volume mount and is never
touched by a rebuild. No re-running the setup wizard after an update.

```bash
docker compose ps                                  # all containers Up
curl -s https://repo.yourdomain.com/api/health    # {"status":"ok","configured":true}
```

---

## Directory layout

```
repository/
├── backend/                FastAPI application (Python 3.12)
│   ├── core/               Config, database, security helpers
│   ├── models/             SQLAlchemy ORM models (user, repo)
│   ├── routers/            API route handlers
│   │   ├── setup.py        First-run wizard
│   │   ├── auth.py         Login, JWT, /me, phpMyAdmin cookie bridge
│   │   ├── users.py        User CRUD (also manages MySQL accounts)
│   │   ├── settings.py     Config overview (read-only)
│   │   ├── repos.py        Repository CRUD + access management
│   │   └── objects.py      Object browsing + download endpoints
│   ├── schemas/            Pydantic request/response models
│   ├── aorepo_db.sql       v2.5 per-repository schema (exact legacy schema)
│   └── Dockerfile
├── frontend/               Nuxt 4 SPA (Vue 3, TypeScript)
│   └── app/
│       ├── pages/
│       │   ├── setup.vue         First-run wizard
│       │   ├── login.vue         Login form
│       │   ├── dashboard.vue     Repository card grid
│       │   ├── repos/
│       │   │   └── [db_name].vue Browse + search objects; detail panel; downloads
│       │   └── admin/
│       │       ├── repos.vue     Repository management + access toggles
│       │       ├── users.vue     User management
│       │       └── settings.vue  Config overview
│       ├── components/     AppLogo, StatusOk, StatusWarn
│       └── composables/    useAuth.ts (JWT + apiFetch)
├── sshgateway/             SSH tunnel gateway container (port 2222)
│   ├── Dockerfile          Alpine + OpenSSH + PAM + pymysql
│   ├── sshd_config         Tunnel-only; PermitOpen db:3306
│   ├── pam_ltpda           PAM module — calls validate_auth.py
│   └── validate_auth.py    Authenticates via MySQL; auto-creates stub accounts
├── ssh-sync-daemon/        Optional host daemon for Option B (port 22 tunneling)
│   ├── ssh_sync_daemon.py  Flask webhook API (HMAC-signed)
│   ├── ltpda-ssh-sync.service  systemd unit
│   ├── config.example.json
│   └── requirements.txt
├── config/                 Runtime config volume (config.json — excluded from git)
├── .env.example            Template for required environment variables
├── docker-compose.yml
├── nginx.conf
├── update-bundled.sh       One-command update script (bundled MySQL)
├── update-external.sh      One-command update script (external MySQL)
└── README.md
```
