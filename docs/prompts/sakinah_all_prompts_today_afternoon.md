# Sakinah Daily — 今天下午所有项目执行 Prompts 汇总

说明：这里汇总的是今天下午为 Sakinah Daily 产出的 **Codex / Agent / 项目执行 prompts**，用于复制到 Codex、放进 repo，或交给团队执行。  
不包含任何 ChatGPT 内部系统指令或隐藏推理内容。

## 目录

1. 01 — Codex Kickoff Prompt + Milestone Prompt Sequence
2. 02 — MVP Plan Suggested First / Follow-up Codex Prompts
3. 03 — Repo Docs Codex Milestones File
4. 04 — Empty Repo Flutter Foundation Kickoff Variant
5. 05 — After Docs Patch First Codex Task
6. 06 — Home Screen Visual Implementation Prompt
7. 07 — Daily Push Content System Codex Prompt
8. 08 — Content Agent Service Codex Prompt
9. 09 — Content Agent Internal Prompt Pack
10. 10 — Source Corpus Ingestion Codex Prompt
11. 11 — Client Content Delivery & Cache Codex Prompt
12. 12 — Short Direct Prompt Variants from Chat

---


# 01 — Codex Kickoff Prompt + Milestone Prompt Sequence

# Sakinah Daily — Codex Import Package

Use this file to import the current ChatGPT planning context into Codex.

## How to use

1. Open Codex.
2. Select the target repository and branch.
3. Paste the **Kickoff Prompt** below into a new Codex task.
4. Add or commit this file and `sakinah_daily_mvp_codex_plan.md` into the repo under `/docs/` if possible.
5. Ask Codex to implement Milestone 1 only, then review the diff before continuing.

---

# Kickoff Prompt for Codex

You are Codex working on the Sakinah Daily MVP v0.1 repository.

Project context:
Sakinah Daily is an Islamic daily calm app for Middle East and Indonesia users. It combines Quran listening, Dua, Dhikr, prayer reminders, and gender-aware worship routines. The product should feel like a calm daily worship companion, not a generic meditation app and not a full Quran super-app.

Primary markets:
- Middle East: Arabic-first, RTL, conservative audio defaults, high trust expectations.
- Indonesia: Bahasa Indonesia-first, Android-friendly, Dzikir/Doa/Shalat localization, warm daily routine tone.

Core product principle:
Build the smallest polished daily worship companion. Do not build a huge feature bundle.

MVP user journey:
1. User opens app.
2. Chooses language: Arabic, Bahasa Indonesia, or English.
3. Chooses location manually or via device location for prayer times.
4. Chooses optional personalization: male, female, or prefer not to say.
5. Chooses audio preference.
6. Lands on Home.
7. Sees next prayer countdown and Today’s Sakinah Daily Session.
8. Starts a Daily Session.
9. Completes: Intention → Quran audio → Reflection → Guided Dua → Dhikr Counter → Completion.
10. Can browse Dua and Dhikr libraries.
11. Can configure notifications and Women’s Ibadah Mode in Settings.

Hard product rules:
- Never play background music under Quran recitation.
- Do not use generic TTS for Arabic Quran recitation.
- Quran audio must be modeled as approved/authorized audio assets.
- Dua details must show source and review status.
- Arabic UI must support RTL from day one.
- Women’s Ibadah Mode must be privacy-first and should not feel like a medical period tracker.
- Women’s mode data should default to local-only storage.
- Do not implement AI fatwa, AI religious Q&A, community posts, ads, or UGC religious content in MVP.
- Do not add a subscription/paywall in v0.1 unless explicitly requested later.

Preferred stack:
- Client: Flutter + Dart.
- State: Riverpod.
- Routing: go_router.
- Localization: Flutter l10n with ARB files.
- Audio: just_audio.
- Prayer times: adhan_dart or equivalent.
- Local notifications: flutter_local_notifications.
- Server push: Firebase Cloud Messaging later.
- Backend: Supabase Postgres/Auth/Storage/Edge Functions.
- CMS: Directus for content editing/review/publishing.

Design direction:
- Keywords: Sakinah, Noor, Calm, Sacred, Soft, Trustworthy.
- Main colors:
  - Deep Emerald: #0E3B2E
  - Midnight Navy: #101B2D
  - Sand Gold: #C9A45C
  - Ivory: #F7F2E8
  - Sage Green: #AABFA3
  - Warm Taupe: #B8A897
- UI should be spacious, quiet, and audio-first.
- Do not make women’s mode pink or overly medical.
- Use large Daily Session cards, calm audio controls, and clear content source chips.

