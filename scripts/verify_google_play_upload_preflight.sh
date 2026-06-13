#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

package_name="com.sakinahdaily.app"
default_tester_group="sakinah-daily-testers@googlegroups.com"
aab_path="${SAKINAH_RELEASE_AAB_PATH:-build/app/outputs/bundle/release/app-release.aab}"
checksum_path="${SAKINAH_RELEASE_CHECKSUM_PATH:-build/play-internal/app-release.aab.sha256}"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Play upload preflight failed: %s\n' "$message" >&2
  exit "$code"
}

has_env_signing() {
  [[ -n "${SAKINAH_UPLOAD_STORE_FILE:-}" ]] &&
    [[ -n "${SAKINAH_UPLOAD_STORE_PASSWORD:-}" ]] &&
    [[ -n "${SAKINAH_UPLOAD_KEY_ALIAS:-}" ]] &&
    [[ -n "${SAKINAH_UPLOAD_KEY_PASSWORD:-}" ]] &&
    [[ -f "${SAKINAH_UPLOAD_STORE_FILE:-}" ]]
}

has_local_signing() {
  local signing_file="android/key.properties"
  [[ -f "$signing_file" ]] || return 1
  grep -Eq '^[[:space:]]*storeFile[[:space:]]*=' "$signing_file" &&
    grep -Eq '^[[:space:]]*storePassword[[:space:]]*=' "$signing_file" &&
    grep -Eq '^[[:space:]]*keyAlias[[:space:]]*=' "$signing_file" &&
    grep -Eq '^[[:space:]]*keyPassword[[:space:]]*=' "$signing_file"
}

is_https_url() {
  [[ "$1" =~ ^https://[^[:space:]]+\.[^[:space:]]+ ]]
}

is_feedback_channel() {
  is_https_url "$1" || [[ "$1" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]
}

require_true_var() {
  local name="$1"
  local description="$2"
  [[ "${!name:-}" == "true" ]] ||
    fail "$name=true is required after $description."
}

check_no_tracked_secret_files() {
  command -v git >/dev/null 2>&1 || fail "git is required to inspect tracked files."

  local tracked_secret
  # Keep .env, key.properties, service-account.json, .jks, and .keystore files out of git.
  tracked_secret="$(
    git ls-files |
      grep -E '(^|/)(\.env(\..*)?|key\.properties|service-account\.json)$|(\.jks|\.keystore)$' |
      head -n 1 || true
  )"

  [[ -z "$tracked_secret" ]] ||
    fail "tracked secret-like file found: $tracked_secret"
}

validate_release_artifact_integrity() {
  [[ -s "$aab_path" ]] || fail "expected signed bundle is missing or empty at $aab_path."
  [[ -s "$checksum_path" ]] || fail "expected checksum is missing or empty at $checksum_path."

  command -v shasum >/dev/null 2>&1 ||
    fail "shasum is required to verify the release AAB checksum."
  command -v python3 >/dev/null 2>&1 ||
    fail "python3 is required to verify the release AAB zip structure."

  local expected_checksum
  local actual_checksum
  expected_checksum="$(
    awk 'NF {print tolower($1); exit}' "$checksum_path"
  )"
  [[ "$expected_checksum" =~ ^[0-9a-f]{64}$ ]] ||
    fail "release AAB checksum file must start with a 64-character SHA-256 digest."

  actual_checksum="$(
    shasum -a 256 "$aab_path" | awk '{print tolower($1)}'
  )"
  [[ "$actual_checksum" == "$expected_checksum" ]] ||
    fail "AAB checksum mismatch: $aab_path does not match $checksum_path."

  local bundle_validation
  if ! bundle_validation="$(
    python3 - "$aab_path" <<'PY' 2>&1
import sys
import zipfile

path = sys.argv[1]
try:
    with zipfile.ZipFile(path) as bundle:
        bad_member = bundle.testzip()
        if bad_member is not None:
            raise ValueError(f"corrupt zip member: {bad_member}")
        names = set(bundle.namelist())
        required = {"base/manifest/AndroidManifest.xml"}
        missing = sorted(required - names)
        if missing:
            raise ValueError("missing required App Bundle entries: " + ", ".join(missing))
except zipfile.BadZipFile as exc:
    raise SystemExit(f"not a valid zip/App Bundle: {exc}")
except ValueError as exc:
    raise SystemExit(str(exc))
PY
  )"; then
    fail "AAB integrity check failed: $bundle_validation"
  fi

  printf 'AAB integrity: verified\n'
}

privacy_policy_url="${SAKINAH_PRIVACY_POLICY_URL:-}"
testing_feedback="${SAKINAH_PLAY_TESTING_FEEDBACK:-}"
tester_group_email="${SAKINAH_PLAY_TESTER_GROUP_EMAIL:-$default_tester_group}"

[[ "$tester_group_email" == "$default_tester_group" ]] ||
  fail "SAKINAH_PLAY_TESTER_GROUP_EMAIL must match $default_tester_group for this launch pack."

[[ -n "$privacy_policy_url" ]] ||
  fail "SAKINAH_PRIVACY_POLICY_URL is required before Play upload."
is_https_url "$privacy_policy_url" ||
  fail "SAKINAH_PRIVACY_POLICY_URL must be an https URL."

[[ -n "$testing_feedback" ]] ||
  fail "SAKINAH_PLAY_TESTING_FEEDBACK is required before Play upload."
is_feedback_channel "$testing_feedback" ||
  fail "SAKINAH_PLAY_TESTING_FEEDBACK must be an email address or https URL."

scripts/verify_google_play_public_links.sh

require_true_var \
  SAKINAH_PLAY_TESTER_GROUP_CREATED \
  "creating Sakinah Daily Alpha Testers in Google Groups"
require_true_var \
  SAKINAH_PLAY_CLOSED_TRACK_READY \
  "binding $tester_group_email to the Play Console closed-testing track"
require_true_var \
  SAKINAH_PLAY_APP_CONTENT_READY \
  "completing Play Console App content declarations"
require_true_var \
  SAKINAH_PLAY_STORE_LISTING_READY \
  "final store listing, screenshots, and metadata review"

if ! has_env_signing && ! has_local_signing; then
  fail "upload signing is required through android/key.properties or SAKINAH_UPLOAD_* environment variables."
fi

check_no_tracked_secret_files

if [[ "${SAKINAH_PREFLIGHT_SKIP_RELEASE_GATE:-false}" != "true" ]]; then
  scripts/verify_google_play_internal_release.sh
fi

validate_release_artifact_integrity

printf 'Google Play upload preflight passed.\n'
printf 'Package: %s\n' "$package_name"
printf 'Tester group: %s\n' "$tester_group_email"
printf 'Privacy policy: %s\n' "$privacy_policy_url"
printf 'Testing feedback: %s\n' "$testing_feedback"
printf 'Bundle: %s\n' "$aab_path"
printf 'SHA-256: %s\n' "$checksum_path"
