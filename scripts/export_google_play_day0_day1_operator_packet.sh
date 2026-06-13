#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_DAY0_DAY1_OPERATOR_PACKET_DIR:-build/play-day0-day1-operator}"
require_strict="${SAKINAH_REQUIRE_DAY0_DAY1_OPERATOR_READY:-false}"
require_complete="${SAKINAH_REQUIRE_DAY0_DAY1_EVIDENCE_COMPLETE:-false}"

launch_day_checklist="docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md"
retention_plan="docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md"
evidence_log="docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md"
submission_runbook="docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
analytics_plan="docs/privacy/07_GOOGLE_ANALYTICS_EVENT_PLAN.md"
group_link="https://groups.google.com/g/sakinah-daily-testers"
opt_in_link="https://play.google.com/apps/testing/com.sakinahdaily.app"
store_link="https://play.google.com/store/apps/details?id=com.sakinahdaily.app"
leave_link="https://play.google.com/apps/testing/com.sakinahdaily.app/leave"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play Day 0 / Day 1 operator packet failed: %s\n' "$message" >&2
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

validate_completed_day0_day1_evidence() {
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
      fail "$label completed evidence still contains placeholder: $placeholder"
    fi
  done

  for needle in "$@"; do
    require_text "$path" "$needle"
  done
}

