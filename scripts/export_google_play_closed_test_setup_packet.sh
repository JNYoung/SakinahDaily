#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_CLOSED_TEST_SETUP_PACKET_DIR:-build/play-closed-test-setup}"
require_strict="${SAKINAH_REQUIRE_CLOSED_TEST_SETUP_READY:-false}"

package_name="com.sakinahdaily.app"
group_email="sakinah-daily-testers@googlegroups.com"
group_link="https://groups.google.com/g/sakinah-daily-testers"
opt_in_link="https://play.google.com/apps/testing/com.sakinahdaily.app"
store_link="https://play.google.com/store/apps/details?id=com.sakinahdaily.app"

docs_index="docs/00_DOCS_INDEX.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
version_notes="docs/release/08_VERSION_AND_RELEASE_NOTES.md"
launch_pack="docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md"
runbook="docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md"
acceptance="docs/testing/01_ACCEPTANCE_CHECKLIST.md"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Play closed-test setup packet failed: %s\n' "$message" >&2
  exit "$code"
}

require_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "required file is missing: $path"
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

validate_completed_closed_test_setup_evidence() {
  local path="$1"
  local label="$2"
  shift 2

  require_file "$path"
  for placeholder in \
    TBD \
    pending_manual_observation \
    pending_play_console_action \
    record_manually \
    unknown \
    example.com \
    localhost; do
    if grep -Fq "$placeholder" "$path"; then
      fail "$label completed closed-test setup evidence still contains placeholder: $placeholder"
    fi
  done

  for needle in "$@"; do
    require_text "$path" "$needle"
  done
}

