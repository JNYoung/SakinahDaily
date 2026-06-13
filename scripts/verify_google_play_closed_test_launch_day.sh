#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

launch_day_doc="docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md"
launch_pack="docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md"
runbook="docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
upload_manifest="build/play-upload/manifest.txt"
public_links_manifest="build/play-public-links/manifest.txt"
completed_evidence_dir="build/play-closed-test-launch-day/completed-evidence"
group_email="sakinah-daily-testers@googlegroups.com"
group_link="https://groups.google.com/g/sakinah-daily-testers"
opt_in_link="https://play.google.com/apps/testing/com.sakinahdaily.app"
store_link="https://play.google.com/store/apps/details?id=com.sakinahdaily.app"
leave_link="https://play.google.com/apps/testing/com.sakinahdaily.app/leave"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play closed-test launch day gate failed: %s\n' "$message" >&2
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

require_true_var() {
  local name="$1"
  local description="$2"
  [[ "${!name:-}" == "true" ]] ||
    fail "$name=true is required after $description."
}

require_env_file() {
  local name="$1"
  local description="$2"
  local path="${!name:-}"

  [[ -n "$path" ]] ||
    fail "$name must point to completed evidence after $description."
  [[ -f "$path" ]] ||
    fail "$name points to a missing evidence file: $path"
}

validate_completed_launch_evidence() {
  local path="$1"
  local label="$2"
  shift 2

  require_file "$path"
  for placeholder in \
    TBD \
    pending_manual_observation \
    pending_tap_route \
    record_manually \
    unknown; do
    if grep -Fq "$placeholder" "$path"; then
      fail "$label completed launch evidence still contains placeholder: $placeholder"
    fi
  done

  for needle in "$@"; do
    require_text "$path" "$needle"
  done
}

copy_completed_launch_evidence_file() {
  local env_name="$1"
  local target_name="$2"
  local path="${!env_name:-}"

  require_file "$path"
  mkdir -p "$completed_evidence_dir"
  cp "$path" "$completed_evidence_dir/$target_name"
}

require_launch_evidence_inputs() {
  require_true_var \
    SAKINAH_PLAY_CONSOLE_APP_CREATED \
    "creating the Play Console app record for com.sakinahdaily.app"
  require_true_var \
    SAKINAH_PLAY_TESTER_GROUP_CREATED \
    "creating the Google Group $group_email"
  require_true_var \
    SAKINAH_PLAY_CLOSED_TRACK_READY \
    "binding the tester group to the Closed testing track"
  require_true_var \
    SAKINAH_PLAY_TESTING_FEEDBACK_READY \
    "configuring Play Console Testing feedback"
  require_true_var \
    SAKINAH_PLAY_UPLOAD_PACKET_REVIEWED \
    "reviewing build/play-upload before launch"
  require_true_var \
    SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE \
    "confirming the closed-testing release is approved or visible to testers"
  require_true_var \
    SAKINAH_PLAY_TESTER_LINKS_REVIEWED \
    "reviewing the tester group, opt-in, store, and leave links"
  require_true_var \
    SAKINAH_PLAY_INVITE_COPY_REVIEWED \
    "reviewing the final invite copy and feedback privacy language"
  require_env_file \
    SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE \
    "confirming the Play Console app, upload packet, feedback channel, and live closed-test release"
  require_env_file \
    SAKINAH_CLOSED_TEST_LINKS_EVIDENCE \
    "reviewing Google Group, Play opt-in, store listing, and leave-testing links"
  require_env_file \
    SAKINAH_CLOSED_TEST_INVITE_EVIDENCE \
    "reviewing invite copy, share order, feedback privacy copy, and leave-link exclusion"

  validate_completed_launch_evidence \
    "$SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE" \
    "release" \
    "checkpoint,status,evidence_path,privacy_rule" \
    "play_console_app_created" \
    "closed_test_release_live" \
    "upload_packet_reviewed" \
    "testing_feedback_ready" \
    "No tester personal data"
  validate_completed_launch_evidence \
    "$SAKINAH_CLOSED_TEST_LINKS_EVIDENCE" \
    "tester links" \
    "link_type,url,review_result,evidence_path,privacy_rule" \
    "google_group" \
    "$group_link" \
    "play_opt_in" \
    "$opt_in_link" \
    "store_listing" \
    "$store_link" \
    "leave_testing" \
    "$leave_link" \
    "excluded_from_invite" \
    "No tester personal data"
  validate_completed_launch_evidence \
    "$SAKINAH_CLOSED_TEST_INVITE_EVIDENCE" \
    "invite copy" \
    "copy_check,review_result,evidence_path,privacy_rule" \
    "invite_copy_reviewed" \
    "group_link_first" \
    "play_opt_in_second" \
    "feedback_privacy_copy_reviewed" \
    "leave_link_not_invite" \
    "No tester personal data"

  rm -rf "$completed_evidence_dir"
  copy_completed_launch_evidence_file \
    SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE \
    closed_test_release_evidence.csv
  copy_completed_launch_evidence_file \
    SAKINAH_CLOSED_TEST_LINKS_EVIDENCE \
    closed_test_links_evidence.csv
  copy_completed_launch_evidence_file \
    SAKINAH_CLOSED_TEST_INVITE_EVIDENCE \
    closed_test_invite_evidence.csv
}

