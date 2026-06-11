#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/capture_android_store_screenshots.sh [output-dir]

Defaults:
  output-dir: build/store-screenshots/android
  locales: en id ar
  routes: /splash /onboarding /home /prayer /settings /settings/notifications /settings/prayer-location /settings/privacy /session/session_morning_ease

Environment:
  ANDROID_SERIAL=...                    Target one connected Android device.
  SAKINAH_SCREENSHOT_LOCALES="en ar"    Limit locales.
  SAKINAH_SCREENSHOT_ROUTES="/home"     Limit routes.
  SAKINAH_SCREENSHOT_SKIP_EXISTING=true Skip existing PNGs.

Example:
  ANDROID_SERIAL=emulator-5554 \
  SAKINAH_SCREENSHOT_LOCALES="en ar" \
  scripts/capture_android_store_screenshots.sh
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

output_dir="${1:-build/store-screenshots/android}"
single_capture_script="$(dirname "$0")/capture_android_store_screenshot.sh"

if [[ ! -x "${single_capture_script}" ]]; then
  echo "Missing executable helper: ${single_capture_script}" >&2
  exit 66
fi

locales="${SAKINAH_SCREENSHOT_LOCALES:-en id ar}"
routes="${SAKINAH_SCREENSHOT_ROUTES:-/splash /onboarding /home /prayer /settings /settings/notifications /settings/prayer-location /settings/privacy /session/session_morning_ease}"

route_slug() {
  local route="$1"
  printf '%s' "${route#/}" | tr '/' '-'
}

mkdir -p "${output_dir}"

for locale in ${locales}; do
  for route in ${routes}; do
    output="${output_dir}/${locale}-$(route_slug "${route}").png"
    if [[ "${SAKINAH_SCREENSHOT_SKIP_EXISTING:-false}" == "true" && -s "${output}" ]]; then
      echo "Skipping existing ${output}"
      continue
    fi
    "${single_capture_script}" "${locale}" "${route}" "${output}"
  done
done

echo "Captured screenshot set under ${output_dir}"
