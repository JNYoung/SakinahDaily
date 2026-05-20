# Agent Instructions for Sakinah Daily

This repository is for the Sakinah Daily MVP v0.1.

## Read before coding

Always inspect these files before implementing a task:

1. `README.md`
2. `docs/00_DOCS_INDEX.md`
3. `docs/codex/00_CODEX_CONTEXT.md`
4. `docs/codex/01_CODEX_MILESTONES.md`
5. The specific PRD related to the task.

## Product constraints

Do not implement these in MVP unless explicitly requested:

- AI fatwa or AI religious Q&A.
- AI Quran recitation correction.
- User-generated religious content.
- Public community, comments, or social feed.
- Ads.
- Complex paywall/subscription flow.
- Generic TTS for Arabic Quran recitation.
- Background music under Quran recitation.

## Religious-content rules

- Quran Arabic recitation must be modeled as an approved audio asset.
- Quran recitation must never have BGM underneath.
- Dua details must show source and review status.
- Content delivered by CMS must be `published` and `approved` before the client displays it.
- When a topic has school/regional differences, use neutral wording and source labels rather than absolute fatwa-style claims.

## Privacy rules

- Women’s Ibadah Mode is local-first by default.
- Do not upload menstruation/postpartum/pregnancy status unless there is an explicit future consent flow.
- Location should be used only for prayer time and Qibla calculation.
- Provide manual location fallback.

## Engineering standards

- Prefer small, testable milestones.
- Use typed models.
- Keep feature folders modular.
- Preserve Arabic RTL behavior.
- Run formatter, analyzer, and tests before summarizing work.
- If the repo has no Flutter app yet, initialize a clean Flutter project structure first.

## Preferred client stack

- Flutter + Dart
- Riverpod
- go_router
- Flutter l10n with ARB files
- just_audio
- flutter_local_notifications
- adhan_dart or equivalent prayer-time calculation package

## Preferred backend/CMS stack

- Supabase for Postgres/Auth/Storage/Edge Functions
- Directus for CMS editing/review/publishing
- FCM for server-triggered push later

## Delivery format for each task

When finishing a task, summarize:

1. What changed.
2. Files touched.
3. Commands run.
4. Tests/analyzer results.
5. Blockers or assumptions.
6. Suggested next milestone.
