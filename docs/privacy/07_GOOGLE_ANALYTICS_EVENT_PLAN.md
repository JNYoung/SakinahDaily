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
- Android manifest metadata disables Firebase Analytics automatic collection
  and automatic screen reporting by default.
- The Daily Session flow records local `daily_session_started` and
  `daily_session_completed` events.
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

## Blocked Data

The sanitizer drops sensitive or free-text fields, including:

- exact latitude or longitude
- exact prayer completion names or completion timestamps for prayer checklist
  updates and Home retention summaries
- tester names, emails, or personal identifiers
- feedback text, private notes, and free text
- Quran, Dua, reflection, Arabic, translation, or religious text fields
- Women's Ibadah Mode exact status, menstruation, postpartum, pregnancy, or
  health-related fields

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
