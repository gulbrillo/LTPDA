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
| **v3.0** (this fork) | Nuxt 4 + FastAPI + MySQL, Docker | New — recommended for new deployments |
| **v2.5 and below** (upstream/legacy) | PHP + MySQL + Ruby/Gnuplot, Apache | Legacy — instructions below |

---

## Repository v3.0 (Docker)

### How it works

The v3.0 repository is a complete rewrite of the web frontend and backend. The architecture is:

```
Apache (your existing web server)
  └── reverse proxy → Docker container (port 8080, localhost only)
        ├── nginx  →  Nuxt 4 SPA (static files, client-side rendering)
        └── nginx  →  FastAPI REST API (Python, uvicorn)
                           └── your existing MySQL server (host machine, port 3306)
```

Key differences from v2.5:

- **No PHP.** The backend is Python (FastAPI). The frontend is a compiled Vue/Nuxt SPA.
- **No per-user MySQL accounts.** User authentication is handled entirely by the application using bcrypt passwords and JWT tokens. A single MySQL service account is used for all database access.
- **Single MySQL database.** All repositories live in one database (`ltpda_repo` by default), separated internally by a `repository_id` column. No `CREATE DATABASE` or `GRANT` required after initial setup.
- **No Ruby or Gnuplot.** Plot generation uses Python/matplotlib inside the Docker container.
- **First-run wizard.** On first visit the web UI shows a setup page where you enter MySQL credentials. The app creates the database, service account, and first admin user automatically — you never edit config files manually.
- **MATLAB connects to MySQL directly** (unchanged from v2.5) — the MATLAB toolbox bypasses the web API entirely and talks to MySQL over JDBC on port 3306. See the MATLAB configuration section below.

### Requirements

**Server:**
- Linux VPS or dedicated server
- Docker Engine 24+ and Docker Compose v2 (`docker compose` command)
- Apache 2.4+ (or Nginx) as the front-facing web server — your existing server works
- MySQL 5.7+ or MariaDB 10.5+ running on the host (not in Docker)
- A domain or subdomain pointing to your server (e.g. `repo.yourdomain.com`)

**MySQL privileges needed for setup:**
- One MySQL account with enough privileges to `CREATE DATABASE`, `CREATE USER`, and `GRANT` — typically the MySQL root account or a dedicated admin account. This is used **once** during the setup wizard and the credentials are never stored by the application.

**Build machine (to compile the frontend):**
- Node.js 20+ and npm — required to build the Nuxt frontend into static files before deployment. This can be done on your local machine or on the server.

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

The frontend is a Vue/Nuxt application that must be compiled into static HTML/JS/CSS files before Docker can serve it. Run this on any machine that has Node.js 20+ installed (your laptop or the server).

```bash
cd repository/frontend
npm install
npm run generate        # outputs static files to frontend/.output/public/
```

> You must re-run `npm run generate` and restart Docker whenever the frontend source changes.

#### 4. Configure the Apache vhost

Add a new virtual host to your Apache configuration (replace `repo.yourdomain.com` with your actual subdomain):

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

Enable the required Apache modules and reload:

```bash
sudo a2enmod proxy proxy_http ssl
sudo systemctl reload apache2
```

To obtain an SSL certificate with Let's Encrypt:

```bash
sudo certbot --apache -d repo.yourdomain.com
```

#### 5. Start Docker

From the `repository/` directory:

```bash
docker compose up -d
```

This starts two containers:
- **api** — FastAPI backend (Python), connects to your host MySQL on `host.docker.internal:3306`
- **nginx** — serves the Nuxt static build and proxies `/api/` requests to the FastAPI container

Check that both are running: `docker compose ps`

#### 6. Run the setup wizard

Open `https://repo.yourdomain.com` in a browser. You will be redirected to the setup page. Fill in:

1. **MySQL connection** — hostname (`localhost` or your MySQL host), port (default 3306), desired database name (default `ltpda_repo`), and your MySQL admin username/password (e.g. `root`). These credentials are used once to create the database and service account and are never stored.
2. **Service account** — a new MySQL username and password that the application will use for all ongoing database access. The account is created automatically with SELECT/INSERT/UPDATE/DELETE privileges only.
3. **First admin user** — username and password for the first repository administrator.

Click **Run Setup**. The wizard creates the database schema, service account, and admin user, then stores the service account credentials in `repository/config/config.json` (this file is excluded from git). You are redirected to the login page.

#### 7. Verify

- Log in with the admin credentials you entered in the wizard.
- The dashboard should show "No repositories yet."
- `GET https://repo.yourdomain.com/api/health` should return `{"status":"ok","configured":true}`.

### Updating

To update the application:

```bash
git pull
cd repository/frontend && npm install && npm run generate  # rebuild frontend if changed
cd ..
docker compose up -d --build                               # rebuild and restart containers
```

### Configuring MATLAB to use Repository v3.0

See [MATLAB toolbox — repository preferences](#toolbox-installation) (Phase 5, not yet implemented). In the current release, the MATLAB toolbox connects to the repository using the legacy v2.5 protocol (direct JDBC to a named MySQL database). Full v3.0 MATLAB integration is planned for the next release.

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
