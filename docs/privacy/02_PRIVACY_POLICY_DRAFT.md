# Privacy Policy Draft

Status: Draft for legal/store review. This is implementation-oriented copy,
not final legal advice.

## Summary

Sakinah Daily MVP is designed around local-first preferences and approved
content delivery. The app does not include account login, payments, ads,
analytics SDKs, crash-reporting SDKs, live OpenAI calls, or social features in
the MVP.

## Data Stored On Device

- App language and preference settings.
- Prayer calculation settings and manual or preset prayer location.
- Notification enabled state and locally scheduled reminder state.
- Women's Ibadah Mode state, designed local-first.
- Approved content manifest and bundle cache.
- Local revoked content IDs so revoked content stays hidden.
- Saved items and session progress/completion history, stored locally only.

Session progress records store IDs, step position, timestamps, duration,
language code, and total step count. They do not store Quran, Dua, Dhikr,
Hadith, translation text, reflections, or user notes.

Users can clear this local data from Settings > Privacy > Delete local data.
Bundled seed content and app files remain because they are part of the app.

## Data That May Leave Device

If remote content delivery is enabled, requests may include language, market,
app version, and schema version. Detail-bundle recovery may include a bundle
hint. Women's Ibadah Mode exact status is not sent with these requests.

## Not Implemented In MVP

- Account login.
- Payments or subscriptions.
- Ads or tracking.
- Analytics SDK.
- Crash-reporting SDK.
- Exact GPS permission.
- Remote deletion API.
- Remote progress sync.
- Social sharing or leaderboard features.

## Future Review Needed

Before enabling analytics, crash reporting, exact location, account login, or
paid features, update this policy, store declarations, consent copy, and tests.
