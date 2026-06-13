# Android Release Checklist

Status: Draft for release/store review.

## Package Identity

- Namespace: `com.sakinahdaily.app`
- Application ID: `com.sakinahdaily.app`
- Display name: `Sakinah Daily`

## Signing

Production signing is wired but no secret material is committed. Local release
builds keep debug signing unless `android/key.properties` or the
`SAKINAH_UPLOAD_*` environment variables provide a complete upload-key config.

Local file option:

- Copy `android/key.properties.example` to `android/key.properties`.
- Keep the upload keystore outside git. `storeFile` may be absolute or
  relative to `android/app`.
- Never commit `android/key.properties`, `.jks`, or `.keystore` files.
- Or run `scripts/create_android_upload_keystore.sh` with
  `SAKINAH_UPLOAD_KEYSTORE_PATH`, `SAKINAH_UPLOAD_STORE_PASSWORD`,
  `SAKINAH_UPLOAD_KEY_ALIAS`, `SAKINAH_UPLOAD_KEY_PASSWORD`, and
  `SAKINAH_WRITE_KEY_PROPERTIES=true` to create an upload keystore outside the
  repo and write a local ignored `android/key.properties`.

Detailed local setup:

- `docs/release/10_ANDROID_UPLOAD_SIGNING_SETUP.md`

CI environment option:

- `SAKINAH_UPLOAD_STORE_FILE`
- `SAKINAH_UPLOAD_STORE_PASSWORD`
- `SAKINAH_UPLOAD_KEY_ALIAS`
- `SAKINAH_UPLOAD_KEY_PASSWORD`

Production gate:

- Set `SAKINAH_REQUIRE_RELEASE_SIGNING=true` for CI/store builds so Gradle
  fails instead of silently using debug signing when upload-key config is
  missing.
- Review Play App Signing settings before uploading the first bundle.

Internal testing gate:

```sh
scripts/verify_google_play_internal_release.sh
```

The script fails closed unless local `android/key.properties` or the
`SAKINAH_UPLOAD_*` environment variables are configured. It also requires
Android SDK cmdline-tools with `apkanalyzer`, because Flutter uses that tool to
verify release appbundles are stripped of native debug symbols. It also checks
`sdkmanager --licenses` and requires "All SDK package licenses accepted." With
signing and cmdline-tools available, it runs the release readiness test,
`dart analyze`, a prod release appbundle build, and writes
`build/play-internal/app-release.aab.sha256`.

For local build-only QA that is not uploadable to Google Play:

```sh
SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true \
scripts/verify_google_play_internal_release.sh
```

Use this unsigned mode only to exercise the release build path before upload
keys are available.

If you are only validating script control flow on a machine with incomplete
Android cmdline-tools, you may also set
`SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA=true`; do not use that for a Play
upload candidate.

Google Play upload preflight:

```sh
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
SAKINAH_PLAY_TESTER_GROUP_EMAIL=sakinah-daily-testers@googlegroups.com \
SAKINAH_PLAY_TESTER_GROUP_CREATED=true \
SAKINAH_PLAY_CLOSED_TRACK_READY=true \
SAKINAH_PLAY_APP_CONTENT_READY=true \
SAKINAH_PLAY_STORE_LISTING_READY=true \
scripts/verify_google_play_upload_preflight.sh
```

The preflight script is stricter than unsigned local QA. It does not accept
`SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true` as Play upload evidence. It requires
upload signing, an HTTPS privacy policy URL, a Testing feedback email or URL,
the Sakinah Google Group, closed-testing track binding, Play Console app-content
declarations, store listing readiness, and the signed AAB plus checksum. It
also verifies that the checksum matches the current AAB and that the `.aab` is
a readable App Bundle zip with the base module manifest entry. Use
`SAKINAH_PREFLIGHT_SKIP_RELEASE_GATE=true` only when a signed AAB and
`build/play-internal/app-release.aab.sha256` already exist from the release
gate.

Google Play upload evidence packet:

```sh
scripts/export_google_play_upload_packet.sh
```

## Android Launch Smoke Gate

Use the launch smoke gate after app-level changes when a connected Android
device or emulator is available:

```sh
scripts/verify_android_launch_smoke.sh
```

