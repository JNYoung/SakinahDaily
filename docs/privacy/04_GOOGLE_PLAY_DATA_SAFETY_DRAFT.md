# Google Play Data Safety Draft

Status: Draft for legal/store review. Do not submit as final without review.

## Local-Only Data

The MVP stores app preferences, prayer settings, notification enabled state,
Women's Ibadah Mode state, saved items, local content manifests, approved
content bundles, and revoked content IDs on device. These are cleared through
Settings > Privacy > Delete local data.

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

## Permissions

- Notifications: used for local prayer reminders after user explanation and
  permission.
- Location: exact GPS permission is not implemented in MVP. Manual or preset
  prayer location is local by default and is used for prayer times and Qibla.

## Third-Party SDKs

- Flutter and app runtime dependencies.
- `shared_preferences` for local app storage.
- `flutter_local_notifications` for local notifications.
- Audio playback dependencies for approved audio asset playback.
- No analytics SDK.
- No crash-reporting SDK.
- No ads SDK.
- No tracking SDK.

## Future Updates

Revisit this draft before adding exact location, compass/sensor permissions,
FCM/APNs production pushes, analytics, crash reporting, accounts,
subscriptions, remote saved-item sync, or any remote deletion workflow.
