# Sakinah Daily Completed Work And Next Steps

Date: 2026-05-21
Workspace: `/Users/zhengjinyang/Documents/古兰经`

## Completed Work

- Flutter MVP foundation is in place with app routing, theme, Riverpod providers, l10n, RTL support, and feature folders for onboarding, home, daily session, dua, dhikr, prayer, settings, and women ibadah mode.
- Content safety and seed-content behavior are represented in Dart models, repositories, services, and regression tests.
- Content Agent Service materials and service implementation are present under `docs/agent`, `docs/cms`, `docs/content`, and `services/content-agent`.
- A TDD memory file exists at `AGENTS.md`; future feature work must start with failing or updated tests and report validation results.
- Widget/unit coverage now includes responsive layout, localization consistency, navigation flows, feature behavior, content service rules, push candidate rules, and the new splash screen.
- The settings secondary-page routing issue was fixed so returning from women ibadah mode keeps the selected bottom tab and visible page aligned.
- Indonesian and Arabic localization gaps were patched across the main onboarding, home, settings, dua, dhikr, prayer, and session surfaces.
- The supplied Sakinah Daily artwork has been implemented as a native Flutter splash screen at `/splash`, with an automatic transition into onboarding.
- Android native launch resources now use Sakinah static artwork and an Android 12+ Sakinah system splash icon, so the default Flutter template splash no longer flashes before the app splash.
- App launcher icon assets were generated from the Sakinah icon direction for Android, Web, and macOS, with a tracked source at `assets/branding/app_icon.png`.
- Branch `codex/prayer-prefs-notifications` adds real prayer settings, persistent user preferences, calculated prayer times, and a permission-aware local notification scheduling foundation.
- User preferences now persist through a repository abstraction backed by `shared_preferences`, with fake in-memory storage for tests.
- Prayer calculations now use `adhan_dart` for Fajr, Dhuhr, Asr, Maghrib, and Isha across Umm al-Qura, Muslim World League, Egyptian, and Indonesian/KEMENAG methods.
- Settings now exposes prayer method selection and a safe notification toggle; onboarding saves preferences before routing home, and the Prayer page displays calculated times from the active settings.
- Home vertical overscroll stretch/glow is disabled so pulling past the top or bottom no longer visually deforms the screen.
- Branch `codex/prayer-location-notification-ux` adds prayer location presets, optional timezone IDs, localized notification copy, notification permission explanation UX, denied/scheduled feedback, and awaited onboarding preference save.
- App-wide scroll behavior now disables vertical overscroll stretch/glow across Home, Prayer, Dua, Dhikr, Settings, Onboarding, Women's Mode, and Daily Session surfaces.
- Prayer now opens as an immersive pushed page without the bottom navigation bar, while preserving back navigation to Home.
- Branch `codex/local-push-tdd` adds a local push payload model, client-side receiver tests, and a deterministic local push simulator for previewing, queueing, and guardrail-testing push payloads without FCM/APNs.
- Branch `codex/audio-foundation-no-quran-bgm` adds the testable audio policy/player foundation, text-only fallback, and Daily Session Quran no-BGM enforcement without bundling licensed audio.
- Branch `codex/source-corpus-real-ingestion` adds manifest-driven local Quran source corpus ingestion, fixture-only parser/merge/lock tests, draft source item exports, and CMS import JSONL payload generation without live source downloads or full corpus commits.
- Branch `codex/client-content-cache-persistent` adds persistent manifest/bundle cache runtime tests, SharedPreferences-backed MVP cache storage, validated bundle activation, revocation handling, and fake detail-bundle recovery for local push deep links without live CMS calls.
- Branch `codex/cms-api-seed-fallback` adds a disabled-by-default remote content API config, provider-agnostic HTTP manifest client, fake HTTP test client, required bundle sync through existing cache validation, and local push detail-bundle recovery without live CMS calls or generated religious content.
- Branch `codex/content-agent-db-review-queue` adds repository-backed Content Agent runs, candidates, review packets, feedback events, QA re-runs, and CMS draft-only promotion using local deterministic tests with no live OpenAI, DB, CMS, or push sends.
- Branch `codex/client-privacy-store-readiness` adds the Settings Privacy Center, client data inventory, local data reset flow, sensitive remote-request guardrails, and draft store privacy documentation without analytics, crash SDKs, ads, tracking, or new third-party SDKs.
- Branch `codex/client-release-readiness` updates Android package identity to `com.sakinahdaily.app`, adds a dev/staging/prod Dart define config foundation, release-readiness tests, and draft store metadata/release checklists without production signing keys, analytics, crash SDKs, ads, tracking, or secrets.
- Branch `codex/client-notification-tap-qibla-saved` adds client-side notification tap route resolution, a Qibla page based on selected prayer location, and local-only Saved Items with Save Tonight, Dua, and Dhikr save/unsave behavior without GPS, compass permissions, remote sync, FCM/APNs, analytics, crash SDKs, ads, or generated religious content.
- Branch `codex/client-notification-router-quran-entry` adds app-level notification tap navigation cleanup, Quran entry/detail routes, saved Quran verse navigation, voice-only Quran policy UX, and a manual prayer location page without GPS, compass/sensor permissions, remote CMS calls, full Quran corpus downloads, Quran TTS, or generated religious content.
- Branch `codex/client-session-progress-history` adds local-only Daily Session resume progress, completion history, a completion screen, Home progress summary, and Delete Local Data cleanup without analytics, account sync, remote progress sync, social sharing, or generated religious content.
- Branch `codex/client-women-mode-content-filter` adds local-only Women's Mode recommendation policy, Home/Session support notes, privacy-safe notification and remote-request guardrails, and documentation without analytics, remote women status sync, medical advice, fatwa-like claims, or generated religious content.
- 2026-05-30 continuation adds cold-start notification launch payload handoff, Android emulator validation for prayer/session/Quran/Dua routes, and a product requirements progress document for those four chains.
- 2026-05-30 continuation adds local Dua/Dhikr category filters, search, Dhikr category metadata, safe empty states, and product research/progress updates for P0-C Discoverable Dua/Dhikr.
- 2026-05-30 continuation adds the Daily Session completion Set daily reminder CTA, local daily session reminder preference, privacy-safe local notification payload, and P0-D product progress updates.
- Branch `codex/session-reminder-time-settings` expands the Daily Session reminder from fixed 20:00 scheduling to a local user-selected time, adds Settings > Notification settings management, and lets users disable or reschedule the reminder without clearing prayer reminders.
- Branch `codex/audio-cta-truthfulness` marks Dua detail audio as text-only until reviewed audio assets are approved, removing no-op Listen/Repeat buttons while keeping Quran no-BGM/text fallback rules intact.
- Branch `codex/scheduled-content-pack-delivery` adds a local scheduled content-pack generator and read-only delivery endpoints for manifest, bundle, and detail-bundle testing. Dev mode can package current seed content for delivery proof; beta mode blocks until approved inventory reaches the reviewed 5-7 session, 30-50 dua, 20-30 dhikr, and 10-20 Quran ayah targets with source/version/reviewed date metadata.
- Branch `codex/prayer-device-location-baseline` locks Prayer v0.1 to device location with explanatory permission copy, Android foreground coarse location, manual fallback for denied/unavailable states, and a real-device QA checklist. It does not add fine/background location, compass, or sensor permissions.

