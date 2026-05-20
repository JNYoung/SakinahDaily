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
