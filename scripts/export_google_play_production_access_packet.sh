#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_PRODUCTION_ACCESS_PACKET_DIR:-build/play-production-access}"
require_strict="${SAKINAH_REQUIRE_PRODUCTION_ACCESS_PACKET_READY:-false}"
aab_path="${SAKINAH_RELEASE_AAB_PATH:-build/app/outputs/bundle/release/app-release.aab}"
checksum_path="${SAKINAH_RELEASE_CHECKSUM_PATH:-build/play-internal/app-release.aab.sha256}"

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

require_text() {
  local path="$1"
  local needle="$2"
  grep -Fq "$needle" "$path" ||
    fail "$path must contain completed retention evidence validation: $needle"
}

require_completed_retention_packet() {
  local manifest="build/play-retention-observation/manifest.txt"
  local daily="build/play-retention-observation/daily_observation_template.csv"
  local feedback="build/play-retention-observation/feedback_theme_template.csv"
  local decisions="build/play-retention-observation/production_access_decisions_template.csv"
  local debugview="build/play-retention-observation/analytics_debugview_retention_evidence.csv"
  local summary="build/play-retention-observation/production_access_feedback_summary.md"

  require_file "$manifest"
  require_file "$daily"
  require_file "$feedback"
  require_file "$decisions"
  require_file "$debugview"
  require_file "$summary"
  require_text "$manifest" 'Completed retention evidence inputs: validated'
  require_text "$daily" 'Day 14'
  require_text "$daily" 'No tester personal data'
  require_text "$feedback" 'retention_reason_to_return'
  require_text "$feedback" 'No tester personal data'
  require_text "$decisions" 'production_access_answer_note'
  require_text "$decisions" 'No tester personal data'
  require_text "$debugview" 'notification_permission_prompt_viewed'
  require_text "$debugview" 'notification_schedule_result'
  require_text "$debugview" 'notification_tap_opened'
  require_text "$debugview" 'no_forbidden_parameters'
  require_text "$debugview" 'No tester personal data'
  require_text "$summary" 'Production Access Feedback Summary'
  require_text "$summary" 'No tester personal data'
}

validate_production_aab_integrity() {
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
  require_completed_retention_packet
  validate_production_aab_integrity
  SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY=true \
    scripts/verify_google_play_production_access_pack.sh
  require_file build/store-assets/google-play-feature-graphic.png
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

aab_status="$(copy_optional_file "$aab_path")"
aab_checksum_status="$(copy_optional_file "$checksum_path")"
feature_graphic_status="$(copy_optional_file build/store-assets/google-play-feature-graphic.png)"
contact_sheet_status="$(copy_optional_file build/store-screenshots/android-contact-sheet.png)"
retention_manifest_status="$(copy_optional_file build/play-retention-observation/manifest.txt)"
retention_daily_status="$(copy_optional_file build/play-retention-observation/daily_observation_template.csv)"
retention_feedback_status="$(copy_optional_file build/play-retention-observation/feedback_theme_template.csv)"
retention_decisions_status="$(copy_optional_file build/play-retention-observation/production_access_decisions_template.csv)"
retention_debugview_status="$(copy_optional_file build/play-retention-observation/analytics_debugview_retention_evidence.csv)"
retention_answer_summary_status="$(copy_optional_file build/play-retention-observation/production_access_feedback_summary.md)"

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
- $aab_path: $aab_status
- $checksum_path: $aab_checksum_status
- build/store-assets/google-play-feature-graphic.png: $feature_graphic_status
- build/store-screenshots/android-contact-sheet.png: $contact_sheet_status
- build/play-retention-observation/manifest.txt: $retention_manifest_status
- build/play-retention-observation/daily_observation_template.csv: $retention_daily_status
- build/play-retention-observation/feedback_theme_template.csv: $retention_feedback_status
- build/play-retention-observation/production_access_decisions_template.csv: $retention_decisions_status
- build/play-retention-observation/analytics_debugview_retention_evidence.csv: $retention_debugview_status
- build/play-retention-observation/production_access_feedback_summary.md: $retention_answer_summary_status

Use:
- Upload the app and answer Play Console fields from the source docs.
- Paste only aggregate tester counts, feedback themes, changes, and readiness
  evidence. Do not paste tester names, emails, health details, private
  messages, or Women's Ibadah Mode status.
- Use production_access_feedback_summary.md from the retention observation
  packet for Day 1 / Day 3 / Day 7 / Day 14 aggregate feedback review before
  filling Production access answers.
- Strict mode requires build/play-retention-observation/manifest.txt to show
  "Completed retention evidence inputs: validated" from
  SAKINAH_REQUIRE_RETENTION_EVIDENCE_COMPLETE=true before this packet can be
  used as final Play Console handoff evidence.
- Strict mode also validates that SAKINAH_RELEASE_AAB_PATH matches
  SAKINAH_RELEASE_CHECKSUM_PATH and that the current AAB is a readable App
  Bundle with base/manifest/AndroidManifest.xml.
EOF

printf 'Production access evidence packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
