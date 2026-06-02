# Screenshot Plan

Status: Draft for release/store review.

## Required Screens

1. Splash / brand.
2. Home.
3. Daily Session Quran step.
4. Dua Detail.
5. Dhikr Counter.
6. Prayer Times.
7. Women's Ibadah Mode.
8. Privacy Center.
9. Settings.

## Device Sizes

Android:

- 1080 x 1920 phone or Play Store compatible equivalent.
- Optional tablet later.

iOS:

- iPhone 6.7-inch.
- iPhone 6.5-inch.
- Optional iPad later.

## Localization Coverage

- English primary store screenshots.
- Bahasa Indonesia localized set.
- Arabic RTL localized set.

## Automation Notes

The real-device route screenshot helper can capture the main QA/store surfaces
without coordinate tapping by using the dev-only `SAKINAH_INITIAL_ROUTE`
dart-define:

```sh
DEVICE_ID=SC65XWPZ7DLNUSTC \
  scripts/android_e2e/capture_route_screenshots.sh
```

Captured files are written to `build/e2e/route-screenshots-<timestamp>/`.
The route override is ignored in `prod` builds and is intended for dev/staging
QA only.

To smoke a single route during development:

```sh
DEVICE_ID=SC65XWPZ7DLNUSTC \
  ROUTE_SPECS_OVERRIDE='privacy-center|/settings/privacy' \
  scripts/android_e2e/capture_route_screenshots.sh
```

Useful existing test keys:

- `SakinahKeys.homePrayerBadge`
- `SakinahKeys.homeSessionStartButton`
- `SakinahKeys.duaListItem(...)`
- `SakinahKeys.dhikrCounter`
- `SakinahKeys.settingsWomenModeTile`
- `SakinahKeys.settingsPrivacyTile`
- `SakinahKeys.privacyCenterPage`

Future screenshot automation should use deterministic seed content, disable
network calls, and avoid capturing any sensitive Women's Ibadah Mode status on
lock-screen or external surfaces.

## Review Checklist

- [ ] No draft/in-review content visible.
- [ ] Quran recitation screen shows no background music affordance.
- [ ] Privacy Center clearly shows local-only and leaves-device categories.
- [ ] Notification copy is not sensitive.
- [ ] Arabic screenshots are RTL-safe.
- [ ] Text does not overflow on required device sizes.
