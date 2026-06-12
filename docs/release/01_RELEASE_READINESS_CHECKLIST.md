# Release Readiness Checklist

Status: Draft for release/store review.

## Client Build Identity

- [x] Android namespace uses `com.sakinahdaily.app`.
- [x] Android `applicationId` uses `com.sakinahdaily.app`.
- [x] Android display label is `Sakinah Daily`.
- [x] Android release signing can be supplied from ignored local
  `android/key.properties` or CI environment variables.
- [x] Android release-signing required gate fails closed when upload-key config
  is missing.
- [x] Google Play internal release gate script exists at
  `scripts/verify_google_play_internal_release.sh`; it requires upload signing
  by default, verifies `apkanalyzer` and `sdkmanager --licenses`, builds the
  prod release `.aab`, and writes a SHA-256 checksum.
- [x] Google Play upload preflight script exists at
  `scripts/verify_google_play_upload_preflight.sh`; it requires upload signing,
  privacy policy URL, testing feedback channel, Google Group/closed-track
  human confirmations, app-content/store-listing confirmations, release AAB
  and checksum evidence, and does not accept unsigned release QA as upload evidence.
- [x] Google Play upload evidence packet export exists at
  `scripts/export_google_play_upload_packet.sh`; template mode copies the Play
  upload docs, privacy/data-safety drafts, Android package/build evidence,
  verifier scripts, feature graphic, screenshots, AAB checksum, and a manifest
  into `build/play-upload`, while strict mode delegates to the upload preflight
  and strict store-asset gate before export.
- [x] Android upload keystore setup helper exists at
  `scripts/create_android_upload_keystore.sh` with a documented flow in
  `docs/release/10_ANDROID_UPLOAD_SIGNING_SETUP.md`; it requires explicit local
  passwords/path, refuses repo-local keystore output, writes
  `android/key.properties` only when requested, and keeps secret files ignored.
- [x] Google Play public links preflight exists at
  `scripts/verify_google_play_public_links.sh` with hosting guidance in
  `docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md`; it validates the final
  privacy policy URL and Testing feedback channel, rejects placeholder/private
  URLs, and is called by the upload preflight.
- [x] Google Play public links hosting packet exists at
  `docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md` with an exporter at
  `scripts/export_google_play_public_links_packet.sh`; template mode generates
  `build/play-public-links/privacy/index.html`,
  `build/play-public-links/feedback/index.html`, source drafts, and a manifest
  for legal/store review, while strict mode delegates to the public-links
  network gate after final HTTPS hosting.
- [x] Google Play public links hosting packet QA exists at
  `scripts/verify_google_play_public_links_packet.sh`; it regenerates
  `build/play-public-links` and checks the static privacy/feedback pages for
  required privacy sections, viewport/readability metadata, no placeholder
  copy, no placeholder/private URLs, safe tester-feedback wording, and no
  form/input fields that could collect sensitive details before publishing.
- [x] Google Play closed-testing evidence log template exists at
  `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md` with a verifier at
  `scripts/verify_google_play_closed_testing_evidence.sh`; template mode
  checks the evidence structure, and strict mode fails until the real 14-day
  closed test has complete aggregate tester counts and feedback decisions.
- [x] Play Console submission pack exists at
  `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md` with a verifier at
  `scripts/verify_google_play_submission_pack.sh`; template mode checks the
  local store listing, App content, screenshot, privacy, data-safety,
  closed-testing, and evidence materials, while strict mode requires human
  Play Console confirmations and delegates to the upload preflight.
- [x] Production access answer pack exists at
  `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md` with a verifier at
  `scripts/verify_google_play_production_access_pack.sh`; template mode checks
  the answer structure and evidence links, while strict mode requires the real
  14-day closed test, feedback summary, changes summary, readiness evidence,
  and human review before applying for Production access.
- [x] Production access evidence packet export exists at
  `scripts/export_google_play_production_access_packet.sh`; template mode
  copies the answer draft, closed-testing evidence log, release readiness,
  privacy/data-safety drafts, verifier scripts, checksum, and store visual
  evidence into `build/play-production-access`, while strict mode delegates to
  the Production access answer pack strict gate before export.
