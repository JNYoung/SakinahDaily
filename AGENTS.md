# Agent Instructions for Sakinah Daily

This repository is for the Sakinah Daily MVP v0.1. Treat religious content,
privacy, localization, and Arabic RTL as product-critical behavior.

## Read Before Coding

Always inspect these files before implementing a task:

1. `README.md`
2. `docs/00_DOCS_INDEX.md`
3. `docs/codex/00_CODEX_CONTEXT.md`
4. `docs/codex/01_CODEX_MILESTONES.md`
5. The specific PRD or job note related to the task.

## TDD Memory

- Default to TDD for feature work: add or update the failing test first, then
  implement the smallest change that makes it pass.
- Every new or changed feature must include a matching unit, widget, service,
  or corpus test.
- Changes touching navigation, localization, Arabic RTL, responsive layout,
  Quran/Dua/Dhikr display, push content, or women's mode privacy must update
  the relevant regression tests in the same change.
- Prefer user-visible behavior assertions over implementation details. Add
  stable `Key` values for important interactive controls when widget tests need
  reliable targeting.
- Keep tests fast and local by default. Do not add golden tests, live APIs, FCM
  sends, or network dependencies unless explicitly asked.

## Product Constraints

Do not implement these in MVP unless explicitly requested:

- AI fatwa or AI religious Q&A.
- AI Quran recitation correction.
- User-generated religious content.
- Public community, comments, or social feed.
- Ads.
- Complex paywall/subscription flow.
- Generic TTS for Arabic Quran recitation.
- Background music under Quran recitation.

## Religious-Content Rules

- Quran Arabic recitation must be modeled as an approved audio asset.
- Quran recitation must never have BGM underneath.
- Quran text and translations must come from approved sources, not generation.
- Dua details must show source and review status.
- Content delivered by CMS must be `published` and `approved` before the client
  displays it.
- When a topic has school or regional differences, use neutral wording and
  source labels rather than absolute fatwa-style claims.

## Privacy Rules

- Women's Ibadah Mode is local-first by default.
- Do not upload menstruation, postpartum, or pregnancy status unless there is an
  explicit future consent flow.
- Sensitive women's mode copy must not appear on lock-screen push text.
- Location should be used only for prayer time and Qibla calculation.
- Provide manual location fallback.

## Engineering Standards

- Prefer small, testable milestones.
- Use typed models.
- Keep feature folders modular.
- Preserve Arabic RTL behavior.
- Run formatter, analyzer, and tests before summarizing work.
- If the repo has no Flutter app yet, initialize a clean Flutter project
  structure first.

## Required Verification

- For Flutter/Dart changes, run `flutter test`.
- For Flutter/Dart code changes, also run `flutter analyze`.
- If `flutter analyze` crashes under the current Chinese-character workspace
  path, record the blocker and run `dart analyze` as the stable local gate.
- When an Android emulator is available, also run the Flutter app on Android
  after tests, using the connected emulator device such as `emulator-5554`, and
  report whether launch succeeds.
- For `services/content-agent`, run `npm test` and `npm run typecheck`.
- For `scripts/source_corpus`, run
  `python3 -m unittest discover -s scripts/source_corpus -p 'test_*.py'`.

## Preferred Client Stack

- Flutter + Dart
- Riverpod
- go_router
- Flutter l10n with ARB files
- just_audio
- flutter_local_notifications
- adhan_dart or equivalent prayer-time calculation package

## Preferred Backend/CMS Stack

- Supabase for Postgres/Auth/Storage/Edge Functions
- Directus for CMS editing/review/publishing
- FCM for server-triggered push later

## Delivery Format For Each Task

When finishing a task, summarize:

1. What changed.
2. Files touched.
3. Commands run.
4. Tests/analyzer results.
5. Blockers or assumptions.
6. Suggested next milestone.
