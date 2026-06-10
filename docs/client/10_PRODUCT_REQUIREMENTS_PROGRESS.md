# Product Requirements Progress — Prayer, Session, Quran, Dua

Status date: 2026-06-10
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
- Seed-reviewed minimum content only; staging CMS is not required for v0.1.
- Quran, Dua, Dhikr, Qibla, Saved Items, and Women’s Mode can remain as
  secondary/deep routes, but they are not Home or bottom-navigation surfaces.
- Licensed Quran audio and expanded content packs are post-baseline unless an
  audio CTA is visible and would otherwise be a no-op.

Current high-priority release work:

1. Real-device Android notification permission and delivery QA.
2. Debug/release Android build validation with Flutter available on PATH.
3. Store screenshots focused on Home, Prayer, Notification Settings, Manual
   Location, Privacy Center, Settings, and optional Session.
4. Production signing, version/build number, privacy policy URL, and final
   store metadata review.

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
- Home can show next prayer countdown from the active prayer settings.
- Settings exposes prayer method and notification toggle.
- Manual prayer location page saves label, latitude, longitude, optional
  timezone ID, and calculation method locally.
- Qibla uses the selected prayer location without GPS or sensor permissions.
- Local prayer reminder taps, including cold-start taps, route to `/prayer`.
- Women’s Mode notification copy avoids sensitive lock-screen state.

Open product links:

- Device-location permission flow is intentionally deferred for v0.1.
- Reminder control is intentionally broad for v0.1. Per-prayer enablement,
  lead-time offset, and quiet hours are P1 after release QA.
- Prayer page does not yet highlight the current/next prayer state beyond the
  Home countdown.
- Hijri date tuning, regional default presets, and polished live compass remain
  P1.
- Real-device permission and OEM scheduling QA remains open.

Suggested next milestone:

- Decide whether v0.1 requires device location. If yes, add explanatory
  permission UX plus manual fallback tests. If no, update PRD copy to make
  manual/preset location the release baseline.
- Add per-prayer reminder preferences only after permission QA is stable.

## 3. Daily Session Chain

Product status: MVP functional with a locally manageable completion reminder
loop; production content/audio depth remains incomplete.

Completed:

- Daily Session route supports Intention -> Quran -> Reflection -> Dua ->
  Dhikr -> Completion.
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
  session pack or staging CMS content.
- Licensed Quran reciter audio is not bundled; current seed audio metadata uses
  empty URL/hash placeholders.
- Offline audio cache validation, asset rights, and hash checks remain open.
- Analytics is still a local stub; product metrics cannot be measured yet.
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
- Quran verse detail route `/quran/:verseKey` displays Arabic, translation,
  source, and voice-only safety copy.
- Saved Quran verse references route back to verse detail.
- Local push/Quran notification taps, including cold-start taps, route to an
  available local verse before falling back to a session route.
- Quran UI keeps no-BGM and no-Quran-TTS rules visible.

Open product links:

- Full approved Quran corpus routing is not shipped.
- Seed Quran source labels still say “replace with approved Quran source before
  production”; this is not store-production content.
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

- Detail actions “Listen” and “Repeat slowly” are UI placeholders and do not
  play reviewed dua audio.
- Reviewed content depth is still seed-level; no staging CMS publishing flow is
  connected for expanded dua packs.
- Women’s Ibadah category curation remains limited to local policy notes rather
  than a reviewed content category.
- PRD categories such as Before sleep, Anxiety, Travel, Study / Work, Ramadan,
  and Women’s Ibadah still need reviewed content coverage before beta.

Suggested next milestone:

- Expand the reviewed Dua/Dhikr content pack now that discovery UX exists.
- Either wire reviewed dua audio controls or mark the audio CTAs as deferred in
  the release scope.

## 6. Product Readiness Summary

| Chain | Current release posture | Main blocker before beta/store |
|---|---|---|
| Prayer | v0.1 main release path | Real-device notification QA and build/signing gates |
| Daily Session | Optional secondary habit loop | Ensure no visible no-op audio CTA in release path |
| Quran | Secondary/deep route only | Not a v0.1 blocker unless release path exposes unsafe/no-op audio |
| Dua / Dhikr | Secondary/deep route only | Not a v0.1 blocker |

The strongest next product move is real-device prayer reminder QA and Android
release build preparation, not additional content or feature expansion.