The script locates `adb` through `ADB`, `ANDROID_HOME`, `ANDROID_SDK_ROOT`, the
default macOS SDK path, or PATH. It builds a dev debug APK, installs
`build/app/outputs/flutter-apk/app-debug.apk`, starts Sakinah Daily through the
launcher intent, checks `pidof -s com.sakinahdaily.app`, and writes screenshot
evidence plus a manifest to `build/android-launch-smoke`.

Useful options:

- `SAKINAH_ANDROID_SERIAL=<adb-serial>` targets a specific connected device.
- `SAKINAH_ANDROID_EMULATOR_ID=<flutter-emulator-id>` asks Flutter to launch an
  emulator before the install/launch check.
- `SAKINAH_ANDROID_SKIP_BUILD=true` reuses an existing debug APK for fast
  device smoke checks.
- `SAKINAH_ANDROID_KEEP_APP_RUNNING=true` leaves the app open after capture for
  manual inspection.
- `SAKINAH_PLAY_TESTING_FEEDBACK=<email-or-url>` passes the closed-testing
  feedback channel into the dev build when verifying tester-facing surfaces.

## Android OEM Reminder Observation Packet

Use the Android OEM reminder observation packet before broad beta to prepare
long-window local reminder evidence without tester personal data:

```sh
scripts/export_android_oem_reminder_observation_packet.sh
```

Template mode exports `build/android-oem-reminder-observation` with:

- `long_window_observation_log.csv` for 8-hour and 24-hour prayer reminder
  delivery/tap observations.
- `reboot_delivery_checklist.csv` for `RECEIVE_BOOT_COMPLETED` reminder restore
  checks after reboot or package replacement.
- `battery_policy_review.csv` for aggressive battery-management notes.
- `device_environment_snapshot.txt` for non-personal Android device/build
  environment, prefilled from `adb shell getprop` and
  `adb shell cmd deviceidle whitelist` when a device is connected, otherwise
  left as a manual handoff template.
- `adb_observation_commands.sh` for package-filtered ADB capture commands
  covering package resolution, device-idle state, alarm/notification hints, and
  crash-buffer review without tester personal data.
- `oem_observation_checklist.md` for lock-screen copy and privacy-safe
  observation rules.

Strict mode should pass only after real device evidence is complete:

```sh
SAKINAH_REQUIRE_ANDROID_OEM_REMINDER_OBSERVATION_READY=true \
SAKINAH_ANDROID_OEM_TEST_DEVICE_CONFIRMED=true \
SAKINAH_8H_PRAYER_REMINDER_OBSERVED=true \
SAKINAH_24H_PRAYER_REMINDER_OBSERVED=true \
SAKINAH_REBOOT_REMINDER_RESTORE_OBSERVED=true \
SAKINAH_BATTERY_POLICY_REVIEWED=true \
SAKINAH_OEM_OBSERVATION_OWNER_ASSIGNED=true \
SAKINAH_ANDROID_OEM_LONG_WINDOW_EVIDENCE=path/to/completed-long-window.csv \
SAKINAH_ANDROID_OEM_REBOOT_EVIDENCE=path/to/completed-reboot.csv \
SAKINAH_ANDROID_OEM_BATTERY_EVIDENCE=path/to/completed-battery.csv \
scripts/export_android_oem_reminder_observation_packet.sh
```

The three strict evidence CSVs are copied into the packet and must not contain
template placeholders such as `pending_manual_observation`,
`pending_tap_route`, `record_manually`, `TBD`, or `unknown`. This keeps strict
mode tied to completed device evidence rather than environment flags alone.

Template mode exports `build/play-upload` for local review. Strict mode requires
the same upload signing, public privacy/feedback links, Google Group,
closed-track binding, app-content/store-listing confirmations, signed AAB
checksum, and strict visual assets:

```sh
SAKINAH_REQUIRE_PLAY_UPLOAD_PACKET_READY=true \
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
SAKINAH_PLAY_TESTER_GROUP_EMAIL=sakinah-daily-testers@googlegroups.com \
SAKINAH_PLAY_TESTER_GROUP_CREATED=true \
SAKINAH_PLAY_CLOSED_TRACK_READY=true \
SAKINAH_PLAY_APP_CONTENT_READY=true \
SAKINAH_PLAY_STORE_LISTING_READY=true \
scripts/export_google_play_upload_packet.sh
```

Public links gate:

```sh
scripts/export_google_play_public_links_packet.sh
scripts/verify_google_play_public_links_packet.sh

SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/verify_google_play_public_links.sh
```