P0 MVP modules:
1. Flutter foundation: app shell, routing, theme, l10n, RTL.
2. Models and seed content.
3. Reusable design components.
4. Onboarding flow.
5. Prayer times and local reminders.
6. Home screen.
7. Daily Session flow.
8. Dua Library and Dua Detail.
9. Dhikr list and counter.
10. Settings and Women’s Ibadah Mode.
11. CMS/API integration with seed fallback.
12. Analytics event stubs and QA checks.

P1 modules after beta:
- Ramadan plan.
- Offline audio downloads.
- More reciters.
- Full Qibla UI polish.
- Premium subscription.
- Advanced Women’s Ibadah routines.
- Cloud sync.

P2 / excluded from MVP:
- AI fatwa/Q&A.
- AI Quran recitation correction.
- Community/UGC.
- Ads.
- Full Quran + Tafsir system.
- Quran Arabic TTS.

Implementation behavior:
- Work in small milestones.
- Before coding, inspect the repository.
- If the repo is empty, create a new Flutter app foundation.
- If the repo already exists, adapt to its structure.
- Keep changes testable.
- Run formatter, analyzer, and tests after each milestone when possible.
- Summarize changes and follow-up tasks at the end.

Your first task:
Implement Milestone 1 only.

Milestone 1 goal:
Create/prepare the Flutter app foundation.

Acceptance criteria:
- Flutter app boots.
- `lib/main.dart` launches the app.
- App has `app/`, `core/`, `features/`, `shared/` structure or equivalent.
- Routing exists with at least `/onboarding` and `/home` routes.
- App theme includes the Sakinah color tokens.
- Localization has English, Bahasa Indonesia, and Arabic ARB files.
- Arabic locale uses RTL-friendly layout APIs.
- Placeholder Onboarding and Home pages exist.
- A minimal widget test proves the app can render.
- Formatter/analyzer/tests run or blockers are clearly explained.

Do not implement Daily Session, prayer calculations, notifications, CMS, or audio playback in Milestone 1.

---

# Milestone Prompt Sequence

Use these as separate Codex tasks after Milestone 1 is reviewed.

## Milestone 2 — Models and Seed Content

Implement typed domain models and seed content for Sakinah Daily.

Required models:
- DailySession
- DailySessionStep
- QuranAyah
- DuaItem
- DhikrItem
- ReflectionItem
- AudioAsset
- PrayerSettings
- UserPreferences
- WomenIbadahMode

Seed content requirements:
- At least 3 Daily Sessions.
- At least 8 Dua items.
- At least 5 Dhikr items.
- At least 3 Quran ayah metadata records.
- Include English, Bahasa Indonesia, and Arabic display fields where practical.
- Every religious content item must include source, reviewStatus, and status.
- Quran audio assets must include a flag that prevents background sound.

Acceptance criteria:
- Models are typed and serializable.
- Seed repository/service can return sessions, duas, dhikrs.
- Unit tests cover JSON parsing or model creation.

## Milestone 3 — Design Components

Build reusable UI components from the design system.

Components:
- PrimaryButton
- AppCard
- PrayerCountdownPill
- DailySessionCard
- AudioPlayerBar placeholder
- SourceChip
- DhikrCounterCircle
- SettingsTile
- LanguageAwareScaffold or equivalent wrapper

Acceptance criteria:
- Components are reusable and theme-driven.
- No hardcoded English in core reusable components unless passed as props.
- Components render in light and dark themes.
- At least basic widget tests or golden-ready structure exists.

## Milestone 4 — Onboarding

Implement onboarding flow.

Screens:
1. Welcome.
2. Language selection.
3. Location choice placeholder: use location / choose manually.
4. Personalization: male / female / prefer not to say.
5. Life support interests.
6. Audio preference.
7. First Daily Session CTA.

Acceptance criteria:
- Preferences are stored locally.
- Language change updates locale.
- Arabic screen direction works.
- Location permission is not requested before explanatory UI.
- Completion routes to Home.

## Milestone 5 — Home Screen

Implement Home dashboard.

Home content:
- Greeting.
- Hijri/Gregorian placeholder or simple date.
- Next prayer countdown placeholder until prayer service is ready.
- Today’s Sakinah Daily Session card.
- Quick actions: Quran, Dua, Dhikr, Qibla.
- Tonight recommendation.

Acceptance criteria:
- Home uses seed DailySession.
- Quick actions navigate to placeholder routes if target is not implemented.
- Design matches calm, spacious direction.

## Milestone 6 — Prayer Times and Local Notifications

Implement prayer-time service and local notification scheduling.

Requirements:
- Prayer calculation service using adhan_dart or equivalent.
- Manual location support with latitude/longitude.
- Prayer method stored in settings.
- Next prayer countdown.
- Local reminder scheduling via flutter_local_notifications.
- Notification permission requested only after user intent/value screen.