## Current Validation Gate

- Primary app gate: `flutter test`
- Static analysis gate: `dart analyze`
- Android gate: launch the Flutter app on the connected emulator after app-level changes.
- Latest milestone validation on `codex/prayer-location-notification-ux`: `flutter test` passed with 51 tests, `dart analyze` passed with no issues, and `flutter run -d emulator-5554` built, installed, and launched successfully.
- `flutter analyze` was retried for this milestone and still crashes in Flutter's analysis server with `FormatException: Unexpected end of input` while handling the current Chinese-character workspace path; generated `flutter_*.log` crash files are ignored.
- Known note: `flutter analyze` may fail under the current Chinese-character workspace path because the Flutter analysis server crashes while parsing its protocol stream. Use `dart analyze` as the stable local gate unless the workspace path is moved or the Flutter toolchain issue is resolved.

## Recommended Next Jobs

1. Run the full verification gate after every app change: `flutter test`, `dart analyze`, and Android emulator launch.
2. Continue the UI refactor from the design outputs, starting with Home, Daily Session, Dua Detail, and Women Ibadah Mode.
3. Add visual or integration coverage only after the widget tests remain stable; keep TDD fast by default.
4. After approved local source files are placed under `data/source/raw/`, run source corpus manifest ingestion and review the generated lock file before committing any schema or seed payload decisions.
5. Connect the generic remote content API contract to a reviewed staging CMS only after endpoint auth, publishing workflow, and source-corpus approvals are finalized.
6. Implement a reviewed Supabase/Directus staging adapter for the Content Agent review queue only after RLS, service credentials, and CMS draft workflows are approved.
7. Next client milestone: automate store screenshots from deterministic seed content and run visual QA across English, Indonesian, and Arabic.
8. Next QA milestone: run real-device prayer-location permission QA, real device notification permission QA, and Android install/build checks with Flutter available on PATH.
9. Next store milestone: send store metadata, privacy labels, Google Play Data Safety, and permission copy for final legal/store review.
10. Next privacy milestone: decide whether analytics or crash reporting is needed after privacy review; do not add SDKs before that review.
11. Next push milestone: run real-device Android permission/OEM scheduling QA and iOS cold-start notification QA once an iOS runtime is available.
12. Next product milestone: content and audio scope remain open; Prayer location is now decided as v0.1 device location with manual fallback.
13. Next audio milestone: add reviewed licensed reciter assets and offline audio cache validation when asset rights and hashes are finalized.
14. Next content milestone: fill the approved content-pack source inventory so `CONTENT_PACK_PROFILE=beta npm run content-pack:generate` produces a deliverable manifest/bundle instead of an audit block.
15. Next habit-loop milestone: add next-session suggestions after reviewed session content breadth improves.

## Handoff Notes

- Do not commit secrets, production CMS config, full Quran corpus, or licensed audio.
- For Quran text, import and validate authorized source data; do not generate or rewrite Qur'an original text.
- Source corpus tests remain fixture-only: no live Tanzil/QuranEnc downloads, no generated Quran text, and no machine-generated translations.
- Client content cache tests remain fake/local only: no live CMS, no FCM/APNs, and no generated religious content.
- Privacy Center and store-readiness docs are implementation drafts, not legal final policy.
- Release readiness docs are submission preparation drafts; production signing, provisioning, and final store submission remain outside the repo.
- Women's mode privacy remains local-first, and sensitive content must not appear in lock-screen push text.
- Saved items remain local-only and must be cleared by Settings > Privacy > Delete local data.
- Qibla must continue to use the selected device/manual/preset prayer location and must not add compass/sensor behavior without a future permission review.
- Quran pages must continue to use approved local seed/cache content only until reviewed source corpus routing is expanded; do not add Quran TTS or background music under recitation.
- Daily Session progress/history must remain local-only, store IDs and timestamps rather than religious text, and be cleared by Delete Local Data.
- Women's Mode may influence local UI recommendations only; exact status must not leave the device, appear in lock-screen copy, or be used for medical or fatwa-like guidance.
- Prayer/session/Quran/Dua product progress and remaining release gaps are tracked in `docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md`.
