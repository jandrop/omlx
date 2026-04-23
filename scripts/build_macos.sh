#!/bin/bash
# Build oMLX.app and DMG for macOS (Apple Silicon only)
#
# Usage:
#   ./scripts/build_macos.sh               # Full build
#   ./scripts/build_macos.sh --skip-venv   # Skip venvstacks (reuse existing _export/)
#   ./scripts/build_macos.sh --dmg-only    # Only repackage DMG from existing .app
#   ./scripts/build_macos.sh --macos-target 26.0  # Target macOS Tahoe wheels
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGING_DIR="$PROJECT_DIR/packaging"

# ── Prereq checks ────────────────────────────────────────────────────────────

check_dep() {
    if ! command -v "$1" &>/dev/null; then
        echo "✗ Missing dependency: $1 — $2"
        exit 1
    fi
}

echo "Checking prerequisites..."
check_dep python3.11 "Install via: brew install python@3.11"
check_dep pipx      "Install via: brew install pipx"
check_dep uv        "Install via: brew install uv  (or pip install uv)"
check_dep cc        "Install Xcode Command Line Tools: xcode-select --install"
check_dep hdiutil   "Required macOS tool — should be present on any Mac"
check_dep iconutil  "Required macOS tool — should be present on any Mac"

# Ensure venvstacks is available via pipx
if ! pipx run venvstacks --version &>/dev/null 2>&1; then
    echo "Installing venvstacks via pipx..."
    pipx install venvstacks
fi

echo "✓ All prerequisites satisfied"
echo

# ── Build ─────────────────────────────────────────────────────────────────────

echo "Building oMLX macOS app..."
echo "Project: $PROJECT_DIR"
echo "Packaging: $PACKAGING_DIR"
echo

cd "$PACKAGING_DIR"
python3.11 build.py "$@"

# ── Result ────────────────────────────────────────────────────────────────────

echo
echo "Output:"
ls -lh "$PACKAGING_DIR/dist/" 2>/dev/null || echo "  (dist/ not found — build may have failed)"
