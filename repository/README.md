# LTPDA Repository v3.0

Docker-based replacement for the legacy PHP repository server. Compatible with the v2.5 database
schema — MATLAB connects via JDBC exactly as before, no toolbox changes required.

---

## Architecture

```
Apache (your existing web server)
  └── reverse proxy → Docker (port 8088, localhost only)
        ├── nginx  →  Nuxt 4 SPA  (static files, client-side rendering)
        └── nginx  →  FastAPI REST API  (Python 3, uvicorn)
                           └── MySQL
                                 ├── ltpda_admin        ← users, repo registry, options
                                 ├── myrepo             ← per-repository database (v2.5 schema)
                                 └── anotherrepo
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
echo "MYSQL_ROOT_PASSWORD=choose_a_strong_password" > .env
docker compose --profile bundled up -d
```

This starts four containers: `mysql`, `api`, `nginx`, and `sshgateway`. The `api` and `sshgateway`
containers wait for MySQL to pass its healthcheck before starting.

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
- The dashboard should show "No repositories yet."
- `GET https://repo.yourdomain.com/api/health` → `{"status":"ok","configured":true}`

---

## Updating

When a new version is released, update the containers and frontend in one sequence:

```bash
# 1. Pull the latest code
git pull

# 2. Rebuild the frontend (only needed if frontend source changed)
cd frontend && npm install && npm run generate && cd ..

# 3. Rebuild and restart containers
#    Bundled MySQL:
docker compose --profile bundled up -d --build
#    External MySQL:
docker compose up -d --build
```

`--build` tells Compose to rebuild the `api` container image from the updated `Dockerfile` and
`requirements.txt`. The `mysql` and `nginx` containers use upstream images and are pulled
automatically if a newer version is available.

**Zero-downtime note:** `up -d --build` replaces containers one at a time. There will be a brief
interruption (a few seconds) while the `api` container is replaced. The MySQL data volume is
preserved across updates.

**Config is preserved:** `config/config.json` lives in the `./config` volume mount and is never
touched by a rebuild. No re-running the setup wizard after an update.

**After update — verify:**
```bash
docker compose ps                          # all containers Up
curl -s https://repo.yourdomain.com/api/health   # {"status":"ok","configured":true}
```

---

## Configuring MATLAB

MATLAB connects to MySQL via JDBC through an **SSH tunnel**. There are two ways to set this up —
both work simultaneously and you can use whichever suits your environment.

---

### Option A — SSH gateway container (recommended, port 2222)

The `sshgateway` container starts automatically with `docker compose --profile bundled up`. Users
authenticate using their existing MySQL/MATLAB credentials — no Linux host accounts needed.

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

**Why port 2222?** SSH has no equivalent to HTTP's `Host` header — there is no way to route port
22 by hostname the way a web server does with virtual hosts. Port 2222 avoids conflicts with the
host's own SSH service. (GitHub uses port 443 as an SSH fallback for the same reason.)

**How authentication works:** when a user connects, PAM calls `validate_auth.py` inside the
container, which opens a MySQL connection as that user. If MySQL accepts it, SSH auth succeeds.
User create/update/delete in the web UI immediately takes effect for SSH — no sync needed.

---

### Option B — Manual host SSH accounts (fallback, port 22)

If port 2222 cannot be opened, you can use the host's existing SSH service (port 22) instead.
MySQL container port 3306 is bound to `127.0.0.1:3307` on the host, so a host SSH tunnel reaches it.

```bash
# On your local machine — keep this open while using MATLAB
ssh -L 3306:localhost:3307 your_linux_username@repo.yourdomain.com
```

This forwards your local port 3306 → host port 3307 → MySQL container port 3306.

In **LTPDAprefs**, the same settings apply — **Hostname** `localhost`, **Port** `3306`.

**Linux account required.** Each user needs a tunnel-only account on the server host:

```bash
sudo useradd -m -s /usr/sbin/nologin your_username
sudo passwd your_username
```

The `-s /usr/sbin/nologin` shell prevents interactive logins while still allowing SSH port forwarding.
These accounts are managed manually — the web UI does not create or remove them.

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

## Directory layout

```
repository/
├── backend/            FastAPI application (Python)
│   ├── core/           Config, database, security helpers
│   ├── routers/        API route handlers (setup, auth, users, settings)
│   └── Dockerfile
├── frontend/           Nuxt 4 SPA (Vue 3)
│   └── app/
│       ├── pages/      setup.vue, login.vue, dashboard.vue, admin/users.vue
│       ├── components/ AppLogo.vue, StatusOk.vue, StatusWarn.vue
│       └── composables/useAuth.ts
├── sshgateway/         Docker SSH gateway container
│   ├── Dockerfile      Alpine + OpenSSH + pam_exec + pymysql
│   ├── sshd_config     Tunnel-only, PAM auth, PermitOpen db:3306
│   ├── pam_ltpda       pam_exec calls validate_auth.py
│   └── validate_auth.py  Authenticates via MySQL connection attempt
├── config/             Runtime config volume (config.json — excluded from git)
├── docker-compose.yml
└── nginx.conf
```

---

## Database structure

The **admin database** (`ltpda_admin` by default) stores:
- `users` — web UI accounts + MySQL credentials
- `available_dbs` — registry of repository databases
- `options` — global settings

Each **repository database** uses the v2.5 schema (`objs`, `bobjs`, `objmeta`, `transactions`,
etc.) plus a `users` view that reads from the admin database — so MATLAB's internal queries work
unchanged.

Every application user has two independent passwords:

| Password | Purpose | Storage |
|----------|---------|---------|
| Web UI password | Log in to the web interface | bcrypt hash |
| MySQL / MATLAB password | MySQL account for JDBC access | Plaintext in `users` table — required to pass to `CREATE USER` |

The privileged MySQL account (entered during setup) is stored in `config/config.json` and used by
the backend to create databases, create MySQL users, and manage grants.
