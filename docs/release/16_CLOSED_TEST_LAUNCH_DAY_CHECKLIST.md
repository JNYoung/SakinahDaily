# Closed-test launch day checklist

Status: Launch-day operator checklist. Use only after the Play Console
closed-testing release has been submitted and is approved or visible to testers.

Last checked against Google Play Help on 2026-06-11.

## Purpose

This checklist is the final local gate before Sakinah Daily tester links are
shared. It verifies the upload evidence packet, public privacy/feedback pages,
store visual assets, tester invitation order, and safe feedback language.

The goal is simple: Google Group link first, Play opt-in link second, and no
tester receives a Play link before they are eligible to install the closed-test
build.

## Local Template Gate

Run this before the first public tester message:

```sh
scripts/verify_google_play_closed_test_launch_day.sh
```

Template mode regenerates and checks:

- `build/play-upload` through `scripts/export_google_play_upload_packet.sh`.
- `build/play-public-links` through
  `scripts/verify_google_play_public_links_packet.sh`.
- Google Play store visuals through
  `scripts/verify_google_play_store_assets.sh`.
- The Play Console submission pack through
  `scripts/verify_google_play_submission_pack.sh`.

## Day 0 / Day 1 operator packet

Run this when preparing the first 24 hours of closed testing:

```sh
scripts/export_google_play_day0_day1_operator_packet.sh
```

Template mode regenerates the closed-test launch day gate, the retention
observation packet, and the Google Analytics DebugView QA packet, then writes
`build/play-day0-day1-operator` with:

- `day0_day1_operator_checklist.md` for launch share order and Day 1 review.
- `day0_day1_status_template.csv` for owner/status/evidence tracking.
- `day1_feedback_intake_template.csv` for aggregate Day 1 theme intake.

Use this packet to keep Google Group link first, Play opt-in link second,
evidence-log updates, Day 1 onboarding/privacy feedback, and optional
DebugView QA evidence in one operator handoff. Do not store tester personal
data.

The CSV files are templates in normal export mode. They intentionally contain
`TBD` placeholders so operators cannot mistake a prepared handoff for completed
launch-day evidence.

## Strict Launch Gate

Run strict mode only after the real Play Console release is approved or
available to closed testers:

```sh
SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY=true \
SAKINAH_PLAY_CONSOLE_APP_CREATED=true \
SAKINAH_PLAY_MAIN_STORE_LISTING_READY=true \
SAKINAH_PLAY_APP_ACCESS_READY=true \
SAKINAH_PLAY_ADS_DECLARATION_READY=true \
SAKINAH_PLAY_CONTENT_RATING_READY=true \
SAKINAH_PLAY_TARGET_AUDIENCE_READY=true \
SAKINAH_PLAY_DATA_SAFETY_READY=true \
SAKINAH_PLAY_PRIVACY_POLICY_READY=true \
SAKINAH_PLAY_STORE_SETTINGS_READY=true \
SAKINAH_PLAY_RELEASE_NOTES_READY=true \
SAKINAH_PLAY_SCREENSHOTS_READY=true \
SAKINAH_PLAY_FEATURE_GRAPHIC_READY=true \
SAKINAH_PLAY_CLOSED_TEST_RELEASE_DRAFTED=true \
SAKINAH_PLAY_TESTER_GROUP_CREATED=true \
SAKINAH_PLAY_CLOSED_TRACK_READY=true \
SAKINAH_PLAY_APP_CONTENT_READY=true \
SAKINAH_PLAY_STORE_LISTING_READY=true \
SAKINAH_PLAY_TESTING_FEEDBACK_READY=true \
SAKINAH_PLAY_UPLOAD_PACKET_REVIEWED=true \
SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE=true \
SAKINAH_PLAY_TESTER_LINKS_REVIEWED=true \
SAKINAH_PLAY_INVITE_COPY_REVIEWED=true \
SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE=/path/to/closed_test_release_evidence.csv \
SAKINAH_CLOSED_TEST_LINKS_EVIDENCE=/path/to/closed_test_links_evidence.csv \
SAKINAH_CLOSED_TEST_INVITE_EVIDENCE=/path/to/closed_test_invite_evidence.csv \
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/verify_google_play_closed_test_launch_day.sh
```

