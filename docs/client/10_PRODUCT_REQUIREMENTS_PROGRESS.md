# Product Requirements Progress — Prayer, Session, Quran, Dua

Status date: 2026-06-13
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
3. Longer-window Android OEM scheduling observation for local reminders, using
   the Android OEM reminder observation packet before broad beta.
4. Reviewed content pack readiness packet strict mode after Quran source
   placeholders, beta session/dua/dhikr coverage, licensed Quran audio rights,
   and a human content owner are externally confirmed.

Push module completion audit: v0.1 local reminder loop is complete for the
client-side MVP. This means prayer reminders and Daily Session reminders have
local opt-in UX, explanatory permission copy, Android permission handling,
local scheduling/cancel paths, safe lock-screen copy, tap routing, cold-start
payload handling, Settings management, Home/Prayer direct prayer-reminder
opt-in, dev-only delivery smoke controls, and automated regression tests.
Remote FCM/APNs is outside v0.1 scope and should not be treated as completed
until a separate push backend, CMS payload review, consent/data-safety review,
and server-triggered delivery QA are designed.

Push/reminder analytics coverage for the completed local loop uses only the
existing privacy-safe events:

- `notification_settings_viewed` for reminder setup interest and entry source.
- `notification_permission_prompt_viewed` for privacy-safe reminder permission
  education prompt exposure, split only by reminder type and controlled source.
- `prayer_reminder_permission_result` for accepted, dismissed, denied, or
  empty-schedule prayer reminder attempts.
- `prayer_reminder_changed` for global, per-prayer, and lead-time reminder
  changes from Settings, Home, Prayer, or Prayer completion surfaces.
- `notification_schedule_result` for aggregate local scheduling health,
  including reminder type, controlled source, coarse result, enabled state,
  scheduled count, and prayer lead-time offset when relevant.
- `daily_session_reminder_permission_result` and
  `daily_session_reminder_changed` for the Daily Session return loop.
- `notification_tap_result` for coarse local notification tap outcome health,
  including opened, malformed-payload, missing-content, or unhandled results.
- `notification_tap_opened` for coarse successful local notification open rate.

The analytics contract intentionally excludes exact reminder times, raw
payloads, routes, coordinates, manual place labels, prayer completion
timestamps, Women's Ibadah Mode exact status, feedback text, and religious
text.

Push module completion audit packet: `scripts/export_push_module_completion_audit.sh`
now exports `build/push-module-completion-audit` with a feature completion
matrix, push analytics coverage matrix, privacy blocklist, and QA handoff. This
turns the v0.1 local reminder loop completion decision into a repeatable release
gate and keeps Remote FCM/APNs clearly marked as outside v0.1 scope until a
separate backend, CMS payload review, consent/data-safety review, and
server-triggered delivery QA are designed. Strict mode now requires completed
permission QA, real-device smoke, DebugView event review, and OEM owner
assignment CSV evidence before the manifest can show
`Strict push evidence inputs: validated`.

App launch and onboarding return loop: Splash now keeps first-time users on the
onboarding path, stores local onboarding completion when Continue is pressed,
and sends returning users with completed onboarding directly to Home after the
brand screen. Legacy saved preference records that predate the completion flag
count as completed onboarding, so existing testers are not forced back through
setup after an app update.

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
- Home's local progress card now offers a Continue/Review prayer check-in CTA
  back to the Prayer page, so the daily Home -> Prayer check-in loop is
  explicit even when users enter through Home rather than the bottom nav.
- When all five daily prayers are checked in, Prayer shows a localized
  complete-state summary that confirms the five check-ins remain on device.
- The five-prayer complete state now offers a Start session CTA into Today's
  Sakinah session, carrying a privacy-safe `prayer_completion` source on the
  existing Daily Session start and completion events so the prayer-to-session
  loop can be observed without sending prayer names or timestamps. If today's
  session is already complete, the same Prayer completion card changes to
  Review and opens the local completion page instead of restarting the session.
  When prayer reminders are still off, the same complete-state card also offers
  a Manage reminders CTA into Notification Settings with
  `source=prayer_completion_card`, so a full-day prayer completion moment can
  convert into reminder opt-in without sending prayer names, timestamps,
  routes, or Women's Ibadah Mode status.
