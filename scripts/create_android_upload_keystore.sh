#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
cd "$repo_root"
umask 077

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Android upload keystore setup failed: %s\n' "$message" >&2
  exit "$code"
}

require_env() {
  local name="$1"
  [[ -n "${!name:-}" ]] || fail "$name is required."
}

require_env SAKINAH_UPLOAD_KEYSTORE_PATH
require_env SAKINAH_UPLOAD_STORE_PASSWORD
require_env SAKINAH_UPLOAD_KEY_ALIAS
require_env SAKINAH_UPLOAD_KEY_PASSWORD

command -v keytool >/dev/null 2>&1 ||
  fail "keytool is required. Install a JDK before creating the upload keystore."

keystore_path="$SAKINAH_UPLOAD_KEYSTORE_PATH"
case "$keystore_path" in
  /*) ;;
  *) keystore_path="$PWD/$keystore_path" ;;
esac

keystore_parent="$(dirname "$keystore_path")"
keystore_name="$(basename "$keystore_path")"
[[ -d "$keystore_parent" ]] ||
  fail "parent directory does not exist for SAKINAH_UPLOAD_KEYSTORE_PATH."

keystore_parent="$(cd "$keystore_parent" && pwd -P)"
keystore_path="$keystore_parent/$keystore_name"

case "$keystore_path" in
  "$repo_root"/*)
    fail "refusing to create a keystore inside the repo; choose a path outside the repository."
    ;;
esac

if [[ -e "$keystore_path" && "${SAKINAH_OVERWRITE_KEYSTORE:-false}" != "true" ]]; then
  fail "keystore already exists. Set SAKINAH_OVERWRITE_KEYSTORE=true to replace it."
fi
if [[ -e "$keystore_path" ]]; then
  rm -f "$keystore_path"
fi

keytool -genkeypair \
  -v \
  -keystore "$keystore_path" \
  -storetype JKS \
  -storepass "$SAKINAH_UPLOAD_STORE_PASSWORD" \
  -alias "$SAKINAH_UPLOAD_KEY_ALIAS" \
  -keypass "$SAKINAH_UPLOAD_KEY_PASSWORD" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -dname "CN=Sakinah Daily Upload,O=Sakinah Daily,C=US"

key_properties_path="android/key.properties"
if [[ "${SAKINAH_WRITE_KEY_PROPERTIES:-false}" == "true" ]]; then
  if [[ -e "$key_properties_path" && "${SAKINAH_OVERWRITE_KEY_PROPERTIES:-false}" != "true" ]]; then
    fail "android/key.properties already exists. Set SAKINAH_OVERWRITE_KEY_PROPERTIES=true to replace it."
  fi

  {
    printf '# Local upload signing config. Do not commit.\n'
    printf 'storeFile=%s\n' "$keystore_path"
    printf 'storePassword=%s\n' "$SAKINAH_UPLOAD_STORE_PASSWORD"
    printf 'keyAlias=%s\n' "$SAKINAH_UPLOAD_KEY_ALIAS"
    printf 'keyPassword=%s\n' "$SAKINAH_UPLOAD_KEY_PASSWORD"
  } >"$key_properties_path"
  chmod 600 "$key_properties_path"
else
  printf 'Skipped android/key.properties because SAKINAH_WRITE_KEY_PROPERTIES is not true.\n'
fi

printf 'Android upload keystore created.\n'
printf 'Keystore: %s\n' "$keystore_path"
printf 'Alias: %s\n' "$SAKINAH_UPLOAD_KEY_ALIAS"
printf 'Next: run scripts/verify_google_play_upload_preflight.sh after Play Console fields are ready.\n'
