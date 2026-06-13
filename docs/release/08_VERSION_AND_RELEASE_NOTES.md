# Version And Release Notes

Status: v0.1 release-train candidate for Google Play review.

## Release Train

- Release train: v0.1 daily-prayer MVP.
- Flutter version: `0.1.0+1`.
- Android `versionName`: `0.1.0`.
- Android `versionCode`: `1`.
- Android package: `com.sakinahdaily.app`.

The Android app module reads `versionName` and `versionCode` from Flutter's
generated Gradle values, which are sourced from `pubspec.yaml`. Do not edit
Android version values separately from the Flutter version.

## Release Notes Candidate

Sakinah Daily v0.1 is a privacy-first daily prayer companion focused on:

- Local prayer times with manual or preset location.
- Local prayer reminders and daily session reminders.
- A calm daily worship session with Quran safety copy, dua, reflection, and
  dhikr.
- Privacy Center, local data deletion, and local-first Women's Ibadah Mode.
- English, Bahasa Indonesia, and Arabic RTL support.

## Google Play Version Notes

- This is the first internal release train candidate.
- Increment Android `versionCode` before every Play Console upload after this
  candidate.
- Keep `versionName` user-facing and semver-like.
- Keep release notes policy-safe: no medical claims, guaranteed outcomes, AI
  fatwa claims, ads, tracking, or religious-authority claims.
- Google Play internal testing gate:
  `scripts/verify_google_play_internal_release.sh`.
- The gate requires upload signing by default, builds the prod release `.aab`,
  and writes `build/play-internal/app-release.aab.sha256`.
- Google Play closed-testing launch pack:
  `docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md`.
- Google Play closed-testing evidence log:
  `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` and
  `scripts/verify_google_play_closed_testing_evidence.sh`.
- Google Play upload preflight:
  `scripts/verify_google_play_upload_preflight.sh`.
  This gate now verifies AAB integrity by matching the current SHA-256 checksum
  and checking readable App Bundle zip/base manifest structure before upload
  evidence is accepted.
- Google Play upload evidence packet:
  `build/play-upload`, exported by
  `scripts/export_google_play_upload_packet.sh`.
- Android upload signing setup:
  `docs/release/10_ANDROID_UPLOAD_SIGNING_SETUP.md`.
- public privacy/feedback links:
  `docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md` and
  `scripts/verify_google_play_public_links.sh`.
- public links hosting packet:
  `docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md`,
  `build/play-public-links`, and
  `scripts/export_google_play_public_links_packet.sh`.
- public links hosting packet QA:
  `scripts/verify_google_play_public_links_packet.sh`.
- Play Console submission pack:
  `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md` and
  `scripts/verify_google_play_submission_pack.sh`.
- closed-test launch day gate:
  `docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md` and
  `scripts/verify_google_play_closed_test_launch_day.sh`.
- closed-test retention observation packet:
  `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md`,
  `build/play-retention-observation`, and
  `scripts/export_google_play_closed_test_retention_packet.sh`; includes
  `production_access_feedback_summary.md` for answer-ready aggregate feedback
  handoff.
- Day 0 / Day 1 operator packet:
  `build/play-day0-day1-operator`, exported by
  `scripts/export_google_play_day0_day1_operator_packet.sh`; ties first-share
  order, Day 1 aggregate feedback intake, evidence-log updates, and optional
  DebugView decisions into one launch handoff.
- Google Analytics DebugView QA packet:
  `build/google-analytics-debugview`, exported by
  `scripts/export_google_analytics_debugview_packet.sh`; includes retention
  funnel checks, blocked-parameter review, and notification QA smoke result
  verification for local reminder delivery tests.
- Reviewed content pack readiness packet:
  `build/reviewed-content-pack-readiness`, exported by
  `scripts/export_reviewed_content_pack_readiness.sh`.
- Android OEM reminder observation packet:
  `build/android-oem-reminder-observation`, exported by
  `scripts/export_android_oem_reminder_observation_packet.sh`.
- Production access answer pack:
  `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md` and
  `scripts/verify_google_play_production_access_pack.sh`.
- Production access evidence packet:
  `build/play-production-access`, exported by
  `scripts/export_google_play_production_access_packet.sh`; carries
  `production_access_feedback_summary.md` from the retention observation packet
  when available, and strict mode now requires the retention manifest to show
  `Completed retention evidence inputs: validated` before final Play Console
  handoff. Strict mode also verifies the current AAB checksum before copying
  the signed AAB and checksum into the final evidence packet.

## Remaining External Gates

- Upload-key configuration or CI signing secrets.
- Privacy policy hosting URL.
- public privacy/feedback links verified without placeholder URLs.
- public links hosting packet strict mode after the reviewed privacy policy and
  feedback channel are published on real public HTTPS URLs.
- public links hosting packet QA must remain green before publishing updated
  privacy or feedback pages.
- Play Console submission pack strict mode after Main store listing, App
  content, Store settings, screenshots, Feature graphic, release notes, and
  Closed testing release draft are complete.
- Google Play upload evidence packet strict export after upload signing, public
  privacy/feedback links, Google Group, closed-track binding, signed AAB
  checksum, visual evidence, and app-content/store-listing confirmations are
  ready.
- closed-test launch day gate strict mode after the closed-testing release is
  approved or live, the upload packet is reviewed, and final tester links are
  checked in Google Group first / Play opt-in second order.
- closed-test retention observation packet strict mode after feedback channels
  are ready and a human has scheduled Day 1 / Day 3 / Day 7 / Day 14 aggregate
  review.
- closed-test retention completed-evidence mode after Day 14 aggregate daily
  observation, feedback themes, production decisions, and Google Analytics
  DebugView retention evidence CSVs are filled with no template placeholders.
- Day 0 / Day 1 operator packet strict mode after a human owner confirms the
  closed-test release is visible, Google Group link was shared first, Play
  opt-in link second, evidence-log updates are ready, Day 1 review is
  scheduled, and any DebugView usage decision is recorded.
- Google Analytics DebugView QA packet strict mode after a reviewed Firebase
  QA build, Privacy Center opt-in, Data Safety review, and DebugView device
  setup are confirmed, including `notification_permission_prompt_viewed`,
  `notification_schedule_result`, and `notification_smoke_test_result`
  verification without payloads, routes, exact reminder times, scheduled local
  times, lock-screen body copy, tester identity, or religious text.
- Reviewed content pack readiness packet strict mode after Quran source
  placeholders are replaced, beta session/dua/dhikr coverage is reviewed,
  licensed Quran audio rights and hashes are confirmed, and a human content
  owner signs off.
- Android OEM reminder observation packet strict mode after 8-hour, 24-hour,
  reboot restore, and aggressive battery-management reminder behavior is
  observed on a real Android device, completed evidence CSVs contain no
  template placeholders, and a human observation owner signs off.
- Kotlin Gradle Plugin warning tracker remains open for `audio_session` and
  `firebase_analytics` until upstream Flutter plugin Built-in Kotlin migrations
  are available; current packages are already latest/resolvable.
- Google Group and Play Console closed-testing track setup.
- Real 14-day closed-testing evidence log and feedback summary.
- Production access answer draft strict mode after feedback themes, changes
  made, readiness evidence, and human review are complete.
- Production access evidence packet strict export after the real closed-test
  evidence, current AAB checksum, visual evidence, and answer review are
  complete.
- Testing feedback email or URL.
- Final legal/store approval for metadata and privacy drafts.
