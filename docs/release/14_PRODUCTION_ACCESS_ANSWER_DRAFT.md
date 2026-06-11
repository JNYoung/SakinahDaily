# Production Access Answer Draft

Status: Template; fill after the real Google Play closed test completes.

Last checked against Google Play Help on 2026-06-11.

## Purpose

Use this as the local Production access answer draft for Sakinah Daily after
the closed-testing requirement is complete. Google Play asks for information
about the closed test, the app, and why the app is ready for Production access.

Do not store tester personal data here. Use only aggregate tester counts,
feedback themes, decisions, fixes, and evidence links. Do not paste tester
names, emails, screenshots with account data, health details, private messages,
or Women's Ibadah Mode status.

Privacy rule: No tester personal data.

Official requirement reference:
https://support.google.com/googleplay/android-developer/answer/14151465

## Closed Test Summary

Play Console section: Closed test summary.

- App: Sakinah Daily
- Package: `com.sakinahdaily.app`
- Track: Closed testing / Alpha
- Tester group: Sakinah Daily Alpha Testers
- Tester group email: `sakinah-daily-testers@googlegroups.com`
- Version code under test: `1`
- How many testers joined: TBD aggregate opted-in tester count
- Minimum tester target: at least 12 opted-in testers
- Test duration: 14 continuous days
- Start date: TBD
- End date: TBD
- Feedback channels: Google Play Testing feedback plus the configured
  `SAKINAH_PLAY_TESTING_FEEDBACK` email or HTTPS URL

Draft answer:

```text
We ran a closed test for Sakinah Daily on the Alpha track with the Sakinah
Daily Alpha Testers group. Testers joined the Google Group, opted in through
Google Play, installed the app from Play, and used the prayer-first flow during
the 14-day test. We tracked only aggregate opted-in tester counts, version
code, feedback themes, and release decisions in the evidence log.
```

Evidence source:
`docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`

## Intended Users And Value

Play Console section: Intended users and value.

Intended users:

- Muslim users who want a calm, privacy-first daily prayer companion.
- Users who prefer manual or preset prayer location instead of GPS permission
  in v0.1.
- Users who want local prayer reminders, a short daily worship session, Privacy
  Center, English, Bahasa Indonesia, and Arabic RTL support.

Draft answer:

```text
Sakinah Daily is intended for Muslim users who want a quiet daily prayer
companion rather than a broad Quran super-app or a social product. The v0.1
release focuses on local prayer times, local reminders, manual or preset
location, a short daily worship session, clear privacy controls, and Arabic
RTL / English / Bahasa Indonesia support. It does not include ads, tracking,
AI fatwa, religious Q&A, community, or account requirements.
```

Evidence sources:

- `docs/release/04_STORE_METADATA_DRAFT.md`
- `docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md`
- `docs/release/01_RELEASE_READINESS_CHECKLIST.md`

## What Feedback Did You Receive

Play Console prompt: What feedback did you receive?

Summarize only aggregate feedback themes from Google Play Testing feedback and
the configured feedback channel. No tester personal data.

Feedback themes to fill after the closed test:

| Theme | Source | Severity | Decision |
|---|---|---|---|
| TBD | Play Testing feedback / feedback channel | TBD | TBD |

Use `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md` and the
exported `build/play-retention-observation/feedback_theme_template.csv` to keep
the Day 1 / Day 3 / Day 7 / Day 14 feedback summary aggregate-only.

Draft answer:

```text
We reviewed aggregate feedback themes from Google Play Testing feedback and the
configured feedback channel. The main themes were: TBD. We did not store tester
names, emails, health details, private messages, or Women's Ibadah Mode status
in the local evidence log.
```

Evidence source:
`docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`

Additional template source:
`docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md`

## What Changes Did You Make

Play Console prompt: What changes did you make?

Summarize product changes, bug fixes, copy improvements, or documented release
decisions made from tester feedback.

Changes to fill after the closed test:

| Change / decision | Source theme | Evidence | Status |
|---|---|---|---|
| TBD | TBD | TBD | TBD |

Draft answer:

```text
Based on tester feedback, we made or documented the following changes: TBD. We
kept the changes scoped to the v0.1 prayer-first release path and did not add
ads, tracking, social features, AI fatwa, or remote storage of sensitive
Women's Ibadah Mode state.
```

Evidence sources:

- `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`
- `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md`
- `docs/release/01_RELEASE_READINESS_CHECKLIST.md`

## Why Is The App Ready For Production

Play Console prompt: Why is the app ready for Production?

Readiness points:

- Release path is Home / Prayer / Session / Settings.
- Local prayer times and local reminders are implemented.
- Manual and preset prayer location avoid GPS permission in v0.1.
- Privacy Center, Delete local data, data inventory, and data-safety drafts are
  documented.
- Closed testing guide supports daily tester checklist, Day 1 / Day 3 /
  Day 7 / Day 14 feedback prompts, copyable templates, and local feedback-sent
  checkboxes.
- Android release identity, store metadata, screenshots, feature graphic, and
  submission runbook are documented.
- Unsigned local release QA is available; signed upload requires final upload
  key configuration before Play upload.

Draft answer:

```text
The app is ready for Production access after the closed test because the v0.1
release path is narrow, local-first, and verified: users can complete the core
Home -> Prayer -> Session -> Settings flow, manage local reminders, use manual
or preset prayer location without GPS permission, review Privacy Center, delete
local data, and send closed-test feedback. Release readiness, data-safety,
store listing, screenshots, feature graphic, and Android build checks are
tracked locally before submission.
```

Evidence sources:

- `docs/release/01_RELEASE_READINESS_CHECKLIST.md`
- `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md`
- `docs/release/05_SCREENSHOT_PLAN.md`
- `build/play-internal/app-release.aab.sha256`
- `build/store-assets/google-play-feature-graphic.png`

## Final Review Checklist

- [ ] `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` has real Day 1 through
  Day 14 aggregate tester counts.
- [ ] Feedback themes have no tester personal data.
- [ ] Changes made or release decisions are summarized.
- [ ] Release readiness checklist reflects the tested build.
- [ ] Signed AAB checksum is available before upload / Production access
  review.
- [ ] Human reviewer has checked wording for accuracy and policy safety.

## Validation

Template-mode check:

```sh
scripts/verify_google_play_production_access_pack.sh
scripts/export_google_play_production_access_packet.sh
```

Strict check after the real closed test and human review:

```sh
SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY=true \
SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED=true \
SAKINAH_PLAY_FEEDBACK_SUMMARY_READY=true \
SAKINAH_PLAY_CHANGES_SUMMARY_READY=true \
SAKINAH_PLAY_READINESS_EVIDENCE_READY=true \
SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true \
scripts/verify_google_play_production_access_pack.sh

SAKINAH_REQUIRE_PRODUCTION_ACCESS_PACKET_READY=true \
SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED=true \
SAKINAH_PLAY_FEEDBACK_SUMMARY_READY=true \
SAKINAH_PLAY_CHANGES_SUMMARY_READY=true \
SAKINAH_PLAY_READINESS_EVIDENCE_READY=true \
SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true \
scripts/export_google_play_production_access_packet.sh
```
