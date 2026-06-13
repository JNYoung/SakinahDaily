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

require_env_file() {
  local name="$1"
  local description="$2"
  local path="${!name:-}"

  [[ -n "$path" ]] ||
    fail "$name must point to completed evidence after $description."
  [[ -f "$path" ]] ||
    fail "$name points to a missing evidence file: $path"
}

validate_completed_debugview_evidence() {
  local path="$1"
  local label="$2"
  local header="$3"
  shift 3

  require_file "$path"
  require_text "$path" "$header"

  for placeholder in \
    pending_manual_observation \
    pending_debugview_observation \
    pending_tap_route \
    record_manually \
    TBD \
    unknown; do
    if grep -Fq "$placeholder" "$path"; then
      fail "$label completed DebugView evidence still contains placeholder: $placeholder"
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

copy_required_text_evidence() {
  local path="$1"
  local target="$out_dir/source-evidence/$path.txt"

  require_file "$path"
  mkdir -p "$(dirname "$target")"
  cp "$path" "$target"
}

copy_strict_evidence_file() {
  local env_name="$1"
  local target_name="$2"
  local path="${!env_name:-}"

  [[ -n "$path" ]] || return 0
  require_file "$path"
  mkdir -p "$out_dir/completed-evidence"
  cp "$path" "$out_dir/completed-evidence/$target_name"
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
  'notification_permission_prompt_viewed' \
  'prayer_reminder_permission_result' \
  'notification_schedule_result' \
  'notification_smoke_test_result' \
  'notification_permission_recovery_opened' \
  'prayer_location_changed' \
  'qibla_viewed' \
  'notification_tap_result' \
  'notification_tap_opened' \
  'daily_session_reminder_permission_result' \
  'daily_session_reminder_changed' \
  'dua_viewed' \
  'dua_saved' \
  'dhikr_started' \
  'dhikr_completed' \
  'women_ibadah_mode_changed' \
  'Push/reminder module analytics coverage is complete' \
  'home_session_completion' \
  'DebugView QA packet'; do
  require_text "$analytics_plan" "$needle"
done

require_text "$data_safety" 'Data Safety must be reviewed and updated'
require_text "$sdk_inventory" 'Google Analytics / Firebase Analytics SDK'
require_text "$retention_plan" 'DebugView QA packet'
require_text "$retention_plan" 'Push/reminder module DebugView coverage'
require_text "$retention_plan" 'Home → Prayer → Daily Session'
require_text "$readiness" 'Google Analytics DebugView QA packet'
require_text "$readiness" 'retention loop QA checklist'
require_text "$version_notes" 'Google Analytics DebugView QA packet'
require_text "$analytics_service" 'AnalyticsEventCatalog'
require_text "$analytics_service" 'AnalyticsParameterPolicy'
require_text "$analytics_service" 'notification_tap_result'
require_text "$analytics_service" 'notification_tap_opened'
require_text "$analytics_service" 'analytics_consent_changed'
require_text "$analytics_service" 'notification_settings_viewed'
require_text "$analytics_service" 'notification_permission_prompt_viewed'
require_text "$analytics_service" 'prayer_reminder_permission_result'
require_text "$analytics_service" 'notification_schedule_result'
require_text "$analytics_service" 'notification_smoke_test_result'
require_text "$analytics_service" 'notification_permission_recovery_opened'
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

strict_evidence_status="not requested"
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
  require_env_file \
    SAKINAH_ANALYTICS_DEBUGVIEW_SETUP_EVIDENCE \
    "confirming the reviewed analytics QA build, Firebase config, consent, Data Safety, and DebugView device setup"
  require_env_file \
    SAKINAH_ANALYTICS_DEBUGVIEW_EVENT_EVIDENCE \
    "observing required analytics events in Firebase DebugView"
  require_env_file \
    SAKINAH_ANALYTICS_DEBUGVIEW_RETENTION_LOOP_EVIDENCE \
    "walking the Home to Prayer to Daily Session to Reminder/Feedback retention loop"
  require_env_file \
    SAKINAH_ANALYTICS_DEBUGVIEW_BLOCKED_PARAMETER_EVIDENCE \
    "reviewing blocked analytics parameters in DebugView"
  validate_completed_debugview_evidence \
    "$SAKINAH_ANALYTICS_DEBUGVIEW_SETUP_EVIDENCE" \
    "analytics DebugView setup" \
    "check_id,status,evidence_path,privacy_rule,data_safety_rule" \
    analytics_enabled_build \
    firebase_project_config \
    privacy_center_opt_in \
    data_safety_review \
    debugview_device \
    confirmed \
    "No tester personal data" \
    "Data Safety reviewed"
  validate_completed_debugview_evidence \
    "$SAKINAH_ANALYTICS_DEBUGVIEW_EVENT_EVIDENCE" \
    "analytics DebugView event" \
    "event_name,qa_flow,debugview_status,parameter_status,privacy_rule" \
    home_viewed \
    prayer_viewed \
    prayer_checklist_updated \
    daily_session_started \
    daily_session_completed \
    daily_session_reminder_permission_result \
    daily_session_reminder_changed \
    notification_permission_prompt_viewed \
    notification_schedule_result \
    notification_smoke_test_result \
    notification_permission_recovery_opened \
    notification_tap_result \
    notification_tap_opened \
    analytics_consent_changed \
    prayer_location_changed \
    qibla_viewed \
    dua_viewed \
    dhikr_started \
    women_ibadah_mode_changed \
    closed_test_prompt_copied \
    closed_test_prompt_marked_sent \
    observed \
    no_forbidden_parameters \
    "No tester personal data"
  validate_completed_debugview_evidence \
    "$SAKINAH_ANALYTICS_DEBUGVIEW_RETENTION_LOOP_EVIDENCE" \
    "analytics DebugView retention loop" \
    "loop_step,expected_event,observed_status,source,privacy_result,notes_rule" \
    home_to_prayer \
    prayer_checkin \
    prayer_to_session \
    session_complete \
    session_to_reminder \
    reminder_schedule \
    notification_tap \
    closed_test_feedback \
    home_viewed \
    prayer_viewed \
    daily_session_started \
    daily_session_completed \
    daily_session_reminder_changed \
    notification_schedule_result \
    notification_tap_result \
    closed_test_prompt_marked_sent \
    observed \
    no_forbidden_parameters \
    "aggregate QA only"
  validate_completed_debugview_evidence \
    "$SAKINAH_ANALYTICS_DEBUGVIEW_BLOCKED_PARAMETER_EVIDENCE" \
    "analytics DebugView blocked parameter" \
    "forbidden_parameter,review_status,evidence_path,privacy_rule" \
    latitude \
    longitude \
    women_ibadah_status \
    feedback_text \
    quran_arabic_text \
    payload \
    scheduled_local_time \
    reminder_time \
    device_model \
    blocked \
    "No tester personal data"
  strict_evidence_status="validated"
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

copy_strict_evidence_file \
  SAKINAH_ANALYTICS_DEBUGVIEW_SETUP_EVIDENCE \
  analytics_debugview_setup_evidence.csv
copy_strict_evidence_file \
  SAKINAH_ANALYTICS_DEBUGVIEW_EVENT_EVIDENCE \
  analytics_debugview_event_evidence.csv
copy_strict_evidence_file \
  SAKINAH_ANALYTICS_DEBUGVIEW_RETENTION_LOOP_EVIDENCE \
  analytics_debugview_retention_loop_evidence.csv
copy_strict_evidence_file \
  SAKINAH_ANALYTICS_DEBUGVIEW_BLOCKED_PARAMETER_EVIDENCE \
  analytics_debugview_blocked_parameter_evidence.csv

cat >"$out_dir/analytics_events_catalog.csv" <<'EOF'
event_name,qa_flow,expected_parameters,forbidden_parameters,retention_signal
onboarding_started,onboarding_start,"screen|source","latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text",Onboarding Completion Rate
onboarding_completed,onboarding_finish,"language_code|location_method|audio_preference|source","gender_mode|latitude|longitude|women_ibadah_status",Onboarding Completion Rate
home_viewed,home_open,"screen|route|prayers_completed_today|prayer_checkins_7d|prayer_checkin_days_7d|prayer_checkin_streak_days|prayer_reminders_enabled","prayer_name|latitude|longitude|women_ibadah_status|feedback_text",D1/D7 Retention
prayer_viewed,prayer_open,"screen|route|prayer_name|calculation_method|location_method|source=home_prayer_badge|source=home_prayer_card|source=home_progress_card","latitude|longitude|women_ibadah_status|session_id|content_id",Prayer View Rate
qibla_viewed,qibla_open,"screen|route|calculation_method|location_method|source=prayer_page_card|source=settings|source=manual_location|source=direct","latitude|longitude|location_label|qibla_bearing_degrees|women_ibadah_status|feedback_text",Qibla View Rate
prayer_location_changed,prayer_location_settings,"location_method|calculation_method|source=settings_prayer_location|source=settings_prayer_method|source=manual_location_page|source=prayer_page_card|source=qibla_page|change_type","latitude|longitude|location_label|timezone_id|route|women_ibadah_status|feedback_text",Prayer Settings Completion Rate
notification_settings_viewed,notification_settings_open,"screen|source|prayer_reminders_enabled","route|latitude|longitude|women_ibadah_status|feedback_text|reminder_time",Reminder Setup View Rate
notification_permission_prompt_viewed,notification_permission_prompt,"reminder_type|source","payload|route|scheduled_local_time|reminder_time|body|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text",Reminder Permission Prompt Exposure Rate
prayer_reminder_permission_result,notification_permission,"enabled|source|change_type|reminder_offset_minutes","route|latitude|longitude|women_ibadah_status|feedback_text|reminder_time",Prayer Reminder Permission Outcome Rate
notification_schedule_result,local_reminder_schedule,"reminder_type|enabled|source|change_type|scheduled_count|reminder_offset_minutes","payload|route|scheduled_local_time|reminder_time|prayer_name|body|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text",Local Reminder Schedule Health
notification_smoke_test_result,notification_qa_smoke,"content_type|source=notification_settings_qa|change_type","payload|route|scheduled_local_time|reminder_time|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text|body",Notification QA Smoke Result Rate
notification_permission_recovery_opened,notification_permission_recovery,"source=notification_settings|change_type","payload|route|device_model|scheduled_local_time|reminder_time|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text|body",Notification Permission Recovery Rate
notification_tap_result,local_notification_tap_result,"content_type|source=local_notification|change_type","route|content_id|session_id|prayer_name|payload|body|quran_arabic_text|women_ibadah_status|feedback_text",Push Tap Outcome Health
prayer_reminder_changed,notification_settings_or_prayer_page,"prayer_name|enabled|source=settings|source=home_prayer_card|source=prayer_page_card|source=prayer_completion_card|reminder_offset_minutes","route|latitude|longitude|women_ibadah_status|feedback_text|reminder_time",Prayer Reminder Opt-in And Timing Tune Rate
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
Prayer Settings Completion Rate,"/settings prayer location, prayer method, Prayer page location action, Qibla location action, or manual location save",prayer_location_changed,"settings_prayer_location, settings_prayer_method, manual_location_page, prayer_page_card, or qibla_page",coarse method source and change_type only,no coordinates location labels timezone IDs routes or free text
Reminder Setup View Rate,/settings/notifications,notification_settings_viewed,"settings, home_prayer_card, prayer_page_card, prayer_completion_card, home_session_completion, or session_completion",source and aggregate enabled state only,no route exact reminder time location women mode status or free text
Reminder Permission Prompt Exposure Rate,prayer or Daily Session reminder explanation prompt,notification_permission_prompt_viewed,"settings, home_prayer_card, prayer_page_card, prayer_completion_card, home_session_completion, or session_completion",reminder_type and controlled source only,no route payload exact reminder time lock-screen copy location women mode status feedback text or religious text
Prayer Reminder Permission Outcome Rate,notification permission flow,prayer_reminder_permission_result,"settings, home_prayer_card, prayer_page_card, or prayer_completion_card",scheduled or denied outcome only,no route exact reminder time location women mode status or free text
Local Reminder Schedule Health,"Notification Settings, Home prayer card direct Enable reminders CTA, Prayer page direct Enable reminders CTA, lead-time dropdown, Daily Session reminder toggle, and Daily Session reminder time update",notification_schedule_result,"settings, home_prayer_card, prayer_page_card, prayer_completion_card, home_session_completion, or session_completion",scheduled count and coarse result only,no route payload exact reminder time prayer name lock-screen body coordinates women mode status feedback text or religious text
Notification QA Smoke Result Rate,Notification Settings QA buttons,notification_smoke_test_result,notification_settings_qa,scheduled denied or failed QA outcome only,no payload route scheduled local time exact reminder time location women mode status feedback text or religious text
Notification Permission Recovery Rate,Notification Settings denied-permission recovery button,notification_permission_recovery_opened,notification_settings,system settings opened or unavailable outcome only,no route payload device model exact reminder time coordinates women mode status feedback text or religious text
Prayer Reminder Opt-in And Timing Tune Rate,"/settings/notifications, Home prayer card direct Enable reminders CTA, Prayer page direct Enable reminders CTA, Prayer completion card, or lead-time dropdown",prayer_reminder_changed,"settings, home_prayer_card, prayer_page_card, or prayer_completion_card",enabled state and reminder_offset_minutes only,no route exact reminder time exact location women mode status or free text
Push/reminder module,"Notification Settings, QA smoke buttons, denied-permission recovery button, Home prayer card direct Enable reminders CTA, Prayer page direct Enable reminders CTA, lead-time dropdown, Daily Session reminder toggle, and local notification tap","notification_settings_viewed|notification_permission_prompt_viewed|notification_schedule_result|notification_smoke_test_result|notification_permission_recovery_opened|prayer_reminder_permission_result|prayer_reminder_changed|daily_session_reminder_permission_result|daily_session_reminder_changed|notification_tap_result|notification_tap_opened","settings|notification_settings|notification_settings_qa|home_prayer_card|prayer_page_card|home_session_completion|session_completion|local_notification",local reminder loop coverage,no route payload exact reminder time coordinates women mode status feedback text or religious text
Push Tap Outcome Health,foreground or cold-start notification tap handling,notification_tap_result,local_notification,coarse content_type and change_type only,no route content ID prayer name raw payload or lock-screen body
Push Open Rate,foreground or cold-start notification tap,notification_tap_opened,local_notification,coarse content_type only,no route content ID prayer name or raw payload
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
Closed-test Prompt Usage,/settings/testing-guide,closed_test_prompt_copied|closed_test_prompt_marked_sent,closed_testing_guide,prompt_day and theme_key only,no feedback text/email
EOF

cat >"$out_dir/retention_loop_debugview_qa.md" <<'EOF'
# Retention Loop DebugView QA

Status: ordered QA checklist for reviewed analytics builds only.

This checklist verifies the core retained-user loop from Home → Prayer → Daily
Session → Reminder/Feedback. Run it only after the QA build has reviewed
Firebase configuration, `SAKINAH_ANALYTICS_ENABLED=true`, Privacy Center usage
analytics opt-in, and Firebase DebugView device setup.

## Home → Prayer → Daily Session → Reminder/Feedback

1. Open Home after onboarding or a returning-user launch.
   Expected DebugView sequence: `home_viewed → prayer_viewed` when the user
   enters Prayer from the Home next-prayer card, badge, or progress card.

2. On Prayer, review the next-prayer context and check off prayers locally.
   Expected events: `prayer_viewed` and `prayer_checklist_updated`.
   Confirm `prayer_checklist_updated` includes only `screen`,
   `completed_count`, `all_prayers_completed`, and
   `source=prayer_page_checklist`.

3. Start Daily Session from Home, bottom navigation, or the prayer-completion
   entry point.
   Expected events: `daily_session_started`, `daily_session_step_viewed`, and
   `daily_session_completed`.
   Confirm no Quran, Dua, Dhikr, reflection, translation, or free-text content
   appears in DebugView.

4. From the completed-session Home surface, choose Set daily reminder.
   Expected events: `notification_permission_prompt_viewed`,
   `daily_session_reminder_permission_result`, and
   `daily_session_reminder_changed` with `source=home_session_completion`.
   Confirm exact reminder time and routine notes are absent.

5. Open Notification Settings from a relevant entry point and adjust prayer
   reminders or lead time.
   Expected events: `notification_settings_viewed`,
   `notification_permission_prompt_viewed`,
   `prayer_reminder_permission_result`, `notification_schedule_result`, and
   `prayer_reminder_changed`.
   Confirm sources stay controlled, such as `settings`, `home_prayer_card`,
   `prayer_page_card`, or `prayer_completion_card`.

6. If notification QA controls are enabled, schedule both QA smoke buttons from
   Notification Settings.
   Expected event: `notification_smoke_test_result` with only coarse
   `content_type`, `source=notification_settings_qa`, and `change_type`.
   Confirm no payload, route, scheduled local time, exact reminder time,
   location, Women's Ibadah Mode exact status, lock-screen body, feedback text,
   or religious text appears.

7. From a denied notification permission state, tap the system settings recovery
   button in Notification Settings.
   Expected event: `notification_permission_recovery_opened` with only
   `source=notification_settings` and coarse `change_type`.
   Confirm no route, payload, device model, reminder time, coordinates, Women's
   Ibadah Mode status, feedback text, lock-screen body, or religious text
   appears.

8. Tap a local notification during QA, including at least one cold-start launch
   payload.
   Expected events: `notification_tap_result` with only coarse
   `content_type`, `source=local_notification`, and coarse `change_type`; a
   successful open also records `notification_tap_opened` with only coarse
   `content_type` and `source=local_notification`.
   No raw payloads, routes, coordinates, exact reminder times, content IDs,
   prayer names, Women's Ibadah Mode exact status, feedback text, or religious
   text may appear.

9. Open the closed-testing guide, copy a prompt, and mark it sent locally.
   Expected events: `closed_test_prompt_copied` and
   `closed_test_prompt_marked_sent` with only `prompt_day`, `theme_key`, and
   `source=closed_testing_guide`.
   Confirm tester names, email addresses, and feedback text are absent.

## Completion Evidence

- Screenshot or note DebugView rows for the expected events only.
- Keep evidence aggregate-only; do not export tester-level analytics data.
- Record any missing event, wrong source, or blocked-field leak as a release
  blocker before enabling analytics in a Play closed-testing build.
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
payload,payload,raw notification payloads and routes must not be sent
scheduled_local_time,scheduled_local_time,exact QA notification schedule time is not required for retention monitoring
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
- Use \`retention_loop_debugview_qa.md\` for the ordered Home → Prayer → Daily Session → Reminder/Feedback loop.

## Strict Completed Evidence Gate

Run strict export only after the QA reviewer supplies completed aggregate
evidence CSVs with no template placeholders or tester personal data:

\`\`\`sh
SAKINAH_REQUIRE_ANALYTICS_DEBUGVIEW_READY=true \\
SAKINAH_ANALYTICS_ENABLED_CONFIRMED=true \\
SAKINAH_FIREBASE_PROJECT_CONFIG_READY=true \\
SAKINAH_ANALYTICS_CONSENT_QA_READY=true \\
SAKINAH_PLAY_DATA_SAFETY_ANALYTICS_REVIEWED=true \\
SAKINAH_DEBUGVIEW_DEVICE_READY=true \\
SAKINAH_ANALYTICS_DEBUGVIEW_SETUP_EVIDENCE=/path/to/analytics_debugview_setup.csv \\
SAKINAH_ANALYTICS_DEBUGVIEW_EVENT_EVIDENCE=/path/to/analytics_debugview_events.csv \\
SAKINAH_ANALYTICS_DEBUGVIEW_RETENTION_LOOP_EVIDENCE=/path/to/analytics_debugview_retention_loop.csv \\
SAKINAH_ANALYTICS_DEBUGVIEW_BLOCKED_PARAMETER_EVIDENCE=/path/to/analytics_debugview_blocked_parameters.csv \\
scripts/export_google_analytics_debugview_packet.sh
\`\`\`

## Push/reminder module coverage

- Verify \`notification_settings_viewed\` appears when opening Notification Settings from Settings, Home, Prayer, completion, or session-completion entry points.
- Verify \`notification_permission_prompt_viewed\` appears when prayer or Daily Session reminder explanation prompts are shown, with only \`reminder_type\` and a controlled \`source\`.
- Verify Home prayer card direct Enable reminders CTA records \`prayer_reminder_permission_result\` and \`prayer_reminder_changed\` with \`source=home_prayer_card\`.
- Verify Prayer page direct Enable reminders CTA records \`prayer_reminder_permission_result\` and \`prayer_reminder_changed\` with \`source=prayer_page_card\`.
- Verify Daily Session reminder opt-in records \`daily_session_reminder_permission_result\` and \`daily_session_reminder_changed\` with a controlled session reminder source.
- Verify prayer and Daily Session reminder scheduling records \`notification_schedule_result\` with only reminder type, enabled state, controlled source, coarse result, scheduled count, and prayer lead-time offset when relevant.
- Verify Notification Settings QA buttons record \`notification_smoke_test_result\` with only coarse \`content_type\`, \`source=notification_settings_qa\`, and \`change_type\`.
- Verify Notification Settings denied-permission recovery records \`notification_permission_recovery_opened\` with only \`source=notification_settings\` and coarse \`change_type\`.
- Verify foreground/background and cold-start local notification taps record \`notification_tap_result\` with only coarse \`content_type\`, \`source=local_notification\`, and \`change_type\`.
- Verify successful foreground/background and cold-start local notification taps also record \`notification_tap_opened\` with only coarse \`content_type\` and \`source=local_notification\`.

## Android DebugView Commands

\`\`\`sh
adb shell setprop debug.firebase.analytics.app $package_name
adb shell setprop debug.firebase.analytics.app .none.
\`\`\`

## Flows To Exercise

- Onboarding start and completion.
- Privacy Center usage analytics opt-in and opt-out.
- Home prayer card direct Enable reminders CTA to prayer reminder opt-in.
- Prayer page direct Enable reminders CTA to prayer reminder opt-in.
- Prayer completion card to prayer reminder opt-in.
- Notification Settings denied-permission recovery button after a denied permission attempt.
- Notification Settings QA smoke buttons for generic and prayer reminder test notifications.
- Local prayer reminder tap, Daily Session reminder tap, and one cold-start local notification launch.
- Home open after local prayer completion state loads.
- Prayer page open and prayer reminder toggle.
- Qibla page open from Prayer card, Settings/manual location, or direct route.
- Settings prayer location preset, prayer method change, Prayer page Change location, Qibla Change prayer location, and manual location save.
- Five local prayer check-ins leading to a Daily Session entry point.
- Daily Session start, step view, and completion.
- Home completed-session Set daily reminder CTA to in-place daily session reminder opt-in with source \`home_session_completion\`.
- Closed testing guide prompt copy and local sent marker.
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
- Verify \`notification_permission_prompt_viewed\` keeps only reminder type and controlled source.
- Verify \`prayer_reminder_permission_result\` keeps only enabled result, controlled source, coarse outcome, and reminder lead-time offset.
- Verify \`notification_schedule_result\` keeps only reminder type, enabled state, controlled source, coarse result, scheduled count, and prayer lead-time offset when relevant.
- Verify \`notification_smoke_test_result\` keeps only coarse content type, \`source=notification_settings_qa\`, and coarse result type.
- Verify \`notification_permission_recovery_opened\` keeps only \`source=notification_settings\` and coarse \`change_type\`.
- Verify \`notification_tap_result\` keeps only coarse content type, \`source=local_notification\`, and coarse \`change_type\`.
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
- retention_loop_debugview_qa.md
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

Strict mode requires:
- SAKINAH_ANALYTICS_ENABLED_CONFIRMED=true
- SAKINAH_FIREBASE_PROJECT_CONFIG_READY=true
- SAKINAH_ANALYTICS_CONSENT_QA_READY=true
- SAKINAH_PLAY_DATA_SAFETY_ANALYTICS_REVIEWED=true
- SAKINAH_DEBUGVIEW_DEVICE_READY=true
- SAKINAH_ANALYTICS_DEBUGVIEW_SETUP_EVIDENCE=<completed analytics_debugview_setup.csv>
- SAKINAH_ANALYTICS_DEBUGVIEW_EVENT_EVIDENCE=<completed analytics_debugview_events.csv>
- SAKINAH_ANALYTICS_DEBUGVIEW_RETENTION_LOOP_EVIDENCE=<completed analytics_debugview_retention_loop.csv>
- SAKINAH_ANALYTICS_DEBUGVIEW_BLOCKED_PARAMETER_EVIDENCE=<completed analytics_debugview_blocked_parameters.csv>

Strict DebugView evidence inputs: $strict_evidence_status
EOF

printf 'Google Analytics DebugView QA packet exported.\n'
printf 'Packet: %s\n' "$out_dir"
printf 'Manifest: %s/manifest.txt\n' "$out_dir"
