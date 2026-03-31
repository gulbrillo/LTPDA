#!/usr/bin/env bash
# make_release.sh — Build release assets and publish to GitHub.
#
# Usage:
#   bash make_release.sh
#
# Requirements:
#   - git
#   - gh  (GitHub CLI — https://cli.github.com/)
#   - zip (included in Git for Windows / macOS / Linux)
#
# What it does:
#   1. Warns if there are uncommitted changes and offers to commit them.
#   2. Pushes the current branch to origin.
#   3. Creates LTPDA_Toolbox-v4.0.0_PSSL.zip  from toolbox/
#   4. Creates LTPDA_Repository-v2.5_PSSL.zip  from repository/
#   5. Creates GitHub release v1.0.0 with both zips attached.
#   6. Optionally deletes the local zip files.

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration — edit these if versions or tag ever change
# ---------------------------------------------------------------------------
TOOLBOX_VERSION="4.0.0"
REPO_VERSION="2.5"
RELEASE_TAG="v1.0.0"
RELEASE_TITLE="LTPDA v1.0.0 (PSSL fork) — R2025a compatibility"

TOOLBOX_ZIP="LTPDA_Toolbox-v${TOOLBOX_VERSION}_PSSL.zip"
REPO_ZIP="LTPDA_Repository-v${REPO_VERSION}_PSSL.zip"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info() { printf "\033[1;32m[info]\033[0m  %s\n" "$*"; }
warn() { printf "\033[1;33m[warn]\033[0m  %s\n" "$*" >&2; }
die()  { printf "\033[1;31m[error]\033[0m %s\n" "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Move to repo root (wherever this script lives)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# ---------------------------------------------------------------------------
# Check dependencies
# ---------------------------------------------------------------------------
command -v git >/dev/null || die "'git' not found."
command -v gh  >/dev/null || die "'gh' not found. Install from https://cli.github.com/"
command -v zip >/dev/null || die "'zip' not found. Install Git for Windows or a zip utility."

gh auth status >/dev/null 2>&1 || die "Not authenticated with GitHub. Run: gh auth login"

# ---------------------------------------------------------------------------
# Check for uncommitted changes
# ---------------------------------------------------------------------------
if ! git diff --quiet || ! git diff --cached --quiet; then
  warn "You have uncommitted changes:"
  git status --short
  echo ""
  read -r -p "Commit all changes now before releasing? [y/N] " yn
  case "$yn" in
    [Yy]*)
      git add -A
      git commit -m "R2025a compatibility: toolbox and GUI rewrites"
      ;;
    *)
      die "Aborting. Please commit or stash your changes first."
      ;;
  esac
fi

# ---------------------------------------------------------------------------
# Push
# ---------------------------------------------------------------------------
info "Pushing to origin..."
git push origin HEAD

# ---------------------------------------------------------------------------
# Check the tag does not already exist
# ---------------------------------------------------------------------------
if git rev-parse "$RELEASE_TAG" >/dev/null 2>&1; then
  die "Tag $RELEASE_TAG already exists locally. If you need to redo the release:
    git tag -d $RELEASE_TAG
    git push origin :refs/tags/$RELEASE_TAG
    gh release delete $RELEASE_TAG --yes"
fi
if gh release view "$RELEASE_TAG" >/dev/null 2>&1; then
  die "GitHub release $RELEASE_TAG already exists. Delete it first:
    gh release delete $RELEASE_TAG --yes"
fi

# ---------------------------------------------------------------------------
# Create zip files
# ---------------------------------------------------------------------------
info "Creating ${TOOLBOX_ZIP} from toolbox/ ..."
rm -f "$TOOLBOX_ZIP"
zip -r "$TOOLBOX_ZIP" toolbox/ \
  --exclude "*.DS_Store" \
  --exclude "*/.git/*" \
  --exclude "*/__pycache__/*"

info "Creating ${REPO_ZIP} from repository/ ..."
rm -f "$REPO_ZIP"
zip -r "$REPO_ZIP" repository/ \
  --exclude "*.DS_Store" \
  --exclude "*/.git/*" \
  --exclude "*/__pycache__/*"

info "Assets ready:"
ls -lh "$TOOLBOX_ZIP" "$REPO_ZIP"
echo ""

# ---------------------------------------------------------------------------
# Create GitHub release
# ---------------------------------------------------------------------------
info "Creating GitHub release ${RELEASE_TAG} ..."

gh release create "$RELEASE_TAG" \
  "$TOOLBOX_ZIP" \
  "$REPO_ZIP" \
  --title "$RELEASE_TITLE" \
  --notes "$(cat <<'NOTES'
## First release of the PSSL fork

This is the first release of the unofficial LTPDA fork maintained by the
Precision Space Systems Lab (PSSL) at the University of Florida.

**Based on:** upstream LTPDA Toolbox v3.0.13 / Repository v2.5

---

### Downloads

| File | Contents |
|------|----------|
| `LTPDA_Toolbox-v4.0.0_PSSL.zip` | MATLAB toolbox, R2025a compatible. Unzip and add the `toolbox/` directory to your MATLAB path, then run `ltpda_startup`. |
| `LTPDA_Repository-v2.5_PSSL.zip` | Repository server (unchanged from upstream v2.5). See the README for installation instructions. |

---

### Changes from upstream (toolbox only)

All changes restore compatibility with MATLAB R2025a, which removed or broke several APIs the upstream toolbox relied on.

**Removed language/built-in functions replaced:**
- `nargchk` → `narginchk`
- `findstr` → `contains`/`strfind`
- Shell escape `!` → `delete()`/`system()`
- `verLessThan` → `isMATLABReleaseOlderThan`
- `sym('expression')` → `str2sym('expression')`

**Removed internal MathWorks Java classes replaced:**
- `com.mathworks.mde.cmdwin.*` (coloured output) → plain `fprintf`
- `com.mathworks.xml.XMLUtils` → `matlab.io.xml.dom`
- `com.mathworks.mlwidgets.io.InterruptibleStreamCopier` → built-in `unzip`
- `javax.swing.JOptionPane` in helpers → `errordlg`/`warndlg`

**Bug fixes:**
- Fixed `msym` constructor crash when called with no arguments, which caused 11/108 test failures
- Fixed black plot background under Windows dark mode: figures now set `Theme = 'light'` explicitly

**GUI rewrites** (Java Swing backends no longer available in R2025a):
- `LTPDAprefs` → `uifigure` with five preference tabs
- `LTPDADatabaseConnectionManager` dialogs → `inputdlg` / `listdlg`
- `submitDialog` → `uifigure` form with blocking `uiwait`
- `LTPDARepositoryQuery` → `uifigure` with SQL input and result table
- `LTPDAModelBrowser` → `uifigure` with model list and documentation panel

**Result: 108/108 tests pass on MATLAB R2025a.**

---

### Contact

Simon Barke — simon.barke@gmail.com
Precision Space Systems Lab (PSSL), University of Florida

Bug reports and questions: https://github.com/gulbrillo/LTPDA/issues
NOTES
)"

echo ""
info "Release published: https://github.com/gulbrillo/LTPDA/releases/tag/${RELEASE_TAG}"

# ---------------------------------------------------------------------------
# Clean up
# ---------------------------------------------------------------------------
echo ""
read -r -p "Delete local zip files? [Y/n] " yn
case "$yn" in
  [Nn]*) info "Zip files kept in repo root (they are git-ignored)." ;;
  *)     rm -f "$TOOLBOX_ZIP" "$REPO_ZIP"
         info "Zip files deleted." ;;
esac
