#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

runbook="docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md"
metadata_doc="docs/release/04_STORE_METADATA_DRAFT.md"
screenshot_plan="docs/release/05_SCREENSHOT_PLAN.md"
version_notes="docs/release/08_VERSION_AND_RELEASE_NOTES.md"
closed_testing_pack="docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md"
public_links_doc="docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md"
evidence_log="docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md"
production_access_draft="docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md"
public_links_hosting_packet="docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md"
launch_day_doc="docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md"
data_safety_doc="docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md"
privacy_policy_doc="docs/privacy/02_PRIVACY_POLICY_DRAFT.md"
sdk_inventory_doc="docs/privacy/06_SDK_AND_API_INVENTORY.md"
store_assets_script="scripts/verify_google_play_store_assets.sh"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Play Console submission pack failed: %s\n' "$message" >&2
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

for path in \
  "$runbook" \
  "$metadata_doc" \
  "$screenshot_plan" \
  "$version_notes" \
  "$closed_testing_pack" \
  "$public_links_doc" \
  "$evidence_log" \
  "$production_access_draft" \
  "$public_links_hosting_packet" \
  "$launch_day_doc" \
  "$data_safety_doc" \
  "$privacy_policy_doc" \
  "$sdk_inventory_doc"; do
  require_file "$path"
done

require_executable scripts/verify_google_play_public_links.sh
require_executable scripts/export_google_play_public_links_packet.sh
require_executable scripts/verify_google_play_public_links_packet.sh
require_executable scripts/verify_google_play_upload_preflight.sh
require_executable scripts/export_google_play_upload_packet.sh
require_executable scripts/verify_google_play_closed_testing_evidence.sh
require_executable scripts/verify_google_play_production_access_pack.sh
require_executable scripts/export_google_play_production_access_packet.sh
require_executable scripts/verify_google_play_closed_test_launch_day.sh
require_executable "$store_assets_script"

for needle in \
  'Play Console submission pack' \
  'Sakinah Daily' \
  'com.sakinahdaily.app' \
  'Main store listing' \
  'App content' \
  'App access' \
  'Ads' \
  'Content rating' \
  'Target audience and content' \
  'Data safety' \
  'Privacy policy' \
  'Store settings' \
  'Feature graphic' \
  'Phone screenshots' \
  'Closed testing release' \
  'Production access' \
  'docs/release/04_STORE_METADATA_DRAFT.md' \
  'docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md' \
  'docs/release/05_SCREENSHOT_PLAN.md' \
  'docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md' \
  'verify_google_play_store_assets.sh' \
  'google-play-feature-graphic.png' \
  'scripts/verify_google_play_upload_preflight.sh' \
  'scripts/export_google_play_public_links_packet.sh' \
  'scripts/verify_google_play_public_links_packet.sh' \
  'scripts/export_google_play_upload_packet.sh' \
  'scripts/verify_google_play_closed_test_launch_day.sh' \
  'scripts/verify_google_play_closed_testing_evidence.sh' \
  'scripts/export_google_play_production_access_packet.sh' \
  'https://support.google.com/googleplay/android-developer/answer/9859455'; do
  require_text "$runbook" "$needle"
done

require_text "$metadata_doc" 'Prayer times and local reminders'
require_text "$screenshot_plan" 'build/store-screenshots/android'
require_text "$screenshot_plan" 'google-play-feature-graphic.png'
require_text "$data_safety_doc" 'No ads'
require_text "$privacy_policy_doc" 'Sakinah Daily'
require_text "$closed_testing_pack" 'sakinah-daily-testers@googlegroups.com'
require_text "$production_access_draft" 'Production access answer draft'
require_text "$public_links_hosting_packet" 'Public links hosting packet'
require_text "$launch_day_doc" 'Closed-test launch day checklist'
require_text "$launch_day_doc" 'Google Group link first'
require_text "$version_notes" 'Release Notes Candidate'

scripts/verify_google_play_closed_testing_evidence.sh
scripts/export_google_play_public_links_packet.sh
scripts/verify_google_play_public_links_packet.sh
scripts/export_google_play_upload_packet.sh
scripts/verify_google_play_production_access_pack.sh
scripts/export_google_play_production_access_packet.sh
"$store_assets_script"

if [[ "${SAKINAH_REQUIRE_PLAY_SUBMISSION_READY:-false}" == "true" ]]; then
  SAKINAH_REQUIRE_STORE_ASSETS_READY=true "$store_assets_script" ||
    fail "store visual assets must be complete before strict Play submission."

  require_true_var \
    SAKINAH_PLAY_CONSOLE_APP_CREATED \
    "creating the Play Console app record for com.sakinahdaily.app"
  require_true_var \
    SAKINAH_PLAY_MAIN_STORE_LISTING_READY \
    "finishing the Main store listing from docs/release/04_STORE_METADATA_DRAFT.md"
  require_true_var \
    SAKINAH_PLAY_APP_ACCESS_READY \
    "completing Play Console App content > App access"
  require_true_var \
    SAKINAH_PLAY_ADS_DECLARATION_READY \
    "declaring the no-ads app content status"
  require_true_var \
    SAKINAH_PLAY_CONTENT_RATING_READY \
    "completing the content rating questionnaire"
  require_true_var \
    SAKINAH_PLAY_TARGET_AUDIENCE_READY \
    "completing Target audience and content"
  require_true_var \
    SAKINAH_PLAY_DATA_SAFETY_READY \
    "completing Data safety from the privacy drafts"
  require_true_var \
    SAKINAH_PLAY_PRIVACY_POLICY_READY \
    "publishing and entering the final privacy policy URL"
  require_true_var \
    SAKINAH_PLAY_STORE_SETTINGS_READY \
    "finishing Play Console Store settings"
  require_true_var \
    SAKINAH_PLAY_RELEASE_NOTES_READY \
    "adding the v0.1 closed-testing release notes"
  require_true_var \
    SAKINAH_PLAY_SCREENSHOTS_READY \
    "uploading the reviewed Android phone screenshots"
  require_true_var \
    SAKINAH_PLAY_FEATURE_GRAPHIC_READY \
    "uploading the reviewed Google Play feature graphic"
  require_true_var \
    SAKINAH_PLAY_CLOSED_TEST_RELEASE_DRAFTED \
    "drafting the Closed testing release in Play Console"

  scripts/verify_google_play_public_links.sh
  scripts/verify_google_play_upload_preflight.sh
fi

printf 'Google Play submission pack passed.\n'
printf 'Runbook: %s\n' "$runbook"
printf 'Metadata: %s\n' "$metadata_doc"
printf 'Data safety: %s\n' "$data_safety_doc"
