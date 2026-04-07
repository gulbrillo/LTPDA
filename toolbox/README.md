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
- **Hostname** — `localhost` (if using an SSH tunnel) or the server hostname
- **Port** — `3306` (or the forwarded port)
- **Database** — the name of the repository database
- **Username / Password** — your MySQL credentials (set by the repository administrator)

For the Docker-based v3.0 repository, users connect via SSH tunnel. See
`../repository/README.md` for details.

---

## Upstream documentation

- User manual: https://www.lisamission.org/ltpda/usermanual/ug/setup.html
- LTPDA project home: https://www.lisamission.org/ltpda/index.html
