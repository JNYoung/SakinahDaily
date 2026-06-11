# Google Play Data Safety Draft

Status: Draft for legal/store review. Do not submit as final without review.

Before submission, choose a public HTTPS privacy policy URL and verify it with
`scripts/verify_google_play_public_links.sh`. The same privacy policy URL must
be used in Play Console App content, Data safety, and the final store upload
preflight.

## Local-Only Data

The MVP stores app preferences, prayer settings, notification enabled state,
per-prayer reminder choices, prayer reminder lead-time offset, selected daily
session reminder time, local closed-testing feedback-sent day markers,
Women's Ibadah Mode state, saved items, session progress/completion history,
local
content manifests, approved content bundles, and revoked content IDs on device.
These are cleared through Settings > Privacy > Delete local data.

Closed-testing feedback status stores only whether Day 1, Day 3, Day 7, or
Day 14 was marked sent in the in-app guide. It does not store feedback text,
tester identity, health details, or Women's Ibadah Mode status.
The app does not store feedback text, tester identity, health details, or
Women's Ibadah Mode status.

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
- Boot completed: used only to restore local scheduled notification reminders
  after device reboot or package replacement.
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
subscriptions, remote saved-item sync, remote progress sync, or any remote
deletion workflow.
