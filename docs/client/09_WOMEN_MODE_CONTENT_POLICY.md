# Women's Mode Content Policy

Status: MVP client foundation.

This milestone makes Women's Ibadah Mode affect local recommendations and
Daily Session UI while keeping the exact mode on device. It does not add
medical advice, fatwa/legal rulings, analytics, account sync, remote women
status sync, FCM/APNs server push, live CMS calls, or generated religious
content.

## Local-Only Policy

`WomenModeContentPolicy` evaluates the local `WomenIbadahMode` state and
returns a client-only decision:

- disabled or normal: standard content remains available.
- menstruating or postpartum: prefer dua, dhikr, and reflection-oriented
  recommendations.
- pregnancy: standard content remains available with gentle support copy.
- prefer not to track: standard content remains available with privacy-safe
  copy.

The policy is intentionally UI guidance, not a religious ruling. The client
does not say that a user can or cannot perform an act of worship.

## Home Behavior

When the local mode calls for support, Home shows a privacy-safe label:

- private gentle path
- local-only mode
- generic note that dua, dhikr, and reflection remain easy to reach

Home does not display exact state words for menstruation, postpartum, cycle, or
similar terms. The existing session remains reachable until a reviewed
dua/dhikr/reflection-specific session exists.

## Daily Session Behavior

Daily Session shows a local-only note when Women's Ibadah Mode is enabled with
a private state. The note says the mode stays on this device and that the
session keeps a gentle worship-friendly path.

The app does not hide Quran content in this milestone and does not rewrite
religious content. Surrounding UI copy stays gentle and avoids guilt, shame,
medical claims, or fatwa-like language.

## Notification Privacy

Prayer reminder copy remains generic when Women's Ibadah Mode is enabled.
Notification titles, bodies, and tap payloads must not expose exact status
terms. Lock-screen copy should never include menstruation, postpartum, cycle, or
similar private terms.

## Remote Request Privacy

Remote manifest requests continue to include only:

- app version
- language
- market
- schema version

Exact Women's Ibadah Mode status, gender mode, cycle day, and private state
terms are not sent to the remote content API.

## Future Review Needed

- Add a reviewed safe-session content model if the product wants a dedicated
  dua/dhikr/reflection session.
- Review any future remote personalization or account sync as sensitive data
  processing before implementation.
- Revisit store/privacy declarations before enabling analytics, crash
  reporting, server-triggered push, or remote recommendation logic.
