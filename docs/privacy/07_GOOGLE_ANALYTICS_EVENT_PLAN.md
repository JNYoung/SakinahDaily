# Google Analytics Event Plan

Status: Privacy-safe implementation plan; Firebase Analytics SDK dependency is present, but analytics collection is default-off in the v0.1 build.

## Purpose

Sakinah Daily needs retention and usage visibility for the daily prayer loop
without weakening the privacy posture that makes the app trustworthy. This plan
defines a Google Analytics 4 compatible event contract that can be wired to
Firebase Analytics only after privacy/legal review, updated Google Play Data
Safety declarations, and final user-facing policy copy.

Current implementation:

- `lib/core/services/analytics_service.dart` defines the event catalog and
  parameter sanitizer.
- `StubAnalyticsService` is local-only and has no network behavior.
- `FirebaseAnalyticsService` can forward sanitized events to Firebase
  Analytics when analytics is explicitly enabled and the user has opted in.
- `FirebaseAnalyticsBootstrap` initializes Firebase only when
  `SAKINAH_ANALYTICS_ENABLED=true` and immediately sets collection disabled by
  default.
- `analyticsCollectionConsentSyncProvider` turns Firebase Analytics collection
  on only when both the build flag and `analyticsOptIn` preference are true,
  and turns collection off when the user opts out.
- Privacy Center records `analytics_consent_changed` when usage analytics is
  toggled in an analytics-enabled build. The event keeps only enabled state and
  `source=privacy_center`, so consent funnel QA never sends tester identity,
  location, Women's Ibadah Mode status, feedback text, or religious content.
- Android manifest metadata disables Firebase Analytics automatic collection
  and automatic screen reporting by default.
- The Onboarding flow records local funnel events for start, language,
  location method, gender step, audio preference, and completion; only enum-like
  language, preset/manual location method, audio preference, source, and screen
  fields are kept, while exact location labels, coordinates, and specific
  gender mode values are dropped.
- The Daily Session flow records local `daily_session_started`,
  `daily_session_step_viewed`, and `daily_session_completed` events. Start
  analytics keeps only session ID, optional language code, and a controlled
  entry source such as `home`, `bottom_navigation`, `prayer_completion`, or
  `direct`; unrecognized route source values are normalized to `direct`. Step
  view analytics keeps only session ID, stable step ID, 1-based step index, and
  source. Completion analytics keeps only session ID and the same controlled
  entry source; Quran, Dua, Dhikr, reflection, translation, and other religious
  or free-text content is not sent.
- Daily Session reminder opt-in and reminder-setting changes record local
  `daily_session_reminder_changed` events with session ID, enabled state,
  controlled source such as `settings`, `session_completion`, or
  `home_session_completion`, and coarse change type only. Exact reminder time,
  Women's Ibadah Mode status, routine notes, and other free text are not sent.
- Daily Session reminder permission attempts record local
  `daily_session_reminder_permission_result` events with session ID, enabled
  result, controlled source, and coarse outcome such as `scheduled`,
  `permission_denied`, `explanation_dismissed`, or `schedule_failed` only.
  This includes enabled-reminder time reschedule attempts when platform
  permission or scheduling fails. Exact reminder time, routes, Women's Ibadah
  Mode status, routine notes, and other free text are not sent.
- The Prayer page records a local `prayer_viewed` event with the next prayer,
  calculation method, route, screen, coarse location method, and a controlled
  Home entry source such as `home_prayer_badge`, `home_prayer_card`, or
  `home_progress_card` only. Exact coordinates, session IDs, content IDs,
  Women's Ibadah Mode status, and free text are not sent.
- The Qibla page records a local `qibla_viewed` event with screen, route,
  coarse location method, calculation method, and a controlled source such as
  `prayer_page_card`, `settings`, `manual_location`, or `direct` only. Exact
  coordinates, selected place labels, Qibla bearing degrees/cardinal labels,
  Women's Ibadah Mode status, and free text are not sent.
- Prayer location and calculation-method changes record local
  `prayer_location_changed` events with only coarse location method
  (`preset` or `manual`), calculation method, controlled source such as
  `settings_prayer_location`, `settings_prayer_method`, or
  `manual_location_page`, plus `prayer_page_card` or `qibla_page` when the
  user enters manual setup from Prayer or Qibla, and coarse change type only.
  Exact coordinates, manual place labels, timezone IDs, routes, Women's Ibadah
  Mode status, and free text are not sent.
- Notification Settings records a local `notification_settings_viewed` event
  once per page entry with only screen, controlled entry source, and whether
  prayer reminders are already enabled. Controlled entry sources include
  reminder setup entries from Home, Prayer, completion, and Daily Session
  completion surfaces. Routes, exact reminder times, locations, Women's Ibadah
  Mode status, and free text are not sent.
- The Home page records a local `home_viewed` event only after local prayer
  completion state is loaded, with aggregate prayer retention counts only:
  today's completed count, 7-day check-in count, 7-day check-in days, current
  check-in streak, and prayer reminder enabled state.
