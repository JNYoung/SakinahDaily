#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

feature_graphic="build/store-assets/google-play-feature-graphic.png"
screenshot_dir="build/store-screenshots/android"
contact_sheet="build/store-screenshots/android-contact-sheet.png"
generator="scripts/generate_google_play_feature_graphic.py"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play store visual assets failed: %s\n' "$message" >&2
  exit "$code"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "required file is missing: $path"
}

command -v python3 >/dev/null 2>&1 ||
  fail "python3 is required to generate and inspect store assets."

require_file "$generator"
python3 "$generator"

# Google Play feature graphic: 1024 x 500, JPEG or 24-bit PNG, no alpha.
python3 - <<'PY'
from pathlib import Path
from PIL import Image
import sys

path = Path("build/store-assets/google-play-feature-graphic.png")
if not path.exists():
    sys.stderr.write(f"feature graphic is missing: {path}\n")
    sys.exit(1)

image = Image.open(path)
if image.size != (1024, 500):
    sys.stderr.write(f"feature graphic must be 1024 x 500, got {image.size}\n")
    sys.exit(1)
if image.format != "PNG":
    sys.stderr.write(f"feature graphic must be PNG for this release pack, got {image.format}\n")
    sys.exit(1)
if image.mode != "RGB":
    sys.stderr.write(f"feature graphic must be 24-bit PNG with no alpha, got {image.mode}\n")
    sys.exit(1)
PY

if [[ "${SAKINAH_REQUIRE_STORE_ASSETS_READY:-false}" == "true" ]]; then
  [[ -d "$screenshot_dir" ]] ||
    fail "screenshot directory is required in strict mode: $screenshot_dir"
  screenshot_count="$(
    find "$screenshot_dir" -maxdepth 1 -type f -name '*.png' |
      wc -l |
      tr -d '[:space:]'
  )"
  [[ "$screenshot_count" =~ ^[0-9]+$ ]] ||
    fail "could not count Android screenshots in $screenshot_dir"
  (( screenshot_count >= 8 )) ||
    fail "at least 8 Android phone screenshots are required in strict mode; found $screenshot_count."
  require_file "$contact_sheet"
fi

printf 'Google Play store visual assets passed.\n'
printf 'Feature graphic: %s\n' "$feature_graphic"
printf 'Feature graphic spec: 1024 x 500, 24-bit PNG, no alpha.\n'
printf 'Screenshot matrix: %s\n' "$screenshot_dir"
printf 'Contact sheet: %s\n' "$contact_sheet"
