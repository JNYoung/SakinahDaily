# Google Play Closed Testing Launch Pack

Status: Launch-prep draft. Use after upload signing, privacy policy hosting,
and Play Console app-content declarations are ready.

Last checked against Google Play Help on 2026-06-11.

## App And Track

- App: Sakinah Daily
- Package name: `com.sakinahdaily.app`
- Track: Closed testing, usually Alpha for the first Google Play test.
- Release artifact: signed `build/app/outputs/bundle/release/app-release.aab`
  from `scripts/verify_google_play_internal_release.sh`.
- Checksum artifact: `build/play-internal/app-release.aab.sha256`.

## Tester Group

Preferred group setup:

- Group name: Sakinah Daily Alpha Testers
- Group slug: `sakinah-daily-testers`
- Group email: `sakinah-daily-testers@googlegroups.com`
- Group link: https://groups.google.com/g/sakinah-daily-testers

Recommended Google Group settings for broad mutual testing:

- Who can search for group: Anyone on the web.
- Who can join group: Anyone can join.
- Conversations: group members only.
- Posting: group members only.
- Member list: group managers only unless a public tester community is
  intentionally created.

If Google Groups shows CAPTCHA or account-policy friction, the human account
owner should complete it in the browser, then continue the Play Console setup.

## Tester Links

Share these only after the Play Console closed-testing release is approved or
available to testers:

- Web opt-in:
  https://play.google.com/apps/testing/com.sakinahdaily.app
- Store listing:
  https://play.google.com/store/apps/details?id=com.sakinahdaily.app

Do not use this as an invite link:

- Leave testing:
  `https://play.google.com/apps/testing/com.sakinahdaily.app/leave`

不要把 leave testing 链接当作邀请链接。

## Play Console Setup Checklist

- [ ] Follow the submission runbook in
  `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md`.
- [ ] Create or confirm the Play Console app for `com.sakinahdaily.app`.
- [ ] Complete app access, ads, content rating, target audience, data safety,
  privacy policy, and store settings declarations.
- [ ] Upload a signed `.aab` built by
  `scripts/verify_google_play_internal_release.sh`.
- [ ] Add `sakinah-daily-testers@googlegroups.com` under Closed testing >
  Testers > Google Groups.
- [ ] Provide a feedback email or URL before saving tester settings.
- [ ] Set countries/regions broad enough for the expected testers.
- [ ] Add concise release notes from `docs/release/08_VERSION_AND_RELEASE_NOTES.md`.
- [ ] Submit all pending changes in Publishing overview.

Before uploading the first candidate, run:

```sh
scripts/verify_google_play_submission_pack.sh
scripts/export_google_play_upload_packet.sh
scripts/verify_google_play_upload_preflight.sh
```

This preflight intentionally fails until upload signing, the privacy policy
URL, testing feedback channel, Google Group creation, closed-testing track
binding, app-content declarations, store listing readiness, the signed AAB, and
the checksum are all ready.

The upload evidence packet is exported to `build/play-upload` for local human
review before the first Closed testing upload. Strict export mode should pass
only after the same Play upload conditions and strict visual-asset evidence are
ready.

Google Play also exposes private Testing feedback in Play Console. Review it
regularly during the test and keep a short issue/decision log for the later
Production access application.

Before sharing tester links on launch day, run:

```sh
scripts/verify_google_play_closed_test_launch_day.sh
```

Share the Google Group link first, then the Play opt-in link only after the
closed-testing release is approved or visible to testers. This gate also checks
the launch-day checklist in
`docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md`, the upload evidence
packet in `build/play-upload`, and the rule that the leave testing link is not
an invite link.

## 12 Tester / 14 Day Requirement

For new personal developer accounts that are subject to Google Play's testing
requirement, plan for at least 12 opted-in testers for 14 days continuously
before applying for Production access.

Operational rule for Sakinah Daily:

- Recruit at least 15 people so one or two drop-offs do not break the threshold.
- Ask testers to stay opted in for the full 14 days continuously.
- Ask testers to install from Google Play, open the app, complete onboarding,
  check prayer times, configure a reminder if comfortable, start the daily
  session, inspect Privacy Center, and send feedback.
- Keep evidence of tester count, start date, version code, major feedback
  themes, and fixes made from feedback.

Production access notes to prepare:

- Intended audience: Muslim users who want a calm, privacy-first daily prayer
  companion.
- App value: local prayer times, local reminders, manual/preset location,
  short daily worship session, privacy controls, Arabic RTL, English, and
  Bahasa Indonesia.
- Testing feedback collection: Google Play Testing feedback plus the configured
  feedback email or URL. Supply the same channel with
  `SAKINAH_PLAY_TESTING_FEEDBACK` so Settings exposes a copyable feedback entry
  during closed testing.
- In-app tester guidance: Settings exposes a Closed testing guide when
  `SAKINAH_PLAY_TESTING_FEEDBACK` is configured. It summarizes a Daily tester
  checklist for Home return intent, prayer times, reminders, Today's Sakinah
  Session, Privacy Center, and feedback.
- Guide feedback status: the top of the Closed testing guide mirrors the next
  unsent Day 1 / Day 3 / Day 7 / Day 14 prompt from local-only sent markers and
  switches to an all-sent state after every checkpoint is marked complete.