Acceptance criteria:
- Prayer times render on Home/Prayer screen.
- Next prayer updates correctly.
- Local notifications can be scheduled/cancelled.
- Tests cover next-prayer calculation logic where feasible.

## Milestone 7 — Daily Session Flow

Implement the core Daily Session experience.

Steps:
1. Intention selection.
2. Quran listening step with no-BGM guard.
3. Reflection step.
4. Guided Dua step.
5. Dhikr counter step.
6. Completion screen.

Acceptance criteria:
- User can complete a full seed Daily Session.
- Step progress is visible.
- Quran step shows Arabic, translation, reciter/source metadata.
- Dua step shows Arabic, transliteration, translation, and source.
- Dhikr counter supports tap count and target completion.
- Completion records local progress event.

## Milestone 8 — Dua and Dhikr Library

Implement Dua and Dhikr browsing.

Requirements:
- Dua category list.
- Dua detail page.
- Favorite/save Dua locally.
- Dhikr list.
- Dhikr detail/counter.

Acceptance criteria:
- Dua detail always shows source/review status.
- Search/filter can be simple category filtering in MVP.
- Saved state persists locally.

## Milestone 9 — Settings and Women’s Ibadah Mode

Implement Settings and privacy-first Women’s Ibadah Mode.

Settings:
- Language.
- Prayer method.
- Audio preferences.
- Notification preferences.
- Privacy.
- Women’s Ibadah Mode.

Women’s Mode states:
- Normal.
- Menstruating.
- Postpartum.
- Pregnancy.
- Prefer not to track.

Acceptance criteria:
- Women’s mode data is local by default.
- UI wording is respectful and non-medical.
- App can adapt reminders/content labels when mode is menstruating/postpartum.
- User can disable/clear Women’s Mode data.

## Milestone 10 — CMS/API Integration

Implement content API abstraction and CMS integration.

Requirements:
- ContentRepository interface.
- SeedContentRepository fallback.
- RemoteContentRepository for Supabase/Directus API.
- Only fetch published + approved content.
- Audio asset metadata loaded from remote source.

Acceptance criteria:
- App works offline/without CMS using seed data.
- Remote repository can be configured by environment variables.
- Invalid/unapproved content is filtered out.
- Tests cover repository fallback behavior.

## Milestone 11 — Analytics and QA

Implement analytics stubs and QA checklist.

Events:
- onboarding_started
- onboarding_completed
- daily_session_started
- daily_session_step_completed
- daily_session_completed
- dua_viewed
- dua_saved
- dhikr_started
- dhikr_completed
- prayer_notification_enabled
- women_ibadah_mode_updated

Acceptance criteria:
- Analytics interface can be swapped for Firebase/Amplitude.
- No sensitive Women’s Mode details are logged by default.
- QA checklist exists under `/docs/qa_mvp_checklist.md`.

---

---

# 02 — MVP Plan Suggested First / Follow-up Codex Prompts

## 15. Suggested First Codex Prompt

```text
You are working on Sakinah Daily MVP v0.1. Inspect the repository and implement Milestone 1 from /mnt/data/sakinah_daily_mvp_codex_plan.md or the project plan provided in this prompt.

Goal for this task:
- Create/prepare the Flutter app foundation.
- Add routing, theme, l10n for English/Indonesian/Arabic, and the recommended folder structure.
- Add placeholder Home route and Onboarding route.
- Use directional layout APIs so Arabic RTL can work.
- Add a minimal test proving the app boots.

Do not implement Daily Session, CMS, notifications, or prayer times yet. After implementation, run formatter, analyzer, and tests. Summarize changes and any follow-up tasks.
```

## 16. Suggested Follow-up Codex Prompts

### Prompt 2 — Models and Seed Content

```text
Implement Milestone 2: typed models, local seed JSON, and local repositories for Sakinah Daily. Create models for DailySession, SessionStep, QuranAyah, DuaItem, DhikrItem, Reflection, AudioAsset, PrayerSettings, GenderMode, AudioPreference, and NotificationTemplate. Add seed content in en/id/ar sufficient to populate Home, Daily Session, Dua, and Dhikr screens. Add tests for JSON parsing and repository loading.
```

### Prompt 3 — Design Components

```text
Implement Milestone 3: design tokens and reusable UI components. Use the colors, spacing, radius, and dark-mode tokens from the MVP plan. Build PrimaryButton, AppCard, PrayerCountdownPill, DailySessionCard, AudioPlayerBar placeholder, SourceChip, DhikrCounterCircle, and SettingsTile. Ensure components support RTL via directional APIs. Add widget tests for at least two components.
```

### Prompt 4 — Onboarding and Home

