# LTPDA — LISA Technology Package Data Analysis

> **Unofficial fork** of the [LTPDA Toolbox](https://www.lisamission.org/ltpda/index.html) (toolbox v3.0.13, repository v2.5), originally developed by the LISA Mission team.

A MATLAB toolbox for **accountable and reproducible data analysis**, with a built-in repository for storing, sharing, and retrieving analysis objects and results.

**Fork maintainer:** Simon Barke — Precision Space Systems Lab (PSSL), University of Florida
<simon.barke@gmail.com> · [Open an issue](https://github.com/gulbrillo/LTPDA/issues)

---

## Goals of this fork

- Restore compatibility with **MATLAB R2025a and beyond** (upstream targets R2012b era)
- Modernise the repository server for current server infrastructure — no legacy LAMP stack required

---

## Components

| Directory | Description | README |
|-----------|-------------|--------|
| `toolbox/` | MATLAB toolbox — R2025a-compatible fork of upstream v3.0.13 | [toolbox/README.md](toolbox/README.md) |
| `repository/` | Repository server v3.0 — Docker, Nuxt 4, FastAPI, MySQL | [repository/README.md](repository/README.md) |
| `repository.old/` | Original v2.5 PHP repository (preserved for reference) | [repository.old/README.md](repository.old/README.md) |

---

## Quick start

### Toolbox (MATLAB)

```matlab
addpath(genpath('/path/to/LTPDA/toolbox'));
ltpda_startup
```

All 108 tests pass on R2025a. See [toolbox/README.md](toolbox/README.md) for full installation
instructions and a summary of all R2025a compatibility changes.

### Repository server v3.0

```bash
cd repository
echo "MYSQL_ROOT_PASSWORD=choose_a_strong_password" > .env
docker compose --profile bundled up -d
```

Then open `https://repo.yourdomain.com` and complete the setup wizard. See
[repository/README.md](repository/README.md) for the full server setup guide including Apache
configuration, SSL, MATLAB SSH tunnel setup, and the optional SSH sync daemon.

---

## Status

| Component | Status |
|-----------|--------|
| Toolbox — R2025a compatibility | ✅ Complete (108/108 tests pass) |
| Repository server v3.0 (Docker skeleton, auth, user management) | ✅ Complete |
| Repository server — SSH sync daemon | ✅ Complete |
| Repository server — full content (objects, queries, plots) | 🔲 Planned (Phase 5) |
| GUI rewrites (Java Swing → uifigure) | ✅ Complete |
| SSH tunnel — modern JSch 0.2.x + MFA (Duo Push) support | ✅ Complete |

---

## Upstream documentation

- Toolbox user manual: https://www.lisamission.org/ltpda/usermanual/ug/setup.html
- Repository installation guide: https://www.lisamission.org/ltpda/repository/repoinstallation/repoinstallation.html
- LTPDA project home: https://www.lisamission.org/ltpda/index.html

---

## Creating a release

The script `make_release.sh` handles zipping the toolbox and repository, creating the GitHub
release, and attaching assets.

**Prerequisites:** [GitHub CLI](https://cli.github.com/) installed and authenticated (`gh auth login`).

```bash
bash make_release.sh
```

The script prompts before committing changes and before deleting local zip files.

---

## Contributing

Please [open an issue](https://github.com/gulbrillo/LTPDA/issues) for bug reports, compatibility
fixes, or questions. Pull requests welcome.