- Home now shows a local-only "Prayer week" summary with recent check-in days
  and current prayer streak, helping users see a lightweight weekly habit loop
  without account sync or remote prayer history.
- Home can show next prayer countdown from the active prayer settings.
- Home's first-screen prayer card explicitly labels the selected prayer
  location, calculation method, and prayer reminder status in English,
  Indonesian, and Arabic, so users do not have to infer state from icons or
  short On/Off chips.
- When prayer reminders are enabled, Home's first-screen prayer card now also
  previews the next local prayer reminder with prayer name and local clock time,
  helping users trust the reminder loop without opening Settings or uploading
  exact reminder timing.
- When prayer reminders are off, Home's first-screen prayer card now enables
  local prayer reminders in place after the existing permission explanation,
  records `source=home_prayer_card`, and leaves the user on Home with a
  scheduled confirmation. Once reminders are on, the same Home surface becomes
  the Manage reminders path into Notification Settings.
- Onboarding now includes a preset prayer-location step for Makkah, Riyadh,
  Jakarta, Dubai, and Cairo, with no GPS permission request in the v0.1
  baseline.
- Settings exposes prayer method and notification toggle.
- Notification Settings now exposes prayer reminder status and enable/disable
  control alongside the daily session reminder controls.
- Prayer page Manage reminders opens Notification Settings with
  `source=prayer_page_card`, so reviewed DebugView QA can separate ordinary
  Prayer-page reminder opt-ins from Home-card, completion-card, and Settings
  changes without sending routes or prayer completion details.
- When prayer reminders are off, the Prayer page top reminder CTA now enables
  local prayer reminders in place after the existing permission explanation,
  records `source=prayer_page_card`, and leaves the user on Prayer with a
  scheduled confirmation so the reminder opt-in loop no longer requires a
  detour through Settings. Once reminders are on, the same surface becomes the
  Manage reminders path.
- Prayer page now also exposes a Qibla context action in the next-prayer card,
  opening `/qibla?source=prayer_page_card` so the prayer-time-to-direction
  loop is visible without turning Home into a generic tool grid.
- Prayer page's Change location action now opens manual prayer location setup
  with `source=prayer_page_card`, so testers can fix prayer location from the
  Prayer surface and reviewed DebugView QA can separate Prayer-page setup
  recovery from ordinary Settings changes without sending coordinates or place
  labels.
- Notification Settings now supports per-prayer reminder controls for Fajr,
  Dhuhr, Asr, Maghrib, and Isha; disabled prayers are excluded from local
  reminder scheduling.
- Notification Settings now supports prayer reminder lead-time offset controls
  for at prayer time, 5 minutes before, 10 minutes before, and 15 minutes
  before; local scheduling applies the selected offset to each selected prayer.
- Prayer reminder lead-time changes now record the same privacy-safe
  `prayer_reminder_changed` analytics event with `prayer_name=all`, current
  enabled state, controlled source, and coarse offset minutes only, so
  reviewed DebugView QA can see whether testers tune reminder timing without
  receiving exact reminder times.
- Notification Settings now summarizes selected prayer names and lead time in
  the enabled reminder status, so users can confirm the exact local reminder
  scope without opening each per-prayer control.
- Notification Settings now previews the next local prayer reminder with prayer
  name and local clock time after reminders are enabled, helping testers verify
  the habit loop without uploading reminder timing.
- Android evidence for per-prayer reminder controls:
  `build/store-screenshots/android-safety/en-notification-settings-per-prayer.png`.
- Notification Settings has an opt-in dev-only smoke-test button for scheduling
  a short-delay local notification during Android device QA.
- Manual prayer location page saves label, latitude, longitude, optional
  timezone ID, and calculation method locally.
- After a manual location save, the confirmation now offers View prayer times,
  taking the user straight back to Prayer so they can verify the updated local
  schedule without hunting through navigation.