```text
Implement Milestones 4 and 6: onboarding flow and Home screen. Onboarding should collect language, location choice/manual fallback, gender mode, support/mood, and audio preference, then persist preferences locally and route to Home. Home should show greeting, next prayer placeholder/countdown area, Today’s Sakinah card, quick actions, and tonight recommendation. Use local seed content.
```

### Prompt 5 — Prayer and Notifications

```text
Implement Milestone 5: prayer-time service and local notification scheduling. Use adhan_dart or an equivalent package. Support manual coordinates and prayer calculation settings. Add a notification service using flutter_local_notifications, with permission requested only after onboarding or after the user enables reminders. Add tests for prayer settings and scheduling logic where practical.
```

### Prompt 6 — Daily Session

```text
Implement Milestone 7: Daily Session flow. Build intention, Quran listening, reflection, guided dua, dhikr counter, and completion screens. Use just_audio for audio assets where available and graceful text fallback where missing. Enforce Quran audio policy: no background sound under Quran recitation. Track session_started and session_completed through the analytics service interface.
```

### Prompt 7 — Dua, Dhikr, Settings, Women’s Mode

```text
Implement Milestones 8 and 9: Dua library/detail, Dhikr list/counter, Settings, and Women’s Ibadah Mode. Dua detail must show Arabic text, transliteration, translation, source, and review status. Women’s Mode must be local-only by default, optional, and disable-able. Adjust gentle reminder copy when Women’s Mode is active.
```

### Prompt 8 — CMS/API Integration

```text
Implement Milestone 10: remote content integration. Add environment-based Directus/Supabase configuration, implement a remote content source for published content, and preserve local seed fallback. Do not commit secrets. Add basic error handling and loading states.
```

---

---

# 03 — Repo Docs Codex Milestones File

# Codex Milestones — MVP v0.1

Use one milestone per Codex task. Do not implement multiple milestones in one PR.

---

## M01 — Flutter Foundation

### Goal

Initialize/prepare the Flutter app foundation.

### Scope

- Flutter app structure.
- Routing with go_router.
- Theme tokens.
- l10n foundation for English, Bahasa Indonesia, Arabic.
- RTL support.
- Placeholder Onboarding and Home routes.
- Basic test proving app boots.

### Do not implement

- Prayer times.
- CMS.
- Audio playback.
- Daily Session logic.
- Notifications.

### Acceptance

- App launches.
- `/onboarding` and `/home` work.
- Locale can be structurally supported.
- Arabic directionality is accounted for.
- `flutter analyze` and `flutter test` pass if Flutter is available.

### Prompt

```text
Read AGENTS.md, README.md, docs/codex/00_CODEX_CONTEXT.md, and docs/prd/02_CLIENT_PRD.md.
Implement M01 — Flutter Foundation only.
Do not implement prayer times, CMS, audio playback, notifications, or Daily Session logic.
Run formatter, analyzer, and tests if possible. Summarize changes and blockers.
```

---

## M02 — Models & Seed Content

### Goal

Create typed models and local seed content for MVP.

### Scope

- AudioAsset, QuranAyah, DuaItem, DhikrItem, Reflection, DailySession, DailySessionStep, UserPreferences.
- Seed repository.
- At least one complete Daily Session.
- At least 5 Dua items and 5 Dhikr items.

### Do not implement

- CMS API.
- Remote sync.
- Real licensed audio.

### Acceptance

- Models parse from JSON.
- Seed content loads.
- Published + approved flags exist.
- Quran audio model has `bgmAllowed=false`.

---

## M03 — Design System Components

### Goal

Build reusable UI components.

### Scope

- PrimaryButton.
- AppCard.
- PrayerCountdownPill.
- DailySessionCard.
- SourceChip.
- AudioPlayerBar placeholder.
- DhikrCounterCircle.
- SettingsTile.

### Acceptance

- Components support light/dark.
- Components are RTL-safe.
- Home can render with components.

---

## M04 — Onboarding

### Goal

Implement onboarding flow.

### Scope

- Welcome.
- Language selection.
- Location setup placeholder/manual option.
- Gender mode.
- Audio preference.
- Persist preferences locally.

### Acceptance

- User can complete onboarding and reach Home.
- Arabic selection changes RTL.
- Gender is optional.
- Location permission not requested before explanatory copy.

---

## M05 — Prayer Times & Local Notifications

### Goal

Implement prayer-time calculation and local reminders.

### Scope

- PrayerCalculationService.
- Manual location support.
- Calculation method setting placeholder/preset.
- PrayerScreen.
- Local notification scheduling.

### Acceptance

- Next prayer appears on Home.
- Notifications can be toggled.
- Denied permission does not break App.

---

## M06 — Home Screen

### Goal

Implement Home dashboard.

### Scope

