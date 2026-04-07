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

This starts three containers: `mysql`, `api`, and `nginx`. The `api` container waits for MySQL to
pass its healthcheck before starting.

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

MATLAB connects to MySQL via JDBC. Because MySQL is inside Docker (not directly on the internet),
users connect through an **SSH tunnel**:

```bash
# On your local machine — keep this open while using MATLAB
ssh -L 3306:localhost:3307 your_linux_username@repo.yourdomain.com
```

This forwards your local port 3306 → host port 3307 → MySQL container port 3306.

In **LTPDAprefs**, set:
- **Hostname** — `localhost`
- **Port** — `3306`
- **Database** — the name of the repository database (e.g. `myrepo`)
- **Username / Password** — the MySQL credentials set when your user account was created

**Linux account required.** You need a Linux account on the server to authenticate the SSH tunnel.
Administrators can create one manually:

```bash
sudo useradd -m -s /usr/sbin/nologin -c "ltpda-managed" username
sudo passwd username
```

Or use the **SSH sync daemon** (see below) to have accounts created automatically whenever a user
is added via the web UI.

---

## SSH sync daemon (optional — bundled MySQL only)

The SSH sync daemon automates Linux account management on the host. When enabled in the setup
wizard, it automatically creates, updates, and removes Linux SSH accounts whenever users are added,
updated, or removed via the web UI.

It runs as a `root` systemd service on the host machine (outside Docker) and receives HMAC-signed
webhooks from the FastAPI container.

### What it does

- Creates tunnel-only accounts (`/usr/sbin/nologin` shell — port-forwarding only)
- Tags accounts with a GECOS marker (`ltpda-managed`); refuses to modify or delete any account it
  did not create
- Returns a 409 conflict error if a requested username already exists as a system account

### Prerequisites

- Python 3.9+ and `pip3` on the host
- Must be the same physical machine Docker is running on

### Installation

Install the daemon **before** running the setup wizard so you can test the connection during setup.

```bash
# 1. Copy daemon files to the host
sudo mkdir -p /opt/ltpda-ssh-sync
sudo cp ssh-sync-daemon/ssh_sync_daemon.py /opt/ltpda-ssh-sync/

# 2. Install Python dependency
sudo pip3 install flask

# 3. Create the config file
sudo cp ssh-sync-daemon/config.example.json /etc/ltpda-ssh-sync.json

# 4. Set the shared secret (generate one: openssl rand -hex 32)
sudo nano /etc/ltpda-ssh-sync.json
```

Config file format:

```json
{
  "port": 9922,
  "shared_secret": "your-strong-random-secret-here"
}
```

```bash
# 5. Install and enable the systemd service
sudo cp ssh-sync-daemon/ltpda-ssh-sync.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ltpda-ssh-sync

# 6. Verify
sudo systemctl status ltpda-ssh-sync
sudo journalctl -u ltpda-ssh-sync -n 20
```

### Firewall

```bash
# Allow Docker bridge only; block all other access to port 9922
sudo ufw allow from 172.16.0.0/12 to any port 9922
sudo ufw allow from 192.168.0.0/16 to any port 9922
```

### Enabling in the setup wizard

1. Install and start the daemon (steps above).
2. In the setup wizard, enable the **SSH sync daemon** toggle.
3. Enter the port (default 9922) and the **same shared secret** as in `/etc/ltpda-ssh-sync.json`.
4. Click **Test daemon connection** — the wizard contacts the daemon and shows a green confirmation
   if the connection and secret are correct.
5. Complete setup. The first admin user is synced to the daemon automatically.

After setup, the sync status is visible in **Admin → Users**. Click **Test** to re-verify at any time.

### Updating the daemon

```bash
sudo cp ssh-sync-daemon/ssh_sync_daemon.py /opt/ltpda-ssh-sync/
sudo systemctl restart ltpda-ssh-sync
```

### Troubleshooting

| Symptom | Likely cause |
|---------|-------------|
| "Cannot reach SSH sync daemon" | Daemon not running, or firewall blocking port 9922 |
| "Invalid signature" | Shared secret mismatch between wizard and config file |
| "Account conflict" | A system account with that username already exists on the host |
| `useradd` errors in journal | Daemon not running as root |

### Safety rules

- Sync failures are **non-fatal**: user CRUD always succeeds in the web UI; a sync error is shown
  as a warning.
- The daemon never touches accounts it did not create.

---

## Directory layout

```
repository/
├── backend/            FastAPI application (Python)
│   ├── core/           Config, database, security helpers
│   ├── routers/        API route handlers (setup, auth, users, sync)
│   └── Dockerfile
├── frontend/           Nuxt 4 SPA (Vue 3)
│   └── app/
│       ├── pages/      setup.vue, login.vue, dashboard.vue, admin/users.vue
│       ├── components/ AppLogo.vue, StatusOk.vue, StatusWarn.vue
│       └── composables/useAuth.ts
├── ssh-sync-daemon/    Host-side SSH account sync daemon
│   ├── ssh_sync_daemon.py
│   ├── ltpda-ssh-sync.service
│   ├── config.example.json
│   └── requirements.txt
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