- [x] Google Play closed-test launch day gate exists at
  `docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md` with verifier
  `scripts/verify_google_play_closed_test_launch_day.sh`; template mode
  checks the local submission pack, public links hosting packet QA, store
  visual assets, upload evidence packet, tester invite copy, and
  `build/play-upload`, while strict mode fails until the real Play Console
  release is live for testers and a human confirms the Closed-test launch day
  gate: Share the Google Group link first, then the Play opt-in link.
- [x] Google Play closed-test retention observation packet exists at
  `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md` with exporter
  `scripts/export_google_play_closed_test_retention_packet.sh`; template mode
  writes D1/D3/D7/D14 retention observation CSV templates into
  `build/play-retention-observation` without tester personal data, while
  strict mode fails until the closed-test release is live, feedback channels
  are ready, and a human review owner/schedule is confirmed.
- [x] Google Analytics DebugView QA packet exists at
  `scripts/export_google_analytics_debugview_packet.sh`; template mode writes
  a DebugView checklist, analytics event catalog, retention funnel checklist,
  and blocked-parameter review into `build/google-analytics-debugview`, while
  strict mode fails until the reviewed Firebase QA build, Privacy Center opt-in,
  Data Safety review, and DebugView device setup are confirmed.
- [x] Reviewed content pack readiness packet exists at
  `scripts/export_reviewed_content_pack_readiness.sh`; template mode writes
  current seed inventory, beta content targets, Quran source placeholder
  review, Quran audio rights/hash review, and a no-generated-religious-content
  checklist into `build/reviewed-content-pack-readiness`, while strict mode
  fails until source placeholders, reviewed beta pack coverage, licensed audio
  rights, and a human content owner are confirmed.
- [x] Google Play store visual assets verifier exists at
  `scripts/verify_google_play_store_assets.sh`; it generates and validates the
  1024 x 500, 24-bit PNG/no-alpha feature graphic and can strictly check the
  Android screenshot matrix plus contact sheet.
- [x] Android launch smoke gate exists at
  `scripts/verify_android_launch_smoke.sh`; it builds a dev debug APK,
  installs it on a connected Android device or requested emulator, launches
  `com.sakinahdaily.app`, checks the app process, and captures local evidence
  in `build/android-launch-smoke`.
- [x] Android OEM reminder observation packet exists at
  `scripts/export_android_oem_reminder_observation_packet.sh`; template mode
  writes 8-hour, 24-hour, reboot restore, battery-policy, lock-screen-copy, and
  privacy-safe observation templates into `build/android-oem-reminder-observation`,
  while strict mode fails until real device long-window reminder evidence,
  reboot restore, battery review, and a human observation owner are confirmed.
- [x] Local e2e gate exists at `scripts/verify_local_e2e.sh`; it runs
  `flutter test`, `dart analyze`, Play submission/public-links template gates,
  the Google Analytics DebugView QA packet, the reviewed content pack readiness
  packet, the Android OEM reminder observation packet, optional internal
  release gate, and Android launch smoke when an Android device is available.
- [x] GitHub Actions local e2e workflow exists at
  `.github/workflows/local-e2e.yml`; it runs on pull requests and pushes to
  `main`, uses Node 24-compatible `actions/checkout@v6`, installs Flutter, and
  delegates to `scripts/verify_local_e2e.sh` without requiring Android devices
  or upload signing secrets.
- [x] Pull request template exists at `.github/PULL_REQUEST_TEMPLATE.md` with
  commands run, tests/analyzer result, screenshots/evidence, and product
  constraints for religious safety, privacy, RTL, and secret handling.
- [ ] iOS bundle identifier is verified after an iOS project is generated or
  restored.
- [x] App version and build number are approved for the release train:
  `0.1.0+1` (`versionName` `0.1.0`, `versionCode` `1`).

## Configuration

- [x] Default app environment is `dev`.
- [x] `staging` and `prod` are selected with `SAKINAH_APP_ENV`.
- [x] Remote content is disabled unless explicitly enabled.
- [x] The approved hosted privacy policy URL can be supplied with
  `SAKINAH_PRIVACY_POLICY_URL`; Privacy Center shows and copies it when valid,
  and keeps draft copy when the value is absent or unsafe.
