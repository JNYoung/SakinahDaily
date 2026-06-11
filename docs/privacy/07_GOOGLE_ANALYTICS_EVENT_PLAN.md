# Google Analytics Event Plan

Status: Privacy-safe implementation plan; no Google Analytics SDK is enabled in
the v0.1 release build yet.

## Purpose

Sakinah Daily needs retention and usage visibility for the daily prayer loop
without weakening the privacy posture that makes the app trustworthy. This plan
defines a Google Analytics 4 compatible event contract that can later be wired
to Firebase Analytics after privacy/legal review, updated Google Play Data
Safety declarations, and final user-facing policy copy.

Current implementation:

- `lib/core/services/analytics_service.dart` defines the event catalog and
  parameter sanitizer.
- `StubAnalyticsService` is local-only and has no network behavior.
- The Daily Session flow records local `daily_session_started` and
  `daily_session_completed` events.
- The Prayer page records a local `prayer_viewed` event with the next prayer,
  calculation method, route, screen, and coarse location method only.
- Prayer reminder global and per-prayer changes record local
  `prayer_reminder_changed` events with reminder enabled state and lead time.
- `SAKINAH_ANALYTICS_ENABLED=true` can enable local event recording for
  controlled QA, but no `firebase_analytics` dependency is added.
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
- `calculation_method`
- `content_id`
- `content_type`
- `enabled`
- `environment`
- `language_code`
- `location_method`
- `prompt_day`
- `prayer_name`
- `reminder_offset_minutes`
- `route`
- `screen`
- `session_id`
- `source`
- `step_id`
- `step_index`

## Blocked Data

The sanitizer drops sensitive or free-text fields, including:

- exact latitude or longitude
- tester names, emails, or personal identifiers
- feedback text, private notes, and free text
- Quran, Dua, reflection, Arabic, translation, or religious text fields
- Women's Ibadah Mode exact status, menstruation, postpartum, pregnancy, or
  health-related fields

## Google Analytics SDK Gate

Before adding `firebase_analytics` or any Google Analytics runtime dependency:

- Update `docs/privacy/02_PRIVACY_POLICY_DRAFT.md`.
- Update `docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md`.
- Update `docs/privacy/06_SDK_AND_API_INVENTORY.md`.
- Decide whether analytics requires explicit in-app consent or a Settings
  opt-out for the target launch markets.
- Verify no event sends Women's Ibadah Mode exact status, coordinates,
  feedback text, religious text, or personal identifiers.
- Re-run `flutter test`, `dart analyze`, and the Google Play release gates.

Until then, analytics remains a local event contract and does not transmit
tester or user data.
