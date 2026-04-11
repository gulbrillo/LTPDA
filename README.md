# LTPDA — LISA Technology Package Data Analysis

> **Unofficial fork** of the [LTPDA Toolbox](https://www.lisamission.org/ltpda/index.html) (toolbox v3.0.13, repository v2.5), originally developed by the LISA Mission team.

A toolset for **accountable and reproducible data analysis** in gravitational wave and precision measurement research. Includes a MATLAB toolbox, a Python package, and a repository server for storing, sharing, and retrieving analysis objects.

**Fork maintainer:** Simon Barke — Precision Space Systems Lab (PSSL), University of Florida
<simon.barke@gmail.com> · [Open an issue](https://github.com/gulbrillo/LTPDA/issues)

---

## Goals of this fork

- Restore compatibility with **MATLAB R2025a and beyond** (upstream targets R2012b era)
- Modernise the repository server for current server infrastructure — no legacy LAMP stack required
- Provide a **Python rewrite** of the core toolbox for broader accessibility and modern tooling

---

## Components

| Directory | Description | README |
|-----------|-------------|--------|
| `matlab/` | MATLAB toolbox — R2025a-compatible fork of upstream v3.0.13 | [matlab/README.md](matlab/README.md) |
| `python/` | Python package — rewrite of LTPDA in Python (fork of [pyda-group/pyda](https://gitlab.com/pyda-group/pyda)) | [python/README.md](python/README.md) |
| `repository/` | Repository server v3.0 — Docker, Nuxt 4, FastAPI, MySQL | [repository/README.md](repository/README.md) |
| `repository.old/` | Original v2.5 PHP repository (preserved for reference) | [repository.old/README.md](repository.old/README.md) |

---

## Quick start

### Toolbox (MATLAB)

```matlab
addpath(genpath('/path/to/LTPDA/matlab'));
ltpda_startup
```

All 108 tests pass on R2025a. See [matlab/README.md](matlab/README.md) for full installation
instructions and a summary of all R2025a compatibility changes.

### Python package

```bash
cd LTPDA/python
pip install .
```

```python
from pyda.tsdata import TSData
from pyda.dsp.spectral import psd

ts = TSData.randn(nsecs=3600, fs=10, yunits='m')
Pxx = psd(ts, navs=10, window='BH92')
Pxx.loglog()
```

See [python/README.md](python/README.md) for the full API reference and examples.

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
| Toolbox — GUI rewrites (Java Swing → uifigure) | ✅ Complete |
| Toolbox — SSH tunnel: modern JSch 0.2.x + MFA (Duo Push) | ✅ Complete |
| Python package — core data classes, spectral analysis, noise gen, I/O | ✅ Functional |
| Python package — IIR filters, calibration objects, simulation | 🔲 Planned |
| Repository server v3.0 — auth, user management, SSH sync | ✅ Complete |
| Repository server — full content (objects, queries, plots) | 🔲 Planned (Phase 5) |

---

## Upstream documentation

- Toolbox user manual: https://www.lisamission.org/ltpda/usermanual/ug/setup.html
- Repository installation guide: https://www.lisamission.org/ltpda/repository/repoinstallation/repoinstallation.html
- LTPDA project home: https://www.lisamission.org/ltpda/index.html
- Python package upstream: https://gitlab.com/pyda-group/pyda

---

## Creating a release

The script `make_release.sh` handles zipping the MATLAB toolbox and repository, creating the GitHub
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