- [x] The closed-testing feedback email or HTTPS URL can be supplied with
  `SAKINAH_PLAY_TESTING_FEEDBACK`; Settings shows and copies it when valid,
  and hides it when the value is absent or unsafe.
- [x] Closed testing guide appears in Settings only when the feedback channel is
  configured, and it gives testers a daily checklist for Home return intent,
  prayer times, reminders, Daily Session, Privacy Center, feedback, and Day 1 /
  Day 3 / Day 7 / Day 14 feedback prompts with copyable structured feedback
  templates, suggested aggregate theme keys, and local feedback-sent checkboxes
  for closed-test retention evidence.
- [x] Home also surfaces a Closed testing guide entry when
  `SAKINAH_PLAY_TESTING_FEEDBACK` is configured, so testers can reach the
  Day 1 / Day 3 / Day 7 / Day 14 prompts from the daily prayer surface without
  adding analytics or personal-data collection.
- [x] Analytics and crash reporting remain disabled.
- [x] v0.1 daily-prayer release baseline does not require staging CMS.
- [x] v0.1 daily-prayer release baseline does not require production CMS.

## Localization

- [x] Release path is localized across English, Bahasa Indonesia, and Arabic RTL
  for Home, Prayer, Settings, bottom navigation, session metadata, and key
  prayer/reminder CTAs.
- [x] Key prayer/reminder buttons are regression-tested to avoid English
  fallback in Indonesian and Arabic.
- [x] Indonesian release copy uses Doa / Dzikir / Shalat / Kiblat.
- [x] Arabic RTL is covered by widget tests and the Android screenshot matrix.

## Safety And Privacy

- [x] Privacy Center exists in Settings.
- [x] Privacy Center includes local closed-testing feedback status and states it
  stores only Day 1 / Day 3 / Day 7 / Day 14 sent markers, not feedback text
  or personal details.
- [x] Local data deletion exists.
- [x] Saved items are local-only and cleared by local data deletion.
- [x] Home exposes recent saved items only as a local continue rail; it does not
  add account sync, social sharing, or remote saved-item storage.
- [x] Qibla uses selected prayer location without GPS or compass permission.
- [x] Manual prayer location updates prayer/Qibla settings without GPS or sensor permission.
- [x] Quran entry/detail routes use local approved seed/cache content only.
- [x] Quran recitation copy remains voice-only with no BGM and no Quran TTS.
- [x] Quran safety screenshot evidence captured at
  `build/store-screenshots/android-safety/en-quran-94-5.png`.
- [x] Settings exposes Content Sources copy for source/review labels, approved
  CMS filtering, non-generated religious content, Quran audio safety, and no AI
  fatwa or religious Q&A.
- [x] Remote CMS defaults to seed/cache behavior. Only published + approved
  remote content can be cached or displayed when remote content is explicitly
  enabled.
- [x] Dua detail displays source and review status through a visible source
  card, and the release test verifies both fields independently.
- [x] Daily Session progress/history is local-only and cleared by Delete local data.
- [x] Prayer completion check-ins are local-only, visible as today's Prayer/Home
  progress plus local weekly Home progress, and cleared by Delete local data.
- [x] Daily Session can be completed optionally from the Home session card and
  records local completion state.
- [x] Home offers a Set daily reminder CTA after today's session is complete
  when the local daily session reminder is still off.
- [x] Daily Session Reflection step displays a localized no-fatwa note so
  reflection copy is positioned as a gentle reminder, not a religious ruling.
- [x] Notification Settings manages prayer reminders and daily session reminders
  separately.
- [x] Home session card surfaces enabled daily session reminder time as a local
  status chip, so users can confirm the habit loop without remote tracking or
  account sync.
- [x] Notification Settings exposes per-prayer local reminder controls for
  Fajr, Dhuhr, Asr, Maghrib, and Isha; Android evidence is
  `build/store-screenshots/android-safety/en-notification-settings-per-prayer.png`.
- [x] Notification Settings exposes prayer reminder lead-time choices for at
  prayer time, 5 minutes before, 10 minutes before, and 15 minutes before; local
  scheduling applies the selected offset per selected prayer.
- [x] Notification Settings shows selected prayer names and lead time in the
  enabled prayer reminder status, so testers can verify the local reminder
  scope without checking every per-prayer control.