- Settings prayer location preset changes, prayer calculation-method changes,
  and manual location saves now emit default-off, opt-in-gated
  `prayer_location_changed` analytics with only coarse location method,
  calculation method, controlled source, and coarse change type, so the
  prayer setup completion loop can be monitored without sending coordinates,
  manual place labels, timezone IDs, routes, Women's Ibadah Mode status, or
  free text.
- Qibla uses the selected prayer location without GPS or sensor permissions.
- Qibla's Change prayer location action now opens manual prayer location setup
  with `source=qibla_page`; after saving, the confirmation can return directly
  to Qibla so users can verify the updated direction without searching through
  navigation.
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
- `scripts/export_android_oem_reminder_observation_packet.sh` now exports an
  Android OEM reminder observation packet with 8-hour, 24-hour, reboot restore,
  battery-policy, privacy-safe notes, and strict-mode confirmation templates.
  Template mode does not claim delivery success; strict mode waits for real
  device observation and now validates completed long-window, reboot, and
  battery-policy evidence CSVs so placeholder rows cannot pass as observed
  reminder reliability.

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
- Completion-page, Home completed-session, and Settings daily session reminder
  changes now emit privacy-safe `daily_session_reminder_permission_result` and
  `daily_session_reminder_changed` analytics when analytics is enabled and the
  user opts in, so the session-to-reminder retention loop can be monitored
  without sending exact reminder time or sensitive mode data.
- Saved sessions can reappear on Home through the local continue rail, giving
  users a lightweight return path without social sharing, accounts, or remote
  saved-item sync.
- Home session card now surfaces the enabled daily session reminder time and a
  Manage daily reminder CTA back to Notification Settings, so users can confirm
  and adjust their local habit loop without hunting through Settings.
- When today's session is already complete and the local daily session reminder
  is still off, Home now shows a Set daily reminder CTA that enables the
  reminder in place after the existing permission explanation, giving the
  completed-session path a clear next-day return loop without a Settings
  detour. Reminder analytics preserves a controlled `home_session_completion`
  source for both the permission result and reminder-enabled event, so the Home
  retention prompt can be measured separately from ordinary Settings changes.
- Settings exposes Notification settings where the daily session reminder can be
  enabled, disabled, and rescheduled to a user-selected local time.
- Turning prayer reminders off no longer clears the local daily session reminder
  habit loop.
- Daily session reminders use privacy-safe lock-screen copy and local
  `daily_session` tap payloads that route back to the session.
