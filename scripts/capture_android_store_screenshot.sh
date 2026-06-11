#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  scripts/capture_android_store_screenshot.sh <locale> <route> [output.png]

Examples:
  scripts/capture_android_store_screenshot.sh en /home
  scripts/capture_android_store_screenshot.sh ar /settings/privacy build/store-screenshots/android/ar-privacy.png

Locales: en, id, ar
Routes:
  /splash
  /onboarding
  /home
  /prayer
  /settings
  /settings/notifications
  /settings/content-sources
  /settings/testing-guide
  /settings/prayer-location
  /settings/privacy
  /session/session_morning_ease
  /quran/94:5

Set ANDROID_SERIAL to target a specific connected device.
Set SAKINAH_SCREENSHOT_SETTLE_SECONDS to override the post-launch wait.
USAGE
}

locale="${1:-}"
route="${2:-}"
output="${3:-}"

if [[ -z "${locale}" || -z "${route}" ]]; then
  usage
  exit 64
fi

case "${locale}" in
  en|id|ar) ;;
  *)
    echo "Unsupported locale: ${locale}" >&2
    usage
    exit 64
    ;;
esac

case "${route}" in
  /splash|/onboarding|/home|/prayer|/settings|/settings/notifications|/settings/content-sources|/settings/testing-guide|/settings/prayer-location|/settings/privacy|/session/session_morning_ease|/quran/94:5) ;;
  *)
    echo "Unsupported route: ${route}" >&2
    usage
    exit 64
    ;;
esac

if [[ -z "${output}" ]]; then
  safe_route="$(printf '%s' "${route#/}" | tr '/' '-')"
  output="build/store-screenshots/android/${locale}-${safe_route}.png"
fi

adb_bin="${ADB:-${HOME}/Library/Android/sdk/platform-tools/adb}"
if [[ ! -x "${adb_bin}" ]]; then
  adb_bin="adb"
fi

adb_args=()
if [[ -n "${ANDROID_SERIAL:-}" ]]; then
  adb_args=(-s "${ANDROID_SERIAL}")
fi

flutter_args=(
  --no-version-check build apk --debug
  --dart-define=SAKINAH_APP_ENV=dev
  --dart-define=SAKINAH_STORE_SCREENSHOT_ENABLED=true
  --dart-define=SAKINAH_STORE_SCREENSHOT_LOCALE="${locale}"
  --dart-define=SAKINAH_STORE_SCREENSHOT_ROUTE="${route}"
)

if [[ -n "${SAKINAH_PLAY_TESTING_FEEDBACK:-}" ]]; then
  flutter_args+=(--dart-define=SAKINAH_PLAY_TESTING_FEEDBACK="${SAKINAH_PLAY_TESTING_FEEDBACK}")
fi

flutter "${flutter_args[@]}"

"${adb_bin}" "${adb_args[@]}" install -r build/app/outputs/flutter-apk/app-debug.apk
"${adb_bin}" "${adb_args[@]}" shell am force-stop com.sakinahdaily.app
"${adb_bin}" "${adb_args[@]}" shell am start -n com.sakinahdaily.app/.MainActivity
settle_seconds="${SAKINAH_SCREENSHOT_SETTLE_SECONDS:-3}"
sleep "${settle_seconds}"

mkdir -p "$(dirname "${output}")"
"${adb_bin}" "${adb_args[@]}" exec-out screencap -p > "${output}"
echo "Captured ${locale} ${route} -> ${output}"
