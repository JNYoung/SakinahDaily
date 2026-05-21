# Sakinah Daily

Sakinah Daily is an Islamic daily calm app for Middle East and Indonesia users.
The MVP focuses on Quran listening, Dua, Dhikr, prayer reminders, and
privacy-first women's worship routines.

The product principle:

> Build a high-quality daily worship companion first, not a full Quran super-app
> and not a generic meditation app.

## Current Status

This repository contains the local MVP foundation:

- Flutter client structure with routing, Riverpod providers, theme tokens,
  localization, RTL support, onboarding, splash, home, prayer, daily session,
  Dua, Dhikr, settings, seed content, and analytics stubs.
- TypeScript `services/content-agent` foundation with deterministic draft
  generation and guardrail tests.
- Python `scripts/source_corpus` tooling for Quran source corpus parsing,
  merging, and validation.
- Documentation for PRD, design, architecture, content safety, CMS, client
  content cache, agent workflows, and next-step jobs.

## MVP Core Experience

After onboarding, the user enters Home:

1. See the next prayer countdown.
2. See Today's Sakinah Daily Session.
3. Start a 5-12 minute session.
4. Complete Intention -> Quran Audio -> Reflection -> Guided Dua -> Dhikr
   Counter -> Completion.
5. Browse Dua and Dhikr libraries, save content, configure push preferences, and
   use Women's Ibadah Mode.

## Safety Rules

- Quran Arabic recitation cannot use generic TTS.
- Quran recitation must never play over background music.
- Quran text and translations must be imported from approved sources, never
  generated.
- Dua, Dhikr, and Reflection content must display source, review status, or CMS
  publish status.
- Arabic UI must support RTL from the start.
- Women's Ibadah Mode is local-first privacy behavior, not a medical period
  tracker.
- MVP does not include AI fatwa, religious Q&A, community, UGC, ads, or complex
  paywalls.

## Docs Entry

| Document | Purpose |
|---|---|
| `docs/00_DOCS_INDEX.md` | Docs map and execution order |
| `docs/prd/01_PRODUCT_PRD.md` | Product PRD |
| `docs/prd/02_CLIENT_PRD.md` | Client PRD |
| `docs/prd/03_SERVER_PRD.md` | Server PRD |
| `docs/prd/04_CMS_PRD.md` | CMS PRD |
| `docs/prd/05_SCM_PRD.md` | SCM / repo / Codex collaboration PRD |
| `docs/design/01_DESIGN_SYSTEM.md` | Design system |
| `docs/design/02_SCREEN_SPECS.md` | Screen specs and wireframes |
| `docs/architecture/01_TECH_ARCHITECTURE.md` | Technical architecture |
| `docs/content/01_CONTENT_GUIDELINES.md` | Religious content safety |
| `docs/agent/01_CONTENT_AGENT_SERVICE_PRD.md` | Content Agent service PRD |
| `docs/client/01_CONTENT_DELIVERY_CACHE_STRATEGY.md` | Client cache strategy |
| `docs/jobs/2026-05-21_completed_work_and_next_steps.md` | Current completion and next jobs |
| `docs/codex/00_CODEX_CONTEXT.md` | Codex project context |
| `docs/codex/01_CODEX_MILESTONES.md` | Codex milestone prompts |
| `docs/testing/01_ACCEPTANCE_CHECKLIST.md` | MVP acceptance checklist |

## Local Setup

Flutter is required for the client:

```sh
flutter doctor
flutter pub get
flutter test
dart analyze
```

Content Agent service:

```sh
cd services/content-agent
npm install
npm test
npm run typecheck
```

Source corpus scripts:

```sh
python3 -m unittest discover -s scripts/source_corpus -p 'test_*.py'
```

## Codex Usage

Ask Codex to read:

```text
AGENTS.md
README.md
docs/00_DOCS_INDEX.md
docs/codex/00_CODEX_CONTEXT.md
docs/codex/01_CODEX_MILESTONES.md
```

Then execute one milestone at a time, review the diff, and continue.

## Notes

The repository intentionally does not include full Quran corpus files, licensed
audio, API secrets, or production CMS configuration.
