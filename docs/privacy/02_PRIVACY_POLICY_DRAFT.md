# Privacy Policy Draft

Status: Draft for legal/store review. This is implementation-oriented copy,
not final legal advice.

App: Sakinah Daily
Effective date: To be finalized before Google Play submission.
Contact: To be finalized before Google Play submission.

## Summary

Sakinah Daily MVP is designed around local-first preferences and approved
content delivery. The app does not include account login, payments, ads,
tracking SDKs, crash-reporting SDKs, live OpenAI calls, or social features in
the MVP. A Firebase Analytics adapter is present for future retention and usage
measurement, but analytics collection is disabled by default and can only be
enabled in a reviewed build with `SAKINAH_ANALYTICS_ENABLED=true` and Firebase
project configuration.

## Data Stored On Device

- App language and preference settings.
- Prayer calculation settings and manual or preset prayer location.
- Notification enabled state, per-prayer reminder choices, prayer reminder
  lead-time offset, selected daily session reminder time, and locally scheduled
  reminder state.
- Women's Ibadah Mode state, designed local-first.
- Approved content manifest and bundle cache.
- Local revoked content IDs so revoked content stays hidden.
- Saved items and session progress/completion history, stored locally only.

Session progress records store IDs, step position, timestamps, duration,
language code, and total step count. They do not store Quran, Dua, Dhikr,
Hadith, translation text, reflections, or user notes.

Women's Ibadah Mode may change Home recommendations and Daily Session support
copy locally. Exact status remains on device and is not used for remote
personalization in the MVP.

Users can clear this local data from Settings > Privacy > Delete local data.
Bundled seed content and app files remain because they are part of the app.

## Data That May Leave Device

If remote content delivery is enabled, requests may include language, market,
app version, and schema version. Detail-bundle recovery may include a bundle
hint. Women's Ibadah Mode exact status is not sent with these requests.

If analytics is explicitly enabled in a reviewed build, the app may send only
whitelisted Google Analytics 4 events about app flow and prayer/session usage,
such as screen route, prayer name, reminder enabled state, session ID, language,
and coarse location method. The analytics sanitizer blocks exact coordinates,
Women's Ibadah Mode exact status, health terms, feedback text, religious text,
names, and email addresses.

Notification text stays generic when Women's Ibadah Mode is enabled so private
state details do not appear on the lock screen.

## Not Implemented In MVP

- Account login.
- Payments or subscriptions.
- Ads or tracking.
- Default-on analytics collection.
- Crash-reporting SDK.
- Exact GPS permission.
- Remote deletion API.
- Remote progress sync.
- Social sharing or leaderboard features.

## Future Review Needed

Before enabling production analytics, crash reporting, exact location, account
login, or paid features, update this policy, store declarations, consent copy,
and tests.
