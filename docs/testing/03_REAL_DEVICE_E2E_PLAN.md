# Real Device E2E Test Plan

Status: active QA plan for MVP v0.1.

This plan turns the existing product requirements into testable modules for a
physical Android device. It complements `flutter test` and `dart analyze`; it
does not replace them.

## 1. Nightly Test Rhythm

Use this split so development work and device QA do not fight each other.

| Time | Scope | Owner mode | Output |
|---|---|---|---|
| Before night run | `flutter test`, `dart analyze`, debug APK build | automated | terminal logs |
| Night unattended | Install, launch, screenshot, logcat tail | automated script | `build/e2e/<timestamp>/` |
| Manual QA window | Permission prompts, notifications, route walkthroughs | human-assisted | checklist notes and screenshots |
| Next dev session | Fix regressions, update docs/tests | Codex/dev | PR summary |

Night unattended runs should avoid destructive actions, OS permission toggles,
and Delete Local Data. Those belong in manual QA windows because they need the
phone state to be intentionally controlled.

## 2. Device Setup

Required before physical-device QA:

- Android phone remains connected over USB with USB debugging authorized.
- Phone is awake or configured to stay awake while charging.
- App package is `com.sakinahdaily.app`.
- `adb` is available at `$HOME/Library/Android/sdk/platform-tools/adb`, or set
  `ADB=/path/to/adb`.
- Prefer setting `DEVICE_ID=<physical-device-id>` so the emulator is not chosen
  accidentally.

Useful command:

```sh
$HOME/Library/Android/sdk/platform-tools/adb devices
```

## 3. Automated Smoke Entry

Run the physical-device smoke script:

```sh
DEVICE_ID=SC65XWPZ7DLNUSTC RUN_FLUTTER_TESTS=1 \
  scripts/android_e2e/real_device_smoke.sh
```

For a night run:

```sh
mkdir -p build/e2e
nohup env DEVICE_ID=SC65XWPZ7DLNUSTC RUN_FLUTTER_TESTS=1 \
  scripts/android_e2e/real_device_smoke.sh \
  > build/e2e/nightly-real-device.log 2>&1 &
```

The script captures:

- Flutter test/analyzer logs when enabled.
- Debug APK build log.
- ADB install and launch logs.
- A device screenshot.
- Recent logcat output.
- The currently resumed Android activity when available.

For route-specific QA/store screenshots, run:

```sh
DEVICE_ID=SC65XWPZ7DLNUSTC \
  scripts/android_e2e/capture_route_screenshots.sh
```

This uses the dev/staging-only `SAKINAH_INITIAL_ROUTE` dart-define to open
stable routes directly. Production builds ignore that override.

## 4. Module Matrix

### M0. Build, Launch, And Native Shell

Automated gate:

- `flutter test`
- `dart analyze`
- `flutter build apk --debug --dart-define=SAKINAH_APP_ENV=dev`
- Install and launch on the physical Android device.

Pass criteria:

- App launches without crash.
- Native splash/app icon appear.
- No fatal errors in logcat.

Evidence:

- Build log.
- Launch log.
- Home or onboarding screenshot.
- Device model and Android version.

### M1. Onboarding And Localization

Requirements:

- User can complete onboarding.
- English, Indonesian, and Arabic are usable.
- Arabic switches to RTL.
- Location explanation appears before device permission.
- City preset location fallback remains available, with advanced manual
  coordinate editing still possible.

Manual true-device flow:

1. Fresh install or clear app data intentionally.
2. Open app.
3. Check splash -> onboarding.
4. Select English, Indonesian, then Arabic in separate runs.
5. Confirm Arabic layout is RTL.
6. Confirm device-location CTA shows explanatory copy before OS permission.
7. Use city preset location path and continue to Home.

Pass criteria:

- No blocked onboarding path.
- No hardcoded English on core Arabic/Indonesian surfaces.
- Location permission is not requested before app copy explains the purpose.

### M2. Home, Prayer, And Qibla

Requirements:

- Home shows next prayer countdown.
- Prayer page shows calculated Fajr, Dhuhr, Asr, Maghrib, Isha.
- Device location and manual location both work.
- Qibla uses selected prayer location without compass/sensor permission.

Manual true-device flow:

1. From Home, open the prayer badge.
2. Verify prayer list renders.
3. Open Qibla quick action.
4. Verify Qibla page opens from selected location.
5. In Settings, open Prayer location, choose Jakarta or Dubai, and confirm
   latitude, longitude, timezone, and method are filled.
6. Return to Prayer and Qibla.

Pass criteria:

- Prayer/Qibla remain usable after denied or unavailable device location.
- Android permission screen requests coarse foreground location only.
- No fine/background/compass/sensor permission is requested.

See also `docs/release/08_PRAYER_DEVICE_LOCATION_QA.md` for the detailed
permission matrix.

### M3. Daily Session And Audio Safety

Requirements:

- Daily Session completes Intention -> Quran -> Reflection -> Dua -> Dhikr ->
  Completion.
- Quran step does not enable BGM.
- Quran step does not use Quran TTS.
- Dua step shows source and review status.
- Completion can save session and set a local reminder.

Manual true-device flow:

1. Start Today's Sakinah from Home.
2. Advance through each step.
3. On Quran step, verify text-only/audio fallback copy and no BGM affordance.
4. On Dua step, tap the source chip and verify Content Sources opens.
5. On Dhikr step, tap counter several times.
6. Finish session.
7. Save session and set daily reminder.

