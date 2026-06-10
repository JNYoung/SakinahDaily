# Screenshot Plan

Status: Draft for release/store review.

## Required Screens

1. Splash / brand.
2. Home with next prayer and reminder status.
3. Prayer Times.
4. Notification Settings.
5. Manual Prayer Location.
6. Privacy Center.
7. Settings.
8. Optional Daily Session start screen.

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

Useful existing test keys:

- `SakinahKeys.homePrayerBadge`
- `SakinahKeys.homePrayerPrimaryCard`
- `SakinahKeys.homePrayerTimesButton`
- `SakinahKeys.homePrayerReminderSettingsButton`
- `SakinahKeys.homeSessionStartButton`
- `SakinahKeys.settingsNotificationSettingsTile`
- `SakinahKeys.settingsPrayerLocationTile`
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