- [x] Notification Settings previews the next local prayer reminder with prayer
  name and local clock time after reminders are enabled, without uploading the
  exact reminder time.
- [x] Notification permission denial keeps Prayer and Daily Session reminders off
  while the Settings flow remains usable.
- [x] Notification copy remains gentle, brief, and privacy-safe across prayer
  reminders, lead-time reminders, daily session reminders, and Women's Ibadah
  Mode privacy-safe variants.
- [x] Dev-only notification smoke-test control is gated by
  `SAKINAH_NOTIFICATION_QA_ENABLED=true` and ignored outside `dev`.
- [x] Dev-only prayer reminder delivery smoke-test control is gated by
  `SAKINAH_NOTIFICATION_QA_ENABLED=true`, ignored outside `dev`, and uses the
  real prayer reminder channel and `/prayer` tap payload.
- [x] Daily Session completion UX avoids social sharing and guaranteed outcome claims.
- [x] Local notification tap payloads avoid Women's Ibadah Mode exact status.
- [x] Resolved local notification taps navigate and clear the pending tap result.
- [x] Android cold-start local notification taps route prayer, session, Quran,
  and Dua payloads through the same safe resolver.
- [x] Privacy acceptance covers no GPS/location permission, manual or preset
  location, and local-first Women's Ibadah Mode data. Remote content requests
  exclude menstruating, postpartum, pregnancy, gender, and exact women-mode
  status fields.
- [x] Privacy docs are marked draft for legal/store review.
- [x] Store privacy label drafts exist.
- [x] No ads, tracking SDK, crash SDK, or default-on analytics collection is
  added.
- [x] Google Analytics-compatible event contract exists with event-name
  whitelist, sensitive-parameter filtering, Firebase Analytics integration, and
  default-off collection. Production telemetry still requires privacy/Data
  Safety review, Firebase project configuration, and user opt-in from Privacy
  Center. Privacy Center analytics consent changes are observable only as
  `analytics_consent_changed` with enabled state and `source=privacy_center`.
  Prayer reminder analytics is observable only with prayer scope, enabled
  state, controlled source such as `settings`, `home_prayer_card`,
  `prayer_page_card`, or `prayer_completion_card`, and lead-time offset; routes
  and exact reminder times are not sent.
  Notification Settings view analytics is observable only as
  `notification_settings_viewed` with screen, controlled source, and aggregate
  prayer-reminder enabled state.
  Prayer reminder permission analytics is observable only as
  `prayer_reminder_permission_result` with enabled result, controlled source,
  coarse outcome, and lead-time offset; routes, exact reminder times,
  coordinates, Women's Ibadah Mode status, and free text are not sent.
  Daily Session reminder permission analytics is observable only as
  `daily_session_reminder_permission_result` with session ID, enabled result,
  controlled source, and coarse outcome; exact reminder times, routes, Women's
  Ibadah Mode status, routine notes, and free text are not sent.
  Notification tap analytics is observable only as `notification_tap_opened`
  with coarse content type and `source=local_notification`.
  Daily Session reminder analytics is limited to enabled state, source, change
  type, and session ID; exact reminder time is not sent.
- [x] No exact GPS permission is added.
- [x] Onboarding offers preset prayer-location setup and states that GPS
  permission is not requested in v0.1.
- [x] No production CMS token is committed.
- [x] No Supabase service role key or production content token is committed;
  release tests scan tracked non-document text files for service-role config
  names and JWT-like secret payloads.
- [x] Home and bottom navigation are scoped to Home / Prayer / Session / Settings.
- [x] Home first screen explicitly labels the next-prayer context with prayer
  location, calculation method, and prayer reminder status in localized copy.
- [x] Home first screen previews the next local prayer reminder after reminders
  are enabled, using only on-device prayer calculation state and local clock
  display.
- [x] Home daily prayer companion acceptance is covered by prayer-first
  next-prayer context, Today's Sakinah Session, local progress, night save flow,
  optional saved continue rail, and widget tests that reject the Quran / Dua /
  Dhikr / Qibla tool-grid pattern on Home.
