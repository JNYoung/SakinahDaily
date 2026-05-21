# Sakinah Daily MVP v0.1

## Product Principle

Build the smallest polished daily worship companion for Quran listening, Dua, Dhikr, prayer reminders, and privacy-first worship routines. Do not build a full Quran super-app in v0.1.

## MVP Modules

1. Flutter foundation: app shell, routing, theme, l10n, RTL.
2. Models and seed content.
3. Reusable design components.
4. Onboarding.
5. Prayer times and local reminders foundation.
6. Home dashboard.
7. Daily Session flow.
8. Dua and Dhikr library.
9. Settings and Women's Ibadah Mode.
10. CMS/API integration with seed fallback.
11. Analytics interface and QA tests.
12. Daily Push Content foundation.
13. Content Agent service foundation.
14. Quran source corpus ingestion foundation.
15. Client content delivery/cache foundation.

## Non-Negotiable Religious Safety

- Quran recitation audio has `bgmAllowed=false`.
- Arabic Quran recitation cannot be generated with generic TTS.
- Imported Quran text must not be modified by scripts.
- Dua details show source and review status.
- AI-generated religious advice, fatwa, community religious posts, ads, and UGC are out of scope.

## Verification

Run Flutter formatter/analyzer/tests for client changes, Node tests for the content-agent service, and Python unit tests for source corpus scripts.
