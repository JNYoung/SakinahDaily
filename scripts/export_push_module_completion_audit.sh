#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

out_dir="${SAKINAH_PUSH_MODULE_AUDIT_DIR:-build/push-module-completion-audit}"
require_strict="${SAKINAH_REQUIRE_PUSH_MODULE_AUDIT_READY:-false}"
package_name="com.sakinahdaily.app"

docs_index="docs/00_DOCS_INDEX.md"
push_audit_doc="docs/release/18_PUSH_MODULE_COMPLETION_AUDIT.md"
product_progress="docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md"
analytics_plan="docs/privacy/07_GOOGLE_ANALYTICS_EVENT_PLAN.md"
readiness="docs/release/01_RELEASE_READINESS_CHECKLIST.md"
acceptance="docs/testing/01_ACCEPTANCE_CHECKLIST.md"
version_notes="docs/release/08_VERSION_AND_RELEASE_NOTES.md"
analytics_service="lib/core/services/analytics_service.dart"
notification_service="lib/core/services/notification_service.dart"
notification_settings="lib/features/settings/notification_settings_page.dart"
prayer_reminder_toggle_flow="lib/shared/prayer_reminder_toggle_flow.dart"
daily_session_reminder_toggle_flow="lib/shared/daily_session_reminder_toggle_flow.dart"
notification_tap_listener="lib/shared/widgets/notification_tap_route_listener.dart"
notification_service_test="test/notification_service_test.dart"
notification_settings_test="test/notification_settings_page_test.dart"
notification_tap_service_test="test/notification_tap_service_test.dart"
notification_tap_route_test="test/notification_tap_route_listener_test.dart"
analytics_test="test/analytics_service_test.dart"

