#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_ANALYTICS_DEBUGVIEW_PACKET_DIR:-build/google-analytics-debugview}"
require_strict="${SAKINAH_REQUIRE_ANALYTICS_DEBUGVIEW_READY:-false}"
package_name="com.sakinahdaily.app"
official_reference="https://firebase.google.com/docs/analytics/debugview"

analytics_plan="docs/privacy/07_GOOGLE_ANALYTICS_EVENT_PLAN.md"
data_safety="docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md"
sdk_inventory="docs/privacy/06_SDK_AND_API_INVENTORY.md"
retention_plan="docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
version_notes="docs/release/08_VERSION_AND_RELEASE_NOTES.md"
analytics_service="lib/core/services/analytics_service.dart"
privacy_center="lib/features/settings/privacy_center_page.dart"
app_environment="lib/core/config/app_environment.dart"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Google Analytics DebugView QA packet failed: %s\n' "$message" >&2
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

copy_required_file() {
  local path="$1"
  local target="$out_dir/$path"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

copy_required_text_evidence() {
  local path="$1"
  local target="$out_dir/source-evidence/$path.txt"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

for path in \
  "$analytics_plan" \
  "$data_safety" \
  "$sdk_inventory" \
  "$retention_plan" \
  "$readiness" \
  "$version_notes" \
  "$analytics_service" \
  "$privacy_center" \
  "$app_environment"; do
  require_file "$path"
done

for needle in \
  'Google Analytics 4 compatible' \
  'SAKINAH_ANALYTICS_ENABLED=true' \
  'analyticsOptIn' \
  'analytics_consent_changed' \
  'notification_settings_viewed' \
  'prayer_reminder_permission_result' \
  'prayer_location_changed' \
  'qibla_viewed' \
  'notification_tap_opened' \
  'daily_session_reminder_permission_result' \
  'daily_session_reminder_changed' \
  'dua_viewed' \
  'dua_saved' \
  'dhikr_started' \
  'dhikr_completed' \
  'women_ibadah_mode_changed' \
  'home_session_completion' \
  'DebugView QA packet'; do
  require_text "$analytics_plan" "$needle"
done

require_text "$data_safety" 'Data Safety must be reviewed and updated'
require_text "$sdk_inventory" 'Google Analytics / Firebase Analytics SDK'
require_text "$retention_plan" 'DebugView QA packet'
require_text "$readiness" 'Google Analytics DebugView QA packet'
require_text "$version_notes" 'Google Analytics DebugView QA packet'
require_text "$analytics_service" 'AnalyticsEventCatalog'
require_text "$analytics_service" 'AnalyticsParameterPolicy'
require_text "$analytics_service" 'notification_tap_opened'
require_text "$analytics_service" 'analytics_consent_changed'
require_text "$analytics_service" 'notification_settings_viewed'
require_text "$analytics_service" 'prayer_reminder_permission_result'
require_text "$analytics_service" 'prayer_location_changed'
require_text "$analytics_service" 'qibla_viewed'
require_text "$analytics_service" 'daily_session_reminder_permission_result'
require_text "$analytics_service" 'daily_session_reminder_changed'
require_text "$analytics_service" 'dua_viewed'
require_text "$analytics_service" 'dua_saved'
require_text "$analytics_service" 'dhikr_started'
require_text "$analytics_service" 'dhikr_completed'
require_text "$analytics_service" 'women_ibadah_mode_changed'
require_text "$analytics_service" 'prayer_checkin_days_7d'
require_text "$privacy_center" 'privacyAnalyticsSwitch'
require_text "$privacy_center" 'setAnalyticsOptIn'
require_text "$app_environment" 'SAKINAH_ANALYTICS_ENABLED'

if [[ "$require_strict" == "true" ]]; then
  require_true_var \
    SAKINAH_ANALYTICS_ENABLED_CONFIRMED \
    "confirming the QA build uses SAKINAH_ANALYTICS_ENABLED=true"
  require_true_var \
    SAKINAH_FIREBASE_PROJECT_CONFIG_READY \
    "adding reviewed Firebase project configuration for the QA build"
  require_true_var \
    SAKINAH_ANALYTICS_CONSENT_QA_READY \
    "verifying Privacy Center usage analytics opt-in on the QA device"
  require_true_var \
    SAKINAH_PLAY_DATA_SAFETY_ANALYTICS_REVIEWED \
    "reviewing Google Play Data Safety for analytics collection"
  require_true_var \
    SAKINAH_DEBUGVIEW_DEVICE_READY \
    "enabling Firebase DebugView for the target Android device"
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  "$analytics_plan" \
  "$data_safety" \
  "$sdk_inventory" \
  "$retention_plan" \
  "$readiness" \
  "$version_notes" \
  scripts/export_google_analytics_debugview_packet.sh; do
  copy_required_file "$path"
done

for path in \
  "$analytics_service" \
  "$privacy_center" \
  "$app_environment"; do
  copy_required_text_evidence "$path"
done

cat >"$out_dir/analytics_events_catalog.csv" <<'EOF'
event_name,qa_flow,expected_parameters,forbidden_parameters,retention_signal
onboarding_started,onboarding_start,"screen|source","latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text",Onboarding Completion Rate
onboarding_completed,onboarding_finish,"language_code|location_method|audio_preference|source","gender_mode|latitude|longitude|women_ibadah_status",Onboarding Completion Rate
home_viewed,home_open,"screen|route|prayers_completed_today|prayer_checkins_7d|prayer_checkin_days_7d|prayer_checkin_streak_days|prayer_reminders_enabled","prayer_name|latitude|longitude|women_ibadah_status|feedback_text",D1/D7 Retention
prayer_viewed,prayer_open,"screen|route|prayer_name|calculation_method|location_method|source=home_prayer_badge|source=home_prayer_card|source=home_progress_card","latitude|longitude|women_ibadah_status|session_id|content_id",Prayer View Rate
qibla_viewed,qibla_open,"screen|route|calculation_method|location_method|source=prayer_page_card|source=settings|source=manual_location|source=direct","latitude|longitude|location_label|qibla_bearing_degrees|women_ibadah_status|feedback_text",Qibla View Rate
prayer_location_changed,prayer_location_settings,"location_method|calculation_method|source=settings_prayer_location|source=settings_prayer_method|source=manual_location_page|change_type","latitude|longitude|location_label|timezone_id|route|women_ibadah_status|feedback_text",Prayer Settings Completion Rate
notification_settings_viewed,notification_settings_open,"screen|source|prayer_reminders_enabled","route|latitude|longitude|women_ibadah_status|feedback_text|reminder_time",Reminder Setup View Rate
prayer_reminder_permission_result,notification_permission,"enabled|source|change_type|reminder_offset_minutes","route|latitude|longitude|women_ibadah_status|feedback_text|reminder_time",Prayer Reminder Permission Outcome Rate
prayer_reminder_changed,notification_settings,"prayer_name|enabled|source=settings|source=home_prayer_card|source=prayer_page_card|source=prayer_completion_card|reminder_offset_minutes","route|latitude|longitude|women_ibadah_status|feedback_text",Prayer Reminder Opt-in Rate
notification_tap_opened,local_notification_open,"content_type|source=local_notification","route|content_id|session_id|prayer_name|quran_arabic_text|women_ibadah_status|feedback_text",Push Open Rate
analytics_consent_changed,privacy_center,"enabled|source=privacy_center","email|tester_name|latitude|longitude|women_ibadah_status|feedback_text",Analytics Consent Rate
prayer_checklist_updated,prayer_checkin,"screen|completed_count|all_prayers_completed|source=prayer_page_checklist","prayer_name|completed_at|latitude|longitude",local prayer check-in usage
daily_session_started,session_start,"session_id|language_code|source","quran_arabic_text|reflection_text|translation|feedback_text",Daily Session Start Rate
daily_session_step_viewed,session_step,"session_id|step_id|step_index|source","content_id|quran_arabic_text|reflection_text|translation",Daily Session Step Drop-off
daily_session_completed,session_complete,"session_id|source","quran_arabic_text|reflection_text|translation|feedback_text",Daily Session Completion Rate
daily_session_reminder_permission_result,session_reminder_permission,"session_id|enabled|source|change_type","reminder_time|route|women_ibadah_status|feedback_text|note",Daily Session Reminder Permission Outcome Rate
daily_session_reminder_changed,session_to_reminder,"session_id|enabled|source=home_session_completion|change_type","reminder_time|women_ibadah_status|feedback_text",Daily Session Reminder Opt-in Rate
dua_viewed,dua_detail,"content_id|screen|source","arabic_text|translation|feedback_text",Dua Detail View Rate
dua_saved,dua_save,"content_id|enabled|source","arabic_text|translation|title|body|feedback_text",Dua Save Rate
dhikr_started,dhikr_counter,"content_id|source","arabic_text|translation|current_count|women_ibadah_status",Dhikr Start Rate
dhikr_completed,dhikr_counter,"content_id|source","arabic_text|translation|current_count|women_ibadah_status",Dhikr Completion Rate
women_ibadah_mode_changed,women_mode,"enabled|source","women_ibadah_status|health_note|menstruation|postpartum|pregnancy",Women Mode Trust Signal
closed_test_prompt_copied,closed_test_feedback,"prompt_day|theme_key|source","feedback_text|email|tester_name",Closed-test prompt usage
closed_test_prompt_marked_sent,closed_test_feedback,"prompt_day|theme_key|source","feedback_text|email|tester_name",Closed-test prompt usage
EOF

cat >"$out_dir/retention_funnel_debugview.csv" <<'EOF'
funnel_step,trigger_path,expected_event,expected_source,success_signal,privacy_check
Onboarding Completion Rate,/onboarding,onboarding_completed,onboarding,language_code and location_method only,no GPS or exact location
Prayer View Rate,/prayer,prayer_viewed,home_prayer_badge or home_prayer_card or home_progress_card,screen route coarse method and controlled source,no exact coordinates or session/content IDs
Qibla View Rate,/qibla,qibla_viewed,"prayer_page_card, settings, manual_location, or direct",screen route coarse method and controlled source,no exact coordinates selected place label or bearing degrees
Prayer Settings Completion Rate,"/settings prayer location, prayer method, or manual location save",prayer_location_changed,"settings_prayer_location, settings_prayer_method, or manual_location_page",coarse method source and change_type only,no coordinates location labels timezone IDs routes or free text
Reminder Setup View Rate,/settings/notifications,notification_settings_viewed,"settings, home_prayer_card, prayer_page_card, prayer_completion_card, home_session_completion, or session_completion",source and aggregate enabled state only,no route exact reminder time location women mode status or free text
Prayer Reminder Permission Outcome Rate,notification permission flow,prayer_reminder_permission_result,"settings, home_prayer_card, prayer_page_card, or prayer_completion_card",scheduled or denied outcome only,no route exact reminder time location women mode status or free text
Prayer Reminder Opt-in Rate,"/settings/notifications, Home prayer card, Prayer page card, or Prayer completion card",prayer_reminder_changed,"settings, home_prayer_card, prayer_page_card, or prayer_completion_card",enabled true,no route exact location women mode status or free text
Push Open Rate,notification tap,notification_tap_opened,local_notification,coarse content_type only,no route content ID prayer name or raw payload
Analytics Consent Rate,/settings/privacy,analytics_consent_changed,privacy_center,usage analytics opt-in or opt-out,no tester identity location or women mode status
Prayer To Session,/prayer complete state,daily_session_started,prayer_completion,session starts after five check-ins,no prayer completion names/timestamps
Daily Session Start Rate,/session/:id,daily_session_started,home or bottom_navigation,session starts,no religious text
Daily Session Step Drop-off,/session/:id,daily_session_step_viewed,home or prayer_completion,step_id and step_index only,no quran/dua/reflection text
Daily Session Reminder Permission Outcome Rate,session reminder permission flow,daily_session_reminder_permission_result,"settings, session_completion, or home_session_completion",scheduled or denied outcome only,no route exact reminder time women mode status routine notes or free text
Session To Reminder,/home completed-session CTA,daily_session_reminder_changed,home_session_completion,session_to_reminder enabled true,no exact reminder time
Dua Detail View Rate,/dua/:id,dua_viewed,direct,content_id screen and source only,no dua text or translation
Dua Save Rate,/dua/:id save toggle,dua_saved,dua_detail,enabled state only,no dua text title or feedback
Dhikr Start Rate,/dhikr counter first tap,dhikr_started,dhikr_counter,content_id and source only,no dhikr text or count trail
Dhikr Completion Rate,/dhikr counter reaches target,dhikr_completed,dhikr_counter,content_id and source only,no dhikr text or count trail
Women Mode Trust Signal,/settings/women,women_ibadah_mode_changed,women_mode,enabled state only,no exact women mode status or health details
Closed-test Prompt Usage,/settings/testing-guide,closed_test_prompt_copied,closed_testing_guide,prompt_day and theme_key only,no feedback text/email
EOF

cat >"$out_dir/blocked_parameter_review.csv" <<'EOF'
blocked_fragment,example_key,reason
latitude,latitude,exact location is not sent to analytics
longitude,longitude,exact location is not sent to analytics
location_label,location_label,selected place labels are not required for usage telemetry
qibla_bearing,qibla_bearing_degrees,Qibla bearing values are not required for usage telemetry
women_ibadah_status,women_ibadah_status,sensitive local-only women's mode status
feedback,feedback_text,free-text tester feedback must not be sent
quran,quran_arabic_text,religious text must not be sent/generated as analytics
reflection,reflection_text,free text/religious reflection must not be sent
translation,translation_text,religious translation text must not be sent
email,email,personal identifier must not be sent
tester_name,tester_name,personal identifier must not be sent
reminder_time,reminder_time,exact reminder time is not required for retention monitoring
timezone_id,timezone_id,manual timezone identifiers are not required for usage telemetry
EOF

cat >"$out_dir/debugview_checklist.md" <<EOF
# Google Analytics DebugView QA Checklist

Status: Local QA packet for reviewed analytics builds only.

Official reference: $official_reference

## Build Prerequisites

- Build with \`SAKINAH_ANALYTICS_ENABLED=true\` and reviewed Firebase project configuration.
- Confirm Google Play Data Safety has been reviewed before any Play closed-testing build transmits analytics.
- Turn on Privacy Center usage analytics opt-in on the QA device.
- Toggle Privacy Center usage analytics once during QA to verify \`analytics_consent_changed\`.
- Store screenshot mode forces analytics off; do not use screenshot builds for DebugView QA.

## Android DebugView Commands

\`\`\`sh
adb shell setprop debug.firebase.analytics.app $package_name
adb shell setprop debug.firebase.analytics.app .none.
\`\`\`

## Flows To Exercise

- Onboarding start and completion.
- Privacy Center usage analytics opt-in and opt-out.
- Home prayer card to prayer reminder opt-in.
- Prayer page card to prayer reminder opt-in.
- Prayer completion card to prayer reminder opt-in.
- Local prayer reminder tap and Daily Session reminder tap.
- Home open after local prayer completion state loads.
- Prayer page open and prayer reminder toggle.
- Qibla page open from Prayer card, Settings/manual location, or direct route.
- Settings prayer location preset, prayer method change, and manual location save.
- Five local prayer check-ins leading to a Daily Session entry point.
- Daily Session start, step view, and completion.
- Home completed-session CTA to Notification Settings, then daily session reminder opt-in with source \`home_session_completion\`.
- Dua detail open and save toggle.
- Dhikr counter first tap and target completion.
- Women's Ibadah Mode enabled/disabled change.
- Closed testing guide prompt copy.

## DebugView Privacy Review

- Verify no latitude, longitude, feedback text, tester name, email, exact reminder time, Quran text, Dua text, Dhikr text, translation text, reflection text, or Women's Ibadah Mode exact status appears in Firebase DebugView.
- Verify Qibla analytics keeps only coarse location method, calculation method, route, screen, and controlled source.
- Verify \`prayer_location_changed\` keeps only coarse location method, calculation method, controlled source, and coarse change type.
- Verify \`prayer_reminder_changed\` keeps only prayer scope, enabled state, controlled source, and lead-time offset.
- Verify \`notification_settings_viewed\` keeps only screen, controlled source, and aggregate prayer-reminder enabled state.
- Verify \`prayer_reminder_permission_result\` keeps only enabled result, controlled source, coarse outcome, and reminder lead-time offset.
- Verify \`notification_tap_opened\` keeps only coarse content type and source.
- Verify \`analytics_consent_changed\` keeps only enabled state and source.
- Verify \`daily_session_reminder_permission_result\` keeps only session ID, enabled result, controlled source, and coarse outcome.
- Verify \`daily_session_reminder_changed\` keeps only session ID, enabled state, controlled source, and coarse change type.
- Verify \`dua_viewed\` and \`dua_saved\` keep only content ID, source/screen, and enabled state where relevant.
- Verify \`dhikr_started\` and \`dhikr_completed\` keep only content ID and source.
- Verify \`women_ibadah_mode_changed\` keeps only enabled state and source.
- Verify Home retention events keep aggregate counts only.
EOF

cat >"$out_dir/manifest.txt" <<EOF
Google Analytics DebugView QA packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: $package_name
Strict mode requested: $require_strict
Privacy rule: No tester personal data.
Official reference: $official_reference

Firebase DebugView setup:
- Use SAKINAH_ANALYTICS_ENABLED=true only in reviewed QA or release builds.
- Enable Privacy Center usage analytics opt-in on the QA device.
- Run: adb shell setprop debug.firebase.analytics.app $package_name
- Disable after QA: adb shell setprop debug.firebase.analytics.app .none.

Generated QA files:
- debugview_checklist.md
- analytics_events_catalog.csv
- retention_funnel_debugview.csv
- blocked_parameter_review.csv

Copied evidence:
- $analytics_plan
- $data_safety
- $sdk_inventory
- $retention_plan
- $readiness
- $version_notes
- source-evidence/$analytics_service.txt
- source-evidence/$privacy_center.txt
- source-evidence/$app_environment.txt
- scripts/export_google_analytics_debugview_packet.sh
EOF

printf 'Google Analytics DebugView QA packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
