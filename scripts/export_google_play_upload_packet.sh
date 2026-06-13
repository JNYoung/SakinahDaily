#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_PLAY_UPLOAD_PACKET_DIR:-build/play-upload}"
require_strict="${SAKINAH_REQUIRE_PLAY_UPLOAD_PACKET_READY:-false}"

aab_path="${SAKINAH_RELEASE_AAB_PATH:-build/app/outputs/bundle/release/app-release.aab}"
checksum_path="${SAKINAH_RELEASE_CHECKSUM_PATH:-build/play-internal/app-release.aab.sha256}"
feature_graphic="build/store-assets/google-play-feature-graphic.png"
screenshot_dir="build/store-screenshots/android"
contact_sheet="build/store-screenshots/android-contact-sheet.png"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play upload evidence packet failed: %s\n' "$message" >&2
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

copy_required_file() {
  local path="$1"
  local target="$out_dir/$path"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

copy_optional_file() {
  local path="$1"
  local target="$out_dir/$path"

  if [[ -f "$path" ]]; then
    mkdir -p "$(dirname "$target")"
    cp "$path" "$target"
    printf 'included\n'
  else
    printf 'missing\n'
  fi
}

copy_optional_dir() {
  local path="$1"
  local target="$out_dir/$path"

  if [[ -d "$path" ]]; then
    mkdir -p "$(dirname "$target")"
    cp -R "$path" "$target"
    printf 'included\n'
  else
    printf 'missing\n'
  fi
}

public_or_missing() {
  local value="$1"
  if [[ -n "$value" ]]; then
    printf '%s\n' "$value"
  else
    printf 'missing\n'
  fi
}

require_executable scripts/verify_google_play_upload_preflight.sh
require_executable scripts/verify_google_play_public_links.sh
require_executable scripts/export_google_play_public_links_packet.sh
require_executable scripts/verify_google_play_public_links_packet.sh
require_executable scripts/verify_google_play_internal_release.sh
require_executable scripts/verify_google_play_store_assets.sh
require_executable scripts/verify_google_play_submission_pack.sh
require_executable scripts/verify_google_play_closed_test_launch_day.sh

if [[ "$require_strict" == "true" ]]; then
  scripts/verify_google_play_upload_preflight.sh
  SAKINAH_REQUIRE_STORE_ASSETS_READY=true \
    scripts/verify_google_play_store_assets.sh
  require_file "$aab_path"
  require_file "$checksum_path"
  require_file "$feature_graphic"
else
  scripts/verify_google_play_public_links_packet.sh
  scripts/verify_google_play_store_assets.sh
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  docs/release/01_RELEASE_READINESS_CHECKLIST.md \
  docs/release/02_ANDROID_RELEASE_CHECKLIST.md \
  docs/release/04_STORE_METADATA_DRAFT.md \
  docs/release/05_SCREENSHOT_PLAN.md \
  docs/release/08_VERSION_AND_RELEASE_NOTES.md \
  docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md \
  docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md \
  docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md \
  docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md \
  docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md \
  docs/privacy/02_PRIVACY_POLICY_DRAFT.md \
  docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md \
  docs/privacy/06_SDK_AND_API_INVENTORY.md \
  android/app/build.gradle.kts \
  android/app/src/main/AndroidManifest.xml \
  android/key.properties.example \
  scripts/export_google_play_public_links_packet.sh \
  scripts/verify_google_play_public_links_packet.sh \
  scripts/verify_google_play_upload_preflight.sh \
  scripts/verify_google_play_public_links.sh \
  scripts/verify_google_play_internal_release.sh \
  scripts/verify_google_play_store_assets.sh \
  scripts/verify_google_play_submission_pack.sh \
  scripts/verify_google_play_closed_test_launch_day.sh; do
  copy_required_file "$path"
done

aab_status="$(copy_optional_file "$aab_path")"
checksum_status="$(copy_optional_file "$checksum_path")"
feature_graphic_status="$(copy_optional_file "$feature_graphic")"
contact_sheet_status="$(copy_optional_file "$contact_sheet")"
screenshot_dir_status="$(copy_optional_dir "$screenshot_dir")"

cat >"$out_dir/manifest.txt" <<EOF
Google Play upload evidence packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: com.sakinahdaily.app
Strict mode requested: $require_strict
Privacy rule: No tester personal data.

Public release fields:
- SAKINAH_PRIVACY_POLICY_URL: $(public_or_missing "${SAKINAH_PRIVACY_POLICY_URL:-}")
- SAKINAH_PLAY_TESTING_FEEDBACK: $(public_or_missing "${SAKINAH_PLAY_TESTING_FEEDBACK:-}")
- SAKINAH_PLAY_TESTER_GROUP_EMAIL: $(public_or_missing "${SAKINAH_PLAY_TESTER_GROUP_EMAIL:-sakinah-daily-testers@googlegroups.com}")

Validation:
- scripts/verify_google_play_upload_preflight.sh
- scripts/verify_google_play_public_links.sh
- scripts/verify_google_play_public_links_packet.sh
- scripts/verify_google_play_store_assets.sh
- scripts/verify_google_play_submission_pack.sh
- scripts/verify_google_play_closed_test_launch_day.sh
- Release AAB integrity: strict mode validates current checksum match and
  App Bundle zip/base manifest structure through upload preflight.

Required copied evidence:
- docs/release/01_RELEASE_READINESS_CHECKLIST.md
- docs/release/02_ANDROID_RELEASE_CHECKLIST.md
- docs/release/04_STORE_METADATA_DRAFT.md
- docs/release/05_SCREENSHOT_PLAN.md
- docs/release/08_VERSION_AND_RELEASE_NOTES.md
- docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md
- docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md
- docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md
- docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md
- docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md
- docs/privacy/02_PRIVACY_POLICY_DRAFT.md
- docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md
- docs/privacy/06_SDK_AND_API_INVENTORY.md
- android/app/build.gradle.kts
- android/app/src/main/AndroidManifest.xml
- android/key.properties.example
- scripts/verify_google_play_upload_preflight.sh
- scripts/export_google_play_public_links_packet.sh
- scripts/verify_google_play_public_links_packet.sh
- scripts/verify_google_play_closed_test_launch_day.sh

Optional copied artifacts:
- $aab_path: $aab_status
- $checksum_path: $checksum_status
- build/store-assets/google-play-feature-graphic.png: $feature_graphic_status
- build/store-screenshots/android-contact-sheet.png: $contact_sheet_status
- build/store-screenshots/android: $screenshot_dir_status

Use:
- Keep keystores, android/key.properties, and service-account files out of this
  packet and out of git.
- Upload the signed AAB from the source build path, not from chat text.
- Complete Play Console App content, Store listing, Testing feedback, tester
  group, and Closed testing track fields before sharing tester links.
- Share the Google Group link before the Play opt-in link so testers are
  eligible to install the closed-testing build.
- Closed-test launch day gate: run
  scripts/verify_google_play_closed_test_launch_day.sh after the closed-testing
  release is approved or visible to testers.
EOF

printf 'Google Play upload evidence packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