- Greeting.
- Date area.
- Next prayer countdown.
- Today’s Sakinah card.
- Quick actions.
- Tonight suggestion.

### Acceptance

- Home renders from seed data.
- Home handles no-location state.
- Home is quiet, not crowded.

---

## M07 — Daily Session Flow

### Goal

Implement core Daily Session experience.

### Scope

- Intention step.
- Quran listening step with audio placeholder/player.
- Reflection step.
- Guided Dua step.
- Dhikr counter step.
- Completion step.

### Acceptance

- User can complete session end-to-end.
- Quran step cannot enable BGM.
- Dua step shows source/review status.
- Completion event is saved locally.

---

## M08 — Dua & Dhikr Library

### Goal

Implement Dua and Dhikr browsing.

### Scope

- Dua categories.
- Dua detail.
- Favorite/save.
- Dhikr list.
- Dhikr counter.

### Acceptance

- Dua detail shows Arabic/transliteration/translation/source/review.
- Dhikr counter supports target count.
- Saved items persist locally.

---

## M09 — Settings & Women’s Ibadah Mode

### Goal

Implement settings and women mode.

### Scope

- Language.
- Region/location.
- Prayer method.
- Audio preferences.
- Notifications.
- Privacy.
- Women’s Ibadah Mode.

### Acceptance

- Women’s mode saves locally.
- Women’s mode copy is respectful.
- Sensitive women mode data is not sent remotely.

---

## M10 — CMS/API Integration

### Goal

Connect client to CMS/Supabase content API with seed fallback.

### Scope

- ContentRepository abstraction.
- CmsContentRepository.
- Seed fallback.
- Published + approved validation.

### Acceptance

- App works without CMS.
- App loads CMS content when configured.
- Draft/in_review content is filtered out.

---

## M11 — Analytics & QA

### Goal

Add analytics interface and QA checklist hooks.

### Scope

- AnalyticsService interface.
- Stub implementation.
- Core events.
- Widget tests for major screens.

### Acceptance

- Events can be called without vendor lock-in.
- Tests cover Home, Onboarding, Dua detail, Daily Session happy path.

---

# 04 — Empty Repo Flutter Foundation Kickoff Variant

```text
This repo is for Sakinah Daily, a Quran / Dua / Dhikr / Prayer Calm MVP app for Middle East and Indonesia.

Create the Flutter MVP foundation only.

Implement Milestone 1:
- Initialize a Flutter app structure if the repo is empty.
- Add app routing.
- Add light/dark theme tokens.
- Add localization foundation for English, Bahasa Indonesia, and Arabic.
- Ensure Arabic RTL can work.
- Add placeholder routes for Onboarding and Home.
- Add recommended folders:
  lib/app
  lib/core
  lib/features/onboarding
  lib/features/home
  lib/features/prayer
  lib/features/daily_session
  lib/features/dua
  lib/features/dhikr
  lib/features/settings
  lib/shared
  assets/audio
  assets/images
  docs

Do not implement prayer times, notifications, audio playback, CMS, or Daily Session logic yet.

After implementation, run formatter, analyzer, and tests if available. Summarize the changes and blockers.
```

---

# 05 — After Docs Patch First Codex Task

```text
Read AGENTS.md, README.md, docs/00_DOCS_INDEX.md, docs/codex/00_CODEX_CONTEXT.md, and docs/codex/01_CODEX_MILESTONES.md.

Implement M01 — Flutter Foundation only.

Do not implement prayer times, CMS, audio playback, notifications, or Daily Session logic.

Run formatter, analyzer, and tests if possible. Summarize changes and blockers.
```

---

# 06 — Home Screen Visual Implementation Prompt

```text
Read docs/design/mockups and docs/design/01_DESIGN_SYSTEM.md.

Implement the Flutter visual foundation for the Home screen based on:
- 01_home_light_en.png
- 06_home_screen_design_spec.png

Scope:
- Build HomeScreen layout only.
- Create reusable widgets:
  PrayerCountdownPill
  DailySessionCard
  QuickActionGrid
  TonightRecommendationCard
  BottomNavShell

Do not implement real prayer calculation, CMS, audio playback, or notifications yet.
Use placeholder data.
Support light/dark theme tokens and RTL-safe layout APIs.
Run formatter, analyzer, and tests if possible.
```

---

# 07 — Daily Push Content System Codex Prompt

# Codex Prompt — Daily Push Content System

Read:
- docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md
- docs/content/daily_push_seed_content.csv
- docs/cms/02_PUSH_CONTENT_SCHEMA.sql

Implement only the MVP data/content foundation for Daily Push Content.

Scope:
1. Add Dart/Flutter models:
   - SourceItem
   - SourceItemTranslation
   - ContentCluster
   - PushTemplate
   - PushCandidate
   - PushPreference
