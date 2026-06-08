# Prayer Device Location QA

Status: Required before v0.1 beta sign-off.

## Product Baseline

v0.1 uses device location for prayer time and Qibla setup, with manual location
as the required fallback. Location stays local in MVP and is not used for
background tracking, analytics, remote personalization, or content requests.

Android implementation scope:

- Request `ACCESS_COARSE_LOCATION`.
- Do not request `ACCESS_FINE_LOCATION`.
- Do not request background or foreground-service location.
- Do not request compass or sensor permissions.

iOS implementation scope:

- Blocked until an iOS project/runtime is available.
- Future implementation should use When In Use location copy only.
- Do not add Always/background location without a separate review.

## Android Real-Device Matrix

Run on at least one fresh physical Android device before beta. Prefer one
Android 13+ device because notification and location prompts are both runtime
permissions.

| Scenario | Steps | Expected result |
|---|---|---|
| Fresh allow | Fresh install, open onboarding, read location explanation, tap Use device location, allow permission | App saves Device location, Home/Prayer show calculated times, no crash |
| Approximate/coarse | Choose approximate/coarse location if the OS offers it | App still saves Device location and prayer times calculate |
| Deny once | Fresh install or reset app permission, tap Use device location, deny | App shows manual fallback message and manual fields remain usable |
| Deny forever/settings blocked | Deny repeatedly or disable in system settings, tap Use device location | App shows blocked fallback message and does not loop permission prompts |
| Location services off | Turn off device location services, tap Use device location | App shows services-off fallback message and manual entry remains usable |
| Manual fallback save | After any denied/unavailable state, enter manual label/lat/lon and save | Prayer page and Qibla use the manual location |
| Reopen app | Kill and reopen after saving device location | Saved prayer location persists locally |
| Delete local data | Save device location, then Settings > Privacy > Delete local data | Prayer location resets to defaults and scheduled reminders are cleared |

## Evidence To Capture

- Device model, Android version, app build, and date.
- Screenshots or short screen recordings for allow, deny, and manual fallback.
- `adb logcat` excerpt if any permission or location failure occurs.
- Confirmation that the Android permission screen does not request background
  location.
- Confirmation that Prayer page still opens after denial.

## Sign-Off Rule

Do not mark Prayer ready for beta until the allow path and at least one denied
fallback path pass on a physical Android device.
