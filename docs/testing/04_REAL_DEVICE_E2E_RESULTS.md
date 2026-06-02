# Real Device E2E Results

Use this file to record physical-device QA runs. Evidence directories under
`build/e2e/` are local artifacts and are not committed.

## 2026-06-02 Smoke Run

Device ID/model: `SC65XWPZ7DLNUSTC` / `PKB110`

Android version: `16`

Build command:

```sh
DEVICE_ID=SC65XWPZ7DLNUSTC scripts/android_e2e/real_device_smoke.sh
```

Modules tested:

- M0 build, install, launch, native shell smoke.
- Onboarding first screen screenshot capture.

Pass:

- Debug APK built successfully.
- ADB install passed on the physical device.
- Cold launch passed with `Status: ok`, `LaunchState: COLD`,
  `TotalTime: 1394`, and `Activity: com.sakinahdaily.app/.MainActivity`.
- `dumpsys activity` showed `com.sakinahdaily.app/.MainActivity` as the
  top resumed activity.
- Screenshot captured the Sakinah Daily onboarding screen with location
  explanation shown before the device-location permission request.
- No app crash signature was found in the captured logcat tail.

Fail:

- No functional module walkthrough was run in this smoke pass.
- Notification and location permission branch QA still need controlled manual
  runs.

Evidence directory:

```text
build/e2e/20260602-122824
```

Open bugs:

- None from this smoke run.

Next run focus:

- M1 onboarding language/RTL/manual-location walkthrough.
- M2 prayer location allow/deny matrix.
- M6 real-device notification permission and reminder behavior.
