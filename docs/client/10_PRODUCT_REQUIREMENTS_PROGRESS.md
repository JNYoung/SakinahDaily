# Product Requirements Progress — Prayer, Session, Quran, Dua

Status date: 2026-06-11
Scope: product-side progress for the core worship chains and notification
cold-start routing.

## 0. Release Baseline Decision

Decision date: 2026-06-10.

v0.1 is now scoped as a daily prayer release, not a broad Quran/Dua/Dhikr
companion release. The main app path is Home -> Prayer -> Session -> Settings.

Release baseline:

- Manual/preset prayer location only; no GPS/location permission in v0.1.
- Local prayer reminders and local daily session reminders only; no production
  FCM/APNs.
- A dev-only notification smoke-test control can be enabled with
  `SAKINAH_NOTIFICATION_QA_ENABLED=true` for real-device permission, delivery,
  and tap-route QA. It is off by default and ignored outside `dev`.
- Seed-reviewed minimum content only; staging CMS is not required for v0.1.
- Quran, Dua, Dhikr, Qibla, Saved Items, and Women’s Mode can remain as
  secondary/deep routes, but they are not Home or bottom-navigation surfaces.
- Licensed Quran audio and expanded content packs are post-baseline unless an
  audio CTA is visible and would otherwise be a no-op.

Current high-priority release work:

1. Debug/release Android build validation with Flutter available on PATH.
2. Upload-key provisioning, version/build number, privacy policy URL, and final
   legal/store approval for the Google Play listing candidate.
3. Longer-window Android OEM scheduling observation for local reminders.
4. Reviewed content pack readiness packet strict mode after Quran source
   placeholders, beta session/dua/dhikr coverage, licensed Quran audio rights,
   and a human content owner are externally confirmed.

## 1. Cold-Start Notification Routing

Status: implemented and Android-emulator verified.

The app now consumes platform launch payloads from
`flutter_local_notifications` once on startup, resolves them through the same
safe `NotificationTapService` path used for warm notification taps, navigates,
and clears pending tap state so the route is not replayed.

Android QA evidence on `emulator-5554` with a dev debug APK:

| Payload type | Content ID | Expected route | Result |
|---|---|---|---|
| `prayer` | `prayer` | `/prayer` | Opened Prayer page |
| `daily_session` | `session_morning_ease` | `/session/session_morning_ease` | Opened Daily Session step 1 |
| `quran` | `94:5` | `/quran/94:5` | Opened Quran verse detail |
| `dua` | `dua_ease` | `/dua/dua_ease` | Opened Dua detail |

Local screenshot evidence was captured during QA at:

- `/tmp/sakinah-cold-prayer.png`
- `/tmp/sakinah-cold-session.png`
- `/tmp/sakinah-cold-quran.png`
- `/tmp/sakinah-cold-dua.png`

Remaining notification QA:

- iOS cold-start tap validation after an iOS project/runtime is available.
- Real-device Android permission behavior and OEM battery/background behavior.
- Future server-triggered FCM/APNs payload parity after push backend design.

## 2. Prayer Chain

Product status: v0.1 release baseline, pending real-device notification and
build QA.

Completed:

- Prayer page displays calculated Fajr, Dhuhr, Asr, Maghrib, and Isha times.
- Prayer page now labels the current prayer window and the next upcoming
  prayer in the daily list.
- Prayer page now gives the full-day list an explicit localized "Today's
  prayer times" heading, so users can recognize it as the all-day Fajr, Dhuhr,
  Asr, Maghrib, and Isha schedule rather than a loose utility list.
- Prayer page now includes a local-only "Today's prayer check-in" checklist for
  Fajr, Dhuhr, Asr, Maghrib, and Isha, and Home summarizes the completed count
  as "Prayers today" inside the local progress card.
- When all five daily prayers are checked in, Prayer shows a localized
  complete-state summary that confirms the five check-ins remain on device.
- The five-prayer complete state now offers a Start session CTA into Today's
  Sakinah session, carrying a privacy-safe `prayer_completion` source on the
  existing Daily Session start and completion events so the prayer-to-session
  loop can be observed without sending prayer names or timestamps.
