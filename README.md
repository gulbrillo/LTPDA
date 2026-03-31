# LTPDA — Linear Time-invariant Physical Data Analysis

> **Unofficial fork** of the [LTPDA Toolbox](https://www.lisamission.org/ltpda/index.html) (toolbox v3.0.13, repository v2.5), originally developed by the LISA Mission team.

A MATLAB toolbox for **accountable and reproducible data analysis**, with a built-in repository for storing, sharing, and retrieving analysis objects and results.

## Goals of this fork

- Restore compatibility with **MATLAB R2025a and beyond** (the upstream toolbox targets R2012b era MATLAB)
- Modernise the repository server so it can be deployed on **current server infrastructure** without legacy LAMP stack constraints

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

This fork is a work in progress. Contributions, bug reports, and compatibility fixes for modern MATLAB and server environments are welcome — open an issue or pull request.
