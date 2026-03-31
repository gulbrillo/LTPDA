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

The LTPDA repository is a web application that stores analysis objects and results, allowing them to be retrieved directly from MATLAB.

### Requirements (upstream/legacy)

| Component | Minimum version |
|-----------|----------------|
| Apache    | 2.2.6          |
| MySQL     | 5.0            |
| PHP       | 5.2.4          |
| Ruby      | 1.8.7          |
| Gnuplot   | any recent     |
| Sendmail / Postfix / qmail | — |

> **Note:** One goal of this fork is to remove or replace these legacy dependencies so the repository can run on a modern stack.

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

## Contributing

This fork is a work in progress. Please [open an issue on GitHub](https://github.com/gulbrillo/LTPDA/issues) for bug reports, compatibility fixes, or questions. Pull requests are welcome.
