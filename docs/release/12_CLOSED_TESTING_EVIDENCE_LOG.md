# Closed Testing Evidence Log

Status: Template; not started. Fill this file after the first Google Play
closed-testing release is live.

Last checked against Google Play Help on 2026-06-11.

## Purpose

This log keeps the local evidence needed before applying for Google Play
Production access on accounts subject to the closed-testing requirement. The
operating target is at least 12 opted-in testers for 14 continuous days, plus
clear feedback review and changes made from that feedback.

No tester personal data should be stored here. Keep only aggregate tester
counts, version codes, feedback themes, and release decisions. Do not paste
tester names, emails, account screenshots, health details, private messages, or
women's-mode status. The in-app copyable feedback templates remind testers:
"Please avoid personal or sensitive health details."

The in-app Day 1 / Day 3 / Day 7 / Day 14 feedback-sent checklist is only a
local tester aid. Do not treat it as aggregate Play Console evidence, and do
not copy device-local status into this log unless it is summarized as a
nonpersonal feedback-process note.

Use the retention observation packet at
`docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md` and
`build/play-retention-observation` to prepare aggregate Day 1 / Day 3 /
Day 7 / Day 14 review templates before the test starts. Generate it with:

```sh
scripts/export_google_play_closed_test_retention_packet.sh
```

Official requirement reference:
https://support.google.com/googleplay/android-developer/answer/14151465

## Release Under Test

| Field | Value |
|---|---|
| App | Sakinah Daily |
| Package | `com.sakinahdaily.app` |
| Track | Closed testing / Alpha |
| Version code | `1` |
| AAB checksum | TBD |
| Start date | TBD |
| End date | TBD |
| Tester group | `sakinah-daily-testers@googlegroups.com` |
| Feedback channel | TBD |

## 14-Day Evidence Log

| Test day | Calendar date | Version code | Opted-in testers | Active/install signal | Feedback reviewed | Changes made / decision | Evidence note |
|---|---|---:|---:|---|---|---|---|
| Day 0 | TBD | 1 | TBD | Track submitted | TBD | Wait for review | TBD |
| Day 1 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 2 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 3 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 4 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 5 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 6 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 7 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 8 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 9 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 10 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 11 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 12 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 13 | TBD | 1 | TBD | TBD | TBD | TBD | TBD |
| Day 14 | TBD | 1 | TBD | TBD | TBD | Prepare Production access answers | TBD |

## Feedback themes

| Theme | Severity | Source | Decision | Fix / follow-up | Status |
|---|---|---|---|---|---|
| TBD | TBD | Play Testing feedback / feedback channel | TBD | TBD | TBD |

## Changes made

Use this section for a short chronological summary of release changes made from
tester feedback. Keep the language factual and product-focused.

- TBD

## Production access answers

Prepare short answers for the Play Console Production access application.
Use `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md` as the canonical
copy-ready answer draft:

- Intended audience: Muslim users who want a calm, privacy-first daily prayer
  companion.
- Testing approach: Closed testing with the Sakinah Daily Alpha Testers group,
  Google Play opt-in, install from Play, daily use prompts, and in-app Day 1 /
  Day 3 / Day 7 / Day 14 copyable feedback guidance with local sent-status
  checkboxes.
- Feedback collected: Summarize only aggregate themes from Google Play Testing
  feedback and the configured feedback channel.
- Changes made: Summarize fixes or product decisions made from tester feedback.
- Readiness evidence: Link this evidence log, the release readiness checklist,
  the signed AAB checksum, store screenshots, privacy/data-safety drafts, and
  real-device notification QA.

## Validation

Template-mode check:

```sh
scripts/verify_google_play_closed_testing_evidence.sh
scripts/export_google_play_closed_test_retention_packet.sh
scripts/verify_google_play_production_access_pack.sh
```

Strict completion check after the real 14-day run:

```sh
SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true \
scripts/verify_google_play_closed_testing_evidence.sh

SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY=true \
SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED=true \
SAKINAH_PLAY_FEEDBACK_SUMMARY_READY=true \
SAKINAH_PLAY_CHANGES_SUMMARY_READY=true \
SAKINAH_PLAY_READINESS_EVIDENCE_READY=true \
SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true \
scripts/verify_google_play_production_access_pack.sh
```

Strict mode is expected to fail until the log has real dates, at least 12
opted-in testers for each Day 1 through Day 14 row, reviewed feedback, and
changes made or documented release decisions.
