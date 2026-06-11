#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_PRODUCTION_ACCESS_PACKET_DIR:-build/play-production-access}"
require_strict="${SAKINAH_REQUIRE_PRODUCTION_ACCESS_PACKET_READY:-false}"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Production access evidence packet failed: %s\n' "$message" >&2
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

require_executable scripts/verify_google_play_production_access_pack.sh
require_executable scripts/verify_google_play_closed_testing_evidence.sh
require_executable scripts/verify_google_play_store_assets.sh
require_executable scripts/export_google_play_closed_test_retention_packet.sh

if [[ "$require_strict" == "true" ]]; then
  SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY=true \
    scripts/verify_google_play_production_access_pack.sh
  require_file build/play-internal/app-release.aab.sha256
  require_file build/store-assets/google-play-feature-graphic.png
  require_file build/play-retention-observation/manifest.txt
else
  scripts/verify_google_play_production_access_pack.sh
  scripts/export_google_play_closed_test_retention_packet.sh
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  docs/release/01_RELEASE_READINESS_CHECKLIST.md \
  docs/release/04_STORE_METADATA_DRAFT.md \
  docs/release/05_SCREENSHOT_PLAN.md \
  docs/release/08_VERSION_AND_RELEASE_NOTES.md \
  docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md \
  docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md \
  docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md \
  docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md \
  docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md \
  docs/privacy/02_PRIVACY_POLICY_DRAFT.md \
  docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md \
  docs/privacy/06_SDK_AND_API_INVENTORY.md \
  scripts/verify_google_play_closed_testing_evidence.sh \
  scripts/verify_google_play_production_access_pack.sh \
  scripts/export_google_play_closed_test_retention_packet.sh \
  scripts/verify_google_play_store_assets.sh; do
  copy_required_file "$path"
done

aab_checksum_status="$(copy_optional_file build/play-internal/app-release.aab.sha256)"
feature_graphic_status="$(copy_optional_file build/store-assets/google-play-feature-graphic.png)"
contact_sheet_status="$(copy_optional_file build/store-screenshots/android-contact-sheet.png)"
retention_manifest_status="$(copy_optional_file build/play-retention-observation/manifest.txt)"
retention_daily_status="$(copy_optional_file build/play-retention-observation/daily_observation_template.csv)"
retention_feedback_status="$(copy_optional_file build/play-retention-observation/feedback_theme_template.csv)"

cat >"$out_dir/manifest.txt" <<EOF
Production access evidence packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: com.sakinahdaily.app
Strict mode requested: $require_strict
Privacy rule: No tester personal data.

Validation:
- scripts/verify_google_play_production_access_pack.sh
- scripts/verify_google_play_closed_testing_evidence.sh
- scripts/verify_google_play_store_assets.sh

Required copied evidence:
- docs/release/01_RELEASE_READINESS_CHECKLIST.md
- docs/release/04_STORE_METADATA_DRAFT.md
- docs/release/05_SCREENSHOT_PLAN.md
- docs/release/08_VERSION_AND_RELEASE_NOTES.md
- docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md
- docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md
- docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md
- docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md
- docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md
- docs/privacy/02_PRIVACY_POLICY_DRAFT.md
- docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md
- docs/privacy/06_SDK_AND_API_INVENTORY.md
- scripts/verify_google_play_production_access_pack.sh

Optional copied artifacts:
- build/play-internal/app-release.aab.sha256: $aab_checksum_status
- build/store-assets/google-play-feature-graphic.png: $feature_graphic_status
- build/store-screenshots/android-contact-sheet.png: $contact_sheet_status
- build/play-retention-observation/manifest.txt: $retention_manifest_status
- build/play-retention-observation/daily_observation_template.csv: $retention_daily_status
- build/play-retention-observation/feedback_theme_template.csv: $retention_feedback_status

Use:
- Upload the app and answer Play Console fields from the source docs.
- Paste only aggregate tester counts, feedback themes, changes, and readiness
  evidence. Do not paste tester names, emails, health details, private
  messages, or Women's Ibadah Mode status.
- Use the retention observation packet for Day 1 / Day 3 / Day 7 / Day 14 aggregate
  feedback review before filling Production access answers.
EOF

printf 'Production access evidence packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
