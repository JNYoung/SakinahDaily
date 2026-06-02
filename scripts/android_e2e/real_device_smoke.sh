#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_ID="${APP_ID:-com.sakinahdaily.app}"
DART_DEFINE="${DART_DEFINE:-SAKINAH_APP_ENV=dev}"
RUN_FLUTTER_TESTS="${RUN_FLUTTER_TESTS:-0}"
ADB="${ADB:-$HOME/Library/Android/sdk/platform-tools/adb}"
DEVICE_ID="${DEVICE_ID:-}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/build/e2e/$TIMESTAMP}"
APK_PATH="$ROOT_DIR/build/app/outputs/flutter-apk/app-debug.apk"

mkdir -p "$OUTPUT_DIR"

log() {
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" | tee -a "$OUTPUT_DIR/run.log"
}

run_with_timeout() {
  local seconds="$1"
  shift
  "$@" &
  local pid="$!"
  local elapsed=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$elapsed" -ge "$seconds" ]; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 124
    fi
    sleep 1
    elapsed=$((elapsed + 1))
  done
  wait "$pid"
}

run_logged() {
  local name="$1"
  local seconds="$2"
  shift 2
  log "Running $name"
  {
    printf '$'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n\n'
  } > "$OUTPUT_DIR/$name.log"
  if run_with_timeout "$seconds" "$@" >> "$OUTPUT_DIR/$name.log" 2>&1; then
    log "$name passed"
    return 0
  fi
  local status="$?"
  log "$name failed with status $status; see $OUTPUT_DIR/$name.log"
  return "$status"
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
  log "No authorized Android device found. Connect a physical device and run: $ADB devices"
  exit 1
fi

log "Using device $DEVICE_ID"
log "Writing evidence to $OUTPUT_DIR"

"$ADB" -s "$DEVICE_ID" shell getprop ro.product.model > "$OUTPUT_DIR/device-model.txt" 2>/dev/null || true
"$ADB" -s "$DEVICE_ID" shell getprop ro.build.version.release > "$OUTPUT_DIR/android-version.txt" 2>/dev/null || true

if [ "$RUN_FLUTTER_TESTS" = "1" ]; then
  run_logged flutter-test 900 flutter test
  run_logged dart-analyze 180 dart analyze
fi

run_logged flutter-build-debug 900 flutter build apk --debug --dart-define="$DART_DEFINE"
run_logged adb-install 240 "$ADB" -s "$DEVICE_ID" install -t -r "$APK_PATH"
run_logged adb-launch 90 "$ADB" -s "$DEVICE_ID" shell am start -W -n "$APP_ID/.MainActivity"

sleep 8

log "Capturing screenshot"
"$ADB" -s "$DEVICE_ID" shell screencap -p "/sdcard/sakinah-smoke-$TIMESTAMP.png" >/dev/null 2>&1 || true
"$ADB" -s "$DEVICE_ID" pull "/sdcard/sakinah-smoke-$TIMESTAMP.png" "$OUTPUT_DIR/screenshot.png" >/dev/null 2>&1 || true
"$ADB" -s "$DEVICE_ID" shell rm "/sdcard/sakinah-smoke-$TIMESTAMP.png" >/dev/null 2>&1 || true

log "Capturing logcat tail"
"$ADB" -s "$DEVICE_ID" logcat -d -t 500 > "$OUTPUT_DIR/logcat-tail.txt" 2>/dev/null || true

log "Capturing current activity"
if ! run_with_timeout 20 "$ADB" -s "$DEVICE_ID" shell dumpsys activity activities > "$OUTPUT_DIR/current-activity.txt" 2>&1; then
  log "current activity capture timed out"
fi

if grep -R "FATAL EXCEPTION\\|AndroidRuntime\\|Process: $APP_ID" "$OUTPUT_DIR/logcat-tail.txt" >/dev/null 2>&1; then
  log "Possible crash signature found in logcat-tail.txt"
  exit 2
fi

log "Real-device smoke complete"
log "Evidence directory: $OUTPUT_DIR"