- Prayer reminder global, per-prayer, and lead-time changes record local
  `prayer_reminder_changed` events with reminder enabled state, lead-time
  offset, and a controlled source such as `settings`, `home_prayer_card`,
  `prayer_page_card`, or `prayer_completion_card`. Lead-time changes use
  `prayer_name=all`. Routes, exact reminder times, locations, Women's Ibadah
  Mode status, and free text are not sent.
  Home-card and Prayer-page direct reminder enable use the same
  `home_prayer_card` and `prayer_page_card` sources as their reminder settings
  paths, so top-card opt-in loops can be reviewed without adding route or
  prayer-completion details.
- Prayer reminder permission attempts record local
  `prayer_reminder_permission_result` events with enabled result, controlled
  source, coarse outcome such as `scheduled`, `permission_denied`,
  `explanation_dismissed`, or `schedule_empty`, and lead-time offset only.
  Routes, exact reminder times, locations, Women's Ibadah Mode status, and
  free text are not sent.
- Handled local notification taps record `notification_tap_opened` with only a
  coarse content type such as `prayer`, `daily_session`, `quran`, `dua`, or
  `dhikr`, plus `source=local_notification`. Raw payloads, routes, content IDs,
  prayer names, exact reminder times, Women's Ibadah Mode status, and religious
  text are not sent.
- Push/reminder module analytics coverage is complete for the v0.1 local
  reminder loop without adding new sensitive events. Reminder setup interest is
  covered by `notification_settings_viewed`; prayer reminder outcomes and
  changes are covered by `prayer_reminder_permission_result` and
  `prayer_reminder_changed`; Daily Session reminder outcomes and changes are
  covered by `daily_session_reminder_permission_result` and
  `daily_session_reminder_changed`; local notification opens are covered by
  `notification_tap_opened`. The Home and Prayer direct prayer opt-in surfaces
  use controlled `source=home_prayer_card` and `source=prayer_page_card`, while
  Daily Session reminder sources stay controlled as `settings`,
  `session_completion`, or `home_session_completion`. Exact reminder times,
  routes, payloads, coordinates, Women's Ibadah Mode exact status, feedback
  text, and religious text remain blocked.
- Prayer checklist updates record local `prayer_checklist_updated` events with
  aggregate completed count, all-prayers-completed boolean, and the controlled
  `source=prayer_page_checklist` entry label only; exact prayer completion
  names and timestamps are not sent.
- Dua detail views and save toggles record local `dua_viewed` and `dua_saved`
  events with content ID, screen/source, and saved enabled state only. Dua
  Arabic, transliteration, translations, source text, and free-text notes are
  never sent.
- Dhikr counter usage records local `dhikr_started` when the counter moves from
  0 to 1 and `dhikr_completed` when the target count is reached. These events
  keep only content ID and `source=dhikr_counter`; current count trails, Arabic,
  transliteration, translations, and Women's Ibadah Mode exact status are not
  sent.
- Women's Ibadah Mode changes record local `women_ibadah_mode_changed` with
  only enabled state and `source=women_mode`. Exact status values such as
  menstruation, postpartum, pregnancy, prefer-not-to-track, health notes, or
  other sensitive details are never sent.
- Closed-test feedback prompt copy and local sent-marker actions record
  `closed_test_prompt_copied` and `closed_test_prompt_marked_sent` events with
  prompt day, suggested theme key, and screen source only; feedback text,
  feedback channel, tester names, and email addresses are never sent.
- `SAKINAH_ANALYTICS_ENABLED=true` can enable controlled QA telemetry only when
  Firebase project configuration is present and the user turns usage analytics
  on in Privacy Center.
- Store screenshot mode always disables analytics recording.

## Event Scope

Allowed events are intentionally focused on the prayer app loop:

- `onboarding_started`
- `onboarding_completed`
- `language_selected`
- `location_method_selected`
- `gender_mode_selected`
- `audio_preference_selected`
- `home_viewed`
- `prayer_viewed`
- `qibla_viewed`
- `prayer_location_changed`
- `notification_settings_viewed`
- `prayer_reminder_permission_result`
- `prayer_reminder_changed`
- `notification_tap_opened`
- `analytics_consent_changed`
- `daily_session_reminder_permission_result`
- `daily_session_reminder_changed`
- `prayer_checklist_updated`
- `daily_session_started`
- `daily_session_step_viewed`
- `daily_session_completed`
- `dua_viewed`
- `dua_saved`
- `dhikr_started`
- `dhikr_completed`
- `women_ibadah_mode_changed`
- `closed_test_prompt_copied`
- `closed_test_prompt_marked_sent`

## Allowed Parameters

Only enum-like, non-sensitive operational parameters are allowed:

- `audio_preference`
- `all_prayers_completed`
- `calculation_method`
- `change_type`
- `completed_count`
- `content_id`
- `content_type`
- `enabled`
- `environment`
- `language_code`
- `location_method`
- `prompt_day`
- `prayer_checkin_days_7d`
- `prayer_checkin_streak_days`
- `prayer_checkins_7d`
- `prayer_name`
- `prayer_reminders_enabled`
- `prayers_completed_today`
- `reminder_offset_minutes`
- `route`
- `screen`
- `session_id`
- `source`
- `step_id`
- `step_index`
- `theme_key`