- Home closed-test entry: the Home daily prayer surface also exposes the Closed
  testing guide when the same feedback channel is configured, so testers can
  reach Day 1 / Day 3 / Day 7 / Day 14 prompts from the main retention path.
- In-app feedback prompts: the same guide surfaces Day 1, Day 3, Day 7, and
  Day 14 prompts so testers can report onboarding clarity, prayer-loop trust,
  daily return friction, and the single change that would most improve daily
  use before wider release.
- Copyable feedback templates: when `SAKINAH_PLAY_TESTING_FEEDBACK` is
  configured, each Day 1 / Day 3 / Day 7 / Day 14 prompt has a copy action
  that prepares a structured feedback message with the prompt, suggested
  aggregate theme key, feedback channel, and privacy line:
  "Please avoid personal or sensitive health details."
- Local feedback-sent checklist: testers can mark each Day 1 / Day 3 /
  Day 7 / Day 14 prompt as sent. This stores only the day marker on the device
  and is cleared by Delete local data; feedback text and personal details are
  not stored in the app.
- Closed-testing evidence log:
  `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`. Use
  `scripts/verify_google_play_closed_testing_evidence.sh` in template mode
  during launch prep, then run strict mode with
  `SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true` after the real 14-day test
  before drafting Production access answers.
- Production access answer draft:
  `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`. Use
  `scripts/verify_google_play_production_access_pack.sh` in template mode
  during launch prep, then run strict mode after the real closed test, feedback
  summary, changes summary, readiness evidence, and human review are complete.
- Retention observation packet:
  `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md`. Use
  `scripts/export_google_play_closed_test_retention_packet.sh` before sharing
  tester invites so Day 1 / Day 3 / Day 7 / Day 14 feedback themes can be
  captured as aggregate notes without tester personal data.

Daily tester checklist coverage:

- Home return intent.
- Prayer times and location.
- Reminder settings.
- Today's Sakinah Session.
- Privacy Center and Delete local data.
- Feedback channel.
- Production readiness evidence: release readiness checklist, signed AAB gate,
  screenshots, privacy/data-safety drafts, and real-device notification QA.

## Tester Daily QA Prompts

Use these prompts to collect retention and UX signal during the closed test:

The same themes are mirrored in the in-app Closed testing guide so testers can
find them from Home or Settings without returning to the invitation message.
The app currently surfaces Day 1, Day 3, Day 7, and Day 14 as the
highest-leverage retention checkpoints with copyable feedback templates and a
local feedback-sent checklist; use the full list below for manual follow-up
messages.

- Day 1: Did onboarding explain location and notification choices clearly?
- Day 2: Were the next prayer time and prayer location understandable?
- Day 3: Were prayer times, location, and reminder controls easy to trust?
- Day 4: Did notification settings feel respectful and controllable?
- Day 5: Did Arabic RTL, Bahasa Indonesia, or English copy feel natural?
- Day 6: Did Privacy Center and Delete local data build trust?
- Day 7: What made you want to reopen or ignore the app?
- Day 14: What one change would most improve daily use?

## Chinese Mutual-Testing Invitation

```text
✅ 邀请加入 Sakinah Daily 封闭测试！

Sakinah Daily 是一款安静、隐私优先的每日祷告陪伴 App，支持本地祷告时间、
本地提醒、手动/预设地点、短 Daily Session、隐私中心，以及 English /
Bahasa Indonesia / Arabic RTL。

1️⃣ 第一步（加入测试群组）：
https://groups.google.com/g/sakinah-daily-testers

2️⃣ 第二步（加入 Google Play 测试并下载）：
网页测试：https://play.google.com/apps/testing/com.sakinahdaily.app
Google Play 下载：https://play.google.com/store/apps/details?id=com.sakinahdaily.app

请保持加入测试至少 14 天，并尽量每天打开一次：看祷告时间、体验 Daily
Session、检查提醒设置和隐私中心。任何卡顿、崩溃、文案不自然或宗教内容展示
不清楚的地方，都请直接反馈给我。

感谢支持！如果你也有应用需要回测，请随时告诉我。

备注：如果暂时无法下载，说明 Google Play 封闭测试版本还在审核中；请先加入
群组，审核通过后再打开链接安装。
```

## Evidence Log

Use `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` as the canonical
closed-testing evidence log. It tracks Day 0 through Day 14, aggregate opted-in
tester counts, feedback reviewed, changes made, and Production access answer
notes without storing tester personal data.

Use `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md` as the copy-ready
Production access answer draft after the real 14-day test. It maps the closed
test summary, intended users and value, feedback themes, changes made, and
readiness evidence into Play Console answer structure.

Run the template gate before launch:

```sh
scripts/verify_google_play_closed_testing_evidence.sh
```

Run the strict completion gate after the real 14-day test:

```sh
SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true \
scripts/verify_google_play_closed_testing_evidence.sh
```

## Official References

- Google Play app testing requirements for new personal developer accounts:
  https://support.google.com/googleplay/android-developer/answer/14151465
- Google Play open, closed, and internal test setup:
  https://support.google.com/googleplay/android-developer/answer/9845334