Pass criteria:

- Session completes without crash.
- Quran safety copy remains visible.
- Completion history and save actions persist locally.

### M4. Quran

Requirements:

- Quran entry opens from Home.
- Featured ayah detail route opens.
- Verse detail shows Arabic, translation, source, review status, and voice-only
  safety copy.
- Saved Quran verse returns to detail.

Manual true-device flow:

1. Open Home -> Quran quick action.
2. Open featured ayah.
3. Save ayah.
4. Open Settings -> Saved Items.
5. Tap saved ayah.
6. Tap source chip and verify Content Sources.

Pass criteria:

- No generated Quran text or TTS is exposed.
- Placeholder source labels are visible only as current seed blocker, not as
  production-ready copy.

### M5. Dua And Dhikr Discovery

Requirements:

- Dua library categories, search, detail, source, review status, save.
- Dhikr categories, search, manual counter, target count, save.
- Empty search states are safe and calm.

Manual true-device flow:

1. Open Dua tab.
2. Filter a category and search.
3. Open `dua_ease`, save it, and tap source chip.
4. Open Dhikr tab.
5. Filter/search, select `dhikr_subhanallah`.
6. Tap counter and save.
7. Check Saved Items contains the saved Dua/Dhikr.

Pass criteria:

- Source and review status are visible.
- Source chips route to Content Sources.
- Saved items remain local-only.

### M6. Notifications And Deep Links

Requirements:

- Prayer reminders can be enabled/disabled.
- Daily session reminder can be enabled/disabled and rescheduled.
- Permission denial does not break app usage.
- Notification tap routes safely to Prayer, Session, Quran, or Dua.
- Lock-screen copy is privacy safe.

Manual true-device flow:

1. Open Settings -> Notification settings.
2. Toggle daily session reminder on and set a time.
3. Toggle prayer reminders on/off from Settings.
4. If OS notification permission appears, allow and deny in separate controlled
   runs.
5. Use local push or scheduled reminder flow to validate tap routing when
   practical.

Pass criteria:

- Denial keeps toggles and app navigation sane.
- Notification copy never reveals exact Women's Ibadah Mode status.
- Taps do not replay after navigation.

### M7. Women’s Ibadah Mode And Privacy

Requirements:

- Women’s Mode is local-first.
- Menstruating/postpartum/pregnancy state is not uploaded.
- Sensitive state does not appear on lock-screen copy.
- Home/session recommendations can become gentle without fatwa-like claims.

Manual true-device flow:

1. Open Settings -> Women’s Ibadah Mode.
2. Select Menstruating and save/start.
3. Verify Home local-only support card.
4. Start Daily Session and verify local-only note.
5. Confirm notification copy remains generic.

Pass criteria:

- Copy is respectful and non-medical.
- No remote request is triggered by sensitive mode state.
- Delete Local Data clears local women-mode preferences.

### M8. Settings, Privacy, And Local Data

Requirements:

- Settings exposes language, prayer method, prayer location, notifications,
  saved items, content sources, privacy, and Women’s Mode.
- Privacy Center explains local-only and leaving-device data.
- Delete Local Data clears preferences, saved items, progress, cache, and
  reminders.

Manual true-device flow:

1. Open Settings.
2. Visit Content Sources and Privacy Center.
3. Visit Privacy Data Inventory.
4. Save a session/Dua/Dhikr/ayah.
5. Use Delete Local Data only in a controlled manual run.
6. Confirm saved/progress data is reset.

Pass criteria:

- No content API token or secret renders.
- Deletion requires confirmation and succeeds.

### M9. Content Delivery And Trust

Requirements:

- Client filters out draft, in-review, rejected, and revoked content.
- CMS content must be published and approved before display.
- Content Sources explains seed/CMS/review status/no-generated-religious-text.
- Item-level source chips open Content Sources.

Automated gate:

- `test/content_sources_page_test.dart`
- `test/client_content_cache_test.dart`
- `test/remote_content_api_client_test.dart`

Manual true-device flow:

1. Open Content Sources from Settings.
2. Open source chips from Dua, Dhikr, Quran, Daily Session Dua.
3. Verify no tokens/secrets render.

Pass criteria:

- User has a visible trust path from religious content to source policy.

### M10. Visual, Store, And Release Readiness

Requirements:

- Required store screens can be captured.
- English, Indonesian, Arabic/RTL layouts do not overflow.
- App icon and native splash are reviewed on Android.

Manual true-device flow:

1. Capture Splash, Home, Daily Session Quran, Dua Detail, Dhikr, Prayer,
   Women’s Mode, Privacy Center, Settings.
2. Repeat for English, Indonesian, Arabic where practical.
3. Check text overflow, clipping, and RTL direction.

Pass criteria:

- Screens are usable for store review drafts.
- No sensitive Women’s Mode status is captured on external/lock-screen
  surfaces.

## 5. Current Blockers To Track

- Approved content inventory is still below beta target.
- Licensed Quran reciter assets and audio hashes are not finalized.
- iOS runtime/project QA remains blocked.
- `flutter analyze` may crash under the current Chinese-character workspace
  path; use `dart analyze` as the stable gate and record the blocker.
- Real-device notification timing/OEM scheduling requires phone-specific QA.

## 6. Result Recording Template

Create a short note after each real-device run:

```text
Date:
Device ID/model:
Android version:
Build command:
Modules tested:
Pass:
Fail:
Evidence directory:
Open bugs:
Next run focus:
```
