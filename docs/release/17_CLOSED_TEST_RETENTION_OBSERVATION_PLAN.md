# Closed-test retention observation plan

Status: Template; use during the real Google Play closed test.

Last checked against Google Play Help on 2026-06-13.

## Purpose

This plan turns the Sakinah Daily closed test into a lightweight retention and
user-experience observation loop without adding default-on analytics, crash
SDKs, ads, accounts, or remote personal-data collection.

Use it with:

- Google Play Testing feedback.
- The configured `SAKINAH_PLAY_TESTING_FEEDBACK` email or HTTPS URL.
- The in-app Closed testing guide Day 1 / Day 3 / Day 7 / Day 14 feedback
  prompts.
- The Home Closed testing guide entry that appears only when the feedback
  channel is configured.
- The copied in-app feedback prompt and optional public feedback page include a
  suggested aggregate theme key, so feedback can be summarized without storing
  personal text.
- The optional Google Analytics DebugView QA packet exported by
  `scripts/export_google_analytics_debugview_packet.sh` when a reviewed
  analytics QA build is available.
- The Day 0 / Day 1 operator packet exported by
  `scripts/export_google_play_day0_day1_operator_packet.sh`, which regenerates
  the launch-day, retention-observation, and DebugView packets before writing a
  first-24-hours operator checklist and aggregate Day 1 feedback intake
  templates.
- `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`.
- `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`.

Privacy rule: No tester personal data. Do not store tester names, emails,
private messages, health details, screenshots with account data, or Women's
Ibadah Mode exact status. Feedback prompts should keep saying:
"Please avoid personal or sensitive health details."

## North Star And Observation Metrics

North star:

- Weekly Active Prayer Reminder Users.

Closed-test proxy metrics, collected only as aggregate or self-reported
signals:

- Onboarding Completion Rate.
- Prayer View Rate.
- Qibla View Rate.
- Prayer Location/Method Setup Rate.
- Prayer Reminder Opt-in Rate.
- Analytics Consent Rate for reviewed QA builds that need DebugView evidence.
- D1 / D7 Retention.
- Push Open Rate from aggregate tester feedback by default, or
  `notification_tap_opened` DebugView evidence when reviewed analytics QA is
  explicitly approved.
- Daily Session Start Rate.
- Settings Completion Rate.

Because Firebase Analytics is default-off until a reviewed build provides
Firebase project configuration, `SAKINAH_ANALYTICS_ENABLED=true`, and user
opt-in from Privacy Center, these remain observation categories by default. Use
aggregate tester counts, Play Testing feedback, and voluntary tester comments
unless telemetry is explicitly approved and declared for the test build.

If telemetry is explicitly approved for a closed-testing QA build, export the
DebugView QA packet and use Firebase DebugView only to verify the whitelisted
events and blocked fields. Do not replace the aggregate Day 1 / Day 3 / Day 7 /
Day 14 evidence log with raw analytics exports, and do not store tester
personal data.
Privacy Center consent toggles should appear only as
`analytics_consent_changed` with enabled state and `source=privacy_center`.
Prayer reminder changes should appear only as `prayer_reminder_changed` with
prayer scope, enabled state, controlled source such as `settings`,
`home_prayer_card`, `prayer_page_card`, or `prayer_completion_card`, and
lead-time offset; do not store routes, exact reminder times, coordinates,
Women's Ibadah Mode status, or free text.
Notification Settings views should appear only as
`notification_settings_viewed` with screen, controlled source, and aggregate
prayer-reminder enabled state, so setup interest can be observed separately
from reminder opt-in.
Qibla views should appear only as `qibla_viewed` with screen, route, coarse
location method, calculation method, and controlled source such as
`prayer_page_card`, so prayer utility interest can be observed without exact
coordinates, selected place labels, bearing degrees, Women's Ibadah Mode
status, or free text.
Prayer location and calculation-method setup should appear only as
`prayer_location_changed` with coarse location method, calculation method,
controlled source such as `settings_prayer_location`,
`settings_prayer_method`, `manual_location_page`, `prayer_page_card`, or
`qibla_page`, and coarse change type; do not store coordinates, manual place
labels, timezone IDs, routes, Women's Ibadah Mode status, or free text.
Prayer reminder permission attempts should appear only as
`prayer_reminder_permission_result` with enabled result, controlled source,
coarse outcome, and lead-time offset, so denial or explanation dismissal can be
observed without storing routes, exact reminder times, coordinates, Women's
Ibadah Mode status, or free text.
Home-card and Prayer-page direct reminder enable should use
`source=home_prayer_card` or `source=prayer_page_card` and keep the user on the
originating surface after local scheduling, so closed-test reviewers can
compare Home and Prayer opt-in friction against Settings and completion-card
entry points without collecting routes or exact reminder times.
Prayer checklist updates should appear only as `prayer_checklist_updated` with
screen, aggregate completed count, all-prayers-completed state, and
`source=prayer_page_checklist`; do not store prayer names, completion
timestamps, coordinates, Women's Ibadah Mode status, or free text.
Daily Session reminder permission attempts should appear only as
`daily_session_reminder_permission_result` with session ID, enabled result,
controlled source, and coarse outcome, so the session-to-reminder funnel can be
diagnosed without storing exact reminder time, routes, Women's Ibadah Mode
status, routine notes, or free text.
Local notification opens should appear only as `notification_tap_opened` with
coarse content type and `source=local_notification`; do not store raw payloads,
routes, content IDs, prayer names, or religious text.
Push/reminder module DebugView coverage should be reviewed as one closed loop:
`notification_settings_viewed` shows setup intent,
`prayer_reminder_permission_result` and `prayer_reminder_changed` show prayer
reminder opt-in or preference changes,
`daily_session_reminder_permission_result` and
`daily_session_reminder_changed` show the Daily Session return loop, and
`notification_tap_opened` shows coarse local-notification open behavior. Home
and Prayer direct prayer reminder opt-ins must retain `source=home_prayer_card`
and `source=prayer_page_card` respectively, and the Home completed-session
Daily Session reminder opt-in must retain `source=home_session_completion`.
Exact reminder times, routes, raw payloads, coordinates, Women's Ibadah Mode
exact status, feedback text, and religious text stay out of DebugView.
The optional DebugView packet also includes a Home → Prayer → Daily Session →
Reminder/Feedback retention loop QA checklist. Use it to verify that
`home_viewed → prayer_viewed`, `prayer_checklist_updated`,
`daily_session_started`, `daily_session_completed`,
`daily_session_reminder_permission_result`,
`daily_session_reminder_changed`, `notification_tap_opened`,
`closed_test_prompt_copied`, and `closed_test_prompt_marked_sent` appear in the
expected order with controlled sources and no raw payloads, routes,
coordinates, exact reminder times, feedback text, tester identity, Women's
Ibadah Mode exact status, or religious text.

