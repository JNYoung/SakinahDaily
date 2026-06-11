#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

package_name="com.sakinahdaily.app"
apk_path="build/app/outputs/flutter-apk/app-debug.apk"
evidence_dir="build/android-launch-smoke"

usage() {
  cat <<'USAGE'
Usage:
  scripts/verify_android_launch_smoke.sh

Builds a dev debug APK, installs it on a connected Android device or emulator,
launches Sakinah Daily through the launcher intent, checks the process is
running, and saves a screenshot under build/android-launch-smoke.

Environment:
  ADB                         Optional adb binary path.
  ANDROID_SERIAL              Optional adb serial, used if SAKINAH_ANDROID_SERIAL is unset.
  SAKINAH_ANDROID_SERIAL      Optional adb serial to target.
  SAKINAH_ANDROID_EMULATOR_ID Optional Flutter emulator id to launch first.
  SAKINAH_ANDROID_WAIT_SECONDS Device/emulator wait timeout, default 90.
  SAKINAH_ANDROID_SETTLE_SECONDS Post-launch wait, default 4.
  SAKINAH_ANDROID_SKIP_BUILD  Set true to reuse an existing debug APK.
  SAKINAH_ANDROID_KEEP_APP_RUNNING Set true to leave app running after capture.
  SAKINAH_PLAY_TESTING_FEEDBACK Optional feedback channel dart-define.
USAGE
}

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Android launch smoke failed: %s\n' "$message" >&2
  exit "$code"
}

find_adb() {
  local candidate

  if [[ -n "${ADB:-}" && -x "${ADB:-}" ]]; then
    printf '%s\n' "$ADB"
    return 0
  fi

  for sdk_root in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "$HOME/Library/Android/sdk"; do
    [[ -n "$sdk_root" ]] || continue
    candidate="$sdk_root/platform-tools/adb"
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if command -v adb >/dev/null 2>&1; then
    command -v adb
    return 0
  fi

  return 1
}

device_status() {
  local serial="$1"
  "$adb_bin" devices | awk -v serial="$serial" '$1 == serial { print $2; exit }'
}

first_ready_device() {
  "$adb_bin" devices | awk 'NR > 1 && $2 == "device" { print $1; exit }'
}

first_ready_emulator() {
  "$adb_bin" devices | awk 'NR > 1 && $1 ~ /^emulator-/ && $2 == "device" { print $1; exit }'
}

wait_for_serial() {
  local preferred_serial="$1"
  local prefer_emulator="$2"
  local timeout_seconds="${SAKINAH_ANDROID_WAIT_SECONDS:-90}"
  local deadline=$((SECONDS + timeout_seconds))
  local serial=""
  local status=""

  while (( SECONDS < deadline )); do
    if [[ -n "$preferred_serial" ]]; then
      status="$(device_status "$preferred_serial" || true)"
      if [[ "$status" == "device" ]]; then
        printf '%s\n' "$preferred_serial"
        return 0
      fi
    elif [[ "$prefer_emulator" == "true" ]]; then
      serial="$(first_ready_emulator || true)"
      if [[ -n "$serial" ]]; then
        printf '%s\n' "$serial"
        return 0
      fi
    else
      serial="$(first_ready_device || true)"
      if [[ -n "$serial" ]]; then
        printf '%s\n' "$serial"
        return 0
      fi
    fi
    sleep 2
  done

  if [[ -n "$preferred_serial" ]]; then
    fail "device $preferred_serial did not become ready within ${timeout_seconds}s" 2
  fi
  fail "no ready Android device was found within ${timeout_seconds}s" 2
}

wait_for_boot_complete() {
  local serial="$1"
  local timeout_seconds="${SAKINAH_ANDROID_WAIT_SECONDS:-90}"
  local deadline=$((SECONDS + timeout_seconds))
  local boot_completed=""

  "$adb_bin" -s "$serial" wait-for-device
  while (( SECONDS < deadline )); do
    boot_completed="$("$adb_bin" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r' || true)"
    if [[ "$boot_completed" == "1" ]]; then
      return 0
    fi
    sleep 2
  done

  fail "device $serial did not finish booting within ${timeout_seconds}s" 3
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

command -v flutter >/dev/null 2>&1 || fail "flutter is not available on PATH"

adb_bin="$(find_adb || true)"
[[ -n "$adb_bin" ]] || fail "adb was not found. Set ADB, ANDROID_HOME, or ANDROID_SDK_ROOT."

emulator_id="${SAKINAH_ANDROID_EMULATOR_ID:-}"
requested_serial="${SAKINAH_ANDROID_SERIAL:-${ANDROID_SERIAL:-}}"

if [[ -n "$emulator_id" ]]; then
  printf 'Launching Flutter emulator: %s\n' "$emulator_id"
  flutter --no-version-check emulators --launch "$emulator_id"
fi

prefer_emulator=false
if [[ -n "$emulator_id" && -z "$requested_serial" ]]; then
  prefer_emulator=true
fi

serial="$(wait_for_serial "$requested_serial" "$prefer_emulator")"
wait_for_boot_complete "$serial"

flutter_args=(
  --no-version-check build apk --debug
  --dart-define=SAKINAH_APP_ENV=dev
)

if [[ -n "${SAKINAH_PLAY_TESTING_FEEDBACK:-}" ]]; then
  flutter_args+=(--dart-define=SAKINAH_PLAY_TESTING_FEEDBACK="${SAKINAH_PLAY_TESTING_FEEDBACK}")
fi

if [[ "${SAKINAH_ANDROID_SKIP_BUILD:-false}" != "true" ]]; then
  flutter "${flutter_args[@]}"
fi

[[ -f "$apk_path" ]] || fail "expected debug APK not found at $apk_path"

"$adb_bin" -s "$serial" install -r "$apk_path"
"$adb_bin" -s "$serial" shell am force-stop "$package_name" || true
"$adb_bin" -s "$serial" shell monkey -p "$package_name" -c android.intent.category.LAUNCHER 1 >/dev/null

settle_seconds="${SAKINAH_ANDROID_SETTLE_SECONDS:-4}"
sleep "$settle_seconds"

pid="$("$adb_bin" -s "$serial" shell pidof -s "$package_name" 2>/dev/null | tr -d '\r' || true)"
[[ -n "$pid" ]] || fail "$package_name did not remain running after launch" 4

mkdir -p "$evidence_dir"
safe_serial="$(printf '%s' "$serial" | tr -c 'A-Za-z0-9._-' '_')"
screenshot_path="$evidence_dir/${safe_serial}-launch.png"
manifest_path="$evidence_dir/${safe_serial}-manifest.txt"

"$adb_bin" -s "$serial" exec-out screencap -p > "$screenshot_path"
cat > "$manifest_path" <<EOF
package=$package_name
serial=$serial
pid=$pid
apk=$apk_path
screenshot=$screenshot_path
app_env=dev
EOF

if [[ "${SAKINAH_ANDROID_KEEP_APP_RUNNING:-false}" != "true" ]]; then
  "$adb_bin" -s "$serial" shell am force-stop "$package_name" || true
fi

printf 'Android launch smoke passed.\n'
printf 'Device: %s\n' "$serial"
printf 'Package: %s\n' "$package_name"
printf 'PID: %s\n' "$pid"
printf 'Screenshot: %s\n' "$screenshot_path"
printf 'Manifest: %s\n' "$manifest_path"
