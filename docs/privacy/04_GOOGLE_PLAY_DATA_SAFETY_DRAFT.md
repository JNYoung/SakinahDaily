# Google Play Data Safety Draft

Status: Draft for legal/store review. Do not submit as final without review.

## Local-Only Data

The MVP stores app preferences, prayer settings, selected prayer location
(device, manual, or preset), notification enabled state, selected daily session
reminder time, Women's Ibadah Mode state, saved items, session
progress/completion history, local content manifests, approved content bundles,
and revoked content IDs on device. These are cleared through Settings > Privacy
> Delete local data.

Women's Ibadah Mode can adjust Home recommendations and Daily Session support
copy locally. Exact status is not transmitted for remote personalization in the
MVP.

Session progress/completion history stores local session IDs, step index,
timestamps, duration, language code, and total step count only. It does not
store Quran, Dua, Dhikr, Hadith, translation text, reflections, or user notes.

Draft note: Google Play Data Safety focuses on data collected from or shared
off device. Confirm final treatment of local-only data before submission.

## Data That May Be Transmitted

Remote content requests may include:

- language
- market
- app version
- schema version
- bundle hint for detail recovery

No Women's Ibadah Mode exact status is included in remote content requests.
Notification copy remains generic when Women's Ibadah Mode is enabled and does
not include exact private state terms.

## Permissions

- Notifications: used for local prayer reminders after user explanation and
  permission.
- Location: foreground coarse device location is used after explanation and
  permission for prayer times and Qibla. Manual entry remains available when
  permission is denied or location is unavailable. Fine/background location,
  compass, and sensor permissions are not implemented.

## Third-Party SDKs

- Flutter and app runtime dependencies.
- `shared_preferences` for local app storage.
- `flutter_local_notifications` for local notifications.
- `geolocator` for foreground coarse device location used in prayer/Qibla
  setup.
- Audio playback dependencies for approved audio asset playback.
- No analytics SDK.
- No crash-reporting SDK.
- No ads SDK.
- No tracking SDK.

## Future Updates

Revisit this draft before adding fine/background location, compass/sensor
permissions, FCM/APNs production pushes, analytics, crash reporting, accounts,
subscriptions, remote saved-item sync, remote progress sync, or any remote
deletion workflow.
