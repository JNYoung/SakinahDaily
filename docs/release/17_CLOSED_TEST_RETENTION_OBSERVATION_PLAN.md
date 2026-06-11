# Closed-test retention observation plan

Status: Template; use during the real Google Play closed test.

Last checked against Google Play Help on 2026-06-11.

## Purpose

This plan turns the Sakinah Daily closed test into a lightweight retention and
user-experience observation loop without adding analytics, crash SDKs, ads,
accounts, or remote personal-data collection.

Use it with:

- Google Play Testing feedback.
- The configured `SAKINAH_PLAY_TESTING_FEEDBACK` email or HTTPS URL.
- The in-app Closed testing guide Day 1 / Day 3 / Day 7 / Day 14 feedback
  prompts.
- The Home Closed testing guide entry that appears only when the feedback
  channel is configured.
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
- Prayer Reminder Opt-in Rate.
- D1 / D7 Retention.
- Push Open Rate when testers voluntarily mention reminder opens.
- Daily Session Start Rate.
- Settings Completion Rate.

Because v0.1 has no analytics SDK, these are observation categories, not
tracked per-user telemetry. Use aggregate tester counts, Play Testing feedback,
and voluntary tester comments only.

## Observation Windows

| Window | Focus | Question |
|---|---|---|
| Day 0 | Launch readiness | Can testers join the group, opt in, install, and open the app? |
| Day 1 | First-use clarity | Did onboarding explain location and notification choices clearly? |
| Day 3 | Prayer loop | Were prayer times, selected location, and reminder controls understandable? |
| Day 7 | Retention friction | What made testers want to reopen or ignore the app? |
| Day 14 | Production readiness | What one change would most improve daily use before wider release? |

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
- This plan.
- The closed-testing evidence log.
- The Production access answer draft.
- The closed-test launch day checklist.

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
- Whether local prayer reminders felt useful or annoying.
- Whether Privacy Center and Delete local data increased trust.
- Whether Arabic RTL and Bahasa Indonesia copy felt natural.

Map those summaries into:

- `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`
- `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`

## Official Reference

- Google Play app testing requirements for new personal developer accounts:
  https://support.google.com/googleplay/android-developer/answer/14151465