Strict mode also delegates to the Play submission strict gate, so upload
signing, public privacy/feedback links, app-content declarations, store listing
readiness, screenshots, feature graphic, Google Group binding, closed-testing
track setup, signed AAB, and checksum evidence must already be ready.
It also validates the three completed launch-day evidence CSV files before
delegating to the external Play submission strict gate.

Operators can validate just the local completed launch-day evidence without
requiring the external Play Console strict gate:

```sh
SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_EVIDENCE=true \
SAKINAH_PLAY_CONSOLE_APP_CREATED=true \
SAKINAH_PLAY_TESTER_GROUP_CREATED=true \
SAKINAH_PLAY_CLOSED_TRACK_READY=true \
SAKINAH_PLAY_TESTING_FEEDBACK_READY=true \
SAKINAH_PLAY_UPLOAD_PACKET_REVIEWED=true \
SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE=true \
SAKINAH_PLAY_TESTER_LINKS_REVIEWED=true \
SAKINAH_PLAY_INVITE_COPY_REVIEWED=true \
SAKINAH_CLOSED_TEST_RELEASE_EVIDENCE=/path/to/closed_test_release_evidence.csv \
SAKINAH_CLOSED_TEST_LINKS_EVIDENCE=/path/to/closed_test_links_evidence.csv \
SAKINAH_CLOSED_TEST_INVITE_EVIDENCE=/path/to/closed_test_invite_evidence.csv \
scripts/verify_google_play_closed_test_launch_day.sh
```

Completed evidence mode copies the three CSVs into
`build/play-closed-test-launch-day/completed-evidence` and prints
`Closed-test launch evidence inputs: validated`. The completed evidence must
prove the Play Console app exists, upload packet was reviewed, Testing feedback
is ready, the closed-test release is live or visible to testers, Google Group /
Play opt-in / Store listing / leave-testing links were reviewed in the right
order, invite copy was reviewed, the leave link was excluded from invite copy,
and every row keeps `No tester personal data`. Rows with `TBD`,
`pending_manual_observation`, `pending_tap_route`, `record_manually`, or
`unknown` do not pass.

Day 0 / Day 1 operator strict mode is separate and should be run after the
launch strict gate:

```sh
SAKINAH_REQUIRE_DAY0_DAY1_OPERATOR_READY=true \
SAKINAH_DAY0_OPERATOR_OWNER_ASSIGNED=true \
SAKINAH_DAY0_CLOSED_TEST_RELEASE_VISIBLE=true \
SAKINAH_DAY0_GROUP_LINK_SHARED_FIRST=true \
SAKINAH_DAY0_PLAY_OPT_IN_SHARED_SECOND=true \
SAKINAH_DAY0_EVIDENCE_LOG_UPDATED=true \
SAKINAH_DAY1_REVIEW_SCHEDULED=true \
SAKINAH_DAY1_FEEDBACK_PRIVACY_COPY_REVIEWED=true \
SAKINAH_DAY1_EVIDENCE_LOG_READY=true \
SAKINAH_DAY1_DEBUGVIEW_DECISION_RECORDED=true \
SAKINAH_DAY0_DAY1_STATUS_EVIDENCE=/path/to/day0_day1_status_evidence.csv \
SAKINAH_DAY1_FEEDBACK_EVIDENCE=/path/to/day1_feedback_evidence.csv \
scripts/export_google_play_day0_day1_operator_packet.sh
```

Strict mode validates the two completed evidence CSVs before delegating to the
external Play Console launch and retention readiness gates. The completed
evidence must include launch visibility, Google Group first / Play opt-in
second share order, leave-link exclusion, feedback privacy copy review, Day 1
review scheduling, Privacy Center review, DebugView decision, evidence-log
readiness, Day 1 aggregate theme intake, and `No tester personal data`. Rows
with `TBD`, `pending_manual_observation`, `pending_tap_route`,
`record_manually`, or `unknown` do not pass.

After the real Day 1 review, the operator can also validate just the local
completed Day 0 / Day 1 evidence packet without requiring the external strict
Play Console gates:

