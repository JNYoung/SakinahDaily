#!/usr/bin/env bash
set -euo pipefail

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play public links failed: %s\n' "$message" >&2
  exit "$code"
}

is_https_url() {
  [[ "$1" =~ ^https://[^[:space:]]+\.[^[:space:]]+ ]]
}

is_email() {
  [[ "$1" =~ ^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$ ]]
}

reject_placeholder_url() {
  local name="$1"
  local value="$2"
  local lower
  lower="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"

  case "$lower" in
    *example.com*|*localhost*|*127.0.0.1*|*0.0.0.0*|*.invalid*|*.test*)
      fail "$name must be a real public URL, not example.com, localhost, 127.0.0.1, .invalid, or .test."
      ;;
  esac
}

reject_placeholder_email() {
  local name="$1"
  local value="$2"
  local domain
  domain="$(printf '%s' "$value" | sed -E 's/^[^@]+@//' | tr '[:upper:]' '[:lower:]')"

  case "$domain" in
    example.com|*.example.com|*.example|localhost|*.localhost|*.invalid|*.test)
      fail "$name must be a real feedback email, not example.com, localhost, .invalid, or .test."
      ;;
  esac
}

verify_public_url() {
  local name="$1"
  local url="$2"

  is_https_url "$url" || fail "$name must be an https:// URL."
  reject_placeholder_url "$name" "$url"

  if [[ "${SAKINAH_SKIP_PUBLIC_LINK_NETWORK:-false}" == "true" ]]; then
    return 0
  fi

  command -v curl >/dev/null 2>&1 ||
    fail "curl is required to verify public URLs. Set SAKINAH_SKIP_PUBLIC_LINK_NETWORK=true only for local script-control QA."

  curl --silent --show-error --location --fail --max-time 20 --output /dev/null "$url" ||
    fail "$name is not publicly reachable: $url"
}

privacy_policy_url="${SAKINAH_PRIVACY_POLICY_URL:-}"
testing_feedback="${SAKINAH_PLAY_TESTING_FEEDBACK:-}"

[[ -n "$privacy_policy_url" ]] ||
  fail "SAKINAH_PRIVACY_POLICY_URL is required before Play upload."
verify_public_url "SAKINAH_PRIVACY_POLICY_URL" "$privacy_policy_url"

[[ -n "$testing_feedback" ]] ||
  fail "SAKINAH_PLAY_TESTING_FEEDBACK is required before Play upload."
if is_email "$testing_feedback"; then
  reject_placeholder_email "SAKINAH_PLAY_TESTING_FEEDBACK" "$testing_feedback"
else
  verify_public_url "SAKINAH_PLAY_TESTING_FEEDBACK" "$testing_feedback"
fi

printf 'Google Play public links passed.\n'
printf 'Privacy policy: %s\n' "$privacy_policy_url"
printf 'Testing feedback: %s\n' "$testing_feedback"