for path in \
  "$launch_day_doc" \
  "$launch_pack" \
  "$runbook" \
  "$readiness"; do
  require_file "$path"
done

require_executable scripts/verify_google_play_submission_pack.sh
require_executable scripts/verify_google_play_public_links_packet.sh
require_executable scripts/verify_google_play_store_assets.sh
require_executable scripts/export_google_play_upload_packet.sh

scripts/verify_google_play_submission_pack.sh
scripts/verify_google_play_public_links_packet.sh
scripts/verify_google_play_store_assets.sh
scripts/export_google_play_upload_packet.sh

require_file "$upload_manifest"
require_file "$public_links_manifest"

for needle in \
  'Closed-test launch day checklist' \
  'Google Group link first' \
  'Play opt-in link second' \
  'Leave testing link is not an invite' \
  'No tester personal data' \
  'Please avoid personal or sensitive health details' \
  "$group_link" \
  "$opt_in_link" \
  "$store_link" \
  "$leave_link" \
  'https://support.google.com/googleplay/android-developer/answer/9845334'; do
  require_text "$launch_day_doc" "$needle"
done

for needle in \
  'Sakinah Daily Alpha Testers' \
  "$group_email" \
  "$group_link" \
  "$opt_in_link" \
  "$store_link" \
  "$leave_link" \
  'Do not use this as an invite link' \
  '不要把 leave testing 链接当作邀请链接' \
  '邀请加入 Sakinah Daily 封闭测试' \
  '第一步' \
  '第二步' \
  'Share the Google Group link first' \
  'feedback email or URL' \
  'Testing feedback'; do
  require_text "$launch_pack" "$needle"
done

for needle in \
  'verify_google_play_closed_test_launch_day.sh' \
  'Closed-test launch day gate' \
  'Share the Google Group link first'; do
  require_text "$runbook" "$needle"
  require_text "$readiness" "$needle"
done
require_text "$launch_day_doc" 'SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE'
require_text "$launch_pack" 'SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_EVIDENCE'
require_text "$readiness" 'SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE'

for needle in \
  'Google Play upload evidence packet' \
  'Package: com.sakinahdaily.app' \
  'Privacy rule: No tester personal data.' \
  'Closed-test launch day gate' \
  'scripts/verify_google_play_closed_test_launch_day.sh' \
  'docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md'; do
  require_text "$upload_manifest" "$needle"
done

for needle in \
  'Google Play public links hosting packet' \
  'No tester personal data' \
  'SAKINAH_PLAY_TESTING_FEEDBACK'; do
  require_text "$public_links_manifest" "$needle"
done

if [[ "${SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_EVIDENCE:-false}" == "true" || \
  "${SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY:-false}" == "true" ]]; then
  require_launch_evidence_inputs
  printf 'Closed-test launch evidence inputs: validated\n'
fi

if [[ "${SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY:-false}" == "true" ]]; then
  SAKINAH_REQUIRE_PLAY_SUBMISSION_READY=true \
    scripts/verify_google_play_submission_pack.sh
fi

printf 'Google Play closed-test launch day gate passed.\n'
printf 'Checklist: %s\n' "$launch_day_doc"
printf 'Upload packet: %s\n' "$upload_manifest"
printf 'Tester group link: %s\n' "$group_link"
printf 'Play opt-in link: %s\n' "$opt_in_link"
