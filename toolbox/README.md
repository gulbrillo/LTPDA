# LTPDA Toolbox

MATLAB toolbox for accountable and reproducible data analysis. This is a fork of upstream
v3.0.13, updated for compatibility with **MATLAB R2025a and beyond**.

---

## Requirements

- MATLAB R2025a or later

Older MATLAB versions may work but are not tested. The upstream release targeted R2012b-era MATLAB;
this fork removes the API calls that were removed in R2025a.

---

## Installation

### 1. Add to MATLAB path

In MATLAB:

```matlab
addpath(genpath('/path/to/LTPDA/toolbox'));
savepath;
```

Or use **HOME → Set Path → Add with Subfolders**, select this `toolbox/` directory, and save.

### 2. Initialise

```matlab
ltpda_startup
```

This launches the LTPDA Launchbay and loads all toolbox classes.

### 3. Build the documentation search index (optional)

```matlab
utils.helper.buildSearchDatabase()
```

### 4. Auto-startup (optional)

Add `ltpda_startup` to your MATLAB `startup.m` file:

```matlab
% In ~/Documents/MATLAB/startup.m
ltpda_startup
```

### 5. Verify

```matlab
run_tests
```

All 108 tests should pass.

---

## R2025a compatibility changes

The following upstream API calls were removed or broken in R2025a and have been replaced:

**Language and built-ins:**

| Removed | Replacement | Files |
|---------|------------|-------|
| `nargchk` | `narginchk` | `@repository/report.m`, `@ao/computeperiodogram.m`, and others |
| Shell escape `!` | `delete()` / `system()` | `@math/diffStepFish.m`, `@ssm/diffStepFish.m` |
| `findstr` | `contains` / `strfind` | `MakeContents.m`, `@helper/remove_svn_from_matlabpath.m` |
| `verLessThan` | `isMATLABReleaseOlderThan` | `ltpda_startup.m` and version guards |
| `sym('expression')` | `str2sym('expression')` | `examples/test_isequal.m` |

**Internal MathWorks Java classes:**

| Removed | Replacement | Files |
|---------|------------|-------|
| `com.mathworks.mde.cmdwin.*` | plain `fprintf` | `LTPDAprintf.m`, `cprintf.m` |
| `com.mathworks.xml.XMLUtils` | `matlab.io.xml.dom` | `@ltpda_uo/save.m` |
| `com.mathworks.mlwidgets.io.InterruptibleStreamCopier` | built-in `unzip` | `@helper/dunzip.m` |
| `javax.swing.JOptionPane` | `errordlg` / `warndlg` | `@helper/errorDlg.m`, `@helper/warnDlg.m` |

**GUI rewrites** (Java Swing backends removed in R2025a):

| Component | Replacement |
|-----------|-------------|
| `LTPDAprefs` | `uifigure` with 5 tabs |
| `LTPDADatabaseConnectionManager` credentials dialog | `inputdlg` |
| `LTPDADatabaseConnectionManager` database-selector dialog | `listdlg` |
| `submitDialog` | `uifigure` form with `uiwait` |
| `LTPDARepositoryQuery` | `uifigure` with SQL text area and `uitable` |
| `LTPDAModelBrowser` | `uifigure` with listbox and documentation pane |

**Bug fixes:**

| Fix | Files |
|----|-------|
| `msym` constructor: added `nargin == 0` early return (crashed `ltpda_obj.newarray`) | `@msym/msym.m` |
| `iplot`: apply `Theme = 'light'` per figure (R2025a dark mode overrides root defaults) | `@ao/iplot.m` |
| `iplot`: re-apply `grid on` after theme change | `@ao/iplot.m` |

---

## Directory layout

```
toolbox/
├── classes/        LTPDA class definitions (@ao, @ltpda_uo, @plist, etc.)
├── m/              Helper functions, startup scripts, GUI code
├── examples/       Example scripts and test suite (run_tests.m)
├── jar/            Bundled Java JARs (connection manager, pipeline, etc.)
├── help/           HTML documentation
└── src/            Java source (reference only — not needed at runtime)
```

---

## Connecting to the repository

MATLAB connects to an LTPDA repository via JDBC (MySQL). Configure the connection in the
preferences GUI:

```matlab
LTPDAprefs
```

Go to the **Repository** tab and set:
- **Hostname** — `localhost` (when using any SSH tunnel)
- **Port** — the local tunnel port (see below; default `13306`)
- **Database** — the name of the repository database (e.g. `myrepo`)
- **Username / Password** — your MySQL/MATLAB credentials (set by the administrator)

### SSH tunnel options

Because MySQL runs inside Docker and is not directly accessible from the internet, MATLAB connects
through an SSH tunnel. Three options are supported — all use the same LTPDAprefs settings.

#### Option 1 — Automatic tunnel from within MATLAB (recommended)

Works on **Windows and Mac without PuTTY or any external tools**. Requires the SSH gateway
container on the server (port 2222 must be open in the server firewall: `sudo ufw allow 2222/tcp`).

**One-time setup:**
```matlab
ltpda_ssh_setup('server', 'repo.yourdomain.com')  % your repository server
ltpda_ssh_setup enable
% In LTPDAprefs: Hostname=localhost, Port=13306
```

The tunnel is established automatically each time `ltpda_startup` runs. If the tunnel drops
(e.g. network interruption), reconnect without restarting MATLAB:
```matlab
ltpda_tunnel    % reconnects silently using stored credentials; prompts if needed
```

#### Option 2 — Manual tunnel via terminal or PuTTY (SSH gateway, port 2222)

Run in a terminal (Mac/Linux) or configure in PuTTY (Windows), keep open while using MATLAB:

```bash
ssh -L 13306:db:3306 -p 2222 your_username@repo.yourdomain.com
```

In LTPDAprefs: `Hostname=localhost`, `Port=13306`.

#### Option 3 — Manual tunnel via host SSH (port 22, fallback)

Use this if port 2222 cannot be opened on the server. Requires a Linux account on the host
server (created manually by the administrator).

```bash
ssh -L 13306:localhost:3307 your_linux_username@repo.yourdomain.com
```

In LTPDAprefs: `Hostname=localhost`, `Port=13306`.

### LTPDAprefs summary

All three options use identical MATLAB settings:

| Setting | Value |
|---------|-------|
| Hostname | `localhost` |
| Port | `13306` (or whatever local port you forwarded) |
| Database | repository database name (e.g. `myrepo`) |
| Username | your username |
| Password | your **MySQL/MATLAB** password (not the web UI password) |

> **Note:** The MySQL/MATLAB password is the one set when your account was created in the web UI —
> separate from the web interface login password.

For server-side setup (Docker stack, SSH gateway container, port 2222, user management), see
`../repository/README.md`.

---

## Upstream documentation

- User manual: https://www.lisamission.org/ltpda/usermanual/ug/setup.html
- LTPDA project home: https://www.lisamission.org/ltpda/index.html