copy_required_file() {
  local path="$1"
  local target="$out_dir/$path"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

copy_completed_evidence_file() {
  local env_name="$1"
  local target_name="$2"
  local path="${!env_name:-}"

  [[ -n "$path" ]] || return 0
  require_file "$path"
  mkdir -p "$out_dir/completed-evidence"
  cp "$path" "$out_dir/completed-evidence/$target_name"
}

for path in \
  "$launch_day_checklist" \
  "$retention_plan" \
  "$evidence_log" \
  "$submission_runbook" \
  "$readiness" \
  "$analytics_plan"; do
  require_file "$path"
done

for path in \
  scripts/verify_google_play_closed_test_launch_day.sh \
  scripts/export_google_play_closed_test_retention_packet.sh \
  scripts/export_google_analytics_debugview_packet.sh; do
  require_executable "$path"
done

require_text "$launch_day_checklist" 'Google Group link first'
require_text "$launch_day_checklist" 'Play opt-in link second'
require_text "$launch_day_checklist" 'Leave testing link is not an invite'
require_text "$launch_day_checklist" 'Day 0 / Day 1 operator packet'
require_text "$retention_plan" 'Day 0 / Day 1 operator packet'
require_text "$retention_plan" 'Day 1'
require_text "$retention_plan" 'onboarding_location_clarity'
require_text "$evidence_log" 'Day 0 / Day 1 operator packet'
require_text "$evidence_log" 'No tester personal data'
require_text "$submission_runbook" 'export_google_play_day0_day1_operator_packet.sh'
require_text "$readiness" 'Day 0 / Day 1 operator packet'
require_text "$analytics_plan" 'retention loop QA checklist'
require_text "$launch_day_checklist" 'SAKINAH_DAY0_DAY1_STATUS_EVIDENCE'
require_text "$retention_plan" 'SAKINAH_REQUIRE_DAY0_DAY1_EVIDENCE_COMPLETE'
require_text "$readiness" 'SAKINAH_DAY1_FEEDBACK_EVIDENCE'

scripts/verify_google_play_closed_test_launch_day.sh
scripts/export_google_play_closed_test_retention_packet.sh
scripts/export_google_analytics_debugview_packet.sh

completed_evidence_status="not requested"
if [[ "$require_strict" == "true" || "$require_complete" == "true" ]]; then
  require_true_var \
    SAKINAH_DAY0_OPERATOR_OWNER_ASSIGNED \
    "assigning one human owner to run the Day 0 / Day 1 operator checklist"
  require_true_var \
    SAKINAH_DAY0_CLOSED_TEST_RELEASE_VISIBLE \
    "confirming the closed-test release is visible to testers"
  require_true_var \
    SAKINAH_DAY0_GROUP_LINK_SHARED_FIRST \
    "sharing the Google Group link before any Play opt-in link"
  require_true_var \
    SAKINAH_DAY0_PLAY_OPT_IN_SHARED_SECOND \
    "sharing the Play opt-in link only after the Google Group step"
  require_true_var \
    SAKINAH_DAY0_EVIDENCE_LOG_UPDATED \
    "recording Day 0 aggregate facts in docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md"
  require_true_var \
    SAKINAH_DAY1_REVIEW_SCHEDULED \
    "scheduling Day 1 onboarding and first-use feedback review"
  require_true_var \
    SAKINAH_DAY1_FEEDBACK_PRIVACY_COPY_REVIEWED \
    "confirming Day 1 feedback prompts avoid tester personal or sensitive health details"
  require_true_var \
    SAKINAH_DAY1_EVIDENCE_LOG_READY \
    "preparing aggregate Day 1 evidence-log notes"
  require_true_var \
    SAKINAH_DAY1_DEBUGVIEW_DECISION_RECORDED \
    "recording whether an approved Analytics DebugView QA build will be used"

  require_env_file \
    SAKINAH_DAY0_DAY1_STATUS_EVIDENCE \
    "recording Day 0 share order, launch visibility, owner, and Day 1 review readiness"
  require_env_file \
    SAKINAH_DAY1_FEEDBACK_EVIDENCE \
    "reviewing aggregate Day 1 onboarding, install, reminder, privacy, and localization feedback"

  validate_completed_day0_day1_evidence \
    "$SAKINAH_DAY0_DAY1_STATUS_EVIDENCE" \
    "Day 0 / Day 1 status" \
    'checkpoint_day,checkpoint,owner,status,evidence_path,privacy_rule' \
    'release visible to testers' \
    'group link shared first' \
    'Play opt-in shared second' \
    'leave testing link excluded from invite copy' \
    'feedback privacy copy reviewed' \
    'onboarding_location_clarity review scheduled' \
    'Privacy Center first-use feedback reviewed' \
    'DebugView QA decision recorded' \
    'evidence log ready for aggregate notes' \
    'No tester personal data'
  validate_completed_day0_day1_evidence \
    "$SAKINAH_DAY1_FEEDBACK_EVIDENCE" \
    "Day 1 feedback intake" \
    'test_day,theme_key,aggregate_signal,decision_or_follow_up,evidence_path,privacy_rule' \
    'Day 1' \
    'onboarding_location_clarity' \
    'play_install_or_opt_in_access' \
    'reminder_usefulness_or_annoyance' \
    'privacy_center_trust' \
    'localization_rtl_or_bahasa' \
    'reviewed' \
    'No tester personal data'
  completed_evidence_status="validated"
fi

if [[ "$require_strict" == "true" ]]; then
  SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY=true \
    scripts/verify_google_play_closed_test_launch_day.sh
  SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY=true \
    scripts/export_google_play_closed_test_retention_packet.sh
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  "$launch_day_checklist" \
  "$retention_plan" \
  "$evidence_log" \
  "$submission_runbook" \
  "$readiness" \
  "$analytics_plan" \
  scripts/export_google_play_day0_day1_operator_packet.sh \
  scripts/verify_google_play_closed_test_launch_day.sh \
  scripts/export_google_play_closed_test_retention_packet.sh \
  scripts/export_google_analytics_debugview_packet.sh; do
  copy_required_file "$path"
done

copy_completed_evidence_file \
  SAKINAH_DAY0_DAY1_STATUS_EVIDENCE \
  day0_day1_status_evidence.csv
copy_completed_evidence_file \
  SAKINAH_DAY1_FEEDBACK_EVIDENCE \
  day1_feedback_evidence.csv

cat >"$out_dir/day0_day1_operator_checklist.md" <<EOF
# Google Play Day 0 / Day 1 Operator Checklist

Status: Template for the first 24 hours of closed testing.

Privacy rule: No tester personal data. Keep only aggregate counts, theme keys,
decisions, and evidence paths. Do not store tester names, emails, private
messages, screenshots with account data, health details, locations, or Women's
Ibadah Mode exact status.

## Inputs Regenerated By This Script

- Closed-test launch day gate: \`scripts/verify_google_play_closed_test_launch_day.sh\`
- Retention observation packet: \`build/play-retention-observation\`
- Google Analytics DebugView QA packet: \`build/google-analytics-debugview\`
- Upload manifest: \`build/play-upload/manifest.txt\`
- Evidence log: \`docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md\`

## Day 0 Launch Checks

- Confirm the closed-test release is approved or visible to testers.
- Share the Google Group link first: $group_link
- Share the Play opt-in link second: $opt_in_link
- Share the Store listing link only after group membership is clear: $store_link
- Confirm the Leave testing link is not an invite: $leave_link
- Confirm invite copy says: "Please avoid personal or sensitive health details."
- Update \`docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md\` with aggregate Day 0 facts.

## Day 1 First-Use Checks

- Review aggregate onboarding clarity feedback under \`onboarding_location_clarity\`.
- Review whether testers understood manual/preset prayer location and notification choices.
- Review Privacy Center trust feedback under \`privacy_center_trust\`.
- Check whether the in-app closed-testing guide surfaces the Day 1 prompt.
- If a reviewed analytics QA build is available, use \`retention_loop_debugview_qa.md\` from \`build/google-analytics-debugview\`.
- Verify \`closed_test_prompt_copied\` and \`closed_test_prompt_marked_sent\` appear only with prompt day, theme key, and source.
- Keep DebugView evidence aggregate-only; do not export tester-level analytics data.
- Update \`docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md\` with aggregate Day 1 notes.

## Exit Criteria

- Day 0 share order is recorded as Google Group link first, Play opt-in link second.
- Day 1 feedback review has an owner, a time, and a safe aggregate note location.
- Any install eligibility issue is logged under \`play_install_or_opt_in_access\`.
- Any onboarding or privacy confusion has a decision or follow-up.
- No tester personal data is copied into local evidence.
EOF

cat >"$out_dir/day0_day1_status_template.csv" <<'EOF'
checkpoint_day,checkpoint,owner,status,evidence_path,privacy_rule
Day 0,release visible to testers,TBD,TBD,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,No tester personal data
Day 0,group link shared first,TBD,TBD,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,No tester personal data
Day 0,Play opt-in shared second,TBD,TBD,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,No tester personal data
Day 0,leave testing link excluded from invite copy,TBD,TBD,docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md,No tester personal data
Day 0,feedback privacy copy reviewed,TBD,TBD,docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md,No tester personal data
Day 1,onboarding_location_clarity review scheduled,TBD,TBD,build/play-retention-observation/daily_observation_template.csv,No tester personal data
Day 1,Privacy Center first-use feedback reviewed,TBD,TBD,build/play-retention-observation/feedback_theme_template.csv,No tester personal data
Day 1,DebugView QA decision recorded,TBD,TBD,build/google-analytics-debugview/retention_loop_debugview_qa.md,No tester personal data
Day 1,evidence log ready for aggregate notes,TBD,TBD,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,No tester personal data
EOF

cat >"$out_dir/day1_feedback_intake_template.csv" <<'EOF'
test_day,theme_key,aggregate_signal,decision_or_follow_up,evidence_path,privacy_rule
Day 1,onboarding_location_clarity,TBD,TBD,build/play-retention-observation/feedback_theme_template.csv,No tester personal data
Day 1,play_install_or_opt_in_access,TBD,TBD,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,No tester personal data
Day 1,reminder_usefulness_or_annoyance,TBD,TBD,build/play-retention-observation/feedback_theme_template.csv,No tester personal data
Day 1,privacy_center_trust,TBD,TBD,build/play-retention-observation/feedback_theme_template.csv,No tester personal data
Day 1,localization_rtl_or_bahasa,TBD,TBD,build/play-retention-observation/feedback_theme_template.csv,No tester personal data
EOF

cat >"$out_dir/manifest.txt" <<EOF
Google Play Day 0 / Day 1 operator packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: com.sakinahdaily.app
Strict mode requested: $require_strict
Completed evidence requested: $require_complete
Privacy rule: No tester personal data.

Generated files:
- day0_day1_operator_checklist.md
- day0_day1_status_template.csv
- day1_feedback_intake_template.csv

Completed evidence:
- SAKINAH_DAY0_DAY1_STATUS_EVIDENCE=<completed day0_day1_status_evidence.csv>
- SAKINAH_DAY1_FEEDBACK_EVIDENCE=<completed day1_feedback_evidence.csv>
- Completed evidence inputs: $completed_evidence_status

Regenerated dependency packets:
- build/play-upload/manifest.txt
- build/play-public-links/manifest.txt
- build/play-retention-observation
- build/google-analytics-debugview

Copied evidence:
- $launch_day_checklist
- $retention_plan
- $evidence_log
- $submission_runbook
- $readiness
- $analytics_plan
- scripts/export_google_play_day0_day1_operator_packet.sh
- scripts/verify_google_play_closed_test_launch_day.sh
- scripts/export_google_play_closed_test_retention_packet.sh
- scripts/export_google_analytics_debugview_packet.sh

Use:
- Run before sharing tester links and again before Day 1 feedback review.
- Keep Google Group link first and Play opt-in link second.
- Use build/google-analytics-debugview/retention_loop_debugview_qa.md only
  when a reviewed analytics QA build is approved.
- Record only aggregate Day 0 / Day 1 facts in
  docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md.
EOF

printf 'Google Play Day 0 / Day 1 operator packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