- [x] Client feature folders match PRD boundaries for `app`, `core`,
  `features`, `shared`, and `l10n`; MVP feature code stays under isolated
  `lib/features/*` folders with no direct cross-feature implementation imports.
- [x] Seed fallback covers release-critical offline content types: Home Daily
  Session, session steps, Dua, Dhikr, Quran ayah, reflection, source item, push
  template, and approved no-BGM Quran audio asset.
- [x] Prayer page exposes a localized all-day prayer-times section for Fajr,
  Dhuhr, Asr, Maghrib, and Isha.
- [x] Prayer page exposes a localized local-only prayer check-in checklist for
  Fajr, Dhuhr, Asr, Maghrib, and Isha, and Home summarizes today's completed
  count without account sync.
- [x] Prayer page shows a localized local-only complete state after all five
  daily prayer check-ins are marked on the same day.
- [x] Home exposes a localized local-only Prayer week summary with check-in
  days and streak, while analytics can only receive aggregate retention counts
  after the default-off Firebase gate and user opt-in.
- [x] Android build toolchain is pinned to Gradle 8.14+, AGP 8.11.1+, and Kotlin 2.2.20+.
- [x] No visible audio CTA is a no-op in the release path.
- [x] Android app module no longer applies the Kotlin Gradle Plugin directly.
- [x] `shared_preferences_android` is upgraded to a patch that no longer emits
  the Flutter Built-in Kotlin warning.
- [x] Android manifest enables the predictive back callback for Android 13+
  launch compatibility.
- [x] Android manifest declares local scheduled-notification receivers and
  reboot restore permission required by `flutter_local_notifications`.
- [ ] Flutter Built-in Kotlin warning remains for `audio_session` and
  `firebase_analytics` Android plugins until upstream Built-in Kotlin
  migrations are available through `just_audio` / Firebase Flutter packages.

## Release Assets

- [x] 27-screen Android phone matrix captured on
  `SC65XWPZ7DLNUSTC` at 1080 x 2374.
- [x] Android deterministic store-screenshot mode and single-screen capture
  script exist for Splash, Home, Prayer, Settings, Notification Settings,
  Manual Location, Privacy Center, onboarding, and optional Session route
  captures.
- [x] Android batch screenshot helper exists for the English, Indonesian, and
  Arabic store screenshot matrix.
- [x] Google Play title, short descriptions, full descriptions, and keywords
  have a prayer-first, policy-safe listing candidate.
- [x] Google Play feature graphic is generated at
  `build/store-assets/google-play-feature-graphic.png` and validated as
  1024 x 500, 24-bit PNG with no alpha.
- [ ] Final legal/store approval for title, subtitle, descriptions, and
  keywords.
- [x] App icon and splash assets reviewed on Android device
  `SC65XWPZ7DLNUSTC`; launcher icon resource dimensions pass local tests and
  splash capture evidence is
  `build/store-screenshots/android-assets/en-splash.png`.
- [ ] Privacy policy hosting URL selected before store submission.
- [ ] Final public privacy policy URL and Testing feedback channel pass
  `scripts/verify_google_play_public_links.sh` without
  `SAKINAH_SKIP_PUBLIC_LINK_NETWORK=true`.
- [x] Google Play public links hosting packet can be exported to
  `build/play-public-links` with
  `scripts/export_google_play_public_links_packet.sh`; it contains a static
  privacy policy page, optional feedback page, source privacy/data-safety
  drafts, public-links verifier, and manifest for final public hosting review.
- [x] Google Play public links hosting packet QA passes locally with
  `scripts/verify_google_play_public_links_packet.sh`.
- [x] Daily-prayer focused screenshots captured for Splash, Home, Prayer,
  Notification Settings, Manual Location, Privacy Center, and optional Session.
- [x] Google Play closed-testing launch pack exists at
  `docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md` with the Sakinah Daily Alpha
  Testers Google Group candidate, opt-in/store links for
  `com.sakinahdaily.app`, 12 opted-in testers / 14 continuous days operating
  notes, in-app Closed testing guide, copyable Day 1 / Day 3 / Day 7 /
  Day 14 feedback templates, local feedback-sent checklist, feedback-channel
  reminder, Chinese mutual-testing invitation copy, and a linked
  closed-testing evidence log.
