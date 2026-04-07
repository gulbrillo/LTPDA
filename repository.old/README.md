# LTPDA Repository v2.5 (legacy)

This is the original PHP-based repository server from the upstream LTPDA project. It is preserved
here for reference and for administrators who need to maintain an existing v2.5 installation.

**For new deployments, use the v3.0 Docker-based repository in `../repository/`.**

---

## Stack

| Component | Minimum version |
|-----------|----------------|
| Apache    | 2.2.6          |
| MySQL     | 5.0            |
| PHP       | 5.2.4          |
| Ruby      | 1.8.7          |
| Gnuplot   | any recent     |
| Sendmail / Postfix / qmail | — |

---

## Installation

### 1. Configure MySQL

Add to `my.cnf` and restart MySQL:

```ini
max_allowed_packet = 256M
```

### 2. Configure PHP

Add to `php.ini` and restart Apache:

```ini
memory_limit = 256M
```

### 3. Deploy the repository files

```bash
unzip ltpdarepo.zip
cp -r ltpdarepo/ /var/www/html/ltpdarepo/
chown -R apache:apache /var/www/html/ltpdarepo/
chmod a+w /var/www/html/ltpdarepo/config.inc.php
```

### 4. Run the web installer

Navigate to `http://<your-server>/ltpdarepo/install.php` and follow the on-screen instructions.
The installer creates the database schema and writes `config.inc.php`.

### 5. Harden after installation

```bash
rm /var/www/html/ltpdarepo/install.php
chmod 640 /var/www/html/ltpdarepo/config.inc.php
```

### 6. Configure plot generation

In the repository web interface, go to **General Options** and set:
- Internal and external plot paths
- Robot script location (`ltpdareporobot.rb`)

For scheduled XML dumps, copy `ltpdareporobot.rb` to `/root/bin` with execute permissions and add
a cron entry:

```bash
chmod +x /root/bin/ltpdareporobot.rb
# Add to crontab (crontab -e):
# 0 3 * * * /root/bin/ltpdareporobot.rb
```

---

## Upstream documentation

- Installation guide: https://www.lisamission.org/ltpda/repository/repoinstallation/repoinstallation.html
- LTPDA project home: https://www.lisamission.org/ltpda/index.html
