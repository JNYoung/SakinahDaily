# Privacy Data Inventory

Status: Draft for legal/store review.

This document mirrors the MVP client inventory implemented in
`lib/core/privacy/privacy_data_inventory.dart`. It is not a final legal
classification.

## Categories

| Category | Collected? | Stored locally? | Transmitted? | Shared? | Required? | Purpose | Deletion path | Store note |
|---|---:|---:|---:|---:|---:|---|---|---|
| App preferences | Yes | Yes | No by default | No | Optional | Language, gender mode, audio preference, prayer settings | Settings > Privacy > Delete local data | Local app preference candidate |
| Prayer location preset / manual location | Yes, when selected | Yes | No by default | No | Optional | Prayer-time and Qibla calculation | Settings > Privacy > Delete local data | Manual/preset location only; no GPS or sensor permission in MVP |
| Notification preferences | Yes | Yes | No by default | No | Optional | Local reminder scheduling, per-prayer choices, prayer reminder lead-time offset, and daily session reminder time | Settings > Privacy > Delete local data | Notification permission should be declared separately |
| Closed testing feedback status | Yes, when tester marks a prompt sent | Yes | No | No | Optional | Remember whether Day 1, Day 3, Day 7, or Day 14 feedback was marked sent | Settings > Privacy > Delete local data | Stores day IDs only; no feedback text or personal details |
| Women's Ibadah Mode state | Yes, if enabled | Yes | No | No | Optional | Local privacy-aware reminder behavior and local UI recommendation adjustments | Settings > Privacy > Delete local data | High sensitivity, local-only in MVP |
| Local content cache | Yes | Yes | No | No | Operational | Store approved published bundles and revocation IDs | Settings > Privacy > Delete local data | Content cache is local device data |
| Saved items | Yes, when user saves content | Yes | No | No | Optional | Local shortcuts to saved sessions, duas, dhikr, and verse references | Settings > Privacy > Delete local data | Local-only saved content list |
| Session progress and completion history | Yes, when user starts or completes a session | Yes | No | No | Optional | Resume sessions and show local progress summary | Settings > Privacy > Delete local data | Stores session IDs and timestamps only |
| Remote content request metadata | Yes, when remote API is enabled | No durable client storage by default | Yes | Possible server/CDN logs | Operational | Request manifest/detail bundles | Server log deletion is future work | Language, market, app version, schema version only |
| Audio playback state | No persistent history in MVP | No | No | No | No | Playback runtime only | Not applicable | No playback history claim for MVP |
| Analytics consent preference | Yes | Yes | No | No | Optional | Remember whether usage analytics is allowed in analytics-enabled builds | Settings > Privacy > Delete local data | Default false; local switch controls Firebase Analytics collection |
| Default-off analytics events | Only when explicitly enabled, configured, and opted in | No durable client storage by default | Yes, only when `SAKINAH_ANALYTICS_ENABLED=true`, Firebase configuration is present, and the user opts in | Firebase/Google as analytics processor when enabled | Optional | Retention and prayer/session usage analysis after review | Turn off usage analytics in Privacy Center; remote deletion is future work | Whitelisted GA4 events only; no exact coordinates, Women's Ibadah Mode exact status, feedback text, religious text, names, or email |
| Crash reporting | Not implemented | No | No | No | No | Future reliability analysis after review | Not applicable | Do not declare as implemented |
| Account data | Not implemented | No | No | No | No | Future account features | Not applicable | No account collection in MVP |
| Payments/subscription | Not implemented | No | No | No | No | Future monetization | Not applicable | No payment collection in MVP |
| Ads/tracking | Not implemented | No | No | No | No | Not in MVP | Not applicable | No tracking SDK or ATT prompt in MVP |

## Guardrails

- Women's Ibadah Mode exact status must not be included in remote content API
  requests.
- Women's Ibadah Mode may affect Home and Daily Session recommendations locally,
  but exact state must not leave the device.
- Lock-screen notification copy must stay generic and must not include
  menstruation, postpartum, cycle, or similar sensitive terms.
- Content API tokens must not be displayed in the Privacy Center.
- Delete local data must clear preferences, saved items, cached manifests,
  cached bundles, revoked content IDs, session progress/history, and scheduled
  local reminders.
- Delete local data must not delete seed assets or bundled app files.
- Manual prayer location remains local-only in MVP and must not trigger exact
  GPS, coarse location, compass, or sensor permissions.
- Session progress/history must not store Quran, Dua, Dhikr, Hadith, or
  translation text and must not sync remotely in MVP.
- Analytics is default-off, Android automatic collection is disabled by
  manifest metadata, Store screenshot mode forces analytics off, and the
  Privacy Center opt-in must be on before events are sent.
