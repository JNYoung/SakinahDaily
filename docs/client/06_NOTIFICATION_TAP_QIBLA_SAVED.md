# Notification Tap, Qibla, And Saved Items

Status: MVP client foundation.

This milestone closes three client-side usability gaps without adding live
push services, GPS, compass sensors, remote saved-item sync, analytics, or
new religious content.

## Notification Tap Flow

Local notification taps are parsed by `NotificationTapService`. The app-level
bridge stores the resolved result in Riverpod state, and the router listens for
handled routes.

- Prayer reminder payloads resolve to `/prayer`.
- Daily-session payloads remain compatible with `LocalPushReceiver` and open
  `/session/:id` only when local or recovered approved content is available.
- Dua payloads can fall back to `/dua/:id`.
- Dhikr payloads can fall back to `/dhikr/:id`.
- Malformed payloads return an unhandled result with safety flags.
- Missing content can use a safe fallback route, but the client does not invent
  Quran, Dua, Dhikr, Hadith, or translation content.

Prayer reminders use a local JSON tap payload:

```json
{
  "type": "prayer",
  "contentId": "prayer",
  "fallbackRoute": "/prayer"
}
```

The payload intentionally does not include Women's Ibadah Mode exact status.

## Local Push Compatibility

Existing local push payloads can still include `bundleHint`, `languageCode`,
localized title/body, lock-screen safety flags, and nested `data`. The
notification tap service delegates daily-session resolution to
`LocalPushReceiver` so content cache recovery and missing-content fallback stay
centralized.

No FCM/APNs server push, production tokens, or live CMS calls are added.

## Qibla

The Qibla page at `/qibla` calculates an initial bearing from the selected
manual or preset prayer location to the Kaaba coordinates:

- latitude: `21.4225`
- longitude: `39.8262`

The page shows the selected location label, bearing in degrees, a static
compass-style visual, and a link back to prayer location settings.

No GPS permission, compass permission, sensors plugin, or live location lookup
is used in this MVP. The in-app copy states that exact GPS is not required.

## Saved Items

Saved items are stored by `SavedItemsRepository` through local
`SharedPreferences` storage. Tests use `InMemorySavedItemsStore`.

Supported saved item types:

- `dailySession`
- `dua`
- `dhikr`
- `quranVerse`

The repository de-duplicates by type and item id. It supports list, save,
remove, toggle, and clear operations.

The Saved Items page at `/saved` lists local saved items, supports removal, and
navigates back to available local content. Empty state copy makes the local-only
behavior explicit.

## Save Tonight

Home's Save Tonight button saves the current daily session with the night-card
title snapshot when no dedicated tonight session exists. The button changes to
the saved state and does not create duplicate saved items.

## Privacy Notes

- Saved items remain local-only.
- Qibla uses the selected prayer location already stored for prayer times.
- Delete local data clears saved items along with preferences, cache, and local
  reminders.
- No account, remote saved-item sync, analytics SDK, crash SDK, ads, tracking,
  live CMS calls, or remote deletion API is implemented.

## Future Work

- Cold-start notification tap handoff from platform launch details.
- Detail pages for saved Quran verse references after approved corpus routing.
- Optional cloud sync only after account, consent, privacy, and deletion
  workflows are designed and reviewed.
- Sensor-based compass only after a separate permission/privacy review.