2. Add seed JSON converted from `daily_push_seed_content.csv`.
3. Add repository/service layer that can:
   - load source items
   - load push templates
   - filter by language
   - filter by ritual moment
   - filter by published/approved status
   - apply simple cooldown rules
4. Add tests for:
   - no unapproved content returned
   - language fallback works
   - women_ibadah_mode does not return cycle-sensitive lock-screen copy
   - same cluster cooldown blocks recent repeated pushes
5. Do not integrate live FCM yet.
6. Do not implement real scheduling yet.
7. Do not generate religious content with AI.

Acceptance:
- All models are serializable.
- Seed data loads in tests.
- Candidate selector returns deterministic result for a sample user.
- Analyzer/tests pass if Flutter project foundation exists.

---

# 08 — Content Agent Service Codex Prompt

# Codex Prompt — Implement Content Agent Service Foundation

Read:
- docs/agent/01_CONTENT_AGENT_SERVICE_PRD.md
- docs/agent/02_AGENT_WORKFLOWS.md
- docs/agent/03_AGENT_OUTPUT_SCHEMAS.md
- docs/agent/04_AGENT_PROMPTS.md
- docs/agent/05_AGENT_SERVICE_OPENAPI.yaml
- docs/agent/06_EVAL_AND_GUARDRAILS.md
- docs/cms/03_AGENT_SERVICE_SCHEMA.sql
- docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md
- docs/cms/02_PUSH_CONTENT_SCHEMA.sql

Goal:
Implement the MVP foundation for the Content Agent Service.

Scope:
1. Create a backend service folder:
   - `services/content-agent/`
2. Use TypeScript.
3. Add:
   - package.json
   - src/index.ts
   - src/routes/agentRuns.ts
   - src/domain/schemas.ts
   - src/domain/validators.ts
   - src/domain/candidateSelector.ts
   - src/domain/safetyChecks.ts
   - src/repositories/agentRunRepository.ts
   - src/repositories/contentRepository.ts
   - src/llm/structuredOutputClient.ts
   - src/prompts/
   - test/
4. Implement HTTP endpoints from OpenAPI at a stub/functional level:
   - POST /agent-runs
   - GET /agent-runs
   - GET /agent-runs/:run_id
   - GET /agent-runs/:run_id/review-packet
   - POST /agent-candidates/:candidate_id/qa
   - POST /agent-candidates/:candidate_id/promote-to-cms-draft
5. Implement validators:
   - approved source only
   - lock-screen length
   - no women/cycle-sensitive lock-screen terms
   - no full Qur'an text on lock screen unless explicitly allowed
   - no guaranteed outcome claims
   - no shaming tone
   - no fatwa-like claims
6. Implement dry-run weekly_preproduction that:
   - loads seed source items if DB is not configured
   - selects candidate clusters
   - creates candidate push template payloads using deterministic placeholder generation first
   - marks them as `needs_human_review`
7. Add tests for all guardrails.
8. Do not call live OpenAI API in tests.
9. Do not auto-publish content.
10. Do not send live FCM.

Acceptance:
- Service starts locally.
- Tests pass.
- Candidate outputs are schema-valid.
- Unsafe candidates are rejected or flagged.
- README explains env vars and local run.

---

# 09 — Content Agent Internal Prompt Pack

# Agent Prompt Pack

These prompts are implementation guidance. They should be versioned and tested. Do not paste private user data into prompts.

## 1. System prompt — global content safety

```text
You are a content pre-production assistant for Sakinah Daily, a Quran, Dua, Dhikr, and prayer calm app.

You are not a religious authority. You may draft editorial copy and tagging suggestions, but you must not invent or modify canonical Islamic source text.

Rules:
- Never generate Qur'an Arabic text. Use only provided source text.
- Never generate hadith Arabic text as canonical. Use only provided source text.
- Never invent references.
- Never mark content approved or published.
- Never write fatwa-style rulings.
- Never claim a dua guarantees a worldly result.
- Never shame the user.
- Never expose women’s mode or cycle-sensitive information in lock-screen copy.
- Keep push copy short, gentle, humble, and safe.
- Push copy should invite the user into an in-app session; it should not replace the in-app source.
- Return only the requested JSON schema.
```

## 2. Planner prompt

```text
Create a weekly content plan for the provided date range.

Inputs:
- date range
- markets
- languages
- enabled clusters
- ritual moments
- editorial priorities
- source item availability
- cooldown rules

Output:
- plan items grouped by date, market, language, ritual moment
- recommended cluster
- recommended source item IDs
- reason
- risk notes

Do not create push copy yet.
Do not use unapproved source items.
Return JSON only.
```

## 3. Source selector prompt

