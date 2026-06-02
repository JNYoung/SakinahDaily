#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_ID="${APP_ID:-com.sakinahdaily.app}"
ADB="${ADB:-$HOME/Library/Android/sdk/platform-tools/adb}"
DEVICE_ID="${DEVICE_ID:-}"
DART_DEFINE_ENV="${DART_DEFINE_ENV:-SAKINAH_APP_ENV=dev}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/build/e2e/route-screenshots-$TIMESTAMP}"
APK_PATH="$ROOT_DIR/build/app/outputs/flutter-apk/app-debug.apk"
SLEEP_AFTER_LAUNCH="${SLEEP_AFTER_LAUNCH:-8}"

ROUTE_SPECS=(
  "splash|/splash"
  "home|/home"
  "quran-detail|/quran/94:5"
  "dua-detail|/dua/dua_ease"
  "dhikr-counter|/dhikr/dhikr_subhanallah"
  "prayer-times|/prayer"
  "women-mode|/settings/women-ibadah"
  "privacy-center|/settings/privacy"
  "content-sources|/settings/content-sources"
  "settings|/settings"
)

if [ -n "${ROUTE_SPECS_OVERRIDE:-}" ]; then
  IFS=',' read -r -a ROUTE_SPECS <<< "$ROUTE_SPECS_OVERRIDE"
fi

mkdir -p "$OUTPUT_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$OUTPUT_DIR/run.log"
}

choose_device() {
  if [ -n "$DEVICE_ID" ]; then
    printf '%s\n' "$DEVICE_ID"
    return 0
  fi

  local devices
  devices="$("$ADB" devices | awk 'NR > 1 && $2 == "device" {print $1}')"
  local physical
  physical="$(printf '%s\n' "$devices" | awk '!/^emulator-/ {print; exit}')"
  if [ -n "$physical" ]; then
    printf '%s\n' "$physical"
    return 0
  fi
  printf '%s\n' "$devices" | awk 'NF {print; exit}'
}

if [ ! -x "$ADB" ]; then
  log "adb not found or not executable: $ADB"
  exit 1
fi

cd "$ROOT_DIR"

DEVICE_ID="$(choose_device)"
if [ -z "$DEVICE_ID" ]; then
  log "No authorized Android device found. Connect a device and run: $ADB devices"
  exit 1
fi

log "Using device $DEVICE_ID"
log "Writing screenshots to $OUTPUT_DIR"
"$ADB" -s "$DEVICE_ID" shell getprop ro.product.model > "$OUTPUT_DIR/device-model.txt" 2>/dev/null || true
"$ADB" -s "$DEVICE_ID" shell getprop ro.build.version.release > "$OUTPUT_DIR/android-version.txt" 2>/dev/null || true

for spec in "${ROUTE_SPECS[@]}"; do
  label="${spec%%|*}"
  route="${spec#*|}"
  log "Capturing $label at $route"

  flutter build apk --debug \
    --dart-define="$DART_DEFINE_ENV" \
    --dart-define="SAKINAH_INITIAL_ROUTE=$route" \
    > "$OUTPUT_DIR/$label-build.log" 2>&1

  "$ADB" -s "$DEVICE_ID" install -t -r "$APK_PATH" \
    > "$OUTPUT_DIR/$label-install.log" 2>&1
  "$ADB" -s "$DEVICE_ID" shell am force-stop "$APP_ID" >/dev/null 2>&1 || true
  "$ADB" -s "$DEVICE_ID" shell am start -W -n "$APP_ID/.MainActivity" \
    > "$OUTPUT_DIR/$label-launch.log" 2>&1

  sleep "$SLEEP_AFTER_LAUNCH"

  "$ADB" -s "$DEVICE_ID" shell screencap -p "/sdcard/sakinah-$label.png" >/dev/null 2>&1
  "$ADB" -s "$DEVICE_ID" pull "/sdcard/sakinah-$label.png" "$OUTPUT_DIR/$label.png" >/dev/null 2>&1
  "$ADB" -s "$DEVICE_ID" shell rm "/sdcard/sakinah-$label.png" >/dev/null 2>&1 || true
  "$ADB" -s "$DEVICE_ID" logcat -d -t 250 > "$OUTPUT_DIR/$label-logcat.txt" 2>/dev/null || true

  if grep -R "FATAL EXCEPTION\\|AndroidRuntime\\|Process: $APP_ID" "$OUTPUT_DIR/$label-logcat.txt" >/dev/null 2>&1; then
    log "Possible crash signature found after $label; see $OUTPUT_DIR/$label-logcat.txt"
    exit 2
  fi
done

log "Route screenshot capture complete"
log "Evidence directory: $OUTPUT_DIR"