Do not use placeholder or private URLs. The upload preflight calls
`scripts/verify_google_play_public_links.sh` automatically.
The hosting packet script exports `build/play-public-links` with a static
privacy page, optional feedback page, source drafts, and manifest for legal /
store review before the final HTTPS URLs are configured. The verifier checks
the generated HTML for required privacy sections, no placeholder copy, and no
feedback form fields before publishing.

Play Console submission pack:

```sh
scripts/verify_google_play_store_assets.sh
scripts/verify_google_play_submission_pack.sh
```

The submission pack is documented in
`docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md`. Template mode verifies
the local Main store listing, App content, screenshot, privacy, data-safety,
closed-testing, and evidence materials. Strict mode with
`SAKINAH_REQUIRE_PLAY_SUBMISSION_READY=true` requires the human Play Console
fields and delegates to `scripts/verify_google_play_upload_preflight.sh`.

The store visual assets gate generates and checks
`build/store-assets/google-play-feature-graphic.png` as a 1024 x 500,
24-bit PNG/no-alpha Google Play feature graphic, and strict mode checks the
27 required Android screenshot filenames, RGB/no-alpha PNG properties,
portrait phone bounds, and contact sheet.

Closed-test launch day gate:

```sh
scripts/verify_google_play_closed_test_launch_day.sh
```

Run this after the local submission pack is green and before sharing tester
links. Template mode verifies the upload packet, public links packet QA, store
visual assets, closed-testing invitation, and the rule to Share the Google
Group link first. Strict mode with
`SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY=true` should pass only after the Play
Console app, Google Group, closed-testing track, Testing feedback channel,
reviewed upload packet, live closed-test release, and final tester links are
confirmed.

Production Flutter build:

```sh
flutter build appbundle --release \
  --dart-define=SAKINAH_APP_ENV=prod \
  --dart-define=SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
  --dart-define=SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app
```

Use the same final privacy URL and testing feedback channel in Play Console and
in the Dart defines so Privacy Center shows the hosted policy and Settings shows
the closed-test feedback channel instead of hiding release-only contact details.

## Google Play Closed Testing

Closed-testing launch pack:

- Play Console submission runbook:
  `docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md`
- `docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md`
- Closed-testing evidence log:
  `docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md`
- Closed-test launch day checklist:
  `docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md`
- Evidence verifier:
  `scripts/verify_google_play_closed_testing_evidence.sh`
- Launch-day verifier:
  `scripts/verify_google_play_closed_test_launch_day.sh`
- Tester group candidate: Sakinah Daily Alpha Testers
- Group slug: `sakinah-daily-testers`
- Group email: `sakinah-daily-testers@googlegroups.com`
- Group link: https://groups.google.com/g/sakinah-daily-testers
- Web opt-in:
  https://play.google.com/apps/testing/com.sakinahdaily.app
- Store listing:
  https://play.google.com/store/apps/details?id=com.sakinahdaily.app

Before submitting the first closed-testing release, create the Google Group,
bind it to the Play Console closed-testing track, configure Testing feedback
with the final feedback email or URL, upload a signed `.aab`, and submit all
pending changes in Publishing overview.

For new personal developer accounts subject to Google Play's testing
requirement, keep at least 12 opted-in testers active for 14 days continuously
before applying for Production access. During the test, update the
closed-testing evidence log with aggregate counts, feedback reviewed, changes
made, and Production access answer notes. The template verifier should pass
before launch; strict mode with `SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE=true`
is expected to fail until the real 14-day evidence is complete.

## Permissions

Current:

- `android.permission.POST_NOTIFICATIONS`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android:enableOnBackInvokedCallback="true"` is set on the application to
  avoid Android 13+ predictive-back launch warnings.
- `flutter_local_notifications` scheduled notification receivers are declared
  so local prayer/session reminders can show and be restored after reboot.

Real-device notification QA:

- Dev builds can enable `SAKINAH_NOTIFICATION_QA_ENABLED=true` to expose
  notification QA controls in Settings > Notification settings.
- On 2026-06-11, `SC65XWPZ7DLNUSTC` delivered the prayer reminder QA
  notification on channel `sakinah_prayer_reminders` with notification `id=298`
  and body `It is time for Fajr prayer.`. Tapping the notification opened the
  Prayer tab.
- Longer-window OEM scheduling behavior, including reboot and aggressive
  battery-management cases, still needs observation before broad beta.
  The OEM observation packet now includes `device_environment_snapshot.txt` so
  the observation owner can confirm the Android version, model, package state,
  and battery/device-idle context without recording tester personal data.

Not currently used:

- `android.permission.ACCESS_COARSE_LOCATION`
- `android.permission.ACCESS_FINE_LOCATION`

Do not add location permission without dedicated permission UX and an updated
Google Play Data Safety review.

## Android Asset Review

- App icon source: `assets/branding/app_icon.png` at 1024 x 1024.
- Android launcher icon resources are present in the `mipmap-*` density
  folders from 48 x 48 through 192 x 192.
- Native splash resources use `sakinah_native_splash.png`,
  `sakinah_splash_icon.xml`, and the Android 12+ launch style instead of the
  default Flutter launcher icon.
- On 2026-06-11, `SC65XWPZ7DLNUSTC` was used for Android splash review with
  the deterministic screenshot build. Evidence path:
  `build/store-screenshots/android-assets/en-splash.png`.
- Local asset regression tests cover launcher icon dimensions and Android
  native splash resource references.

## Build Commands

Build toolchain baseline:

- Gradle wrapper: `8.14` or newer.
- Android Gradle Plugin: `8.11.1` or newer.
- Kotlin Gradle Plugin: `2.2.20` or newer.
- App module: migrated away from directly applying `kotlin-android`; Flutter
  keeps `android.newDsl=false` and `android.builtInKotlin=false` as current
  stable-channel compatibility flags.
- `shared_preferences_android`: upgraded to `2.4.26`, removing its Built-in
  Kotlin warning from local debug builds.

Known toolchain warning:

- Flutter still warns that the `audio_session` and `firebase_analytics`
  Android plugins apply the Kotlin Gradle Plugin instead of Built-in Kotlin.
  Current debug builds pass. `flutter pub outdated --show-all` currently
  reports `audio_session` `0.2.3`, `just_audio` `0.10.5`,
  `firebase_analytics` `12.4.2`, and `firebase_core` `4.10.0` as the latest
  resolvable versions, so there is no package upgrade available yet to clear
  these plugin warnings.
- On 2026-06-11, Android SDK cmdline-tools `latest` was installed into
  `/Users/zhengjinyang/Library/Android/sdk/cmdline-tools/latest`; `sdkmanager`
  reports version `20.0`, and the release gate finds `apkanalyzer` there.
- On 2026-06-11, unsigned release QA now passes with:
  `SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true scripts/verify_google_play_internal_release.sh`.
  The gate verified `apkanalyzer` and `sdkmanager --licenses`, ran release
  readiness tests, `dart analyze`, built the prod release
  `build/app/outputs/bundle/release/app-release.aab` at 57.0 MB, and wrote
  `build/play-internal/app-release.aab.sha256` with SHA-256
  `46e6c74d3f1b484d4ecd6fa090cb9e23f98217eda40781248590b682c664ad60`.
- On 2026-06-11, `flutter doctor --android-licenses` accepted the remaining
  local SDK licenses. `flutter doctor -v` now reports the Android toolchain as
  `[✓]` with "All Android licenses accepted." Repeat this check on CI or any
  final Play upload machine before treating that environment as release-ready.
  The Google Play internal release gate now verifies this with
  `sdkmanager --licenses`.

```sh
flutter pub get
flutter test
dart analyze
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=dev
```

Release signing dry-run with required signing:

```sh
SAKINAH_REQUIRE_RELEASE_SIGNING=true \
flutter build appbundle --release \
  --dart-define=SAKINAH_APP_ENV=prod
```

This command is expected to fail until a local upload key or CI signing
environment variables are supplied.

Google Play internal testing gate:

```sh
scripts/verify_google_play_internal_release.sh
```

This command is expected to fail until upload signing is supplied. After a
successful run, verify the `.aab` and checksum under `build/play-internal/`
before Play Console upload.

Staging example:

```sh
flutter build apk --debug \
  --dart-define=SAKINAH_APP_ENV=staging \
  --dart-define=SAKINAH_CONTENT_API_ENABLED=true \
  --dart-define=SAKINAH_CONTENT_API_BASE_URL=https://staging-content.example
```

Do not pass production tokens from shell history on shared machines.