## Observation Windows

| Window | Focus | Question |
|---|---|---|
| Day 0 | Launch readiness | Can testers join the group, opt in, install, and open the app? |
| Day 1 | First-use clarity | Did onboarding explain location and notification choices clearly? |
| Day 3 | Prayer loop | Were prayer times, selected location, and reminder controls understandable? |
| Day 7 | Retention friction | What made testers want to reopen or ignore the app? |
| Day 14 | Production readiness | What one change would most improve daily use before wider release? |

The in-app prompt templates suggest these aggregate theme keys by default:

- Day 1: `onboarding_location_clarity`
- Day 3: `prayer_time_trust`
- Day 7: `retention_reason_to_return`
- Day 14: `retention_reason_to_return`

## Feedback Theme Taxonomy

Use these theme keys in the exported feedback CSV:

- `onboarding_location_clarity`
- `prayer_time_trust`
- `reminder_usefulness_or_annoyance`
- `daily_session_calmness`
- `privacy_center_trust`
- `religious_content_source_trust`
- `localization_rtl_or_bahasa`
- `performance_or_crash`
- `play_install_or_opt_in_access`
- `retention_reason_to_return`

## Exported Packet

Create the local packet with:

```sh
scripts/export_google_play_closed_test_retention_packet.sh
```

The packet is written to `build/play-retention-observation` and contains:

- `manifest.txt`
- `daily_observation_template.csv`
- `feedback_theme_template.csv`
- `production_access_decisions_template.csv`
- `production_access_feedback_summary.md`
- This plan.
- The closed-testing evidence log.
- The Production access answer draft.
- The closed-test launch day checklist.

For the first 24 hours, also create the Day 0 / Day 1 operator packet:

```sh
scripts/export_google_play_day0_day1_operator_packet.sh
```

It writes `build/play-day0-day1-operator` so the operator can track launch
share order, Day 1 onboarding/privacy feedback, evidence-log updates, and the
optional DebugView decision from one aggregate-only handoff.

## Strict Mode

After the real closed-testing release is live, the operator can require human
launch/observation confirmations:

```sh
SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY=true \
SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE=true \
SAKINAH_PLAY_TESTING_FEEDBACK_READY=true \
SAKINAH_PLAY_RETENTION_OWNER_ASSIGNED=true \
SAKINAH_PLAY_RETENTION_REVIEW_SCHEDULED=true \
SAKINAH_PLAY_EVIDENCE_LOG_READY=true \
scripts/export_google_play_closed_test_retention_packet.sh
```

Strict mode does not prove the 14-day requirement is complete. It proves that
the observation process is ready when the closed test starts. Use
`SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true
scripts/verify_google_play_closed_testing_evidence.sh` after Day 14.

## Production Access Use

When the test ends, summarize only aggregate results:

- D1 / D3 / D7 / D14 feedback themes.
- Major product changes or explicit release decisions.
- Whether testers understood manual/preset prayer location.
- Whether testers completed prayer location and method setup.
- Whether local prayer reminders felt useful or annoying.
- Whether Privacy Center and Delete local data increased trust.
- Whether Arabic RTL and Bahasa Indonesia copy felt natural.

Map those summaries into:

- `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`
- `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`
- `build/play-retention-observation/production_access_feedback_summary.md`
  first, so the final Play Console answers can be reviewed from one
  aggregate-only handoff file.

## Official Reference

- Google Play app testing requirements for new personal developer accounts:
  https://support.google.com/googleplay/android-developer/answer/14151465