- Home now shows a local-only "Prayer week" summary with recent check-in days
  and current prayer streak, helping users see a lightweight weekly habit loop
  without account sync or remote prayer history.
- Home can show next prayer countdown from the active prayer settings.
- Home's first-screen prayer card explicitly labels the selected prayer
  location, calculation method, and prayer reminder status in English,
  Indonesian, and Arabic, so users do not have to infer state from icons or
  short On/Off chips.
- Onboarding now includes a preset prayer-location step for Makkah, Riyadh,
  Jakarta, Dubai, and Cairo, with no GPS permission request in the v0.1
  baseline.
- Settings exposes prayer method and notification toggle.
- Notification Settings now exposes prayer reminder status and enable/disable
  control alongside the daily session reminder controls.
- Notification Settings now supports per-prayer reminder controls for Fajr,
  Dhuhr, Asr, Maghrib, and Isha; disabled prayers are excluded from local
  reminder scheduling.
- Notification Settings now supports prayer reminder lead-time offset controls
  for at prayer time, 5 minutes before, 10 minutes before, and 15 minutes
  before; local scheduling applies the selected offset to each selected prayer.
- Android evidence for per-prayer reminder controls:
  `build/store-screenshots/android-safety/en-notification-settings-per-prayer.png`.
- Notification Settings has an opt-in dev-only smoke-test button for scheduling
  a short-delay local notification during Android device QA.
- Manual prayer location page saves label, latitude, longitude, optional
  timezone ID, and calculation method locally.
- Qibla uses the selected prayer location without GPS or sensor permissions.
- Local prayer reminder taps, including cold-start taps, route to `/prayer`.
- Women’s Mode notification copy avoids sensitive lock-screen state.
- Android store screenshots now verify Home/Prayer current-next prayer labels,
  prayer check-ins, notification settings, manual location, privacy copy, and
  Arabic RTL layout across English, Bahasa Indonesia, and Arabic.
- Real-device short-delay prayer reminder QA on `SC65XWPZ7DLNUSTC` delivered
  through `sakinah_prayer_reminders` with the user-visible Fajr prayer copy, and
  tapping the notification opened the Prayer tab.

Open product links:

- Device-location permission flow is intentionally deferred for v0.1.
- Quiet hours are P1 after release QA.
- Hijri date tuning, regional default presets, and polished live compass remain
  P1.
- Longer-window OEM scheduling behavior remains open for observation, especially
  after reboot or aggressive battery-management states.

Suggested next milestone:

- Decide whether v0.1 requires device location. If yes, add explanatory
  permission UX plus manual fallback tests. If no, update PRD copy to make
  manual/preset location the release baseline.
- Add quiet hours only after longer-window Android OEM scheduling observation is
  stable.

## 3. Daily Session Chain

Product status: MVP functional with a locally manageable completion reminder
loop; production content/audio depth remains incomplete.

Completed:

- Daily Session route supports Intention -> Quran -> Reflection -> Dua ->
  Dhikr -> Completion.
- Session progress resumes locally and completion history/streak summaries are
  local-only.
- Reflection step now shows a localized no-fatwa note, making clear that the
  reflection is a gentle reminder rather than a religious ruling.
- Completion page supports save session, open Saved Items, and set a local daily
  session reminder.
- Completion-page and Settings daily session reminder changes now emit a
  privacy-safe `daily_session_reminder_changed` analytics event when analytics
  is enabled and the user opts in, so the session-to-reminder retention loop can
  be monitored without sending exact reminder time or sensitive mode data.
- Saved sessions can reappear on Home through the local continue rail, giving
  users a lightweight return path without social sharing, accounts, or remote
  saved-item sync.
- Home session card now surfaces the enabled daily session reminder time, so
  users can confirm their local habit loop without digging back into Settings.
- When today's session is already complete and the local daily session reminder
  is still off, Home now shows a Set daily reminder CTA that opens Notification
  settings, giving the completed-session path a clear next-day return loop.
  Reminder analytics preserves a controlled `home_session_completion` source
  when that CTA leads to reminder opt-in, so the Home retention prompt can be
  measured separately from ordinary Settings changes.
- Settings exposes Notification settings where the daily session reminder can be
  enabled, disabled, and rescheduled to a user-selected local time.
