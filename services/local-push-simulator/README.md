# Local Push Simulator

Small deterministic HTTP simulator for Sakinah Daily local push validation.

It previews and queues local payloads only. It does not connect to FCM, APNs,
remote CMS, OpenAI, or production push tokens.

## Commands

```sh
cd services/local-push-simulator
npm install
npm test
npm run typecheck
npm run dev
```

## Endpoints

- `GET /health`
- `POST /push/preview`
- `POST /push/send`
- `GET /push/messages`
- `DELETE /push/messages`

## Preview Example

```sh
curl -X POST http://localhost:8790/push/preview \
  -H 'Content-Type: application/json' \
  -d '{
    "language": "id",
    "type": "daily_session",
    "contentId": "session_morning_ease",
    "clusterId": "calm_through_dhikr",
    "ritualMoment": "morning",
    "womenIbadahSafeRequired": true,
    "permissionState": "granted"
  }'
```

Accepted responses include a local payload with `data.type`, `data.contentId`,
`data.clusterId`, and `data.bundleHint`. Blocked responses return
`accepted: false` and a `flags` array.

## Guardrails

The simulator blocks lock-screen copy that contains cycle-sensitive terms,
guaranteed outcome claims, shaming tone, fatwa-like claims, full Quran-like
body text, missing seed content IDs, or payloads that are not marked
lock-screen safe.
