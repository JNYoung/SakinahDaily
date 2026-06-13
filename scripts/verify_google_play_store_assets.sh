#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

feature_graphic="${SAKINAH_STORE_FEATURE_GRAPHIC:-build/store-assets/google-play-feature-graphic.png}"
screenshot_dir="${SAKINAH_STORE_SCREENSHOT_DIR:-build/store-screenshots/android}"
contact_sheet="${SAKINAH_STORE_CONTACT_SHEET:-build/store-screenshots/android-contact-sheet.png}"
generator="scripts/generate_google_play_feature_graphic.py"
required_screenshots=(
  en-splash.png
  en-onboarding.png
  en-home.png
  en-prayer.png
  en-settings.png
  en-settings-notifications.png
  en-settings-prayer-location.png
  en-settings-privacy.png
  en-session-session_morning_ease.png
  id-splash.png
  id-onboarding.png
  id-home.png
  id-prayer.png
  id-settings.png
  id-settings-notifications.png
  id-settings-prayer-location.png
  id-settings-privacy.png
  id-session-session_morning_ease.png
  ar-splash.png
  ar-onboarding.png
  ar-home.png
  ar-prayer.png
  ar-settings.png
  ar-settings-notifications.png
  ar-settings-prayer-location.png
  ar-settings-privacy.png
  ar-session-session_morning_ease.png
)

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

if ! python3 - <<'PY' >/dev/null 2>&1
from PIL import Image
PY
then
  fail "Python Pillow is required to generate and inspect store assets."
fi

require_file "$generator"
python3 "$generator"

# Google Play feature graphic: 1024 x 500, JPEG or 24-bit PNG, no alpha.
python3 - "$feature_graphic" <<'PY'
from pathlib import Path
from PIL import Image
import sys

path = Path(sys.argv[1])
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
  require_file "$contact_sheet"
  if ! python3 - "$screenshot_dir" "$contact_sheet" "${required_screenshots[@]}" <<'PY'
from pathlib import Path
from PIL import Image
import sys

screenshot_dir = Path(sys.argv[1])
contact_sheet = Path(sys.argv[2])
required_screenshots = sys.argv[3:]

def inspect_png(path: Path, label: str, *, portrait: bool) -> None:
    if not path.exists():
        sys.stderr.write(f"{label} is missing: {path}\n")
        sys.exit(1)
    image = Image.open(path)
    if image.format != "PNG":
        sys.stderr.write(f"{label} must be PNG, got {image.format}: {path}\n")
        sys.exit(1)
    if image.mode != "RGB":
        sys.stderr.write(f"{label} must be 24-bit PNG with no alpha, got {image.mode}: {path}\n")
        sys.exit(1)
    width, height = image.size
    if min(width, height) < 320:
        sys.stderr.write(f"{label} is below Google Play minimum edge 320px, got {image.size}: {path}\n")
        sys.exit(1)
    if max(width, height) > 3840:
        sys.stderr.write(f"{label} exceeds Google Play maximum edge 3840px, got {image.size}: {path}\n")
        sys.exit(1)
    if portrait and height < width:
        sys.stderr.write(f"{label} must be portrait phone screenshot, got {image.size}: {path}\n")
        sys.exit(1)

for name in required_screenshots:
    inspect_png(screenshot_dir / name, f"Android screenshot {name}", portrait=True)

inspect_png(contact_sheet, "Android screenshot contact sheet", portrait=False)
PY
  then
    fail "Android screenshot matrix failed strict validation."
  fi
  printf 'Strict screenshot matrix: %s PNGs verified.\n' "${#required_screenshots[@]}"
fi

printf 'Google Play store visual assets passed.\n'
printf 'Feature graphic: %s\n' "$feature_graphic"
printf 'Feature graphic spec: 1024 x 500, 24-bit PNG, no alpha.\n'
printf 'Screenshot matrix: %s\n' "$screenshot_dir"
printf 'Contact sheet: %s\n' "$contact_sheet"
