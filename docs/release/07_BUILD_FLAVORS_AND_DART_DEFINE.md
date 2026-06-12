# Build Flavors And Dart Define

Status: Draft for release/store review.

The MVP uses Dart defines for client environment selection. No secrets are
stored in the repository.

## App Environment

Supported values:

- `SAKINAH_APP_ENV=dev`
- `SAKINAH_APP_ENV=staging`
- `SAKINAH_APP_ENV=prod`

Default: `dev`

App display names inside Flutter runtime:

- `dev`: `Sakinah Daily Dev`
- `staging`: `Sakinah Daily Staging`
- `prod`: `Sakinah Daily`

The native Android launcher label remains `Sakinah Daily`.

## Privacy Policy URL

Use the final legal/store-approved hosted policy URL in production builds:

```sh
--dart-define=SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy
```

The app accepts public HTTPS URLs and rejects placeholder/private shapes such as
`example.com`, localhost, `.test`, and `.invalid`. When the value is accepted,
Settings > Privacy shows the published privacy policy URL in the Privacy Center
and lets the user copy it. When the value is absent or rejected, the Privacy
Center keeps draft policy copy for review builds.

## Testing Feedback

Use the final Play Console testing feedback email or public HTTPS feedback URL
in closed-test and production builds:

```sh
--dart-define=SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app
```

The app accepts real email addresses or public HTTPS URLs and rejects placeholder
channels such as `support@example.com`, `example.com`, localhost, `.test`, and
`.invalid`. When accepted, Settings shows a Testing feedback tile and lets the
user copy the same channel used in Google Play Closed testing. Settings also
shows a Closed testing guide with a daily checklist for Home return intent,
prayer times, reminders, Today's Sakinah Session, Privacy Center, and feedback.

## Remote Content

Remote content is disabled unless explicitly configured:

```sh
--dart-define=SAKINAH_CONTENT_API_ENABLED=true
--dart-define=SAKINAH_CONTENT_API_PROVIDER=generic
--dart-define=SAKINAH_CONTENT_API_BASE_URL=https://staging-content.example
--dart-define=SAKINAH_CONTENT_MANIFEST_PATH=/manifest
--dart-define=SAKINAH_CONTENT_DETAIL_BUNDLE_PATH=/detail-bundle
```

Optional:

```sh
--dart-define=SAKINAH_CONTENT_API_TOKEN=...
```

Do not commit tokens, `.env` files, `key.properties`, keystores, or service
account files. Prefer CI secrets or local untracked shell configuration.

## Notification QA

The real-device notification smoke-test control is disabled by default and is
only available in `dev` when explicitly enabled:

```sh
--dart-define=SAKINAH_APP_ENV=dev
--dart-define=SAKINAH_NOTIFICATION_QA_ENABLED=true
```

When enabled, Settings > Notification settings shows a local test-notification
button that schedules a short-delay, privacy-safe notification with a prayer
tap payload. The flag is ignored in `staging` and `prod`.

## Store Screenshot QA

`SAKINAH_STORE_SCREENSHOT_ENABLED=true` enables deterministic store screenshot
mode only in `dev`. It starts the app on a requested release-review route,
forces the requested locale, seeds local preferences in memory, and disables
remote content so screenshots use approved seed content only.

Supported locale values:

- `en`
- `id`
- `ar`

Supported route values:

- `/splash`
- `/onboarding`
- `/home`
- `/prayer`
- `/settings`
- `/settings/notifications`
- `/settings/content-sources`
- `/settings/testing-guide`
- `/settings/prayer-location`
- `/settings/privacy`
- `/session/session_morning_ease`
- `/quran/94:5`

Single-screen capture helper:

```sh
scripts/capture_android_store_screenshot.sh en /splash
scripts/capture_android_store_screenshot.sh en /quran/94:5 \
  build/store-screenshots/android-safety/en-quran-94-5.png
scripts/capture_android_store_screenshot.sh en /home
scripts/capture_android_store_screenshot.sh en /settings/content-sources \
  build/store-screenshots/android-safety/en-content-sources.png
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/capture_android_store_screenshot.sh en /settings/testing-guide \
  build/store-screenshots/android-safety/en-closed-testing-guide.png
scripts/capture_android_store_screenshot.sh ar /settings/privacy \
  build/store-screenshots/android/ar-privacy.png
```

Full screenshot matrix helper:

```sh
scripts/capture_android_store_screenshots.sh
```

To limit the matrix:

```sh
SAKINAH_SCREENSHOT_LOCALES="en ar" \
SAKINAH_SCREENSHOT_ROUTES="/home /settings/privacy" \
scripts/capture_android_store_screenshots.sh
```

Direct build example:

```sh
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=dev \
  --dart-define=SAKINAH_STORE_SCREENSHOT_ENABLED=true \
  --dart-define=SAKINAH_STORE_SCREENSHOT_LOCALE=ar \
  --dart-define=SAKINAH_STORE_SCREENSHOT_ROUTE=/settings/privacy
```

## Telemetry

`analyticsEnabled` is disabled by default and can be enabled only with
`SAKINAH_ANALYTICS_ENABLED=true`. The current implementation includes
Firebase Core/Firebase Analytics, a Google Analytics-compatible event
whitelist, and a sensitive-parameter sanitizer. Android automatic analytics
collection and automatic screen reporting are disabled in the manifest by
default. When analytics is enabled, startup calls `Firebase.initializeApp()`,
sets Firebase Analytics collection disabled by default, and then the app-level
consent sync turns collection on only when Firebase project configuration is
available and the user has enabled usage analytics in Privacy Center. Store screenshot mode forces analytics off.

`crashReportingEnabled` remains hard-disabled in `AppEnvironmentConfig`.
Do not enable production analytics or add crash SDKs until privacy review
approves the final provider, consent posture, and data declaration.

## Example Commands

Dev:

```sh
flutter run --dart-define=SAKINAH_APP_ENV=dev
```

Dev notification QA:

```sh
flutter run \
  --dart-define=SAKINAH_APP_ENV=dev \
  --dart-define=SAKINAH_NOTIFICATION_QA_ENABLED=true
```

Staging:

```sh
flutter run \
  --dart-define=SAKINAH_APP_ENV=staging \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=https://staging-content.example
```

Prod dry run without remote content:

```sh
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=prod
```