- Local notification taps now emit default-off, opt-in-gated
  `notification_tap_result` analytics with only coarse content type,
  `source=local_notification`, and coarse tap outcome. Successful opens also
  emit `notification_tap_opened` with only coarse content type and source,
  allowing reviewed DebugView QA to observe Push Open Rate and tap failures
  without raw payloads, routes, content IDs, prayer names, women mode status,
  or religious text.
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
- Privacy Center now emits `analytics_consent_changed` with only enabled state
  and `source=privacy_center`, giving the Google Analytics DebugView QA packet
  a consent-funnel signal without tester identity, location, Women's Ibadah
  Mode status, feedback text, or religious content.
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
  prayer location/method setup, prayer reminder changes, aggregate prayer
  checklist updates, Daily Session start/step/completion, Daily Session
  reminder opt-in and setting changes, handled local notification opens,
  analytics consent changes, Dua detail/save actions, Dhikr counter
  start/completion actions, Women's Ibadah Mode enabled-state changes, and
  closed-test prompt actions.
  Prayer reminder analytics now carries only a controlled source such as
  `settings`, `home_prayer_card`, `prayer_page_card`, or
  `prayer_completion_card`, so Home-card, Prayer-page, and Prayer
  completion-card reminder opt-ins can be separated from ordinary Settings
  changes without sending routes, coordinates, exact reminder times, Women's
  Ibadah Mode status, or free text.
  Prayer checklist analytics now records only aggregate completion count,
  all-prayers-completed state, and `source=prayer_page_checklist`, so core
  check-in usage can be separated from future entry points without sending
  prayer names, completion timestamps, locations, Women's Ibadah Mode status,
  or free text.
  Prayer view analytics now carries only a controlled Home entry source such
  as `home_prayer_badge`, `home_prayer_card`, or `home_progress_card`, so
  Prayer-page interest can be separated by Home entry point without sending
  coordinates, session IDs, content IDs, Women's Ibadah Mode status, or free
  text.
  Notification Settings view analytics now records
  `notification_settings_viewed` once per page entry with only screen,
  controlled source, and aggregate prayer-reminder enabled state, so the
  reminder setup funnel can be observed before the opt-in event.
  Reminder permission prompt analytics now records
  `notification_permission_prompt_viewed` before prayer or Daily Session
  reminder explanation dialogs, with only reminder type and controlled source,
  so opt-in education exposure can be reviewed without sending routes,
  payloads, exact reminder times, locations, Women's Ibadah Mode status,
  lock-screen copy, feedback text, or religious text.
  Prayer reminder permission analytics now records
  `prayer_reminder_permission_result` with only enabled result, controlled
  source, coarse outcome, and lead-time offset, so permission denial or
  explanation dismissal can be diagnosed without sending routes, locations,
  exact reminder times, Women's Ibadah Mode status, or free text.
  Local reminder scheduling analytics now records
  `notification_schedule_result` for prayer and Daily Session reminders with
  only reminder type, enabled state, controlled source, coarse result,
  scheduled count, and prayer lead-time offset when relevant, so reviewed
  DebugView QA can verify push module health without payloads, routes, exact
  reminder times, prayer names, lock-screen body copy, locations, Women's
  Ibadah Mode status, or free text.
  Daily Session reminder permission analytics now records
  `daily_session_reminder_permission_result` with only session ID, enabled
  result, controlled source, and coarse outcome, so completion-to-reminder
  friction can be diagnosed without sending exact reminder times, routes,
  Women's Ibadah Mode status, routine notes, or free text.
  Home view analytics includes only aggregate prayer retention counts such as
  today's completed count, 7-day check-in count, 7-day check-in days, and
  current check-in streak. It is default-off and strips coordinates, feedback
  text, religious text, exact prayer completion names/timestamps for checklist
  and Home retention events, and Women's Ibadah Mode exact status before the
  Firebase Analytics adapter can send events. Privacy Center now exposes the
  user analytics opt-in for analytics-enabled builds.
  Home-card and Prayer-page reminder opt-in analytics use the existing
  `prayer_reminder_permission_result` and `prayer_reminder_changed` events with
  `source=home_prayer_card` or `source=prayer_page_card`, so direct Home and
  Prayer conversion can be reviewed without routes, exact reminder times,
  coordinates, or prayer completion details.
  Qibla view analytics now records only screen, route, coarse location method,
  calculation method, and controlled source such as `prayer_page_card`, so
  Qibla utility interest can be monitored without sending coordinates, place
  labels, or bearing degrees.
  Prayer location setup analytics now records only `prayer_location_changed`
  with coarse location method, calculation method, controlled source, and
  coarse change type, so manual/preset setup friction plus Prayer-page and
  Qibla-page recovery can be observed without sending coordinates, manual
  place labels, timezone IDs, routes, Women's Ibadah Mode status, or free text.
  Dua/Dhikr secondary-feature analytics keeps only content IDs and controlled
  sources, while Women's Ibadah Mode analytics keeps only enabled state and
  `source=women_mode`, so usage can be reviewed without transmitting exact
  status, health notes, Arabic text, translations, or free text.
