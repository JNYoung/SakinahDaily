# Codex Context — Sakinah Daily MVP v0.1

You are working on Sakinah Daily, an Islamic daily calm app for Middle East and Indonesia users.

## Product summary

Sakinah Daily combines Quran listening, Dua, Dhikr, prayer reminders, and gender-aware worship routines into a calm daily worship companion.

It should feel like:

- Calm and audio-first.
- Sacred and trustworthy.
- Practical enough for prayer reminders.
- Respectful toward women’s worship states.
- Localized for Arabic and Bahasa Indonesia.

It should not feel like:

- A generic meditation app.
- A full Quran super-app.
- A noisy utility app.
- A social/community platform.

## Hard rules

- Never play background music under Quran recitation.
- Do not use generic TTS for Arabic Quran recitation.
- Quran audio must be approved/authorized audio assets.
- Dua details must show source and review status.
- Arabic UI must support RTL from day one.
- Women’s Ibadah Mode must be local-first and privacy-first.
- Do not build AI fatwa, religious Q&A, UGC, ads, or community features in MVP.

## Preferred stack

- Flutter + Dart.
- Riverpod.
- go_router.
- Flutter l10n with ARB files.
- just_audio.
- adhan_dart or equivalent prayer-time calculation package.
- flutter_local_notifications.
- Supabase + Directus later.

## MVP journey

1. User chooses language.
2. User sets location manually or with device permission.
3. User optionally chooses gender mode.
4. User chooses audio preference.
5. User lands on Home.
6. Home shows next prayer and Today’s Sakinah.
7. User completes Daily Session.
8. User can browse Dua and Dhikr.
9. User can configure notifications and Women’s Ibadah Mode.

## Implementation principle

Implement in small milestones. Each milestone should compile and be reviewable.

Do not jump ahead.
