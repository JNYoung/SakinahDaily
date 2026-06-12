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
- The Prayer page records a local `prayer_viewed` event with the next prayer,
  calculation method, route, screen, and coarse location method only.
- The Home page records a local `home_viewed` event only after local prayer
  completion state is loaded, with aggregate prayer retention counts only:
  today's completed count, 7-day check-in count, 7-day check-in days, current
  check-in streak, and prayer reminder enabled state.
- Prayer reminder global and per-prayer changes record local
  `prayer_reminder_changed` events with reminder enabled state and lead time.
- Prayer checklist updates record local `prayer_checklist_updated` events with
  aggregate completed count and all-prayers-completed boolean only; exact
  prayer completion names and timestamps are not sent.
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
- `prayer_reminder_changed`
- `analytics_consent_changed`
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
`prayer_reminder_changed`, `analytics_consent_changed`,
`daily_session_started`,
`daily_session_step_viewed`, `daily_session_completed`,
`daily_session_reminder_changed`, `closed_test_prompt_copied`, and
`closed_test_prompt_marked_sent` appear only with allowed parameters. No tester
personal data, exact coordinates, Women's Ibadah Mode exact status, feedback
text, religious text, or exact reminder time should appear in DebugView.
`analytics_consent_changed` must keep only `enabled` and `source`.

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
