# Product Requirements Progress — Prayer, Session, Quran, Dua

Status date: 2026-05-31
Scope: product-side progress for the core worship chains and notification
cold-start routing.

Update: a local scheduled content-pack pipeline now exists in
`services/content-agent`. It can package approved local source records into the
client's generic manifest/bundle contract and serve them from local endpoints.
Beta mode intentionally blocks delivery until the reviewed content inventory
meets the 5-7 session, 30-50 dua, 20-30 dhikr, and 10-20 Quran ayah target with
source, review status, version, and reviewed date metadata.

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

Product status: v0.1 release baseline is device location with manual fallback;
beta usable after real-device permission QA.

Product decision:

- v0.1 should request device location for prayer time and Qibla setup.
- The request must be preceded by in-app explanatory copy.
- If location service or permission is denied, the app must keep manual
  location entry available and usable.
- Device location stays local in MVP and must not be used for background
  tracking, remote sync, analytics, or personalization.

Completed:

- Prayer page displays calculated Fajr, Dhuhr, Asr, Maghrib, and Isha times.
- Home can show next prayer countdown from the active prayer settings.
- Settings exposes prayer method and notification toggle.
- Onboarding and Settings > Prayer location now expose a device-location CTA
  with explanatory copy before requesting platform permission.
- Android declares foreground coarse location for prayer/Qibla setup and does
  not declare fine, background, foreground-service location, compass, or sensor
  permissions.
- Denied, blocked, disabled-service, and unavailable device-location results
  keep the manual location form as fallback.
- Manual prayer location page saves label, latitude, longitude, optional
  timezone ID, and calculation method locally.
- Qibla uses the selected prayer location without compass or sensor
  permissions.
- Local prayer reminder taps, including cold-start taps, route to `/prayer`.
- Women’s Mode notification copy avoids sensitive lock-screen state.

Open product links:

- Real-device Android QA is still required for allow, approximate/coarse,
  denied, denied-forever/system-settings, and location-services-off flows.
- iOS device-location QA is blocked until an iOS project/runtime is available;
  future iOS work must use When In Use copy and avoid Always/background
  location.
- Reminder control is still broad. There is no per-prayer enablement, lead-time
  offset, quiet hours, or separate daily reminder configuration.
- Prayer page does not yet highlight the current/next prayer state beyond the
  Home countdown.
- Hijri date tuning, regional default presets, and polished live compass remain
  P1.
- Real-device permission and OEM scheduling QA remains open.

Suggested next milestone:

- Run the real-device prayer-location QA checklist before beta sign-off.
- Add per-prayer reminder preferences only after permission/location QA is
  stable.

## 3. Daily Session Chain

Product status: MVP functional with a locally manageable completion reminder
loop; production content/audio depth remains incomplete.

Completed:

- Daily Session route supports Intention -> Quran -> Reflection -> Dua ->
  Dhikr -> Completion.
- The content-agent can generate and locally serve scheduled content bundles
  for additional approved sessions through the existing remote content contract.
- Session progress resumes locally and completion history/streak summaries are
  local-only.
- Completion page supports save session, open Saved Items, and set a local daily
  session reminder.
- Settings exposes Notification settings where the daily session reminder can be
  enabled, disabled, and rescheduled to a user-selected local time.
- Daily session reminders use privacy-safe lock-screen copy and local
  `daily_session` tap payloads that route back to the session.
- Quran step enforces no BGM and no Quran TTS.
- Dua step displays source and review status.
- Women’s Mode can show local, privacy-safe support notes.
- Local notification taps, including cold-start taps, can route to
  `/session/:id` when approved local content exists.

Open product links:

- There is only one seed session; a production beta needs a small reviewed
  session pack or staging CMS content. The beta content-pack generator now
  blocks until that approved inventory exists.
- Licensed Quran reciter audio is not bundled; current seed audio metadata uses
  empty URL/hash placeholders.
- Offline audio cache validation, asset rights, and hash checks remain open.
- Analytics is still a local stub; product metrics cannot be measured yet.
- Session history is intentionally small and lacks filters or richer insights.
- Reminder timing is user-selectable locally, but real-device notification
  permission/OEM scheduling QA remains open.

Suggested next milestone:

- Fill the approved content-pack source inventory so the beta generator can
  publish a 5-7 session pack through local manifest/bundle delivery.
- Add next-session suggestions only after reviewed session content breadth
  improves.
- Add licensed audio asset ingestion only after rights and hashes are approved.

## 4. Quran Chain

Product status: safe MVP entry; not production-complete for corpus/audio.

Completed:

- Quran entry page shows a featured approved local seed ayah.
- Quran verse detail route `/quran/:verseKey` displays Arabic, translation,
  source, and voice-only safety copy.
- Saved Quran verse references route back to verse detail.
- Local push/Quran notification taps, including cold-start taps, route to an
  available local verse before falling back to a session route.
- Quran UI keeps no-BGM and no-Quran-TTS rules visible.

Open product links:

- Full approved Quran corpus routing is not shipped.
- Seed Quran source labels still say “replace with approved Quran source before
  production”; beta content-pack generation blocks on those placeholder labels.
- No Surah/Juz browse, Quran search, or broader verse navigation exists.
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
- Dua save/unsave is local-only and cleared by Delete Local Data.
- Local notification taps, including cold-start taps, route to `/dua/:id` when
  approved local content exists.
- Dhikr seed items now carry category metadata.
- Dhikr page supports local category filters, search across title, Arabic,
  transliteration, localized meaning, source, and safe empty states while
  preserving the counter and save flow.

Open product links:

- Dua detail no longer exposes no-op audio CTAs; it shows a text-only state
  until reviewed dua audio assets are approved.
- Reviewed content depth is still seed-level, but local scheduled bundle
  generation/downfeed now exists for expanded approved dua/dhikr packs.
- Women’s Ibadah category curation remains limited to local policy notes rather
  than a reviewed content category.
- PRD categories such as Before sleep, Anxiety, Travel, Study / Work, Ramadan,
  and Women’s Ibadah still need reviewed content coverage before beta.

Suggested next milestone:

- Populate the reviewed Dua/Dhikr source inventory so beta content-pack
  generation reaches 30-50 duas and 20-30 dhikrs.
- Wire reviewed dua audio controls only after assets, rights, and hashes are
  approved.

## 6. Product Readiness Summary

| Chain | Current release posture | Main blocker before beta/store |
|---|---|---|
| Prayer | Device location baseline implemented with manual fallback | Real-device location/notification QA and per-prayer control |
| Daily Session | End-to-end seed flow and local manageable daily reminder | Reviewed session pack, real-device notification QA, licensed audio |
| Quran | Safe local verse entry works | Approved source corpus and licensed reciter assets |
| Dua / Dhikr | Local library/detail/save/search/category discovery works | Reviewed content depth, missing PRD categories, audio CTA decision |

The strongest next product move is to run real-device location and notification
QA while the content team fills the reviewed beta content inventory. Location is
now decided for v0.1; content breadth and licensed audio remain open release
scope decisions.