- [x] Google Play closed-testing evidence log template exists at
  `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`; it tracks Day 0 through
  Day 14, aggregate opted-in tester counts, feedback reviewed, changes made,
  and Production access answer notes without tester personal data.
- [x] Play Console submission pack exists at
  `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md`; it ties together the
  Main store listing, App content declarations, Feature graphic, Phone
  screenshots, Data safety, Privacy policy, Closed testing release, release
  notes, tester links, and Production access evidence path.
- [x] Google Play upload evidence packet can be exported to
  `build/play-upload` with `scripts/export_google_play_upload_packet.sh`; the
  packet keeps local copies of the upload runbook, store metadata,
  privacy/data-safety drafts, Android manifest/build evidence, verifier
  scripts, feature graphic, screenshot evidence, checksum, and manifest for
  final pre-upload review.
- [x] Production access answer draft exists at
  `docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md`; it maps the closed test
  summary, intended users/value, aggregate feedback themes, changes made, and
  Production readiness evidence to Play Console answer-ready copy without
  tester personal data.
- [x] Production access evidence packet can be exported to
  `build/play-production-access` with
  `scripts/export_google_play_production_access_packet.sh`; the packet keeps
  local copies of the answer draft, evidence log, readiness checklist,
  privacy/data-safety drafts, verifier scripts, checksum, feature graphic, and
  manifest for final human review.
- [x] Closed-test launch day checklist exists at
  `docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md`; it documents the final
  tester-link share order, feedback privacy language, evidence paths, and
  external blockers before sending mutual-testing invites.
- [x] Closed-test retention observation packet can be exported to
  `build/play-retention-observation` with
  `scripts/export_google_play_closed_test_retention_packet.sh`; it includes
  daily observation, feedback theme, and Production access decision CSV
  templates for D1/D3/D7/D14 review without storing tester personal data.
- [ ] Google Group `sakinah-daily-testers@googlegroups.com` is created and
  bound to the Play Console closed-testing track.
- [ ] Play Console testing feedback channel is configured with the final
  feedback email or URL.

## Validation

- [x] `flutter pub get`
- [x] `flutter test`
- [x] `dart analyze`
- [x] `flutter build apk --debug`
- [ ] `SAKINAH_REQUIRE_RELEASE_SIGNING=true flutter build appbundle --release`
- [ ] `scripts/verify_google_play_internal_release.sh` succeeds with upload
  signing configured and produces `build/play-internal/app-release.aab.sha256`.
- [ ] `scripts/verify_google_play_upload_preflight.sh` succeeds with upload
  signing, `SAKINAH_PRIVACY_POLICY_URL`, `SAKINAH_PLAY_TESTING_FEEDBACK`,
  Google Group/closed-track confirmations, app-content/store-listing
  confirmations, and signed release artifacts ready for Play upload.
- [x] `scripts/export_google_play_upload_packet.sh` exports a template-mode
  Google Play upload evidence packet at `build/play-upload`.
- [x] `scripts/export_google_play_public_links_packet.sh` exports a
  template-mode Google Play public links hosting packet at
  `build/play-public-links`.
- [x] `scripts/verify_google_play_public_links_packet.sh` passes for the local
  public links hosting packet content and safe feedback-page shape.
- [x] `scripts/verify_google_play_closed_testing_evidence.sh` passes in
  template mode for the closed-testing evidence log.
- [x] `scripts/verify_google_play_submission_pack.sh` passes in template mode
  for the local Play Console submission pack.
- [x] `scripts/verify_google_play_production_access_pack.sh` passes in template
  mode for the local Production access answer pack.
- [x] `scripts/export_google_play_production_access_packet.sh` exports a
  template-mode Production access evidence packet at
  `build/play-production-access`.
- [x] `scripts/verify_google_play_closed_test_launch_day.sh` passes in template
  mode for the closed-test launch day gate, including local upload packet,
  public links packet QA, store assets, tester invite copy, and the rule to
  Share the Google Group link first.
- [x] Closed-test launch day gate: local template checks are green before
  tester links are shared.
- [x] `scripts/export_google_play_closed_test_retention_packet.sh` exports a
  template-mode closed-test retention observation packet at
  `build/play-retention-observation` for aggregate Day 1 / Day 3 / Day 7 /
  Day 14 feedback review, suggested theme-key grouping, and Production access
  answer preparation.
