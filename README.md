# LTPDA — LISA Technology Package Data Analysis

> **Unofficial fork** of the [LTPDA Toolbox](https://www.lisamission.org/ltpda/index.html) (toolbox v3.0.13, repository v2.5), originally developed by the LISA Mission team.

A MATLAB toolbox for **accountable and reproducible data analysis**, with a built-in repository for storing, sharing, and retrieving analysis objects and results.

## Fork maintainer

**Simon Barke** — Precision Space Systems Lab (PSSL), University of Florida
<simon.barke@gmail.com>

Please [open an issue on GitHub](https://github.com/gulbrillo/LTPDA/issues) for bug reports, compatibility problems, or questions about this fork.

## Goals of this fork

- Restore compatibility with **MATLAB R2025a and beyond** (the upstream toolbox targets R2012b era MATLAB)
- Modernise the repository server so it can be deployed on **current server infrastructure** without legacy LAMP stack constraints

---

## Status

All changes are relative to upstream v3.0.13. The toolbox has been updated for R2025a compatibility; the repository server has not been modified yet.

### Toolbox

**R2025a API removals — language and built-ins**

| Change | Reason | Files |
|--------|--------|-------|
| `nargchk` → `narginchk` | `nargchk` removed in R2025a | `@repository/report.m`, `@math/rootmusic.m`, `@ao/computeperiodogram.m`, `@ao/computeDFT.m` and others |
| Shell escape `!` → `delete()`/`system()` | Shell escape syntax removed in R2025a | `@math/diffStepFish.m`, `@math/diffStepFish_1x1.m`, `@ssm/diffStepFish.m` |
| `findstr` → `contains`/`strfind` | `findstr` removed in R2021b | `MakeContents.m`, `@helper/remove_svn_from_matlabpath.m` |
| `verLessThan` → `isMATLABReleaseOlderThan` | Version string format changed in R2025a, making `verLessThan` unreliable | `ltpda_startup.m` and version-branch guards |
| `sym('expression')` → `str2sym('expression')` | `sym()` no longer accepts symbolic expressions (only variable names and numbers) in R2025a | `examples/test_isequal.m` |
| Minimum MATLAB version check added to startup | Provides a clear error instead of cryptic failures on unsupported versions | `m/etc/ltpda_startup.m` |

**R2025a API removals — internal MathWorks Java classes**

| Change | Reason | Files |
|--------|--------|-------|
| `com.mathworks.mde.cmdwin.*` removed — coloured output replaced with plain `fprintf` | Internal command-window Java classes removed in R2025a | `LTPDAprintf.m`, `cprintf/cprintf.m` |
| `com.mathworks.xml.XMLUtils` → `matlab.io.xml.dom` | `XMLUtils` removed in R2025a; standard DOM API used instead | `@ltpda_uo/save.m` |
| `com.mathworks.mlwidgets.io.InterruptibleStreamCopier` removed — replaced with built-in `unzip` | Internal stream-copier class removed in R2025a | `@helper/dunzip.m` |
| `javax.swing.JOptionPane` → `errordlg`/`warndlg` | Java Swing dialogs in helpers broken in R2025a | `@helper/errorDlg.m`, `@helper/warnDlg.m` |

**Bug fixes**

| Change | Reason | Files |
|--------|--------|-------|
| `msym` constructor: added `nargin == 0` early return | Constructor accessed `varargin{1}` unconditionally; crashed `ltpda_obj.newarray` when allocating arrays of `msym` objects, causing 11 test failures | `@msym/msym.m` |
| `iplot`: apply `Theme = 'light'` per figure | R2025a's theme system overrides root `Default*` properties under OS dark mode, causing a black plot background; theme must be set per figure | `@ao/iplot.m` |
| `iplot`: re-apply `grid on` after theme change | Setting `Theme` on a figure can reset axis grid state | `@ao/iplot.m` |

**GUI rewrites (Java Swing backends removed in R2025a)**

All LTPDA GUIs were thin MATLAB wrappers around Java Swing backends in the bundled JAR files. These have been rewritten using pure MATLAB `uifigure`/`uicontrol`. The underlying data and preference logic is unchanged.

| Component | Replacement |
|-----------|-------------|
| `LTPDAprefs` — preferences dialog | `uifigure` with 5 tabs (Display, Plot, Extensions, Time, Misc) |
| `LTPDADatabaseConnectionManager` — credentials and database-selector dialogs | `inputdlg` for credentials, `listdlg` for database selection |
| `submitDialog` — repository upload metadata form | `uifigure` form with `uiwait`-based blocking |
| `LTPDARepositoryQuery` — repository query dialog | `uifigure` with SQL text area, `uitable` results, and workspace retrieval |
| `LTPDAModelBrowser` — built-in model browser | `uifigure` with listbox and documentation text area |

**Test result: 108/108 tests pass on R2025a.**

### Repository server

No changes have been made to the repository server. See goals above.

---

## Toolbox installation

### Requirements

- MATLAB (this fork targets R2025a+)

### Steps

1. **Add the toolbox to the MATLAB path**

   Open MATLAB, go to **HOME → Set Path → Add with Subfolders**, select the `toolbox/` directory, and save.

   Alternatively, run in the MATLAB command window:
   ```matlab
   addpath(genpath('/path/to/LTPDA/toolbox'));
   savepath;
   ```

2. **Initialise the toolbox**

   ```matlab
   ltpda_startup
   ```

   This launches the LTPDA Launchbay and loads the toolbox.

3. **Build the documentation search index** (optional but recommended)

   ```matlab
   utils.helper.buildSearchDatabase()
   ```

4. **Open the preferences GUI** (optional)

   ```matlab
   LTPDAprefs
   ```

   Use this to configure display settings, plotting defaults, time formats, repository connection details, and custom units.

5. **Auto-startup** (optional)

   Add `ltpda_startup` to your personal `startup.m` file so the toolbox loads automatically with MATLAB.

6. **Verify the installation**

   ```matlab
   run_tests
   ```

---

## Repository server installation

Two versions of the repository server exist. Choose based on what you are connecting to:

| Version | Stack | Status |
|---------|-------|--------|
| **v3.0** (this fork) | Nuxt 4 + FastAPI + MySQL (v2.5-compatible schema), Docker | New — recommended for new deployments |
| **v2.5 and below** (upstream/legacy) | PHP + MySQL + Ruby/Gnuplot, Apache | Legacy — instructions below |

---

## Repository v3.0 (Docker)

### How it works

The v3.0 repository is a rewrite of the web frontend and backend. The database structure is **compatible with v2.5**: one MySQL database per repository, per-user MySQL accounts, and a privileged admin account managed by the application. MATLAB connects directly via JDBC using the same credentials as before — no toolbox changes required.

```
Apache (your existing web server)
  └── reverse proxy → Docker container (port 8080, localhost only)
        ├── nginx  →  Nuxt 4 SPA (static files, client-side rendering)
        └── nginx  →  FastAPI REST API (Python, uvicorn)
                           └── MySQL (bundled container OR external dedicated server)
                                 ├── ltpda_admin        ← users, repo registry, options
                                 ├── myrepo             ← per-repository database (v2.5 schema)
                                 └── anotherrepo        ← per-repository database
```

Key differences from v2.5:

- **No PHP.** The backend is Python (FastAPI). The frontend is a compiled Vue/Nuxt SPA.
- **No Ruby or Gnuplot.** Plot generation uses Python/matplotlib (Phase 5).
- **Same database structure as v2.5.** One MySQL database per repository. Each user gets a MySQL account. The application holds a privileged MySQL account (root or equivalent) to create databases and user accounts on demand.
- **Two MySQL deployment options.** MySQL can run as a bundled container (simplest) or connect to an external dedicated MySQL server.
- **First-run wizard.** On first visit the web UI shows a setup page. The wizard creates the admin database, sets up credentials, and creates the first admin user — you never edit config files manually.
- **MATLAB connects to MySQL directly** (unchanged from v2.5) — the MATLAB toolbox bypasses the web API entirely and talks to MySQL over JDBC on port 3306.

> **Shared hosting not supported.** The repository needs to create and drop MySQL databases and user accounts. It requires a dedicated MySQL server (or the bundled container). It is **not compatible** with shared hosting environments (cPanel, Plesk, shared MySQL servers).

### Database structure

The admin database (default name `ltpda_admin`, configurable at setup) stores the user registry, the list of repository databases, and global options. Each repository gets its own MySQL database with the v2.5 schema (`objs`, `bobjs`, `objmeta`, `transactions`, etc.). Each repo database also contains a `users` view that reads from the admin database, so MATLAB's internal queries work unchanged.

Every application user has **two separate passwords**:

| Password | Purpose | How it is stored |
|----------|----------|-----------------|
| **Web UI password** | Log in to the web interface | bcrypt hash — never stored in recoverable form |
| **MySQL / MATLAB password** | MySQL account used by MATLAB over JDBC | Stored in the `users` table — must be recoverable to pass to MySQL `CREATE USER` |

These are set independently and can be changed independently. You can make them the same value if you prefer, but they are managed separately.

### Privileged MySQL account

The admin MySQL account (root or any account with `CREATE DATABASE`, `CREATE USER`, and `GRANT`) is entered during the setup wizard and **stored in `config/config.json`**. It is not a one-time credential — the backend uses it continuously to:

- Create a MySQL database when a new repository is added
- Create a MySQL user account when a new user is created
- Grant per-user permissions on each repository database
- Drop a MySQL user account when a user is deleted

This matches v2.5 behaviour, where `config.inc.php` held the privileged database credentials for all operations.

### Requirements

**Server:**
- Linux VPS or dedicated server
- Docker Engine 24+ and Docker Compose v2 (`docker compose` command)
- Apache 2.4+ (or Nginx) as the front-facing web server
- A domain or subdomain pointing to your server (e.g. `repo.yourdomain.com`)
- MySQL: either use the **bundled** MySQL container (no separate installation needed) or provide an **external dedicated** MySQL 5.7+ / MariaDB 10.5+ server

**Build machine (to compile the frontend):**
- Node.js 20+ and npm — required to build the Nuxt frontend into static files. Can be done on your laptop or on the server.

### Installation

#### 1. Clone the repository

```bash
git clone https://github.com/gulbrillo/LTPDA.git
cd LTPDA/repository
```

#### 2. Install Docker

If Docker is not already installed on your server:

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER   # allow running docker without sudo (re-login after)
```

Verify: `docker compose version` should show v2.x.

#### 3. Build the Nuxt frontend

```bash
cd repository/frontend
npm install
npm run generate        # outputs static files to frontend/.output/public/
cd ..
```

> You must re-run `npm run generate` and restart Docker whenever the frontend source changes.

#### 4. Configure the Apache vhost

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
    ProxyPass        / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>
```

```bash
sudo a2enmod proxy proxy_http ssl
sudo systemctl reload apache2
sudo certbot --apache -d repo.yourdomain.com   # obtain SSL certificate
```

#### 5. Start Docker

**Option A — Bundled MySQL** (recommended for new deployments):

Create a `.env` file in `repository/` with the MySQL root password:

```bash
echo "MYSQL_ROOT_PASSWORD=choose_a_strong_password" > .env
```

Then start all containers including the bundled MySQL service:

```bash
docker compose --profile bundled up -d
```

This starts three containers: `mysql`, `api`, and `nginx`.

**Option B — External dedicated MySQL server:**

```bash
docker compose up -d
```

This starts only `api` and `nginx`. You will point the app at your external MySQL server during the setup wizard. The `extra_hosts` entry in `docker-compose.yml` allows the API container to reach `host.docker.internal` (your server's host machine) if MySQL is running there.

> **External MySQL — allow Docker connections:** By default MySQL binds to `127.0.0.1` only. If your MySQL is on the same host as Docker, add `bind-address = 0.0.0.0` to `/etc/mysql/mysql.conf.d/mysqld.cnf` and restart MySQL. Keep port 3306 firewalled from external traffic.

Check that containers are running: `docker compose ps`

#### 6. Run the setup wizard

Open `https://repo.yourdomain.com` in a browser. You will be redirected to the setup page.

Choose a MySQL deployment mode:

**Bundled MySQL** — MySQL runs inside Docker. Enter the root password you set in `.env`. The admin database name defaults to `ltpda_admin`.

**External MySQL** — Enter the host, port, and admin account credentials (needs `CREATE DATABASE`, `CREATE USER`, `GRANT` — does not need to be root). The wizard creates the admin database and first user.

Both modes require a first admin user with:
- **Web UI password** — used to log in to the web interface (bcrypt, not stored in MySQL)
- **MySQL / MATLAB password** — used to create a MySQL account for this user; MATLAB connects via JDBC using these credentials

Click **Run Setup**. The wizard creates the admin database schema, the first admin's MySQL user account, and stores the privileged MySQL credentials in `repository/config/config.json` (excluded from git). You are redirected to the login page.

#### 7. Verify

- Log in with the admin credentials you entered in the wizard.
- The dashboard should show "No repositories yet."
- `GET https://repo.yourdomain.com/api/health` should return `{"status":"ok","configured":true}`.

### Updating

```bash
git pull
cd repository/frontend && npm install && npm run generate  # rebuild frontend if changed
cd ..
docker compose --profile bundled up -d --build   # (or without --profile bundled for external mode)
```

### Configuring MATLAB

MATLAB connects to the bundled MySQL container via JDBC. Because MySQL is inside Docker (not
directly exposed to the internet), users connect through an **SSH tunnel**:

1. **Create an SSH tunnel** on your local machine before launching MATLAB:
   ```bash
   ssh -L 3306:localhost:3307 your_linux_username@repo.yourdomain.com
   ```
   This forwards your local port 3306 to the host's port 3307, which Docker maps to the MySQL container.
   Keep this terminal open while using MATLAB.

2. **In `LTPDAprefs`**, set:
   - **Hostname** — `localhost`
   - **Port** — `3306`
   - **Database** — the name of the repository database (e.g. `myrepo`)
   - **Username / Password** — the MySQL credentials set when your user account was created

3. **Linux account required.** You need a Linux account on the server to authenticate the SSH tunnel.
   Ask your repository administrator to create one, or see the SSH sync daemon section below.

---

### SSH sync daemon (optional — bundled MySQL mode only)

The SSH sync daemon automates Linux account management. When enabled in the setup wizard, it
automatically creates and removes Linux SSH accounts whenever users are added or removed via the
web UI — eliminating the manual `useradd`/`userdel` step.

#### What it does

- Runs on the host machine as a `root` systemd service
- Listens for webhook calls from the FastAPI container on a configurable port (default: **9922**)
- All webhooks are HMAC-SHA256 signed using a shared secret configured during setup
- Creates tunnel-only accounts (`/usr/sbin/nologin` shell — no interactive access)

#### Installation

```bash
# 1. Copy the daemon files to the host
sudo mkdir -p /opt/ltpda-ssh-sync
sudo cp repository/ssh-sync-daemon/ssh_sync_daemon.py /opt/ltpda-ssh-sync/

# 2. Install the Python dependency
sudo pip3 install flask

# 3. Create the config file
sudo cp repository/ssh-sync-daemon/config.example.json /etc/ltpda-ssh-sync.json
# Edit /etc/ltpda-ssh-sync.json — paste the shared_secret shown in the setup wizard
sudo nano /etc/ltpda-ssh-sync.json

# 4. Install and start the systemd service
sudo cp repository/ssh-sync-daemon/ltpda-ssh-sync.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now ltpda-ssh-sync

# 5. Verify it is running
sudo systemctl status ltpda-ssh-sync
```

#### Firewall

The daemon binds to `0.0.0.0:9922`. Restrict access to the Docker bridge network only:

```bash
# Allow Docker bridge (172.16.0.0/12) to reach port 9922; block everything else
sudo ufw allow from 172.16.0.0/12 to any port 9922
```

#### Testing the connection

After logging in as an administrator, go to **Admin → Users**. A status bar at the top shows the
daemon state. Click **Test** to verify the Docker container can reach the daemon.

---

## Repository v2.5 (legacy)

### Requirements

| Component | Minimum version |
|-----------|----------------|
| Apache    | 2.2.6          |
| MySQL     | 5.0            |
| PHP       | 5.2.4          |
| Ruby      | 1.8.7          |
| Gnuplot   | any recent     |
| Sendmail / Postfix / qmail | — |

### Steps

1. **Configure MySQL** — set `max_allowed_packet = 256M` in `my.cnf` and restart the MySQL service.

2. **Configure PHP** — set `memory_limit = 256M` in `php.ini` and restart Apache.

3. **Deploy the repository files**

   ```bash
   unzip ltpdarepo.zip
   cp -r ltpdarepo/ /var/www/html/ltpdarepo/
   chown -R apache:apache /var/www/html/ltpdarepo/
   chmod a+w /var/www/html/ltpdarepo/config.inc.php
   ```

4. **Run the web installer**

   Navigate to `http://<your-server>/ltpdarepo/install.php` and follow the on-screen instructions.

5. **Harden after installation**

   ```bash
   rm /var/www/html/ltpdarepo/install.php
   chmod 640 /var/www/html/ltpdarepo/config.inc.php
   ```

6. **Configure plot generation** — in the repository web interface, go to General Options and set the internal/external plot paths and the robot script location (`ltpdareporobot.rb`).

For scheduled XML dumps, copy `ltpdareporobot.rb` to `/root/bin` with appropriate execute permissions and add a cron entry.

---

## Upstream documentation

- Toolbox user manual: https://www.lisamission.org/ltpda/usermanual/ug/setup.html
- Repository installation guide: https://www.lisamission.org/ltpda/repository/repoinstallation/repoinstallation.html
- LTPDA project home: https://www.lisamission.org/ltpda/index.html

---

## Creating a release

The script `make_release.sh` in the repo root handles everything: zipping the toolbox and repository, creating the GitHub release, and attaching both assets.

### Prerequisites

1. Install the [GitHub CLI](https://cli.github.com/) — on Windows:
   ```powershell
   winget install GitHub.cli
   ```

2. Authenticate (one-time):
   ```bash
   gh auth login
   ```

### Run

```bash
bash make_release.sh
```

The script will prompt before committing uncommitted changes and before deleting the local zip files. Edit the version and tag constants at the top of the script if they ever need to change.

---

## Contributing

This fork is a work in progress. Please [open an issue on GitHub](https://github.com/gulbrillo/LTPDA/issues) for bug reports, compatibility fixes, or questions. Pull requests are welcome.
