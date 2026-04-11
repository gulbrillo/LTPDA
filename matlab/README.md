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

Two installation paths are supported. **Do not use both at the same time** — having the
toolbox on the path from two locations causes class-definition conflicts. `ltpda_startup`
will warn if it detects this.

---

### Option A — Manual (`addpath`)

Suitable for development or when you want full control over which files are loaded.

#### 1. Add to MATLAB path

```matlab
addpath(genpath('/path/to/LTPDA/matlab'));
savepath;
```

Or use **HOME → Set Path → Add with Subfolders**, select this `matlab/` directory, and save.

#### 2. Auto-startup (recommended)

Add `ltpda_startup` to your MATLAB `startup.m`:

```matlab
% In ~/Documents/MATLAB/startup.m
ltpda_startup
```

#### 3. Initialise manually (if not using startup.m)

```matlab
ltpda_startup
```

---

### Option B — Add-On Manager (`.mltbx`)

Recommended for end-users. Provides clean install/uninstall and version management.
MATLAB adds the toolbox to the path automatically; three LTPDA buttons appear in the
**APPS** tab of the ribbon.

#### 1. Build the package (maintainer step — requires MATLAB)

From the repository root:

```matlab
run make_package.m
```

This produces `LTPDA.mltbx` in the repository root. Distribute this file to users.

#### 2. Install

In MATLAB: **HOME → Add-Ons → Install Add-On**, select `LTPDA.mltbx`.

The toolbox appears in **HOME → Add-Ons → Manage Add-Ons** and can be updated or
uninstalled from there.

#### 3. Auto-startup

Add `ltpda_startup` to your MATLAB `startup.m` (still required — the Add-On Manager
handles the path but does not run startup scripts automatically):

```matlab
% In ~/Documents/MATLAB/startup.m
ltpda_startup
```

#### 4. APPS tab buttons

After installation, three buttons appear in the MATLAB **APPS** tab under **LTPDA**:

| Button | Action |
|--------|--------|
| LTPDA Startup | Run `ltpda_startup` |
| LTPDA Prefs | Open preferences dialog |
| SSH Tunnel | Connect/reconnect repository tunnel |

---

### Verify

```matlab
run_tests
```

All 108 tests should pass.

---

### Build the documentation search index (optional)

```matlab
utils.helper.buildSearchDatabase()
```

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
matlab/
├── classes/        LTPDA class definitions (@ao, @ltpda_uo, @plist, etc.)
│   └── +utils/     Utility namespace: @ssh, @DuoHandler, @credentials, ...
├── m/              Helper functions, startup scripts, GUI code
├── examples/       Example scripts and test suite (run_tests.m)
├── jar/            Bundled Java JARs
│   ├── jsch-0.2.21.jar   Modern JSch (mwiede fork) — replaces MATLAB's bundled 0.1.54
│   ├── ConnectionManager.jar
│   ├── MPipeline.jar
│   └── lib/
├── help/           HTML documentation
├── java/           Java source for bundled helper classes
│   └── com/ltpda/ssh/LTPDAUserInfo.java   JSch UserInfo + MFA handler
└── src/            Java source (reference only — not needed at runtime)
```

---

## SSH and Java library notes

### Bundled JSch 0.2.x (mwiede fork)

MATLAB ships with an ancient JSch 0.1.54 (2018, unmaintained). This causes a
**"Signature Encoding Error"** when connecting to servers that require SHA-256/512 RSA
signatures, and it lacks modern key-exchange algorithms (`curve25519`, `ed25519`).

This fork bundles `jsch-0.2.21.jar` (the [mwiede/jsch](https://github.com/mwiede/jsch)
drop-in replacement). On the **first `ltpda_startup`** after installing this fork, MATLAB
will print:

```
LTPDA: Modern JSch (0.2.x) added to static Java classpath:
       C:\...\javaclasspath.txt
       ** Restart MATLAB once for SSH tunnels to work. **
```

Restart MATLAB once. After that you can verify:

```matlab
char(com.jcraft.jsch.JSch().VERSION)   % → '0.2.21'
```

The patch is idempotent — `ltpda_startup` will not print the message again.

### MFA / Duo Push support

The SSH tunnel (`ltpda_tunnel`) supports **keyboard-interactive multi-factor authentication**
(e.g. Duo Push on HiPerGator or other institutional HPC clusters) in addition to plain
password auth. When connecting to an MFA-enabled server, `ltpda_tunnel` prints:

```
Connecting SSH tunnel to hipergator.rc.ufl.edu:22 ...
LTPDA SSH MFA: Duo two-factor login for alice
Enter a passcode or select one of the following options:
 1. Duo Push to XXX-XXX-1234
(1-1): — selecting 1 (Push)
```

Check your phone and approve the push. The 30-second connection timeout gives enough time.

If your server uses plain password auth, the MFA path is never triggered — everything
works the same as before.

Authentication is handled by `com.ltpda.ssh.LTPDAUserInfo`, a compiled Java class bundled
as `jar/ltpda-ssh.jar`. It implements JSch's `UserInfo` and `UIKeyboardInteractive`
interfaces directly in Java — this is necessary because MATLAB's `classdef` inheritance from
Java interfaces only works for JARs on the *dynamic* classpath, which conflicts with MATLAB's
own bundled `jsch.jar`. The pre-compiled Java class has no such limitation.

Source: `java/com/ltpda/ssh/LTPDAUserInfo.java`. To rebuild after editing:

```bash
# from matlab/ directory — must target --release 8: MATLAB R2025a static classpath is Java 8
javac --release 8 -cp jar/jsch-0.2.21.jar -d java java/com/ltpda/ssh/LTPDAUserInfo.java
python3 -c "
import zipfile
with zipfile.ZipFile('jar/ltpda-ssh.jar','w') as z:
    z.writestr('META-INF/MANIFEST.MF','Manifest-Version: 1.0\n')
    z.write('java/com/ltpda/ssh/LTPDAUserInfo.class','com/ltpda/ssh/LTPDAUserInfo.class')
"
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

The tunnel is established automatically each time `ltpda_startup` runs.

Tunnel management:

```matlab
ltpda_tunnel            % establish or reconnect (prompts if no stored credentials)
ltpda_tunnel close      % disconnect the active tunnel
ltpda_tunnel(u, pw)     % connect with explicit credentials
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