fail() {
  local message="$1"
  local code="${2:-1}"
  printf 'Push module completion audit packet failed: %s\n' "$message" >&2
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

validate_completed_push_evidence() {
  local path="$1"
  local label="$2"
  shift 2

  require_file "$path"
  for placeholder in \
    pending_manual_observation \
    pending_tap_route \
    pending_owner_assignment \
    record_manually \
    TBD \
    unknown; do
    if grep -Fq "$placeholder" "$path"; then
      fail "$label strict evidence still contains placeholder: $placeholder"
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
  "$docs_index" \
  "$push_audit_doc" \
  "$product_progress" \
  "$analytics_plan" \
  "$readiness" \
  "$acceptance" \
  "$version_notes" \
  "$analytics_service" \
  "$notification_service" \
  "$notification_settings" \
  "$prayer_reminder_toggle_flow" \
  "$daily_session_reminder_toggle_flow" \
  "$notification_tap_listener" \
  "$notification_service_test" \
  "$notification_settings_test" \
  "$notification_tap_service_test" \
  "$notification_tap_route_test" \
  "$analytics_test"; do
  require_file "$path"
done

for needle in \
  'Push module completion audit packet' \
  'v0.1 local reminder loop is complete' \
  'local prayer reminders' \
  'local daily session reminders' \
  'Remote FCM/APNs is outside v0.1 scope' \
  'No tester personal data' \
  'notification_settings_viewed' \
  'notification_permission_prompt_viewed' \
  'prayer_reminder_permission_result' \
  'prayer_reminder_changed' \
  'notification_schedule_result' \
  'notification_smoke_test_result' \
  'notification_permission_recovery_opened' \
  'daily_session_reminder_permission_result' \
  'daily_session_reminder_changed' \
  'notification_tap_result' \
  'notification_tap_opened'; do
  require_text "$push_audit_doc" "$needle"
done

require_text "$docs_index" '18_PUSH_MODULE_COMPLETION_AUDIT.md'
require_text "$docs_index" 'export_push_module_completion_audit.sh'
require_text "$product_progress" 'Push module completion audit packet'
require_text "$analytics_plan" 'Push module completion audit packet'
require_text "$readiness" 'Push module completion audit packet'
require_text "$acceptance" 'Push module completion audit packet'
require_text "$version_notes" 'Push module completion audit packet'
require_text "$analytics_service" 'notification_schedule_result'
require_text "$analytics_service" 'notification_tap_result'
require_text "$analytics_service" 'notification_tap_opened'
require_text "$notification_service" 'schedulePrayerReminders'
require_text "$notification_service" 'scheduleDailySessionReminder'
require_text "$notification_service" 'takeLaunchPayload'
require_text "$notification_service" 'openSystemNotificationSettings'
require_text "$notification_settings" 'notificationSettingsViewed'
require_text "$notification_settings" 'notificationSmokeTestResult'
require_text "$notification_settings" 'notificationPermissionRecoveryOpened'
require_text "$prayer_reminder_toggle_flow" 'trackNotificationPermissionPromptViewed'
require_text "$prayer_reminder_toggle_flow" 'prayerReminderPermissionResult'
require_text "$prayer_reminder_toggle_flow" 'prayerReminderChanged'
require_text "$daily_session_reminder_toggle_flow" 'dailySessionReminderPermissionResult'
require_text "$daily_session_reminder_toggle_flow" 'dailySessionReminderChanged'
require_text "$notification_tap_listener" 'notificationTapOpened'
require_text "$notification_tap_listener" 'notificationTapResult'
require_text "$notification_service_test" 'privacy-safe tap payload'
require_text "$notification_settings_test" 'notificationScheduleResult'
require_text "$notification_tap_service_test" 'malformed notification payload'
require_text "$notification_tap_route_test" 'notificationTapOpened'
require_text "$notification_tap_route_test" 'notificationTapResult'
require_text "$analytics_test" 'notification_permission_prompt_viewed'

strict_evidence_status="not requested"
if [[ "$require_strict" == "true" ]]; then
  require_true_var \
    SAKINAH_PUSH_ANDROID_PERMISSION_QA_READY \
    "verifying Android notification permission accept, deny, and recovery paths"
  require_true_var \
    SAKINAH_PUSH_REAL_DEVICE_SMOKE_READY \
    "capturing real-device short-delay local reminder delivery and tap routing"
  require_true_var \
    SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_REVIEWED \
    "reviewing Google Analytics DebugView push/reminder events"
  require_true_var \
    SAKINAH_PUSH_OEM_OBSERVATION_OWNER_ASSIGNED \
    "assigning long-window Android OEM reminder observation ownership"
  require_env_file \
    SAKINAH_PUSH_ANDROID_PERMISSION_EVIDENCE \
    "verifying Android notification permission accept, deny, and recovery paths"
  require_env_file \
    SAKINAH_PUSH_REAL_DEVICE_SMOKE_EVIDENCE \
    "capturing real-device short-delay local reminder delivery and tap routing"
  require_env_file \
    SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_EVIDENCE \
    "reviewing Google Analytics DebugView push/reminder events"
  require_env_file \
    SAKINAH_PUSH_OEM_OWNER_EVIDENCE \
    "assigning long-window Android OEM reminder observation ownership"
  validate_completed_push_evidence \
    "$SAKINAH_PUSH_ANDROID_PERMISSION_EVIDENCE" \
    "Android notification permission QA" \
    permission_allowed \
    permission_denied \
    system_settings_recovery \
    passed \
    "No tester personal data"
  validate_completed_push_evidence \
    "$SAKINAH_PUSH_REAL_DEVICE_SMOKE_EVIDENCE" \
    "real-device push smoke QA" \
    short_delay_prayer \
    short_delay_daily_session \
    delivered \
    tapped \
    "No tester personal data"
  validate_completed_push_evidence \
    "$SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_EVIDENCE" \
    "push DebugView event review" \
    notification_settings_viewed \
    notification_permission_prompt_viewed \
    prayer_reminder_permission_result \
    prayer_reminder_changed \
    notification_schedule_result \
    notification_smoke_test_result \
    notification_permission_recovery_opened \
    daily_session_reminder_permission_result \
    daily_session_reminder_changed \
    notification_tap_result \
    notification_tap_opened \
    passed \
    "No tester personal data"
  validate_completed_push_evidence \
    "$SAKINAH_PUSH_OEM_OWNER_EVIDENCE" \
    "push OEM observation owner assignment" \
    assigned \
    "No tester personal data"
  strict_evidence_status="validated"
fi

rm -rf "$out_dir"
mkdir -p "$out_dir"

for path in \
  "$push_audit_doc" \
  "$product_progress" \
  "$analytics_plan" \
  "$readiness" \
  "$acceptance" \
  "$version_notes" \
  scripts/export_push_module_completion_audit.sh; do
  copy_required_file "$path"
done

for path in \
  "$analytics_service" \
  "$notification_service" \
  "$notification_settings" \
  "$prayer_reminder_toggle_flow" \
  "$daily_session_reminder_toggle_flow" \
  "$notification_tap_listener" \
  "$notification_service_test" \
  "$notification_settings_test" \
  "$notification_tap_service_test" \
  "$notification_tap_route_test" \
  "$analytics_test"; do
  copy_required_text_evidence "$path"
done

copy_strict_evidence_file \
  SAKINAH_PUSH_ANDROID_PERMISSION_EVIDENCE \
  push_permission_qa_evidence.csv
copy_strict_evidence_file \
  SAKINAH_PUSH_REAL_DEVICE_SMOKE_EVIDENCE \
  push_real_device_smoke_evidence.csv
copy_strict_evidence_file \
  SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_EVIDENCE \
  push_debugview_event_review.csv
copy_strict_evidence_file \
  SAKINAH_PUSH_OEM_OWNER_EVIDENCE \
  push_oem_owner_assignment.csv

cat >"$out_dir/push_module_completion_matrix.csv" <<'EOF'
capability,status,implementation_evidence,test_evidence,analytics_evidence,privacy_note
local_prayer_reminders,complete,"NotificationService.schedulePrayerReminders and prayer_reminder_toggle_flow.dart","notification_service_test.dart and notification_settings_page_test.dart","prayer_reminder_permission_result|prayer_reminder_changed|notification_schedule_result","No exact reminder time, coordinates, route, payload, or women mode status"
local_daily_session_reminders,complete,"NotificationService.scheduleDailySessionReminder and daily_session_reminder_toggle_flow.dart","notification_service_test.dart and notification_settings_page_test.dart","daily_session_reminder_permission_result|daily_session_reminder_changed|notification_schedule_result","No exact reminder time, routine notes, route, payload, or women mode status"
permission_explanation,complete,"showPrayerReminderExplanation and showDailySessionReminderExplanation","notification_settings_page_test.dart","notification_permission_prompt_viewed","No lock-screen copy, route, payload, or religious text"
android_permission_handling,complete,"requestPermissionAfterExplanation and openSystemNotificationSettings","notification_service_test.dart and notification_settings_page_test.dart","prayer_reminder_permission_result|daily_session_reminder_permission_result|notification_permission_recovery_opened","No device model, tester identity, or personal data"
safe_lock_screen_copy,complete,"PrayerNotificationCopy and DailySessionNotificationCopy","notification_service_test.dart","notification_schedule_result","Women's Ibadah Mode exact status is not included"
tap_routing,complete,"NotificationTapService and NotificationTapRouteListener","notification_tap_service_test.dart and notification_tap_route_listener_test.dart","notification_tap_opened","No raw payload, route, content ID, prayer name, or religious text"
cold_start_and_tap_result,complete,"NotificationTapRouteListener tracks handled and unhandled local notification tap outcomes","notification_tap_route_listener_test.dart","notification_tap_result","No raw payload, route, content ID, prayer name, or religious text"
cold_start_payload,complete,"FlutterLocalNotificationService.takeLaunchPayload","notification_tap_route_listener_test.dart","notification_tap_opened","Launch payload is resolved once and cleared"
settings_management,complete,"NotificationSettingsPage prayer and daily reminder controls","notification_settings_page_test.dart","notification_settings_viewed|prayer_reminder_changed|daily_session_reminder_changed","No exact reminder time is sent to analytics"
dev_smoke_controls,complete,"Notification Settings QA smoke buttons guarded by SAKINAH_NOTIFICATION_QA_ENABLED","notification_settings_page_test.dart","notification_smoke_test_result","No raw payloads, scheduled local times, lock-screen body, or religious text"
analytics_sanitizer,complete,"AnalyticsParameterPolicy event-specific allowlists","analytics_service_test.dart","all push/reminder events","Sensitive and free-text fields are dropped"
remote_fcm_apns,out_of_scope,"Remote FCM/APNs is outside v0.1 scope","Future backend/CMS payload parity tests required","none","Requires separate push backend, CMS review, consent/data-safety review, and server-triggered delivery QA"
EOF

cat >"$out_dir/push_analytics_coverage_matrix.csv" <<'EOF'
event_name,coverage_point,emitting_surface,allowed_parameters,blocked_parameters,retention_question
notification_settings_viewed,reminder setup interest,"Notification Settings page entry","screen|source|prayer_reminders_enabled","route|reminder_time|latitude|longitude|women_ibadah_status|feedback_text","Do users enter reminder setup before opting in?"
notification_permission_prompt_viewed,permission education exposure,"Prayer and Daily Session reminder explanation prompts","reminder_type|source","payload|route|scheduled_local_time|reminder_time|body|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text","Do users see the education prompt before system permission?"
prayer_reminder_permission_result,prayer reminder permission outcome,"Settings, home_prayer_card, prayer_page_card, prayer_completion_card","enabled|source|change_type|reminder_offset_minutes","route|reminder_time|latitude|longitude|women_ibadah_status|feedback_text","Where do prayer reminder attempts succeed or fail?"
prayer_reminder_changed,prayer reminder preference change,"Settings, home_prayer_card, prayer_page_card, prayer_completion_card","prayer_name|enabled|source|reminder_offset_minutes","route|reminder_time|latitude|longitude|women_ibadah_status|feedback_text","Which prayer reminder surfaces drive opt-in or tuning?"
notification_schedule_result,local schedule health,"Prayer and Daily Session reminder scheduling and rescheduling","reminder_type|enabled|source|change_type|scheduled_count|reminder_offset_minutes","payload|route|scheduled_local_time|reminder_time|prayer_name|body|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text","Do local schedules get created? No exact reminder time is sent."
notification_smoke_test_result,dev-only delivery QA,"notification_settings_qa buttons","content_type|source=notification_settings_qa|change_type","payload|route|scheduled_local_time|reminder_time|body|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text","Do QA smoke controls schedule or fail safely?"
notification_permission_recovery_opened,denied-permission recovery,"Notification Settings recovery button","source=notification_settings|change_type","payload|route|device_model|scheduled_local_time|reminder_time|latitude|longitude|women_ibadah_status|feedback_text|quran_arabic_text|body","Do users recover from denied notification permission?"
daily_session_reminder_permission_result,daily session reminder permission outcome,"Settings, session_completion, home_session_completion","session_id|enabled|source|change_type","reminder_time|route|women_ibadah_status|feedback_text|note","Does the session-to-reminder loop convert after completion?"
daily_session_reminder_changed,daily session reminder preference change,"Settings, session_completion, home_session_completion","session_id|enabled|source|change_type","reminder_time|women_ibadah_status|feedback_text|note","Do completed-session surfaces create return intent?"
notification_tap_result,local notification tap outcome,"foreground, background, and cold-start local notification tap handling","content_type|source=local_notification|change_type","payload|route|content_id|session_id|prayer_name|reminder_time|body|quran_arabic_text|women_ibadah_status|feedback_text","Do local notification taps open, fail parsing, or miss content without exposing raw payload data?"
notification_tap_opened,local notification open,"foreground, background, and cold-start local notification taps","content_type|source=local_notification","payload|route|content_id|session_id|prayer_name|reminder_time|quran_arabic_text|women_ibadah_status|feedback_text","Do local reminders reopen the app without exposing raw payload data?"
EOF

cat >"$out_dir/push_privacy_blocklist.csv" <<'EOF'
field,blocked_reason,where_checked
payload,Raw notification payloads can contain routes or content hints,AnalyticsParameterPolicy and analytics_service_test.dart
route,Routes reveal exact notification destination,Event-specific analytics allowlists
scheduled_local_time,Exact local reminder time is unnecessary telemetry,notification_schedule_result policy and DebugView QA packet
reminder_time,Exact reminder time can reveal routine patterns,AnalyticsParameterPolicy blocked fragments and event allowlists
latitude,Exact location is used only locally for prayer time and Qibla,AnalyticsParameterPolicy blocked fragments
longitude,Exact location is used only locally for prayer time and Qibla,AnalyticsParameterPolicy blocked fragments
location_label,Manual place labels are local preference data,Prayer location analytics tests
timezone_id,Manual timezone is local prayer calculation metadata,Prayer location analytics tests
women_ibadah_status,Women's Ibadah Mode exact status is sensitive and local-first,Notification copy and analytics sanitizer tests
feedback_text,Closed-test feedback text can include personal details,AnalyticsParameterPolicy blocked fragments
quran_arabic_text,Religious text must not be analytics payload,AnalyticsParameterPolicy blocked fragments
translation,Religious translation text must not be analytics payload,AnalyticsParameterPolicy blocked fragments
body,Lock-screen notification copy must not be sent to analytics,Notification smoke and schedule analytics tests
device_model,Device identity is not needed for in-app analytics,notification_permission_recovery_opened policy
tester_name,Tester identity is never collected by the audit packet,AnalyticsParameterPolicy blocked fragments
email,Tester contact data is never sent in app analytics,AnalyticsParameterPolicy blocked fragments
EOF

cat >"$out_dir/push_permission_qa_evidence.csv" <<'EOF'
scenario,device_serial,android_sdk,expected_result,observed_result,notes_without_personal_data
permission_allowed,record_manually,record_manually,permission granted and reminders scheduled,pending_manual_observation,No tester personal data
permission_denied,record_manually,record_manually,permission denied keeps app usable,pending_manual_observation,No tester personal data
system_settings_recovery,record_manually,record_manually,system settings recovery opens,pending_manual_observation,No tester personal data
EOF

cat >"$out_dir/push_real_device_smoke_evidence.csv" <<'EOF'
scenario,device_serial,reminder_type,expected_delivery_result,observed_delivery_result,tap_route_result,notes_without_personal_data
short_delay_prayer,record_manually,prayer,delivered,pending_manual_observation,pending_tap_route,No tester personal data
short_delay_daily_session,record_manually,daily_session,delivered,pending_manual_observation,pending_tap_route,No tester personal data
EOF

cat >"$out_dir/push_debugview_event_review.csv" <<'EOF'
event_name,expected_parameters,observed_parameters,forbidden_parameters_present,qa_result,notes_without_personal_data
notification_settings_viewed,screen|source|prayer_reminders_enabled,record_manually,record_manually,pending_manual_observation,No tester personal data
notification_permission_prompt_viewed,reminder_type|source,record_manually,record_manually,pending_manual_observation,No tester personal data
prayer_reminder_permission_result,enabled|source|change_type|reminder_offset_minutes,record_manually,record_manually,pending_manual_observation,No tester personal data
prayer_reminder_changed,prayer_name|enabled|source|reminder_offset_minutes,record_manually,record_manually,pending_manual_observation,No tester personal data
notification_schedule_result,reminder_type|enabled|source|change_type|scheduled_count|reminder_offset_minutes,record_manually,record_manually,pending_manual_observation,No tester personal data
notification_smoke_test_result,content_type|source|change_type,record_manually,record_manually,pending_manual_observation,No tester personal data
notification_permission_recovery_opened,source|change_type,record_manually,record_manually,pending_manual_observation,No tester personal data
daily_session_reminder_permission_result,session_id|enabled|source|change_type,record_manually,record_manually,pending_manual_observation,No tester personal data
daily_session_reminder_changed,session_id|enabled|source|change_type,record_manually,record_manually,pending_manual_observation,No tester personal data
notification_tap_result,content_type|source|change_type,record_manually,record_manually,pending_manual_observation,No tester personal data
notification_tap_opened,content_type|source,record_manually,record_manually,pending_manual_observation,No tester personal data
EOF

cat >"$out_dir/push_oem_owner_assignment.csv" <<'EOF'
owner_handle,review_cadence,next_review_date,qa_result,notes_without_personal_data
pending_owner_assignment,daily-through-day14,record_manually,pending_owner_assignment,No tester personal data
EOF

cat >"$out_dir/push_module_qa_handoff.md" <<'EOF'
# 推送模块完成度 QA Handoff

Status: v0.1 本地提醒闭环完成；线上 server push 未纳入 MVP。

## 完成范围

- 本地 prayer reminders: 可从 Settings、Home prayer card、Prayer page、Prayer completion card 开启/关闭，并支持 per-prayer 与 lead-time 设置。
- 本地 Daily Session reminders: 可从 Settings、session completion、Home completed-session CTA 开启/关闭。
- 权限链路: 先显示解释弹窗，再请求系统通知权限；权限拒绝后可从 Notification Settings 打开系统设置恢复。
- 展示与路由: 锁屏文案避开 Women's Ibadah Mode 敏感状态，前台/后台/冷启动 tap 都走安全解析和路由。
- QA 控制: dev-only smoke buttons 用于短延迟本地通知验证。
- Remote FCM/APNs: outside v0.1 scope；需要单独设计 push backend、CMS payload review、consent/data-safety review 和 server-triggered delivery QA。

## 打点覆盖

- Google Analytics DebugView 重点验证: `notification_settings_viewed`, `notification_permission_prompt_viewed`, `prayer_reminder_permission_result`, `prayer_reminder_changed`, `notification_schedule_result`, `notification_smoke_test_result`, `notification_permission_recovery_opened`, `daily_session_reminder_permission_result`, `daily_session_reminder_changed`, `notification_tap_result`, `notification_tap_opened`。
- Android OEM reminder observation packet 继续覆盖 8h / 24h / reboot / battery policy 长窗口可靠性，不把模板证据当成真实送达。
- No raw payloads, routes, coordinates, scheduled local times, exact reminder times, lock-screen copy, tester identity, Women's Ibadah Mode exact status, feedback text, or religious text should appear in analytics.

## Strict evidence 模板

- `push_permission_qa_evidence.csv`: Android 权限允许、拒绝、系统设置恢复。
- `push_real_device_smoke_evidence.csv`: 短延迟 prayer reminder 和 Daily Session reminder 的真机送达/点击路由。
- `push_debugview_event_review.csv`: DebugView 中推送/提醒事件参数复核。
- `push_oem_owner_assignment.csv`: Android OEM 长窗口观察 owner 和节奏。

## 上架前人工复核

1. 在 Android 真机上完成权限允许、权限拒绝、系统设置恢复、短延迟 prayer smoke、短延迟 daily-session smoke。
2. 将真机结果填入 `push_permission_qa_evidence.csv` 和 `push_real_device_smoke_evidence.csv`，不要记录 tester personal data。
3. 在 reviewed QA build 中打开 Privacy Center usage analytics opt-in，并用 Google Analytics DebugView 复核上述事件参数，填入 `push_debugview_event_review.csv`。
4. 为长窗口 OEM 观察指定 owner，并把 owner 填入 `push_oem_owner_assignment.csv`，具体观察结果仍写入 Android OEM reminder observation packet。
5. 设置 strict mode 环境变量和四个 evidence CSV 路径，确认 `Strict push evidence inputs: validated`。
6. 若未来启用 Remote FCM/APNs，先新增独立 PRD、CMS payload review、Data Safety review、server-triggered delivery QA 和新的打点矩阵。
EOF

cat >"$out_dir/manifest.txt" <<EOF
Push module completion audit packet
Generated UTC: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Package: $package_name
Status: v0.1 local reminder loop: complete
Scope: local prayer reminders and local daily session reminders
Out of scope: Remote FCM/APNs is outside v0.1 scope
Privacy rule: No tester personal data

Artifacts:
- push_module_completion_matrix.csv
- push_analytics_coverage_matrix.csv
- push_privacy_blocklist.csv
- push_module_qa_handoff.md
- push_permission_qa_evidence.csv
- push_real_device_smoke_evidence.csv
- push_debugview_event_review.csv
- push_oem_owner_assignment.csv
- docs/release/18_PUSH_MODULE_COMPLETION_AUDIT.md

Strict mode:
- SAKINAH_REQUIRE_PUSH_MODULE_AUDIT_READY=true
- SAKINAH_PUSH_ANDROID_PERMISSION_QA_READY=true
- SAKINAH_PUSH_REAL_DEVICE_SMOKE_READY=true
- SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_REVIEWED=true
- SAKINAH_PUSH_OEM_OBSERVATION_OWNER_ASSIGNED=true
- SAKINAH_PUSH_ANDROID_PERMISSION_EVIDENCE=<completed push_permission_qa_evidence.csv>
- SAKINAH_PUSH_REAL_DEVICE_SMOKE_EVIDENCE=<completed push_real_device_smoke_evidence.csv>
- SAKINAH_PUSH_ANALYTICS_DEBUGVIEW_EVIDENCE=<completed push_debugview_event_review.csv>
- SAKINAH_PUSH_OEM_OWNER_EVIDENCE=<completed push_oem_owner_assignment.csv>

Strict push evidence inputs: $strict_evidence_status
EOF

printf 'Push module completion audit packet exported to %s\n' "$out_dir"
