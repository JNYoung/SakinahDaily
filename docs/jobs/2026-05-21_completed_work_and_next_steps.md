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

## Current Validation Gate

- Primary app gate: `flutter test`
- Static analysis gate: `dart analyze`
- Android gate: launch the Flutter app on the connected emulator after app-level changes.
- Known note: `flutter analyze` may fail under the current Chinese-character workspace path because the Flutter analysis server crashes while parsing its protocol stream. Use `dart analyze` as the stable local gate unless the workspace path is moved or the Flutter toolchain issue is resolved.

## Recommended Next Jobs

1. Run the full verification gate after every app change: `flutter test`, `dart analyze`, and Android emulator launch.
2. Continue the UI refactor from the design outputs, starting with Home, Daily Session, Dua Detail, and Women Ibadah Mode.
3. Add visual or integration coverage only after the widget tests remain stable; keep TDD fast by default.
4. Finish Quran corpus ingestion with fixture-only tests first, then wire the client content cache around manifest, hash, schema, approval, and fallback rules.
5. Expand Content Agent automated tests for guardrails, deterministic weekly preproduction, prayer-content generation packets, and no auto-publish/no FCM behavior.
6. Add CMS/API integration behind seed fallback and keep all remote content filtered by `published` and `approved`.

## Handoff Notes

- Do not commit secrets, production CMS config, full Quran corpus, or licensed audio.
- For Quran text, import and validate authorized source data; do not generate or rewrite Qur'an original text.
- Women's mode privacy remains local-first, and sensitive content must not appear in lock-screen push text.