```text
Select source items from the provided approved source list.

Goal:
Choose source items that fit the target cluster, ritual moment, market, and language.

Rules:
- Use only source_item IDs provided in the input.
- Do not invent a source_item ID.
- If no suitable source exists, return `no_candidate`.
- Prefer Qur'anic dua for work/study/focus.
- Prefer dhikr/calm ayah for calm/sleep/reset.
- Include confidence and reason.

Return JSON only.
```

## 4. Push copywriter prompt

```text
Draft lock-screen-safe push notification copy.

Inputs:
- source item summary
- cluster brief
- target language
- market
- ritual moment
- tone
- max title length
- max body length
- banned terms
- lock-screen policy

Rules:
- Do not include full Qur'an text in push body.
- Do not include cycle or women’s mode private terms on lock screen.
- Do not say “you must”.
- Do not shame.
- Do not promise guaranteed outcomes.
- Do not invent new religious claims.
- Write a gentle invitation into the app.
- Return 3 variants.

Return JSON only matching PushCopyCandidate[].
```

## 5. Localizer prompt

```text
Localize the provided approved English draft into the target language.

Rules:
- Preserve meaning and tone, not literal wording.
- Use Bahasa Indonesia conventions for Indonesian market.
- Use Modern Standard Arabic for Arabic MVP.
- Keep Islamic vocabulary respectful and familiar.
- Do not add religious claims.
- Keep within max title/body lengths.
- Return JSON only.
```

## 6. Reflection draft prompt

```text
Draft a short in-app reflection connected to the provided source item.

Rules:
- Do not create tafsir.
- Do not create fatwa.
- Do not over-explain the verse.
- Do not claim certainty beyond the provided source summary.
- Keep it warm, simple, and suitable for a 5–8 minute Daily Session.
- Mention the source reference in metadata, not necessarily in the reflection copy.
- Return JSON only.
```

## 7. Safety reviewer prompt

```text
Review the candidate for safety and policy.

Check:
- schema validity
- source reference present
- no invented source
- no full scripture on lock screen unless explicitly allowed
- no women’s mode/cycle terms on lock screen
- no fatwa-like language
- no guaranteed outcome claim
- no shaming tone
- correct language
- length limits
- reviewer notes

Return SafetyReviewResult JSON only.
```

---

# 10 — Source Corpus Ingestion Codex Prompt

# Codex Prompt — Source Corpus Ingestion