- Turning prayer reminders off no longer clears the local daily session reminder
  habit loop.
- Daily session reminders use privacy-safe lock-screen copy and local
  `daily_session` tap payloads that route back to the session.
- Quran step enforces no BGM and no Quran TTS.
- Dua step displays source and review status.
- Women’s Mode can show local, privacy-safe support notes.
- Local notification taps, including cold-start taps, can route to
  `/session/:id` when approved local content exists.

Open product links:

- There is only one seed session; a production beta needs a small reviewed
  session pack or staging CMS content.
- `scripts/export_reviewed_content_pack_readiness.sh` now exports a reviewed
  content pack readiness packet with current seed counts, beta targets,
  Quran source placeholder review, Quran audio rights/hash gaps, and a
  no-generated-religious-content checklist. Template mode is local evidence
  only; strict mode must wait for external source, reviewer, and rights
  confirmations.
- Licensed Quran reciter audio is not bundled; current seed audio metadata uses
  empty URL/hash placeholders.
- Offline audio cache validation, asset rights, and hash checks remain open.
- Analytics now has a Google Analytics-compatible event contract and
  default-off Firebase Analytics adapter for the onboarding, prayer/session,
  and closed-test feedback loops with an event whitelist and
  sensitive-parameter sanitizer. Daily Session step view analytics can show
  where users drop off by stable step ID and 1-based step index without sending
  Quran, Dua, Dhikr, reflection, translation, or free-text content. Product
  metrics still cannot be transmitted by default until a reviewed Firebase
  configuration, user opt-in, and Play Data Safety declaration are approved.
- Session history is intentionally small and lacks filters or richer insights.
- Reminder timing is user-selectable locally, but real-device notification
  permission/OEM scheduling QA remains open.

Suggested next milestone:

- Prepare a reviewed seed/session content pack before store or beta QA.
- Add next-session suggestions only after reviewed session content breadth
  improves.
- Add licensed audio asset ingestion only after rights and hashes are approved.

## 4. Quran Chain

Product status: safe MVP entry; not production-complete for corpus/audio.

Completed:

- Quran entry page shows a featured approved local seed ayah.
- Quran entry page now lists the approved local seed ayahs and supports local
  search by verse reference, Arabic text, translation text, or source label,
  without fetching or generating Quran content.
- Quran verse detail route `/quran/:verseKey` displays Arabic, translation,
  source, and voice-only safety copy.
- Quran verse detail supports previous/next navigation within the approved
  local seed ayah list only.
- Saved Quran verse references route back to verse detail.
- Local push/Quran notification taps, including cold-start taps, route to an
  available local verse before falling back to a session route.
- Quran UI keeps no-BGM and no-Quran-TTS rules visible.

Open product links:

- Full approved Quran corpus routing is not shipped.
- Seed Quran source labels still say “replace with approved Quran source before
  production”; this is not store-production content.
- The reviewed content pack readiness packet lists all current Quran source
  placeholders so the smallest approved Quran slice can be reviewed without
  generating Quran text.
- Surah/Juz browse and broader corpus navigation are not shipped; local search
  and previous/next navigation are limited to the current reviewed seed ayahs.
- Licensed reciter assets, offline audio cache, and hash validation are open.
- Tafsir and Quran Arabic TTS remain outside MVP.

Suggested next milestone:

- Promote an approved source-corpus lock and import the smallest reviewed
  Quran slice needed for beta sessions.
- Add corpus-aware missing-verse UX only after approved source routing exists.

## 5. Dua / Dhikr Discovery Chain

Product status: MVP functional for local seed discovery; audio/content depth
remains incomplete.

Completed:

- Dua library lists approved local seed duas.
- Dua library supports local category filters, search across Arabic,
  transliteration, localized meaning, source, and safe empty states.
- Dua detail shows Arabic, transliteration, localized meaning, source, and
  review status.
- Dua detail now marks audio as unavailable/text-only until reviewed audio
  assets are approved, instead of showing no-op audio actions.
- Dua save/unsave is local-only and cleared by Delete Local Data.
- Saved Dua and Dhikr items can surface on Home's local continue rail, making
  saved worship content easier to resume without adding a social or account
  surface.