validate_feedback_channel() {
  local path="$1"
  validate_completed_closed_test_setup_evidence \
    "$path" \
    "feedback channel" \
    'feedback_channel,channel_type,status,evidence_path,privacy_rule' \
    'configured' \
    'No tester personal data'

  if ! grep -Eq '(^|,)([^,[:space:]]+@[^,[:space:]]+|https://[^,[:space:]]+)' "$path"; then
    fail 'feedback channel completed closed-test setup evidence must include a real email or HTTPS URL'
  fi
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
  "$docs_index" \
  "$readiness" \
  "$version_notes" \
  "$launch_pack" \
  "$runbook" \
  "$acceptance"; do
  require_file "$path"
done

require_text "$docs_index" 'export_google_play_closed_test_setup_packet.sh'
require_text "$readiness" 'Google Play closed-test setup packet'
require_text "$version_notes" 'Google Play closed-test setup packet'
require_text "$launch_pack" 'export_google_play_closed_test_setup_packet.sh'
require_text "$runbook" 'export_google_play_closed_test_setup_packet.sh'
require_text "$acceptance" 'Google Play closed-test setup packet'
require_text "$launch_pack" "$group_email"
require_text "$launch_pack" "$group_link"
require_text "$runbook" "$package_name"
require_text "$runbook" 'Closed testing release'

setup_evidence_status="not requested"
if [[ "$require_strict" == "true" ]]; then
  require_true_var \
    SAKINAH_CLOSED_TEST_GOOGLE_GROUP_CREATED \
    "creating the Google Group for closed-test testers"
  require_true_var \
    SAKINAH_CLOSED_TEST_TRACK_BOUND \
    "binding the Google Group to the Play Console Closed testing track"
  require_true_var \
    SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_READY \
    "configuring Google Play Testing feedback and the app feedback channel"
  require_true_var \
    SAKINAH_CLOSED_TEST_RELEASE_DRAFT_READY \
    "uploading or drafting the first closed-testing release artifact"
  require_true_var \
    SAKINAH_CLOSED_TEST_TESTER_LINKS_REVIEWED \
    "reviewing tester share links and share order before inviting testers"

  require_env_file \
    SAKINAH_CLOSED_TEST_GROUP_EVIDENCE \
    "capturing Google Group settings without tester personal data"
  require_env_file \
    SAKINAH_CLOSED_TEST_TRACK_EVIDENCE \
    "capturing Play Console Closed testing track binding"
  require_env_file \
    SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_EVIDENCE \
    "capturing Testing feedback channel setup"
  require_env_file \
    SAKINAH_CLOSED_TEST_RELEASE_ARTIFACT_EVIDENCE \
    "capturing uploaded or drafted AAB evidence"
  require_env_file \
    SAKINAH_CLOSED_TEST_TESTER_LINKS_EVIDENCE \
    "capturing reviewed Google Group, Play opt-in, and store listing links"

  validate_completed_closed_test_setup_evidence \
    "$SAKINAH_CLOSED_TEST_GROUP_EVIDENCE" \
    "Google Group" \
    'group_email,group_url,join_policy,member_visibility,status,evidence_path,privacy_rule' \
    "$group_email" \
    "$group_link" \
    'anyone_can_join' \
    'created' \
    'No tester personal data'
  validate_completed_closed_test_setup_evidence \
    "$SAKINAH_CLOSED_TEST_TRACK_EVIDENCE" \
    "Closed testing track" \
    'package_name,track_name,tester_group,status,countries_scope,evidence_path,privacy_rule' \
    "$package_name" \
    'closed-testing' \
    "$group_email" \
    'bound' \
    'No tester personal data'
  validate_feedback_channel "$SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_EVIDENCE"
  validate_completed_closed_test_setup_evidence \
    "$SAKINAH_CLOSED_TEST_RELEASE_ARTIFACT_EVIDENCE" \
    "release artifact" \
    'artifact_type,package_name,version_name,version_code,sha256,status,evidence_path' \
    'aab' \
    "$package_name" \
    '0.1.0' \
    'sha256:' \
    'uploaded'
  validate_completed_closed_test_setup_evidence \
    "$SAKINAH_CLOSED_TEST_TESTER_LINKS_EVIDENCE" \
    "tester links" \
    'link_type,url,status,share_order,privacy_rule' \
    'google_group' \
    "$group_link" \
    'play_opt_in' \
    "$opt_in_link" \
    'store_listing' \
    "$store_link" \
    'reviewed' \
    'No tester personal data'

  setup_evidence_status="validated"
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  "$docs_index" \
  "$readiness" \
  "$version_notes" \
  "$launch_pack" \
  "$runbook" \
  "$acceptance" \
  scripts/export_google_play_closed_test_setup_packet.sh \
  scripts/verify_google_play_upload_preflight.sh \
  scripts/export_google_play_upload_packet.sh \
  scripts/verify_google_play_submission_pack.sh \
  scripts/verify_google_play_closed_test_launch_day.sh; do
  copy_required_file "$path"
done

copy_completed_evidence_file \
  SAKINAH_CLOSED_TEST_GROUP_EVIDENCE \
  closed_test_group_evidence.csv
copy_completed_evidence_file \
  SAKINAH_CLOSED_TEST_TRACK_EVIDENCE \
  closed_test_track_evidence.csv
copy_completed_evidence_file \
  SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_EVIDENCE \
  closed_test_feedback_channel_evidence.csv
copy_completed_evidence_file \
  SAKINAH_CLOSED_TEST_RELEASE_ARTIFACT_EVIDENCE \
  closed_test_release_artifact_evidence.csv
copy_completed_evidence_file \
  SAKINAH_CLOSED_TEST_TESTER_LINKS_EVIDENCE \
  closed_test_tester_links_evidence.csv

cat >"$out_dir/closed_test_setup_checklist.md" <<EOF
# Google Play Closed-Test Setup Checklist

Status: Template for Play Console setup before tester invites are shared.

Privacy rule: No tester personal data. Keep screenshots and CSVs free of
tester names, tester email addresses, private messages, feedback text,
locations, health details, and sensitive Women's Ibadah Mode status.

## Required Setup

- Google Group created: $group_email
- Google Group link reviewed: $group_link
- Closed testing track bound to the Google Group for package $package_name.
- feedback channel configured in Play Console Testing feedback.
- Release artifact drafted or uploaded from the signed AAB.
- Tester links reviewed in this order: Google Group first, Play opt-in second,
  Store listing third.

## Strict Mode Evidence

Run strict mode only after a human has completed the Play Console actions:

\`\`\`sh
SAKINAH_REQUIRE_CLOSED_TEST_SETUP_READY=true \\
SAKINAH_CLOSED_TEST_GOOGLE_GROUP_CREATED=true \\
SAKINAH_CLOSED_TEST_TRACK_BOUND=true \\
SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_READY=true \\
SAKINAH_CLOSED_TEST_RELEASE_DRAFT_READY=true \\
SAKINAH_CLOSED_TEST_TESTER_LINKS_REVIEWED=true \\
SAKINAH_CLOSED_TEST_GROUP_EVIDENCE=/path/to/closed_test_group_evidence.csv \\
SAKINAH_CLOSED_TEST_TRACK_EVIDENCE=/path/to/closed_test_track_evidence.csv \\
SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_EVIDENCE=/path/to/closed_test_feedback_channel_evidence.csv \\
SAKINAH_CLOSED_TEST_RELEASE_ARTIFACT_EVIDENCE=/path/to/closed_test_release_artifact_evidence.csv \\
SAKINAH_CLOSED_TEST_TESTER_LINKS_EVIDENCE=/path/to/closed_test_tester_links_evidence.csv \\
scripts/export_google_play_closed_test_setup_packet.sh
\`\`\`

## Links

- Google Group: $group_link
- Play opt-in: $opt_in_link
- Store listing: $store_link

Do not share the leave-testing link as an invite.
EOF

cat >"$out_dir/closed_test_setup_evidence.csv" <<'EOF'
setup_area,status,evidence_owner,evidence_path,privacy_rule
google_group,pending_play_console_action,release-ops,record_manually,No tester personal data
closed_testing_track,pending_play_console_action,release-ops,record_manually,No tester personal data
testing_feedback_channel,pending_play_console_action,release-ops,record_manually,No tester personal data
closed_test_release_artifact,pending_play_console_action,release-ops,record_manually,No tester personal data
tester_links_review,pending_manual_observation,release-ops,record_manually,No tester personal data
EOF

cat >"$out_dir/closed_test_tester_links.csv" <<EOF
link_type,url,status,share_order,privacy_rule
google_group,$group_link,review_before_share,1,No tester personal data
play_opt_in,$opt_in_link,share_after_group_join_step,2,No tester personal data
store_listing,$store_link,share_after_play_opt_in_step,3,No tester personal data
EOF

cat >"$out_dir/closed_test_group_binding_evidence.csv" <<EOF
group_email,group_url,join_policy,member_visibility,status,evidence_path,privacy_rule
$group_email,$group_link,anyone_can_join,members_only,pending_play_console_action,record_manually,No tester personal data
EOF

cat >"$out_dir/closed_test_feedback_channel_evidence.csv" <<'EOF'
feedback_channel,channel_type,status,evidence_path,privacy_rule
SAKINAH_PLAY_TESTING_FEEDBACK,email_or_https_url,pending_play_console_action,record_manually,No tester personal data
EOF

cat >"$out_dir/closed_test_release_artifact_evidence.csv" <<EOF
artifact_type,package_name,version_name,version_code,sha256,status,evidence_path
aab,$package_name,0.1.0,1,sha256:TBD,pending_play_console_action,build/play-internal/app-release.aab.sha256
EOF

cat >"$out_dir/closed_test_external_blockers.csv" <<'EOF'
blocker_area,status,next_action,owner,privacy_rule
Google Group creation,pending_manual_observation,confirm group exists and join policy is ready,release-ops,No tester personal data
Play Console app record,pending_manual_observation,confirm app record exists for com.sakinahdaily.app,release-ops,No tester personal data
Closed testing track,pending_manual_observation,bind tester group and countries or regions,release-ops,No tester personal data
Testing feedback,pending_manual_observation,configure support email or HTTPS feedback URL,release-ops,No tester personal data
Release artifact,pending_manual_observation,upload signed AAB and review checksum,release-ops,No tester personal data
EOF

cat >"$out_dir/manifest.txt" <<EOF
Google Play closed-test setup packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: $package_name
Tester group: $group_email
Strict mode requested: $require_strict
Closed-test setup evidence inputs: $setup_evidence_status
Privacy rule: No tester personal data.

Generated templates:
- closed_test_setup_checklist.md
- closed_test_setup_evidence.csv
- closed_test_tester_links.csv
- closed_test_group_binding_evidence.csv
- closed_test_feedback_channel_evidence.csv
- closed_test_release_artifact_evidence.csv
- closed_test_external_blockers.csv

Copied references:
- docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md
- docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md
- docs/release/01_RELEASE_READINESS_CHECKLIST.md
- docs/release/08_VERSION_AND_RELEASE_NOTES.md
- docs/testing/01_ACCEPTANCE_CHECKLIST.md
- scripts/export_google_play_closed_test_setup_packet.sh
- scripts/verify_google_play_upload_preflight.sh
- scripts/export_google_play_upload_packet.sh
- scripts/verify_google_play_submission_pack.sh
- scripts/verify_google_play_closed_test_launch_day.sh

Strict evidence variables:
- SAKINAH_CLOSED_TEST_GROUP_EVIDENCE
- SAKINAH_CLOSED_TEST_TRACK_EVIDENCE
- SAKINAH_CLOSED_TEST_FEEDBACK_CHANNEL_EVIDENCE
- SAKINAH_CLOSED_TEST_RELEASE_ARTIFACT_EVIDENCE
- SAKINAH_CLOSED_TEST_TESTER_LINKS_EVIDENCE

Use:
- Share the Google Group link first, then the Play opt-in link.
- Keep the leave-testing link out of invite copy.
- Use aggregate-only evidence and avoid tester personal data.
EOF

printf 'Google Play closed-test setup packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
