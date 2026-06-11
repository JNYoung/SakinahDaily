#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

evidence_log="${1:-docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md}"
required_tester_count=12
required_day_count=14
official_reference="https://support.google.com/googleplay/android-developer/answer/14151465"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play closed-testing evidence failed: %s\n' "$message" >&2
  exit "$code"
}

require_text() {
  local needle="$1"
  grep -Fq "$needle" "$evidence_log" ||
    fail "missing required evidence text: $needle"
}

require_day_row() {
  local day="$1"
  grep -Eq "^[|][[:space:]]*Day $day[[:space:]]*[|]" "$evidence_log" ||
    fail "missing Day $day row in $evidence_log"
}

opted_in_count_for_day() {
  local day="$1"
  local row
  row="$(
    grep -E "^[|][[:space:]]*Day $day[[:space:]]*[|]" "$evidence_log" |
      head -n 1
  )"
  printf '%s\n' "$row" |
    awk -F'|' '{ value = $5; gsub(/^[[:space:]]+|[[:space:]]+$/, "", value); print value }'
}

[[ -f "$evidence_log" ]] ||
  fail "evidence log not found: $evidence_log"

require_text '12 opted-in testers'
require_text '14 continuous days'
require_text 'No tester personal data'
require_text 'Feedback themes'
require_text 'Changes made'
require_text 'Production access answers'
require_text 'Opted-in testers'
require_text 'Feedback reviewed'
require_text 'Production access'
require_text "$official_reference"

require_day_row 0
# Day 14 is the required completion row for Production access evidence.
for day in $(seq 1 "$required_day_count"); do
  require_day_row "$day"
done

if [[ "${SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE:-false}" == "true" ]]; then
  if grep -Eiq '\b(TBD|Not started)\b' "$evidence_log"; then
    fail "closed testing evidence is not complete: placeholders remain in $evidence_log."
  fi

  for day in $(seq 1 "$required_day_count"); do
    opted_in_count="$(opted_in_count_for_day "$day")"
    [[ "$opted_in_count" =~ ^[0-9]+$ ]] ||
      fail "closed testing evidence is not complete: Day $day opted-in testers must be numeric."
    (( opted_in_count >= required_tester_count )) ||
      fail "closed testing evidence is not complete: Day $day has $opted_in_count opted-in testers, expected at least $required_tester_count."
  done
fi

printf 'Google Play closed-testing evidence passed.\n'
printf 'Evidence log: %s\n' "$evidence_log"
printf 'Required testers: %s\n' "$required_tester_count"
printf 'Required continuous days: %s\n' "$required_day_count"