- Local notification taps, including cold-start taps, route to `/dua/:id` when
  approved local content exists.
- Dhikr seed items now carry category metadata.
- Dhikr page supports local category filters, search across title, Arabic,
  transliteration, localized meaning, source, and safe empty states while
  preserving the counter and save flow.
- Settings exposes a localized Content Sources page that explains reviewed seed
  content, published + approved CMS filtering, non-generated religious content,
  Quran audio safety, and no AI fatwa or religious Q&A.

Open product links:

- Reviewed dua audio remains unavailable in v0.1; visible no-op audio CTAs have
  been removed in favor of text-only state copy.
- Reviewed content depth is still seed-level; no staging CMS publishing flow is
  connected for expanded dua packs.
- Women’s Ibadah category curation remains limited to local policy notes rather
  than a reviewed content category.
- PRD categories such as Before sleep, Anxiety, Travel, Study / Work, Ramadan,
  and Women’s Ibadah still need reviewed content coverage before beta.

Suggested next milestone:

- Expand the reviewed Dua/Dhikr content pack now that discovery UX exists.
- Add reviewed dua audio controls only after assets, rights, and hashes are
  approved.

## 6. Product Readiness Summary

| Chain | Current release posture | Main blocker before beta/store |
|---|---|---|
| Prayer | v0.1 main release path | Real-device notification QA and build/signing gates |
| Daily Session | Optional secondary habit loop | Reviewed content/audio depth can expand after release baseline |
| Quran | Secondary/deep route only | Not a v0.1 blocker unless release path exposes unsafe/no-op audio |
| Dua / Dhikr | Secondary/deep route only with source transparency | Not a v0.1 blocker |

The strongest next product move is real-device prayer reminder QA and Android
release build preparation, not additional content or feature expansion.

Retention observation preparation:

- North star: Weekly Active Prayer Reminder Users.
- Closed-test proxy signals remain aggregate-only by default because Firebase
  Analytics is disabled unless `SAKINAH_ANALYTICS_ENABLED=true` and Firebase
  project configuration are provided and the user opts in from Privacy Center:
  Prayer Reminder Opt-in Rate, D1 / D7 Retention, prayer view feedback,
  local prayer check-in usage count, reminder usefulness or annoyance, Daily
  Session start signal, and Privacy Center trust.
- A privacy-safe analytics event contract now covers onboarding, Home, Prayer,
  prayer reminder changes, aggregate prayer checklist updates, Daily Session
  start/step/completion, Daily Session reminder opt-in and setting changes,
  saved Dua/Dhikr actions, and closed-test prompt actions.
  Home view analytics includes only aggregate prayer retention counts such as
  today's completed count, 7-day check-in count, 7-day check-in days, and
  current check-in streak. It is default-off and strips coordinates, feedback
  text, religious text, exact prayer completion names/timestamps for checklist
  and Home retention events, and Women's Ibadah Mode exact status before the
  Firebase Analytics adapter can send events. Privacy Center now exposes the
  user analytics opt-in for analytics-enabled builds.
- `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md` and
  `scripts/export_google_play_closed_test_retention_packet.sh` prepare local
  Day 1 / Day 3 / Day 7 / Day 14 observation templates for Production access
  evidence without tester personal data.
- Home now exposes the in-app Closed testing guide when
  `SAKINAH_PLAY_TESTING_FEEDBACK` is configured, keeping Day 1 / Day 3 /
  Day 7 / Day 14 feedback prompts close to the daily prayer habit loop while
  analytics stays default-off and personal-data collection is avoided.
- Closed testing feedback templates now include suggested aggregate theme keys
  for onboarding clarity, prayer-loop trust, and retention reason-to-return, so
  Day 14 Production access summaries can be prepared without storing tester
  personal text.

Android release-signing preparation now supports ignored local
`android/key.properties` or CI `SAKINAH_UPLOAD_*` variables, plus
`SAKINAH_REQUIRE_RELEASE_SIGNING=true` to fail store builds when upload-key
config is missing. Actual upload-key creation and Play App Signing enrollment
remain external release tasks.

