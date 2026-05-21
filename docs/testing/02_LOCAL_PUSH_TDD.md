# Local Push TDD

Local push simulation validates Sakinah Daily push behavior without real FCM,
APNs, production tokens, remote CMS, or live network services.

## What It Validates

- Daily push payload shape and safe JSON parsing.
- Multi-language title and body copy for English, Indonesian, and Arabic.
- Women’s Ibadah Mode lock-screen privacy blocks.
- Deep-link routing for seed Daily Session, Dua, Dhikr, and Quran fallback.
- Missing-content fallback without inventing religious source text.
- Permission-denied behavior for local notification scheduling.
- Simulator preview, send, queue, list, and clear flows.

## What It Does Not Validate

- Real device delivery through FCM or APNs.
- Production push token registration.
- Remote CMS fetches or publishing workflows.
- Full Quran corpus delivery.
- Licensed audio availability.
- Any AI-generated religious answer or fatwa behavior.

## Flutter Tests

```sh
flutter test
dart analyze
```

If `flutter analyze` crashes under the current Chinese-character workspace
path, use `dart analyze` as the stable local static-analysis gate and record
the Flutter analysis-server blocker.

## Simulator

```sh
cd services/local-push-simulator
npm install
npm test
npm run typecheck
npm run dev
```

## Example Payload

```json
{
  "id": "local_push_daily_session_session_morning_ease_id",
  "type": "daily_session",
  "contentId": "session_morning_ease",
  "clusterId": "calm_through_dhikr",
  "bundleHint": "daily_session_detail_session_morning_ease",
  "languageCode": "id",
  "title": "Mulai dengan lembut",
  "body": "Sesi Sakinah singkat sudah siap.",
  "lockScreenSafe": true,
  "data": {
    "type": "daily_session",
    "contentId": "session_morning_ease",
    "clusterId": "calm_through_dhikr",
    "bundleHint": "daily_session_detail_session_morning_ease"
  }
}
```

## Women’s Mode Privacy

Lock-screen copy is blocked when it includes cycle-sensitive terms such as
menstruation, period, cycle, postpartum, nifas, haidh, الحيض, or النفاس.
Sensitive women’s mode state remains local-first and is not uploaded by this
simulator.

## Production Difference

Production FCM/APNs will eventually validate delivery, platform permission
prompts, token lifecycle, and server-triggered fanout. This simulator only
checks local payload generation, guardrails, queue behavior, and client-side
route resolution.

## Why This Exists

Push notifications are a lock-screen surface, so privacy, localization, and
religious-content safety have to be testable before any production push system
exists. This TDD layer keeps Quran/Dua/Dhikr behavior deterministic and ensures
the app falls back safely when local content is missing.
