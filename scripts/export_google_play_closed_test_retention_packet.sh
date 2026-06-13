#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_RETENTION_OBSERVATION_PACKET_DIR:-build/play-retention-observation}"
require_strict="${SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY:-false}"
require_complete="${SAKINAH_REQUIRE_RETENTION_EVIDENCE_COMPLETE:-false}"

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

require_env_file() {
  local name="$1"
  local description="$2"
  local path="${!name:-}"

  [[ -n "$path" ]] ||
    fail "$name must point to completed evidence after $description."
  [[ -f "$path" ]] ||
    fail "$name points to a missing evidence file: $path"
}

validate_completed_retention_evidence() {
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
      fail "$label completed retention evidence still contains placeholder: $placeholder"
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
require_text "$answer_draft" 'production_access_feedback_summary.md'
require_text "$launch_day_checklist" 'No tester personal data'
require_text "$product_progress" 'Weekly Active Prayer Reminder Users'
require_text "$acceptance" 'Beta observation'
require_text "$observation_plan" 'SAKINAH_REQUIRE_RETENTION_EVIDENCE_COMPLETE'
require_text "$observation_plan" 'SAKINAH_PLAY_RETENTION_DAILY_EVIDENCE'
require_text "$observation_plan" 'retention_operator_calendar.csv'
require_text "$launch_day_checklist" 'retention_operator_calendar.csv'

scripts/verify_google_play_closed_testing_evidence.sh

if [[ "$require_strict" == "true" || "$require_complete" == "true" ]]; then
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

if [[ "$require_complete" == "true" ]]; then
  require_env_file \
    SAKINAH_PLAY_RETENTION_DAILY_EVIDENCE \
    "recording aggregate Day 0 / Day 1 / Day 3 / Day 7 / Day 14 retention observations"
  require_env_file \
    SAKINAH_PLAY_RETENTION_FEEDBACK_EVIDENCE \
    "summarizing aggregate feedback themes after closed testing"
  require_env_file \
    SAKINAH_PLAY_RETENTION_DECISIONS_EVIDENCE \
    "recording production-access changes or release decisions"
  require_env_file \
    SAKINAH_PLAY_RETENTION_DEBUGVIEW_EVIDENCE \
    "recording the approved Google Analytics DebugView retention-loop review"

  validate_completed_retention_evidence \
    "$SAKINAH_PLAY_RETENTION_DAILY_EVIDENCE" \
    "daily closed-test observation" \
    'test_day' \
    'Day 0' \
    'Day 1' \
    'Day 3' \
    'Day 7' \
    'Day 14' \
    'active_install_signal' \
    'prayer_view_signal' \
    'reminder_opt_in_signal' \
    'daily_session_signal' \
    'No tester personal data'
  validate_completed_retention_evidence \
    "$SAKINAH_PLAY_RETENTION_FEEDBACK_EVIDENCE" \
    "closed-test feedback themes" \
    'onboarding_location_clarity' \
    'prayer_time_trust' \
    'reminder_usefulness_or_annoyance' \
    'retention_reason_to_return' \
    'reviewed' \
    'No tester personal data'
  validate_completed_retention_evidence \
    "$SAKINAH_PLAY_RETENTION_DECISIONS_EVIDENCE" \
    "production-access decisions" \
    'feedback_theme' \
    'change_or_decision' \
    'release_status' \
    'production_access_answer_note' \
    'ready' \
    'No tester personal data'
  validate_completed_retention_evidence \
    "$SAKINAH_PLAY_RETENTION_DEBUGVIEW_EVIDENCE" \
    "Google Analytics DebugView retention evidence" \
    'analytics_decision' \
    'home_viewed' \
    'notification_permission_prompt_viewed' \
    'notification_schedule_result' \
    'notification_tap_opened' \
    'local_push_resolution_result' \
    'no_forbidden_parameters' \
    'No tester personal data'
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

cat >"$out_dir/analytics_debugview_retention_evidence.csv" <<'EOF'
qa_item,analytics_decision,event_name,expected_result,privacy_result,evidence_note,privacy_rule
retention_loop,TBD,home_viewed,TBD,TBD,TBD,No tester personal data
push_prompt,TBD,notification_permission_prompt_viewed,TBD,TBD,TBD,No tester personal data
push_schedule,TBD,notification_schedule_result,TBD,TBD,TBD,No tester personal data
push_open,TBD,notification_tap_opened,TBD,TBD,TBD,No tester personal data
push_resolution,TBD,local_push_resolution_result,TBD,TBD,TBD,No tester personal data
daily_session_return,TBD,daily_session_reminder_changed,TBD,TBD,TBD,No tester personal data
EOF

cat >"$out_dir/retention_operator_calendar.csv" <<'EOF'
test_day,operator_task,evidence_to_update,feedback_focus,privacy_rule,next_action
Day 0,share Google Group link first then Play opt-in link,docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md,play_install_or_opt_in_access,No tester personal data,record aggregate opted-in testers and install visibility
Day 1,record aggregate opted-in testers and first-use clarity,daily_observation_template.csv,onboarding_location_clarity,No tester personal data,review location and notification setup confusion
Day 3,review prayer reminder usefulness and prayer-time trust,feedback_theme_template.csv,prayer_time_trust,No tester personal data,group reminder usefulness or annoyance themes
Day 7,review return reasons and privacy trust,daily_observation_template.csv,retention_reason_to_return,No tester personal data,decide whether a small follow-up is needed before Day 14
Day 14,summarize production access feedback and release decisions,production_access_feedback_summary.md,retention_reason_to_return,No tester personal data,copy aggregate answers into Production access draft
EOF

cat >"$out_dir/retention_operator_runbook.md" <<'EOF'
# Closed-Test Retention Operator Runbook

Status: Template; use with `retention_operator_calendar.csv` during the real
Google Play closed test.

Privacy rule: No tester personal data. Record aggregate counts, theme keys,
decisions, and follow-up status only. Do not record tester names, emails,
private messages, health details, screenshots with account data, exact
locations, or Women's Ibadah Mode exact status.

## Day 0

- Share the Google Group link first, then the Play opt-in link.
- Confirm testers can join, opt in, install, and open the app.
- Update `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` with aggregate
  opted-in tester count and install visibility only.

## Day 1

- Review first-use feedback for onboarding, manual/preset prayer location, and
  notification choice clarity.
- Update `daily_observation_template.csv` and `feedback_theme_template.csv`
  with aggregate themes.

## Day 3

- Review prayer-time trust, selected location clarity, and prayer reminder
  usefulness or annoyance.
- Keep feedback grouped under `prayer_time_trust` or
  `reminder_usefulness_or_annoyance`.

## Day 7

- Review why testers reopened or ignored the app.
- Decide whether any small copy or release-note follow-up should be completed
  before Day 14.

## Day 14

- Summarize aggregate themes and release decisions in
  `production_access_feedback_summary.md`.
- Copy reviewed, aggregate-only answers into
  `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`.
- Confirm the final summary still says No tester personal data.
EOF

if [[ "$require_complete" == "true" ]]; then
  cp "$SAKINAH_PLAY_RETENTION_DAILY_EVIDENCE" \
    "$out_dir/daily_observation_template.csv"
  cp "$SAKINAH_PLAY_RETENTION_FEEDBACK_EVIDENCE" \
    "$out_dir/feedback_theme_template.csv"
  cp "$SAKINAH_PLAY_RETENTION_DECISIONS_EVIDENCE" \
    "$out_dir/production_access_decisions_template.csv"
  cp "$SAKINAH_PLAY_RETENTION_DEBUGVIEW_EVIDENCE" \
    "$out_dir/analytics_debugview_retention_evidence.csv"
fi

cat >"$out_dir/production_access_feedback_summary.md" <<'EOF'
# Production Access Feedback Summary

Status: Template; fill after Day 14 using aggregate closed-test evidence only.

Privacy rule: No tester personal data. Do not paste tester names, emails,
private messages, screenshots with account data, health details, exact
locations, or Women's Ibadah Mode exact status.

## Closed Test Evidence Inputs

- `daily_observation_template.csv` for Day 1 / Day 3 / Day 7 / Day 14
  aggregate observation notes.
- `feedback_theme_template.csv` for aggregate feedback themes, severity,
  decisions, and follow-up status.
- `production_access_decisions_template.csv` for changes made or release
  decisions.
- `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` for the final canonical
  evidence log.
- `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md` for copy-ready Play
  Console answer sections.
- `retention_operator_calendar.csv` and `retention_operator_runbook.md` for the
  Day 0 / Day 1 / Day 3 / Day 7 / Day 14 operator task list.

## What Feedback Did You Receive

Draft after Day 14:

```text
We reviewed aggregate feedback from Google Play Testing feedback and the
configured feedback channel. The main themes were: TBD. We used Day 1 / Day 3 /
Day 7 / Day 14 prompts to group feedback around onboarding clarity, prayer-time
trust, reminder usefulness, daily return intent, privacy trust, localization,
and performance. We did not store tester personal data.
```

Evidence to cite:

- `feedback_theme_template.csv`
- `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`

## What Changes Did You Make

Draft after Day 14:

```text
Based on tester feedback, we made or documented the following changes: TBD. We
kept changes scoped to the prayer-first v0.1 release path and did not add ads,
tracking, social features, AI fatwa, or remote storage of sensitive Women's
Ibadah Mode state.
```

Evidence to cite:

- `production_access_decisions_template.csv`
- `docs/release/01_RELEASE_READINESS_CHECKLIST.md`

## Why Is The App Ready For Production

Draft after Day 14:

```text
The app is ready for Production access after closed testing because the tested
release path is narrow and local-first: Home -> Prayer -> Session -> Settings.
Testers could review prayer times, manage local reminders, complete a daily
session, inspect Privacy Center, and send structured feedback. Store listing,
Data Safety, release readiness, Android launch smoke, and reminder observation
evidence are tracked before submission.
```

Evidence to cite:

- `docs/release/01_RELEASE_READINESS_CHECKLIST.md`
- `build/play-upload/manifest.txt`
- `build/play-production-access/manifest.txt`

## Final Fill Checklist

- [ ] Replace `TBD` with aggregate feedback themes and decisions.
- [ ] Confirm Day 1 / Day 3 / Day 7 / Day 14 evidence is summarized.
- [ ] Confirm no tester personal data appears in this summary.
- [ ] Copy finalized answers into `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`.
EOF

cat >"$out_dir/manifest.txt" <<EOF
Google Play closed-test retention observation packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: com.sakinahdaily.app
Strict mode requested: $require_strict
Completed evidence requested: $require_complete
Completed retention evidence inputs: $([[ "$require_complete" == "true" ]] && printf 'validated' || printf 'not requested')
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
- analytics_debugview_retention_evidence.csv
- retention_operator_calendar.csv
- retention_operator_runbook.md
- production_access_feedback_summary.md

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
- Use production_access_feedback_summary.md to turn Day 1 / Day 3 / Day 7 /
  Day 14 aggregate themes into Play Console answer-ready copy.
- Use retention_operator_calendar.csv and retention_operator_runbook.md to keep
  the Day 0 / Day 1 / Day 3 / Day 7 / Day 14 review cadence explicit.
- Use SAKINAH_REQUIRE_RETENTION_EVIDENCE_COMPLETE=true only after Day 14
  aggregate evidence, production-access decisions, and reviewed DebugView
  retention-loop evidence files are complete and contain no template
  placeholders.
EOF

printf 'Google Play closed-test retention observation packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