- `docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md` and
  `scripts/export_google_play_closed_test_retention_packet.sh` prepare local
  Day 1 / Day 3 / Day 7 / Day 14 observation templates for Production access
  evidence without tester personal data. Completed evidence mode now requires
  filled aggregate daily observation, feedback theme, production decision, and
  Google Analytics DebugView retention-loop evidence CSVs with no template
  placeholders before the packet can be used as final Production access
  handoff evidence.
  `scripts/export_google_play_production_access_packet.sh` strict mode now
  requires that completed retention manifest before exporting the final Play
  Console handoff packet, so Production access evidence cannot silently fall
  back to Day 0 / Day 1 templates. The same strict export now verifies the
  current AAB checksum before copying upload evidence, so the final handoff
  cannot rely on stale local build evidence.
  The Day 0 / Day 1 operator packet now has its own completed-evidence mode:
  it requires aggregate status and Day 1 feedback CSVs through
  `SAKINAH_DAY0_DAY1_STATUS_EVIDENCE` and
  `SAKINAH_DAY1_FEEDBACK_EVIDENCE`, rejects `TBD`/template placeholder rows,
  and writes `Completed evidence inputs: validated` only after the first-share
  order, Day 1 review, DebugView decision, and evidence-log readiness are
  recorded without tester personal data.
- Home now exposes the in-app Closed testing guide when
  `SAKINAH_PLAY_TESTING_FEEDBACK` is configured, keeping Day 1 / Day 3 /
  Day 7 / Day 14 feedback prompts close to the daily prayer habit loop while
  analytics stays default-off and personal-data collection is avoided.
  The Home closed-testing card now highlights the next unsent Day 1 / Day 3 /
  Day 7 / Day 14 feedback prompt from local-only sent markers, so testers know
  which aggregate checkpoint to send next without storing feedback text.
- The Closed testing guide itself mirrors the same next-unsent feedback summary
  at the top of the page and switches to an all-sent state when Day 1 / Day 3 /
  Day 7 / Day 14 are locally marked complete, keeping the retention feedback
  loop understandable after testers enter Settings from Home.
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
  a time from a connected device into `build/store-screenshots/android/` and
  normalizes Android `screencap` output to RGB/no-alpha PNG.
- `scripts/capture_android_store_screenshots.sh` runs the full screenshot
  matrix and supports narrowing/resuming through `SAKINAH_SCREENSHOT_LOCALES`,
  `SAKINAH_SCREENSHOT_ROUTES`, and `SAKINAH_SCREENSHOT_SKIP_EXISTING`.
- Verified captures on `SC65XWPZ7DLNUSTC`: full 27-screen Android phone matrix
  in `build/store-screenshots/android/` at 1080 x 2374 for English, Bahasa
  Indonesia, and Arabic RTL across Splash / brand, onboarding, Home, Prayer,
  Settings, Notification Settings, Manual Prayer Location, Privacy Center, and
  Daily Session start.
- `scripts/verify_google_play_store_assets.sh` strict mode now verifies the
  expected 27 Android screenshot filenames plus PNG, RGB/no-alpha, Google Play
  image bounds, portrait phone orientation, and contact sheet presence before
  upload evidence can claim the visual matrix is ready.
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
- Android OEM reminder observation preparation now exports
  `build/android-oem-reminder-observation` with long-window reminder,
  reboot-restore, battery-policy, notification permission state,
  lock-screen-copy, and no-tester-personal-data templates for the next
  overnight/24-hour device QA pass. When `adb` and a device serial are
  available, the packet also includes a device environment snapshot with no
  personal data: Android version, model, package resolution,
  `POST_NOTIFICATIONS` appops/package state, and battery/device-idle context so
  the observation owner can compare OEM behavior. The packet also includes
  `adb_observation_commands.sh`, a
  package-filtered handoff script for package resolution, notification
  permission/appops, device-idle, alarm/notification, and crash-buffer capture
  around the long-window observation.

Google Play metadata preparation:

- `docs/release/04_STORE_METADATA_DRAFT.md` now contains a prayer-first Google
  Play listing candidate across English, Bahasa Indonesia, and Arabic, with
  short descriptions kept within the Play limit and guardrails against ads,
  tracking, GPS, AI fatwa, medical, religious-authority, or guaranteed-outcome
  claims.
- Final legal/store approval, privacy policy URL selection, and Play Console
  entry remain external release tasks.