- [x] Home exposes the same Day 1 / Day 3 / Day 7 / Day 14 closed-test guide
  entry when the feedback channel is configured, keeping the retention feedback
  loop visible in the primary prayer habit path.
- [x] `scripts/export_reviewed_content_pack_readiness.sh` exports a
  template-mode Reviewed Content Pack readiness packet at
  `build/reviewed-content-pack-readiness` with seed counts, beta targets,
  source-placeholder review, audio rights/hash review, and strict-mode
  confirmation requirements.
- [x] `scripts/export_android_oem_reminder_observation_packet.sh` exports a
  template-mode Android OEM reminder observation packet at
  `build/android-oem-reminder-observation` with 8-hour, 24-hour, reboot
  restore, battery-policy, lock-screen-copy, no-tester-personal-data, and
  strict-mode confirmation templates.
- [x] `scripts/verify_google_play_store_assets.sh` passes for the feature
  graphic and local store visual assets.
- [x] `scripts/verify_local_e2e.sh` is available as the unattended local e2e
  wrapper for tests, analyzer, Play template gates, reviewed content readiness,
  Android OEM reminder observation, optional release gate, and Android launch
  smoke.
- [x] `.github/workflows/local-e2e.yml` provides the PR-facing CI wrapper for
  the local e2e gate with Node 24-compatible checkout.
- [ ] `SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true
  scripts/verify_google_play_closed_testing_evidence.sh` passes after the real
  14-day closed test and before Production access application submission.
- [ ] `SAKINAH_REQUIRE_PLAY_SUBMISSION_READY=true
  scripts/verify_google_play_submission_pack.sh` passes after the human Play
  Console app record, Main store listing, App content, Store settings,
  screenshots, Feature graphic, release notes, Closed testing release draft,
  public links, upload signing, Google Group, and closed-track binding are
  complete.
- [ ] `SAKINAH_REQUIRE_PLAY_UPLOAD_PACKET_READY=true
  scripts/export_google_play_upload_packet.sh` passes after upload signing,
  public privacy/feedback links, Play Console app-content/store-listing
  confirmations, Google Group, closed-track binding, signed AAB checksum, and
  strict visual assets are ready for final pre-upload review.
- [ ] `SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY=true
  scripts/export_google_play_public_links_packet.sh` passes after the reviewed
  privacy policy and feedback channel are hosted on real public HTTPS URLs and
  `scripts/verify_google_play_public_links.sh` passes without local network
  skipping.
- [ ] `SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY=true
  scripts/verify_google_play_production_access_pack.sh` passes after the real
  14-day closed test, aggregate feedback summary, changes summary, readiness
  evidence, and human answer review are complete.
- [ ] `SAKINAH_REQUIRE_PRODUCTION_ACCESS_PACKET_READY=true
  scripts/export_google_play_production_access_packet.sh` passes after the real
  closed-test evidence, Production access answer review, checksum, and visual
  evidence are ready for final human review.
- [ ] `SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY=true
  scripts/verify_google_play_closed_test_launch_day.sh` passes only after the
  Play Console app, Google Group, closed track, Testing feedback channel,
  reviewed upload packet, live closed-test release, and final tester-link copy
  are all confirmed.
- [ ] `SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY=true
  scripts/export_google_play_closed_test_retention_packet.sh` passes only after
  the closed-testing release is live, feedback channels are configured, the
  retention observation owner is assigned, the Day 1 / Day 3 / Day 7 /
  Day 14 review schedule is set, and the evidence log is ready for aggregate
  notes.
- [ ] `SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY=true
  scripts/export_reviewed_content_pack_readiness.sh` passes only after Quran
  source placeholders are replaced, the 5-7 session / 30-50 dua / 20-30 dhikr /
  10-20 Quran ayah beta pack is reviewed, licensed Quran audio rights and
  SHA-256 hashes are confirmed, and a human content owner signs off.
