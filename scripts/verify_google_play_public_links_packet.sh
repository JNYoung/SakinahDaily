#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

packet_dir="${SAKINAH_PUBLIC_LINKS_PACKET_DIR:-build/play-public-links}"
# Default QA targets: build/play-public-links/privacy/index.html and
# build/play-public-links/feedback/index.html.
privacy_html="$packet_dir/privacy/index.html"
feedback_html="$packet_dir/feedback/index.html"
manifest="$packet_dir/manifest.txt"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play public links hosting packet QA failed: %s\n' "$message" >&2
  exit "$code"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "required file is missing: $path"
}

require_executable() {
  local path="$1"
  [[ -x "$path" ]] || fail "required script is not executable: $path"
}

require_text() {
  local path="$1"
  local needle="$2"
  grep -Fq "$needle" "$path" ||
    fail "$path is missing required text: $needle"
}

reject_text() {
  local path="$1"
  local needle="$2"
  if grep -Fqi "$needle" "$path"; then
    fail "$path contains blocked text: $needle"
  fi
}

reject_regex() {
  local path="$1"
  local pattern="$2"
  if grep -Eiq "$pattern" "$path"; then
    fail "$path contains blocked pattern: $pattern"
  fi
}

require_executable scripts/export_google_play_public_links_packet.sh
scripts/export_google_play_public_links_packet.sh

require_file "$privacy_html"
require_file "$feedback_html"
require_file "$manifest"

for path in "$privacy_html" "$feedback_html"; do
  require_text "$path" '<!doctype html>'
  require_text "$path" '<meta name="viewport"'
  require_text "$path" 'max-width: 820px'
  reject_text "$path" 'TBD'
  reject_text "$path" 'To be finalized'
  reject_text "$path" 'example.com'
  reject_text "$path" 'localhost'
  reject_text "$path" '127.0.0.1'
  reject_text "$path" '.invalid'
  reject_text "$path" '.test'
  reject_regex "$path" '<script[[:space:]>]'
done

for blocked_form_pattern in \
  '<form[[:space:]>]' \
  '<input[[:space:]>]' \
  '<textarea[[:space:]>]' \
  '<button[[:space:]>]'; do
  reject_regex "$feedback_html" "$blocked_form_pattern"
done

for needle in \
  'Sakinah Daily Privacy Policy' \
  'Effective date:' \
  'Contact:' \
  'Summary' \
  'Data Stored On Device' \
  'Data That May Leave The Device' \
  'How To Delete Local Data' \
  'Settings &gt; Privacy &gt; Delete local data' \
  'No ads, tracking SDK, crash SDK, or default-on analytics collection' \
  "Women's Ibadah Mode" \
  'No AI fatwa'; do
  require_text "$privacy_html" "$needle"
done

for needle in \
  'Sakinah Daily Closed Testing Feedback' \
  'Please avoid personal or sensitive health details' \
  "Do not send Women's Ibadah Mode exact status" \
  'Day 1' \
  'Day 3' \
  'Day 7' \
  'Day 14' \
  'Home next-prayer context' \
  'Prayer times, local reminders' \
  'Privacy Center, Delete local data' \
  'https://groups.google.com/g/sakinah-daily-testers' \
  'https://play.google.com/apps/testing/com.sakinahdaily.app'; do
  require_text "$feedback_html" "$needle"
done

for needle in \
  'Google Play public links hosting packet' \
  'Package: com.sakinahdaily.app' \
  'Privacy rule: No tester personal data.' \
  'scripts/verify_google_play_public_links.sh' \
  'scripts/verify_google_play_public_links_packet.sh' \
  'SAKINAH_PRIVACY_POLICY_URL' \
  'SAKINAH_PLAY_TESTING_FEEDBACK'; do
  require_text "$manifest" "$needle"
done

printf 'Google Play public links hosting packet QA passed.\n'
printf 'Privacy page: %s\n' "$privacy_html"
printf 'Feedback page: %s\n' "$feedback_html"
printf 'Manifest: %s\n' "$manifest"
