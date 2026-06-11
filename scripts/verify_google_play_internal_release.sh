#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Release gate failed: %s\n' "$message" >&2
  exit "$code"
}

has_env_signing() {
  [[ -n "${SAKINAH_UPLOAD_STORE_FILE:-}" ]] &&
    [[ -n "${SAKINAH_UPLOAD_STORE_PASSWORD:-}" ]] &&
    [[ -n "${SAKINAH_UPLOAD_KEY_ALIAS:-}" ]] &&
    [[ -n "${SAKINAH_UPLOAD_KEY_PASSWORD:-}" ]]
}

has_local_signing() {
  local signing_file="android/key.properties"
  [[ -f "$signing_file" ]] || return 1
  grep -Eq '^[[:space:]]*storeFile[[:space:]]*=' "$signing_file" &&
    grep -Eq '^[[:space:]]*storePassword[[:space:]]*=' "$signing_file" &&
    grep -Eq '^[[:space:]]*keyAlias[[:space:]]*=' "$signing_file" &&
    grep -Eq '^[[:space:]]*keyPassword[[:space:]]*=' "$signing_file"
}

find_apkanalyzer() {
  local sdk_root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
  [[ -d "$sdk_root/cmdline-tools" ]] || return 1
  find "$sdk_root/cmdline-tools" -path '*/bin/apkanalyzer' -type f -perm -111 \
    | head -n 1
}

find_sdkmanager() {
  local sdk_root="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
  [[ -d "$sdk_root/cmdline-tools" ]] || return 1
  find "$sdk_root/cmdline-tools" -path '*/bin/sdkmanager' -type f -perm -111 \
    | head -n 1
}

check_android_licenses() {
  local sdkmanager_path="$1"
  local license_output

  set +e
  license_output="$(printf 'n\n' | "$sdkmanager_path" --licenses 2>&1)"
  local license_status=$?
  set -e

  if [[ "$license_status" -eq 0 ]] &&
    grep -q 'All SDK package licenses accepted' <<<"$license_output"; then
    printf 'All Android licenses accepted.\n'
    return 0
  fi

  printf '%s\n' "$license_output" >&2
  fail "Android SDK licenses are not fully accepted. Run flutter doctor --android-licenses before Play release builds." 4
}

command -v flutter >/dev/null 2>&1 || fail "flutter is not available on PATH"
command -v dart >/dev/null 2>&1 || fail "dart is not available on PATH"

signing_configured=false
if has_env_signing || has_local_signing; then
  signing_configured=true
fi

if [[ "$signing_configured" != "true" ]]; then
  if [[ "${SAKINAH_ALLOW_UNSIGNED_RELEASE_QA:-false}" != "true" ]]; then
    cat >&2 <<'MSG'
Release signing is required for a Google Play internal testing bundle.

Provide either:
- android/key.properties copied from android/key.properties.example, with a
  local upload keystore outside git, or
- SAKINAH_UPLOAD_STORE_FILE, SAKINAH_UPLOAD_STORE_PASSWORD,
  SAKINAH_UPLOAD_KEY_ALIAS, and SAKINAH_UPLOAD_KEY_PASSWORD in CI/local env.

For a local build-only dry run that is not uploadable to Play, set:
SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true
MSG
    exit 2
  fi
  printf 'Unsigned release QA mode enabled; the bundle is not uploadable to Play.\n'
fi

apkanalyzer_path="$(find_apkanalyzer || true)"
if [[ -z "$apkanalyzer_path" ]]; then
  if [[ "${SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA:-false}" != "true" ]]; then
    cat >&2 <<'MSG'
Android cmdline-tools apkanalyzer is required for Flutter's appbundle debug-symbol check.

Install Android SDK Command-line Tools into the same SDK used by Flutter, then
accept Android licenses. `flutter doctor -v` must no longer report missing
cmdline-tools or unknown Android license status before this gate can pass.

For local script-control QA only, set:
SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA=true
MSG
    exit 3
  fi
  printf 'Android cmdline-tools apkanalyzer is missing; continuing only because SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA=true.\n'
else
  printf 'Found apkanalyzer: %s\n' "$apkanalyzer_path"
fi

sdkmanager_path="$(find_sdkmanager || true)"
if [[ -z "$sdkmanager_path" ]]; then
  if [[ "${SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA:-false}" != "true" ]]; then
    fail "Android cmdline-tools sdkmanager is required to verify accepted Android SDK licenses." 5
  fi
  printf 'Android cmdline-tools sdkmanager is missing; skipping license verification only because SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA=true.\n'
else
  printf 'Found sdkmanager: %s\n' "$sdkmanager_path"
  check_android_licenses "$sdkmanager_path"
fi

if [[ "${SAKINAH_RELEASE_SKIP_TESTS:-false}" != "true" ]]; then
  flutter --no-version-check test test/release_readiness_test.dart
fi

if [[ "${SAKINAH_RELEASE_SKIP_ANALYZE:-false}" != "true" ]]; then
  dart analyze
fi

if [[ "${SAKINAH_RELEASE_RUN_FLUTTER_ANALYZE:-false}" == "true" ]]; then
  flutter --no-version-check analyze
else
  printf 'Skipping flutter analyze by default; use dart analyze as the stable gate in this workspace.\n'
fi

if [[ "${SAKINAH_RELEASE_SKIP_BUNDLE_BUILD:-false}" == "true" ]]; then
  printf 'Skipping appbundle build because SAKINAH_RELEASE_SKIP_BUNDLE_BUILD=true.\n'
  exit 0
fi

aab_path="build/app/outputs/bundle/release/app-release.aab"
rm -f "$aab_path"

set +e
if [[ "$signing_configured" == "true" ]]; then
  SAKINAH_REQUIRE_RELEASE_SIGNING=true \
    flutter --no-version-check build appbundle --release \
      --dart-define=SAKINAH_APP_ENV=prod
else
  flutter --no-version-check build appbundle --release \
    --dart-define=SAKINAH_APP_ENV=prod
fi
build_status=$?
set -e

mkdir -p build/play-internal
checksum_path="build/play-internal/app-release.aab.sha256"

if [[ "$build_status" -ne 0 ]]; then
  if [[ -f "$aab_path" ]]; then
    shasum -a 256 "$aab_path" >"$checksum_path"
    printf 'Release appbundle build failed after producing a bundle.\n' >&2
    printf 'Do not upload this artifact until the Flutter/Android toolchain blocker is fixed.\n' >&2
    printf 'Partial bundle: %s\n' "$aab_path" >&2
    printf 'SHA-256: %s\n' "$checksum_path" >&2
    exit "$build_status"
  fi
  fail "appbundle build failed before producing $aab_path" "$build_status"
fi

[[ -f "$aab_path" ]] || fail "expected bundle was not produced at $aab_path"
shasum -a 256 "$aab_path" >"$checksum_path"

if [[ "${SAKINAH_PLAY_INTERNAL_COPY_AAB:-false}" == "true" ]]; then
  cp "$aab_path" "build/play-internal/app-release.aab"
fi

printf 'Google Play internal release gate passed.\n'
printf 'Bundle: %s\n' "$aab_path"
printf 'SHA-256: %s\n' "$checksum_path"
