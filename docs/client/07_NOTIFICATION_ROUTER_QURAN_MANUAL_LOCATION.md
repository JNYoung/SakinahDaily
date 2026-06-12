# Notification Router, Quran Entry, And Manual Location

Status: MVP client foundation.

This milestone completes app-facing routing for local notification taps, adds a
small Quran entry/detail surface, and gives prayer location a manual settings
page. It does not add GPS, compass/sensor permissions, FCM/APNs server push,
default-on analytics, crash reporting, live CMS calls, full Quran corpus
downloads, Quran TTS, or new religious content.

## Notification Tap Routing

`NotificationTapRouteListener` watches the resolved
`notificationTapResultProvider` value at the app level.

- Handled tap results with a route navigate through the app router.
- Results are cleared after handling so rebuilds do not replay the navigation.
- Unhandled or malformed results are cleared without showing sensitive payload
  details.
- Platform notification services still only emit a payload into the testable
  notification tap service; they do not know about `GoRouter`.
- Cold-start notification launch details are read once at app startup, resolved
  by `NotificationTapService`, routed, and cleared so rebuilds do not replay the
  navigation.

Prayer reminders continue to use the local JSON payload documented in
`docs/client/06_NOTIFICATION_TAP_QIBLA_SAVED.md`.

## Quran Page MVP Scope

The Quran entry page at `/quran` shows a featured seed ayah from the current
daily session and a saved Quran verses section. It uses local seed/cache content
through the existing repository layer only.

The page explicitly keeps MVP audio safety visible:

- Quran recitation is voice-only.
- No background music is played under Quran recitation.
- Quran TTS is not used.
- No full Quran corpus is downloaded.

## Quran Verse Detail

The verse detail route is `/quran/:verseKey`. The page loads an approved local
`QuranAyah` by verse key, shows Arabic text, translation, source, and Quran
audio safety copy, and supports local save/unsave as `quranVerse`.

Missing verses show a safe unavailable state. The client does not generate
Quran text, translations, Hadith, Dua, Dhikr, or religious explanations.

Saved Quran verse items now navigate back to `/quran/:verseKey` instead of a
generic Home fallback. Local push Quran payloads with an available local verse
also resolve to the Quran verse detail route.

## Manual Prayer Location

The manual prayer location page at `/settings/prayer-location` lets the user
save:

- location label
- latitude
- longitude
- optional timezone ID
- prayer calculation method

Latitude is validated to `-90..90`, longitude to `-180..180`, and the label must
be non-empty. Saved values update the existing local `PrayerSettings`, which are
used by prayer times and Qibla.

## Privacy Notes

- Manual prayer location is stored locally through user preferences.
- Qibla continues to use the selected prayer location only.
- Exact GPS is not requested.
- Compass and sensor permissions are not requested.
- Saved Quran verse references stay local-only and are cleared by Delete local
  data.

## Future Work

- iOS cold-start notification launch validation.
- Approved expanded Quran corpus routing after source import review.
- Licensed reciter assets and offline audio cache validation after rights and
  hashes are approved.
- Optional sensor compass only after a separate permission and privacy review.
