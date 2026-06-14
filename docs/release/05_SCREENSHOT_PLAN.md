# Screenshot Plan

Status: Android phone matrix, Android brand splash evidence, Google Play
feature graphic, and Quran voice-only safety evidence captured for
release/store review.

Google Play feature graphic requirement checked on 2026-06-11:
https://support.google.com/googleplay/android-developer/answer/9866151

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
- Indonesian / Bahasa Indonesia localized set.
- Arabic RTL localized set.

## Automation Notes

Google Play feature graphic:

```sh
scripts/generate_google_play_feature_graphic.py
scripts/verify_google_play_store_assets.sh
```

The generated feature graphic is
`build/store-assets/google-play-feature-graphic.png`. It must remain
1024 x 500, 24-bit PNG, no alpha. The verifier regenerates the asset from the
app icon and release-safe store copy, then checks the PNG dimensions and color
mode. Strict mode also checks the Android screenshot matrix and contact sheet:
strict mode verifies all 27 required Android screenshot filenames across
English, Indonesian, and Arabic, and checks each screenshot is PNG, RGB/no-alpha,
within Google Play image bounds, and portrait Android phone bounds.

```sh
SAKINAH_REQUIRE_STORE_ASSETS_READY=true \
scripts/verify_google_play_store_assets.sh
```

Single-screen Android capture:

```sh
scripts/capture_android_store_screenshot.sh en /splash \
  build/store-screenshots/android-assets/en-splash.png
scripts/capture_android_store_screenshot.sh en /quran/94:5 \
  build/store-screenshots/android-safety/en-quran-94-5.png
scripts/capture_android_store_screenshot.sh en /settings/content-sources \
  build/store-screenshots/android-safety/en-content-sources.png
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/capture_android_store_screenshot.sh en /settings/testing-guide \
  build/store-screenshots/android-safety/en-closed-testing-guide.png
scripts/capture_android_store_screenshot.sh en /settings/notifications \
  build/store-screenshots/android-safety/en-notification-settings-per-prayer.png
scripts/capture_android_store_screenshot.sh en /home
scripts/capture_android_store_screenshot.sh ar /settings/privacy
```

`en-notification-settings-per-prayer.png` should show the prayer reminder
lead-time selector plus the per-prayer Fajr/Dhuhr/Asr/Maghrib/Isha controls.

Full Android matrix capture:

```sh
scripts/capture_android_store_screenshots.sh
```

Narrow or resume a run:

```sh
SAKINAH_SCREENSHOT_LOCALES="en ar" \
SAKINAH_SCREENSHOT_ROUTES="/home /settings/privacy" \
SAKINAH_SCREENSHOT_SKIP_EXISTING=true \
scripts/capture_android_store_screenshots.sh
```

The script builds a dev QA APK with deterministic screenshot mode enabled,
installs it on the connected Android device, launches the requested route, and
writes a PNG under `build/store-screenshots/android/` unless an output path is
provided. It normalizes Android `screencap` output to RGB/no-alpha PNG so the
strict visual-assets gate can reject alpha-channel screenshots before upload.

Screenshot mode can still target the dev-only `/splash` brand screen for store
asset capture, and the shared native launch artwork lives at
`assets/branding/sakinah_splash.png`. Android uses the same bitmap through
`sakinah_native_splash.png`; iOS uses it through `SakinahSplash.imageset`.
Normal app launch no longer routes through Flutter `/splash`; Android native
splash hands off directly to onboarding or Home. Override
`SAKINAH_SCREENSHOT_SETTLE_SECONDS` only when manually reviewing startup
timing.

Useful existing test keys:

- `SakinahKeys.splashPage`
- `SakinahKeys.splashBrand`
- `SakinahKeys.splashTagline`
- `SakinahKeys.homePrayerBadge`
- `SakinahKeys.homePrayerPrimaryCard`
- `SakinahKeys.homePrayerTimesButton`
- `SakinahKeys.homePrayerReminderSettingsButton`
- `SakinahKeys.homeSessionStartButton`
- `SakinahKeys.settingsNotificationSettingsTile`
- `SakinahKeys.settingsNotificationSwitch`
- `SakinahKeys.settingsDailySessionReminderSwitch`
- `SakinahKeys.settingsDailySessionReminderTimeButton`
- `SakinahKeys.notificationSmokeTestButton` (dev-only QA builds)
- `SakinahKeys.settingsPrayerLocationTile`
- `SakinahKeys.settingsPrivacyTile`
- `SakinahKeys.settingsContentSourcesTile`
- `SakinahKeys.privacyCenterPage`
- `SakinahKeys.contentSourcesPage`
- `SakinahKeys.quranVerseDetailPage`

Future screenshot automation should use deterministic seed content, disable
network calls, and avoid capturing any sensitive Women's Ibadah Mode status on
lock-screen or external surfaces.

Current deterministic screenshot Dart defines:

- `SAKINAH_STORE_SCREENSHOT_ENABLED=true`
- `SAKINAH_STORE_SCREENSHOT_LOCALE=en|id|ar`
- `SAKINAH_STORE_SCREENSHOT_ROUTE=/splash`, `/quran/94:5`, `/home`, or another
  route listed in this plan

Screenshot mode is dev-only, disables remote content, seeds local preferences
for the requested locale, and is ignored in staging/prod builds.

Local capture evidence:

- `build/store-assets/google-play-feature-graphic.png`
- `build/store-screenshots/android-smoke/id-home.png`
- `build/store-screenshots/android-assets/en-splash.png`
- `build/store-screenshots/android/en-splash.png`
- `build/store-screenshots/android/id-splash.png`
- `build/store-screenshots/android/ar-splash.png`
- `build/store-screenshots/android-safety/en-quran-94-5.png`
- `build/store-screenshots/android-safety/en-content-sources.png`
- `build/store-screenshots/android-safety/en-notification-settings-per-prayer.png`
- 2026-06-11 full Android phone matrix on `SC65XWPZ7DLNUSTC`:
  27 screenshots across English, Indonesian, and Arabic RTL for Splash /
  brand, onboarding, Home, Prayer Times, Settings, Notification Settings,
  Manual Prayer Location, Privacy Center, and Daily Session start. Captures are
  under `build/store-screenshots/android/` at 1080 x 2374, with a QA contact
  sheet at `build/store-screenshots/android-contact-sheet.png`.

## Review Checklist

- [x] Google Play feature graphic is generated at 1024 x 500 as 24-bit PNG
  with no alpha.
- [x] No draft/in-review content visible in the captured Android matrix.
- [x] Quran recitation screen shows no background music affordance.
- [x] Privacy Center clearly shows local-only and leaves-device categories.
- [x] Notification copy is not sensitive.
- [x] Arabic screenshots are RTL-safe.
- [x] Text does not overflow on required Android phone device size.