Read:
- docs/content/03_SOURCE_CORPUS_INGESTION.md
- docs/content/source_corpus_manifest.yaml
- docs/cms/04_SOURCE_CORPUS_SCHEMA.sql
- scripts/source_corpus/*.py

Goal:
Implement and test the Source Corpus Ingestion foundation.

Scope:
1. Keep all corpus ingestion code under `scripts/source_corpus/` initially.
2. Add a small test fixture:
   - a few Tanzil-style Arabic lines
   - a few QuranEnc-style CSV translation rows
3. Add tests for:
   - parsing Tanzil `surah|ayah|text`
   - parsing QuranEnc CSV
   - merging by verse_key
   - rejecting missing Arabic text
   - rejecting duplicate verse_key
   - enforcing expected ayah count in full-corpus validation
4. Add README usage docs.
5. Add generated lock file shape, but do not commit real full corpus unless explicitly requested.
6. Do not generate Qur'an text.
7. Do not modify imported source text.
8. Do not fetch from live APIs in tests.
9. Add optional env variables for Quran Foundation API cross-check:
   - QF_CLIENT_ID
   - QF_CLIENT_SECRET
   - QF_ENV

Acceptance:
- Parser works with fixtures.
- Full validation logic exists.
- Scripts can be run locally after raw files are downloaded.
- Attribution/version metadata is preserved.
- Tests pass.

---

# 11 — Client Content Delivery & Cache Codex Prompt

# Codex Prompt — Client Content Delivery & Cache

Read:
- docs/client/01_CONTENT_DELIVERY_CACHE_STRATEGY.md
- docs/client/02_CLIENT_CONTENT_MODELS.md
- docs/client/03_CLIENT_SYNC_FLOWS.md
- docs/cms/05_CLIENT_CONTENT_DELIVERY_SCHEMA.sql
- docs/content/03_SOURCE_CORPUS_INGESTION.md
- docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md

Goal:
Implement the Flutter client content delivery/cache foundation.

Scope:
1. Add client-side models:
   - ContentManifest
   - BundleRef
   - ContentBundle
   - SourceItem
   - QuranVerse
   - QuranVerseTranslation
   - DailySession
   - DailySessionStep
   - AudioAsset
   - CacheEntry
   - ContentRequestContext
2. Add a ContentService abstraction:
   - loadActiveManifest()
   - refreshManifest(context)
   - syncRequiredBundles(manifest)
   - loadHomeContent()
   - loadDailySession(sessionId)
   - ensureDailySession(sessionId)
   - loadSourceItem(sourceItemId)
   - loadQuranVerse(verseKey)
   - handleRevocations(contentIds)
3. Add seed content loader from assets/content/.
4. Add remote manifest client, but tests must use fake HTTP.
5. Add bundle downloader with:
   - temp file download
   - sha256 validation
   - schema version validation
   - status/reviewStatus validation
   - transactional cache update
6. Add local repository:
   - use existing app storage approach if present
   - otherwise create an abstraction with an in-memory fake for tests
   - do not block implementation on choosing SQLite package
7. Add push deep-link recovery method:
   - open cached session
   - fetch detail bundle if missing
   - show fallback state if unavailable
8. Add women privacy local filtering:
   - do not expose content with `cycle_sensitive_hidden` when lock-screen safe content is required
9. Add tests:
   - seed loads offline
   - cached Home loads offline
   - hash mismatch discards bundle
   - unsupported schema discards bundle
   - unapproved bundle is rejected
   - push missing content fetches detail bundle
   - push missing content offline returns fallback state
   - women privacy filter blocks sensitive content
   - audio hash mismatch returns text-only fallback
10. Do not integrate real FCM yet.
11. Do not download full Qur'an corpus by default.
12. Do not generate religious content.

Acceptance:
- Models are serializable.
- ContentService works with fake HTTP and fake repository.
- Tests pass.
- Home screen can later consume HomeContent without knowing sync details.

---

# 12 — Short Direct Prompt Variants from Chat

## 12.1 Import package direct task

```text
Read /docs/sakinah_daily_codex_import_package.md and /docs/sakinah_daily_mvp_codex_plan.md.

Implement Milestone 1 only.

Do not implement Daily Session, CMS, notifications, prayer times, or audio playback yet.
Run formatter, analyzer, and tests if possible.
Summarize changes and blockers.
```

## 12.2 Daily Push Content simplified prompt

```text
Read docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md,
docs/content/daily_push_seed_content.csv,
and docs/cms/02_PUSH_CONTENT_SCHEMA.sql.

Implement the MVP Daily Push Content foundation:
- SourceItem model
- ContentCluster model
- PushTemplate model
- seed data loading
- rule-based push candidate selector
- cooldown rules
- language fallback
- women_ibadah_mode lock-screen safety filter

Do not integrate live FCM yet.
Do not generate religious content with AI.
Add tests for approved-only content, cooldown, language fallback, and women mode privacy safety.
```

## 12.3 Content Agent simplified prompt

```text
Read docs/agent/*, docs/cms/03_AGENT_SERVICE_SCHEMA.sql, and docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md.

Implement the MVP foundation for Content Agent Service.

Scope:
- Create services/content-agent/
- Use TypeScript
- Implement agent run endpoints
- Implement schemas
- Implement validators
- Implement deterministic dry-run generation
- Add tests for guardrails
- Do not call live OpenAI API in tests
- Do not auto-publish content
- Do not send live FCM
```

## 12.4 Source Corpus simplified prompt

```text
Read docs/content/03_SOURCE_CORPUS_INGESTION.md,
docs/content/source_corpus_manifest.yaml,
docs/cms/04_SOURCE_CORPUS_SCHEMA.sql,
and scripts/source_corpus/*.py.

Implement and test Source Corpus Ingestion.

Scope:
- Parse Tanzil surah|ayah|text files
- Parse QuranEnc CSV
- Merge by verse_key
- Validate 114 surahs / 6,236 ayahs
- Preserve provider/version/attribution/checksum metadata
- Generate quran_verses.jsonl
- Do not generate Qur’an text
- Do not modify imported source text
- Do not fetch live APIs in tests
```

## 12.5 Client Content Cache simplified prompt

```text
Read docs/client/01_CONTENT_DELIVERY_CACHE_STRATEGY.md,
docs/client/02_CLIENT_CONTENT_MODELS.md,
docs/client/03_CLIENT_SYNC_FLOWS.md,
and docs/cms/05_CLIENT_CONTENT_DELIVERY_SCHEMA.sql.

Implement the Flutter client content delivery/cache foundation:
- ContentManifest model
- BundleRef model
- ContentBundle model
- SourceItem model
- QuranVerse model
- DailySession model
- AudioAsset model
- CacheEntry model
- ContentService abstraction
- seed content loader
- remote manifest client with fake HTTP tests
- bundle downloader with sha256 validation
- local repository abstraction
- push deep-link recovery
- women privacy local filtering
- offline fallback tests

Do not integrate real FCM yet.
Do not download full Qur’an corpus by default.
Do not generate religious content.
```

---
