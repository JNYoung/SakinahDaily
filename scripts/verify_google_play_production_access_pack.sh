#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

answer_draft="docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md"
evidence_log="docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md"
retention_plan="docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
submission_runbook="docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md"
official_reference="https://support.google.com/googleplay/android-developer/answer/14151465"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Production access answer pack failed: %s\n' "$message" >&2
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

require_file "$answer_draft"
require_file "$evidence_log"
require_file "$retention_plan"
require_file "$readiness"
require_file "$submission_runbook"
require_executable scripts/verify_google_play_closed_testing_evidence.sh
require_executable scripts/export_google_play_closed_test_retention_packet.sh

for needle in \
  'Production access answer draft' \
  'Closed Test Summary' \
  'How many testers joined' \
  '14 continuous days' \
  'What Feedback Did You Receive' \
  'What Changes Did You Make' \
  'Why Is The App Ready For Production' \
  'Intended Users And Value' \
  'Sakinah Daily Alpha Testers' \
  'sakinah-daily-testers@googlegroups.com' \
  'com.sakinahdaily.app' \
  'No tester personal data' \
  'docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md' \
  'docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md' \
  'docs/release/01_RELEASE_READINESS_CHECKLIST.md' \
  'build/play-internal/app-release.aab.sha256' \
  "$official_reference"; do
  require_text "$answer_draft" "$needle"
done

for needle in \
  'Production access answers' \
  'Feedback themes' \
  'Changes made' \
  'No tester personal data'; do
  require_text "$evidence_log" "$needle"
done

for needle in \
  'Closed-test retention observation plan' \
  'Weekly Active Prayer Reminder Users' \
  'Day 1' \
  'Day 7' \
  'Day 14' \
  'No tester personal data'; do
  require_text "$retention_plan" "$needle"
done

require_text "$readiness" 'Release path is localized'
require_text "$submission_runbook" 'Production access'

scripts/verify_google_play_closed_testing_evidence.sh

if [[ "${SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY:-false}" == "true" ]]; then
  require_true_var \
    SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED \
    "human review of the Production access answer draft"
  require_true_var \
    SAKINAH_PLAY_FEEDBACK_SUMMARY_READY \
    "summarizing aggregate closed-test feedback themes"
  require_true_var \
    SAKINAH_PLAY_CHANGES_SUMMARY_READY \
    "summarizing changes made or release decisions from feedback"
  require_true_var \
    SAKINAH_PLAY_READINESS_EVIDENCE_READY \
    "linking release readiness, signed AAB checksum, and store evidence"
  require_true_var \
    SAKINAH_PLAY_RETENTION_OBSERVATION_REVIEWED \
    "reviewing aggregate Day 1 / Day 3 / Day 7 / Day 14 retention observation themes"

  SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true \
    scripts/verify_google_play_closed_testing_evidence.sh

  if grep -Eiq '\b(TBD|Template; fill)\b' "$answer_draft"; then
    fail "Production access answer draft is not complete: placeholders remain in $answer_draft."
  fi
fi

printf 'Production access answer pack passed.\n'
printf 'Answer draft: %s\n' "$answer_draft"
printf 'Evidence log: %s\n' "$evidence_log"