- [ ] `SAKINAH_REQUIRE_ANDROID_OEM_REMINDER_OBSERVATION_READY=true
  scripts/export_android_oem_reminder_observation_packet.sh` passes only after
  the Android OEM test device is confirmed, 8-hour and 24-hour prayer reminder
  delivery/tap routing are observed, reminder restore after reboot is observed,
  aggressive battery-management policy is reviewed, and a human observation
  owner signs off.
- [x] Android release appbundle native debug-symbol stripping is healthy after
  installing Android SDK cmdline-tools `latest` with `apkanalyzer`.
- [x] Unsigned Google Play release QA passes locally:
  `SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true scripts/verify_google_play_internal_release.sh`
  verifies `apkanalyzer` and `sdkmanager --licenses`, runs release readiness
  tests, `dart analyze`, builds the prod release
  `build/app/outputs/bundle/release/app-release.aab` at 57.0 MB, and writes
  `build/play-internal/app-release.aab.sha256` with SHA-256
  `46e6c74d3f1b484d4ecd6fa090cb9e23f98217eda40781248590b682c664ad60`.
  This artifact is build-path evidence only and is not uploadable to Play
  without upload signing.
- [x] Android licenses are fully accepted in the local SDK. `flutter doctor -v`
  now reports the Android toolchain as `[✓]` with "All Android licenses
  accepted." Final CI/upload machines should repeat the same check.
- [x] Internal release gate environment check passes locally with
  `SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true SAKINAH_RELEASE_SKIP_TESTS=true
  SAKINAH_RELEASE_SKIP_ANALYZE=true SAKINAH_RELEASE_SKIP_BUNDLE_BUILD=true
  scripts/verify_google_play_internal_release.sh`; it finds `apkanalyzer`,
  finds `sdkmanager`, and verifies all Android licenses are accepted.
- [ ] `flutter analyze` remains blocked in this Chinese-character workspace
  path by `LspByteStreamServerChannel._readMessage` / `FormatException:
  Unexpected end of input`; use `dart analyze` as the stable local gate until
  the Flutter analyzer issue is resolved.
- [x] Local Android release APK build succeeds with debug-signing fallback for
  QA when required signing is not enabled.
- [x] Local Android release APK installs and launches on `SC65XWPZ7DLNUSTC`.
- [x] Android launch smoke gate is scripted with
  `scripts/verify_android_launch_smoke.sh`; use `SAKINAH_ANDROID_SERIAL` for a
  specific device or `SAKINAH_ANDROID_EMULATOR_ID` to request a Flutter
  emulator before install/launch evidence capture.
- [x] Android launch smoke gate passes on real device `SC65XWPZ7DLNUSTC` with
  `SAKINAH_PLAY_TESTING_FEEDBACK` configured; evidence:
  `build/android-launch-smoke/SC65XWPZ7DLNUSTC-launch.png` and
  `build/android-launch-smoke/SC65XWPZ7DLNUSTC-manifest.txt`.
- [x] `SAKINAH_ANDROID_EMULATOR_ID=Medium_Phone_API_36.1
  SAKINAH_ANDROID_SKIP_BUILD=true scripts/verify_android_launch_smoke.sh`
  passes on `emulator-5554`; evidence:
  `build/android-launch-smoke/emulator-5554-launch.png` and
  `build/android-launch-smoke/emulator-5554-manifest.txt`.
- [x] After emulator smoke QA, the connected-device set returned to
  `SC65XWPZ7DLNUSTC`, macOS, and Chrome only.
- [x] Real device notification permission QA through dev-only smoke test on
  `SC65XWPZ7DLNUSTC`.
- [x] Real device dev-only local notification smoke delivery QA on
  `SC65XWPZ7DLNUSTC`.
- [x] Real device local prayer reminder delivery QA: dev QA build on
  `SC65XWPZ7DLNUSTC` delivered notification `id=298` on channel
  `sakinah_prayer_reminders` with body `It is time for Fajr prayer.`, and
  tapping it opened the Prayer tab.
- [ ] iOS cold-start notification tap QA after iOS runtime is available.

## Not Included In This Milestone

- Production signing keys.
- Provisioning profiles.
- App Store / Google Play submission.
- Analytics or crash SDK.
- Ads or tracking.
- Live CMS calls.
- GPS, compass, or sensor permissions.
- Remote saved-item sync.
- Full Quran corpus or licensed audio.