Local Android SDK readiness has also moved forward: `flutter doctor
--android-licenses` accepted the remaining local SDK licenses, and
`flutter doctor -v` now reports the Android toolchain as `[✓]` with all Android
licenses accepted. The internal release gate now also verifies `sdkmanager
--licenses`; CI or the final Play upload machine must repeat that check.

Google Play internal testing gate is now scripted at
`scripts/verify_google_play_internal_release.sh`. It fails closed without upload
signing, verifies Android cmdline-tools and accepted SDK licenses, runs the
release readiness test and `dart analyze`, builds a prod release `.aab`, and
writes a SHA-256 checksum for the generated bundle. Unsigned local dry-run mode
is available only through the explicit
`SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true` flag and is not uploadable to Play.

Local release-build evidence on 2026-06-10:

- `SAKINAH_REQUIRE_RELEASE_SIGNING=true flutter build appbundle --release`
  fails closed without upload-key config.
- `flutter build apk --release --dart-define=SAKINAH_APP_ENV=prod` succeeds
  with local debug-signing fallback for QA.
- The produced release APK installs and launches on Android device
  `SC65XWPZ7DLNUSTC`; screenshot:
  `/tmp/sakinah-release-qa/release-launch.png`.

Store screenshot preparation:

- Dev-only deterministic screenshot mode can force `en`, `id`, or `ar`, start
  on a whitelisted release route, seed local preferences in memory, and disable
  remote content.
- `scripts/capture_android_store_screenshot.sh` captures one Android screen at
  a time from a connected device into `build/store-screenshots/android/`.
- `scripts/capture_android_store_screenshots.sh` runs the full screenshot
  matrix and supports narrowing/resuming through `SAKINAH_SCREENSHOT_LOCALES`,
  `SAKINAH_SCREENSHOT_ROUTES`, and `SAKINAH_SCREENSHOT_SKIP_EXISTING`.
- Verified captures on `SC65XWPZ7DLNUSTC`: full 27-screen Android phone matrix
  in `build/store-screenshots/android/` at 1080 x 2374 for English, Bahasa
  Indonesia, and Arabic RTL across Splash / brand, onboarding, Home, Prayer,
  Settings, Notification Settings, Manual Prayer Location, Privacy Center, and
  Daily Session start.
- Quran safety screenshot evidence at
  `build/store-screenshots/android-safety/en-quran-94-5.png` verifies the Quran
  verse detail route shows voice-only / no-BGM / no-Quran-TTS copy without a
  background music affordance.
- Batch-script smoke capture evidence remains available at
  `build/store-screenshots/android-smoke/id-home.png`.

Android launch smoke preparation:

- `scripts/verify_android_launch_smoke.sh` now provides a repeatable Android
  launch smoke gate: build a dev debug APK, install it through `adb`, launch
  `com.sakinahdaily.app`, verify the process, and capture screenshot/manifest
  evidence in `build/android-launch-smoke`.
- The gate accepts `SAKINAH_ANDROID_SERIAL` for a specific connected device and
  `SAKINAH_ANDROID_EMULATOR_ID` when the local Flutter emulator should be
  launched first, reducing the gap between widget tests and real Android
  install/launch confidence.
- Real-device launch smoke on `SC65XWPZ7DLNUSTC` passes with
  `SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app`; evidence:
  `build/android-launch-smoke/SC65XWPZ7DLNUSTC-launch.png` and
  `build/android-launch-smoke/SC65XWPZ7DLNUSTC-manifest.txt`.
- Emulator launch smoke now also passes by launching `Medium_Phone_API_36.1`
  as `emulator-5554` with `SAKINAH_ANDROID_SKIP_BUILD=true`; evidence:
  `build/android-launch-smoke/emulator-5554-launch.png` and
  `build/android-launch-smoke/emulator-5554-manifest.txt`.

Google Play metadata preparation:

- `docs/release/04_STORE_METADATA_DRAFT.md` now contains a prayer-first Google
  Play listing candidate across English, Bahasa Indonesia, and Arabic, with
  short descriptions kept within the Play limit and guardrails against ads,
  tracking, GPS, AI fatwa, medical, religious-authority, or guaranteed-outcome
  claims.
- Final legal/store approval, privacy policy URL selection, and Play Console
  entry remain external release tasks.
