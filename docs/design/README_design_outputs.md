# Sakinah Daily MVP Design Outputs

This folder contains first-pass visual mockups for the MVP app pages.

## Files

- `00_app_design_board.png` — combined board with all MVP page mockups.
- `01_home_light_en.png` — primary Home screen, light mode.
- `02_home_dark_ar_rtl.png` — Home screen direction for Arabic RTL / dark mode.
- `03_daily_session_player.png` — Daily Session audio player direction.
- `04_dua_detail.png` — Dua detail page with source/review emphasis.
- `05_womens_ibadah_mode.png` — Women’s Ibadah Mode page.
- `06_home_screen_design_spec.png` — Home screen design annotations.

## Design principles

- Home is centered around the next prayer and today’s Daily Session.
- Qur’an recitation is voice-only by default; no BGM under Qur’an.
- Arabic must support RTL from layout level, not just translated strings.
- Women’s Ibadah Mode is privacy-first, respectful, and not pink-coded.
- The first MVP visual system uses Deep Emerald, Midnight Navy, Sand Gold, Ivory, Sage Green, and Warm Taupe.

## Suggested next step

Use these images as direction and convert the components into Flutter widgets:
`DailySessionCard`, `PrayerCountdownPill`, `AudioPlayerCard`, `SourceChip`, `DhikrCounterCircle`, `SettingsTile`, and `LanguageAwareScaffold`.