## Blocked Data

The sanitizer drops sensitive or free-text fields, including:

- exact latitude or longitude
- exact selected place labels or Qibla bearing/cardinal values
- manual prayer location labels or timezone IDs
- exact prayer completion names or completion timestamps for prayer checklist
  updates and Home retention summaries
- exact daily session reminder time
- tester names, emails, or personal identifiers
- feedback text, private notes, and free text
- Quran, Dua, reflection, Arabic, translation, or religious text fields
- Women's Ibadah Mode exact status, menstruation, postpartum, pregnancy, or
  health-related fields

## DebugView QA Packet

Before any Play closed-testing or release build transmits Firebase Analytics,
export the local DebugView QA packet:

```sh
scripts/export_google_analytics_debugview_packet.sh
```

The packet is written to `build/google-analytics-debugview` and contains a
Firebase DebugView checklist, a Google Analytics event catalog, a retention
funnel checklist, a blocked-parameter review CSV, and copied source evidence.
It follows the official Firebase DebugView workflow at
`https://firebase.google.com/docs/analytics/debugview`, including the Android
debug command:

```sh
adb shell setprop debug.firebase.analytics.app com.sakinahdaily.app
```

Use this packet only with a reviewed QA build where
`SAKINAH_ANALYTICS_ENABLED=true`, Firebase project configuration is present,
and the tester has turned on the Privacy Center usage analytics opt-in. Store
screenshot mode forces analytics off and is not valid DebugView evidence.

The QA reviewer should verify that `home_viewed`,
`prayer_reminder_changed`, `qibla_viewed`, `notification_tap_opened`,
`analytics_consent_changed`,
`notification_settings_viewed`,
`prayer_reminder_permission_result`,
`prayer_location_changed`,
`daily_session_started`,
`daily_session_step_viewed`, `daily_session_completed`,
`daily_session_reminder_permission_result`,
`daily_session_reminder_changed`,
`dua_viewed`, `dua_saved`, `dhikr_started`, `dhikr_completed`,
`women_ibadah_mode_changed`, `closed_test_prompt_copied`, and
`closed_test_prompt_marked_sent` appear only with allowed parameters. No tester
personal data, exact coordinates, Women's Ibadah Mode exact status, feedback
text, religious text, or exact reminder time should appear in DebugView.
`prayer_reminder_changed` must keep only prayer scope, enabled state,
controlled source, and reminder lead-time offset.
`qibla_viewed` must keep only screen, route, coarse location method,
calculation method, and controlled source.
`prayer_location_changed` must keep only coarse location method, calculation
method, controlled source, and coarse change type.
`notification_settings_viewed` must keep only screen, controlled source, and
aggregate prayer-reminder enabled state.
`prayer_reminder_permission_result` must keep only enabled result, controlled
source, coarse outcome, and reminder lead-time offset.
`daily_session_reminder_permission_result` must keep only session ID, enabled
result, controlled source, and coarse outcome.
`notification_tap_opened` must keep only `content_type` and `source`.
`analytics_consent_changed` must keep only `enabled` and `source`.
`dua_viewed` and `dua_saved` must keep only content ID, source/screen, and
saved enabled state where relevant.
`dhikr_started` and `dhikr_completed` must keep only content ID and source.
`women_ibadah_mode_changed` must keep only enabled state and source.

Strict export mode is available for pre-upload review:

```sh
SAKINAH_REQUIRE_ANALYTICS_DEBUGVIEW_READY=true \
SAKINAH_ANALYTICS_ENABLED_CONFIRMED=true \
SAKINAH_FIREBASE_PROJECT_CONFIG_READY=true \
SAKINAH_ANALYTICS_CONSENT_QA_READY=true \
SAKINAH_PLAY_DATA_SAFETY_ANALYTICS_REVIEWED=true \
SAKINAH_DEBUGVIEW_DEVICE_READY=true \
scripts/export_google_analytics_debugview_packet.sh
```

## Google Analytics Production Gate

Before enabling Firebase Analytics for production or any Play closed-testing
build that transmits telemetry:

- Update `docs/privacy/02_PRIVACY_POLICY_DRAFT.md`.
- Update `docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md`.
- Update `docs/privacy/06_SDK_AND_API_INVENTORY.md`.
- Add reviewed Firebase project configuration such as `google-services.json`
  through a secure release process.
- Decide whether analytics requires explicit in-app consent or a Settings
  opt-out for the target launch markets.
- Keep the Privacy Center usage analytics control available and default-off.
- Verify no event sends Women's Ibadah Mode exact status, coordinates,
  feedback text, religious text, or personal identifiers.
- Re-run `flutter test`, `dart analyze`, and the Google Play release gates.

Until a reviewed production build enables `SAKINAH_ANALYTICS_ENABLED=true` with
valid Firebase configuration and the user opts in, analytics remains
default-off and does not transmit tester or user data by default.