```sh
SAKINAH_REQUIRE_DAY0_DAY1_EVIDENCE_COMPLETE=true \
SAKINAH_DAY0_OPERATOR_OWNER_ASSIGNED=true \
SAKINAH_DAY0_CLOSED_TEST_RELEASE_VISIBLE=true \
SAKINAH_DAY0_GROUP_LINK_SHARED_FIRST=true \
SAKINAH_DAY0_PLAY_OPT_IN_SHARED_SECOND=true \
SAKINAH_DAY0_EVIDENCE_LOG_UPDATED=true \
SAKINAH_DAY1_REVIEW_SCHEDULED=true \
SAKINAH_DAY1_FEEDBACK_PRIVACY_COPY_REVIEWED=true \
SAKINAH_DAY1_EVIDENCE_LOG_READY=true \
SAKINAH_DAY1_DEBUGVIEW_DECISION_RECORDED=true \
SAKINAH_DAY0_DAY1_STATUS_EVIDENCE=/path/to/day0_day1_status_evidence.csv \
SAKINAH_DAY1_FEEDBACK_EVIDENCE=/path/to/day1_feedback_evidence.csv \
scripts/export_google_play_day0_day1_operator_packet.sh
```

Completed evidence mode copies those two CSVs into
`build/play-day0-day1-operator/completed-evidence` and writes
`Completed evidence inputs: validated` into the manifest.

## Share Order

1. Confirm the closed-testing release is approved or live for testers.
2. Share the Google Group link first:
   https://groups.google.com/g/sakinah-daily-testers
3. Ask testers to join the group before opening Play links.
4. Share the Play opt-in link second:
   https://play.google.com/apps/testing/com.sakinahdaily.app
5. Share the Store listing link only after group membership is clear:
   https://play.google.com/store/apps/details?id=com.sakinahdaily.app
6. Tell testers that review delays are normal and that they should keep the
   group membership active for the 14-day test.

Leave testing link is not an invite:

```text
https://play.google.com/apps/testing/com.sakinahdaily.app/leave
```

Never put the leave-testing link in invite copy.

## Tester Message Requirements

The Chinese mutual-testing invitation in
`docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md` is the source copy:

- It says `邀请加入 Sakinah Daily 封闭测试`.
- It puts `第一步（加入测试群组）` before Play testing links.
- It puts `第二步（加入 Google Play 测试并下载）` after the group link.
- It reminds testers to keep the test active for at least 14 days.
- It asks for feedback on friction, crashes, wording, religious content
  display clarity, reminders, and Privacy Center.
- It does not collect tester personal data.

Feedback guidance must include:

- No tester personal data.
- Please avoid personal or sensitive health details.
- Do not send Women's Ibadah Mode exact status.
- Use Google Play Testing feedback and the configured feedback email or URL.

## Evidence To Review

- Upload packet: `build/play-upload/manifest.txt`.
- Public links packet: `build/play-public-links/manifest.txt`.
- Launch pack: `docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md`.
- Submission runbook: `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md`.
- Closed-testing evidence log:
  `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`.
- Closed-test retention observation packet:
  `build/play-retention-observation`, exported by
  `scripts/export_google_play_closed_test_retention_packet.sh`.
  Start from `retention_operator_calendar.csv` and
  `retention_operator_runbook.md` inside that packet so Day 0 / Day 1 /
  Day 3 / Day 7 / Day 14 aggregate review tasks and the Google Group link
  first share order stay explicit.
- Production access answer draft:
  `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`.

Record launch-day facts in the evidence log without storing tester personal
data:

- Date the closed-testing release became visible to testers.
- Version code and package name.
- Aggregate tester count target.
- Feedback channel used.
- Whether the Google Group link was shared before the Play opt-in link.
- Any Play review delay or install eligibility issue.

## External Blockers

This checklist cannot complete strict mode until these external steps are done:

- Play Console app record exists for `com.sakinahdaily.app`.
- Google Group `sakinah-daily-testers@googlegroups.com` exists.
- The group is bound to the Closed testing track.
- Testing feedback is configured in Play Console.
- The signed AAB is uploaded and the closed-testing release is approved or
  live for testers.
- The human operator has reviewed the final invite copy and links.

## Official Reference

- Google Play open, closed, and internal test setup:
  https://support.google.com/googleplay/android-developer/answer/9845334
