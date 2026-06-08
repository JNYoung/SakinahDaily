# Android Release Checklist

Status: Draft for release/store review.

## Package Identity

- Namespace: `com.sakinahdaily.app`
- Application ID: `com.sakinahdaily.app`
- Display name: `Sakinah Daily`

## Signing

Production signing is not configured in this repository. Local release builds
currently keep debug signing only so developers can exercise Android build
flows.

Before production:

- Create a release keystore outside the repository.
- Keep `key.properties` outside git or in a local ignored file.
- Use environment-specific CI secrets for signing passwords.
- Verify `.jks`, `.keystore`, `key.properties`, and service-account files are
  not tracked.
- Review Play App Signing settings.

## Permissions

Current:

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.ACCESS_COARSE_LOCATION`

Not currently used:

- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_BACKGROUND_LOCATION`
- `android.permission.FOREGROUND_SERVICE_LOCATION`
- Compass/sensor permissions

Location baseline:

- v0.1 uses foreground coarse device location for prayer time and Qibla setup.
- The app must show explanatory copy before requesting location permission.
- Denied, permanently denied, disabled service, and unavailable location states
  must keep manual location entry available.
- Do not add fine/background location or sensor permissions without a new
  product, privacy, and store review.

## Build Commands

```sh
flutter pub get
flutter test
dart analyze
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=dev
```

Staging example:

```sh
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=staging \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=https://staging-content.example
```

Do not pass production tokens from shell history on shared machines.
