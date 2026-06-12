#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_RETENTION_OBSERVATION_PACKET_DIR:-build/play-retention-observation}"
require_strict="${SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY:-false}"

observation_plan="docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md"
evidence_log="docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md"
answer_draft="docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md"
launch_day_checklist="docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md"
product_progress="docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md"
acceptance="docs/testing/01_ACCEPTANCE_CHECKLIST.md"
official_reference="https://support.google.com/googleplay/android-developer/answer/14151465"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play closed-test retention observation packet failed: %s\n' "$message" >&2
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

copy_required_file() {
  local path="$1"
  local target="$out_dir/$path"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

for path in \
  "$observation_plan" \
  "$evidence_log" \
  "$answer_draft" \
  "$launch_day_checklist" \
  "$product_progress" \
  "$acceptance"; do
  require_file "$path"
done

require_executable scripts/verify_google_play_closed_testing_evidence.sh

for needle in \
  'Closed-test retention observation plan' \
  'Weekly Active Prayer Reminder Users' \
  'Prayer Reminder Opt-in Rate' \
  'Day 1' \
  'Day 7' \
  'Day 14' \
  'No tester personal data' \
  'Please avoid personal or sensitive health details' \
  "$official_reference"; do
  require_text "$observation_plan" "$needle"
done

require_text "$evidence_log" 'Feedback themes'
require_text "$evidence_log" 'Production access answers'
require_text "$answer_draft" 'What Feedback Did You Receive'
require_text "$answer_draft" 'What Changes Did You Make'
require_text "$launch_day_checklist" 'No tester personal data'
require_text "$product_progress" 'Weekly Active Prayer Reminder Users'
require_text "$acceptance" 'Beta observation'

scripts/verify_google_play_closed_testing_evidence.sh

if [[ "$require_strict" == "true" ]]; then
  require_true_var \
    SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE \
    "confirming the closed-testing release is approved or live for testers"
  require_true_var \
    SAKINAH_PLAY_TESTING_FEEDBACK_READY \
    "configuring Google Play Testing feedback and the app feedback channel"
  require_true_var \
    SAKINAH_PLAY_RETENTION_OWNER_ASSIGNED \
    "assigning a human owner for Day 1 / Day 3 / Day 7 / Day 14 review"
  require_true_var \
    SAKINAH_PLAY_RETENTION_REVIEW_SCHEDULED \
    "scheduling Day 1 / Day 3 / Day 7 / Day 14 feedback review"
  require_true_var \
    SAKINAH_PLAY_EVIDENCE_LOG_READY \
    "preparing docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md for aggregate notes"
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  "$observation_plan" \
  "$evidence_log" \
  "$answer_draft" \
  "$launch_day_checklist" \
  "$product_progress" \
  "$acceptance" \
  scripts/export_google_play_closed_test_retention_packet.sh \
  scripts/verify_google_play_closed_testing_evidence.sh; do
  copy_required_file "$path"
done

cat >"$out_dir/daily_observation_template.csv" <<'EOF'
test_day,calendar_date,version_code,opted_in_testers,active_install_signal,prayer_view_signal,reminder_opt_in_signal,daily_session_signal,suggested_theme_key,feedback_reviewed,decision_or_follow_up,evidence_note
Day 0,TBD,1,TBD,release visible to testers,TBD,TBD,TBD,play_install_or_opt_in_access,TBD,launch observation started,no tester personal data
Day 1,TBD,1,TBD,TBD,TBD,TBD,TBD,onboarding_location_clarity,onboarding/location/notification clarity,TBD,Please avoid personal or sensitive health details
Day 3,TBD,1,TBD,TBD,prayer time and location clarity,reminder usefulness or annoyance,TBD,prayer_time_trust,prayer loop feedback,TBD,aggregate only
Day 7,TBD,1,TBD,TBD,TBD,TBD,TBD,retention_reason_to_return,retention friction,TBD,What made testers want to reopen or ignore the app?
Day 14,TBD,1,TBD,TBD,TBD,TBD,TBD,retention_reason_to_return,production readiness feedback,TBD,What one change would most improve daily use?
EOF

cat >"$out_dir/feedback_theme_template.csv" <<'EOF'
theme,severity,source,decision,fix_or_follow_up,status,production_access_answer_note
onboarding_location_clarity,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
prayer_time_trust,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
reminder_usefulness_or_annoyance,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
daily_session_calmness,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
privacy_center_trust,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
religious_content_source_trust,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
localization_rtl_or_bahasa,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
performance_or_crash,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
play_install_or_opt_in_access,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
retention_reason_to_return,TBD,Play Testing feedback / feedback channel,TBD,TBD,TBD,TBD
EOF

cat >"$out_dir/production_access_decisions_template.csv" <<'EOF'
decision_date,feedback_theme,change_or_decision,evidence,release_status,production_access_answer_note
TBD,TBD,TBD,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,TBD,TBD
EOF

cat >"$out_dir/manifest.txt" <<EOF
Google Play closed-test retention observation packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: com.sakinahdaily.app
Strict mode requested: $require_strict
Privacy rule: No tester personal data.

Observation focus:
- Weekly Active Prayer Reminder Users
- Prayer Reminder Opt-in Rate
- D1 / D7 Retention
- Day 1 / Day 3 / Day 7 / Day 14 feedback prompts

Generated templates:
- daily_observation_template.csv
- feedback_theme_template.csv
- production_access_decisions_template.csv

Copied evidence:
- $observation_plan
- $evidence_log
- $answer_draft
- $launch_day_checklist
- $product_progress
- $acceptance
- scripts/export_google_play_closed_test_retention_packet.sh
- scripts/verify_google_play_closed_testing_evidence.sh

Use:
- Keep only aggregate tester counts, feedback themes, decisions, and fixes.
- Do not store tester names, emails, health details, private messages,
  screenshots with account data, or Women's Ibadah Mode exact status.
- Transfer summarized themes into docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md
  and docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md before Production
  access review.
EOF

printf 'Google Play closed-test retention observation packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
