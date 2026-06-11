# SDK And API Inventory

Status: Draft for legal/store review.

## Current Client SDKs And APIs

| SDK/API | Purpose | Sends user data? | Notes |
|---|---|---:|---|
| Flutter framework | App runtime | No direct app data collection by this code | Platform behavior still needs store review |
| Riverpod | Client state management | No | In-process only |
| go_router | Client routing | No | In-process only |
| shared_preferences | Local preference/cache storage | No | Stores app preferences and MVP content cache locally |
| flutter_local_notifications | Local notifications | No remote send by this code | Uses platform notification permission |
| prayer calculation library | Prayer times | No | Uses local manual/preset settings |
| audio playback library | Approved audio playback | No by this code | No persistent playback history in MVP |
| Remote content API client | Manifest and bundle fetch | Yes, request metadata | Disabled by default, no live CMS calls in tests |
| Analytics event contract / local stub | Privacy-safe event taxonomy and QA-only local recording | No remote send by this code | default-off; used for tests and local QA |
| Google Analytics / Firebase Analytics SDK | Optional retention and usage telemetry for reviewed QA or release builds | Yes, only when explicitly enabled and configured | `SAKINAH_ANALYTICS_ENABLED=true` plus Firebase project configuration is required; Android automatic collection and screen reporting are disabled by default; Store screenshot mode forces analytics off |

## Not Implemented

- Crash-reporting SDK.
- Ads SDK.
- Tracking SDK.
- ATT prompt.
- Account login.
- Payments or subscriptions.
- Exact GPS permission.
- FCM/APNs production push tokens.
- Live OpenAI calls.

## Remote Content Request Fields

Allowed manifest request fields:

- `language`
- `market`
- `app_version`
- `schema_version`

Allowed detail recovery fields:

- `bundle_hint`
- `language`
- `market`
- `schema_version`

Women's Ibadah Mode exact status must not be included.
