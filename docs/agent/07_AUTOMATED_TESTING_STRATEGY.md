# Content Agent Automated Testing Strategy

## Goal

The automated suite must prove that the Content Agent can prepare safe, source-backed push drafts without publishing, sending FCM, or making unsupervised religious claims.

## Test Layers

1. Unit tests for pure domain logic:
   - candidate source selection
   - language fallback
   - cooldown filtering
   - women lock-screen safety filtering
   - guardrail flagging
2. Content fixture tests:
   - every dua seed has Arabic text, transliteration, meaning summary, source label, and source URL
   - no lock-screen candidate places full Quran text in title/body
   - every generated candidate remains `needs_human_review`
3. HTTP route integration tests:
   - create/list/get agent runs
   - fetch review packets
   - run candidate QA
   - promote only to CMS draft
   - assert `autoPublished=false` and `fcmSent=false`
4. Service smoke test:
   - start the HTTP server on an unused port
   - call `GET /agent-runs`
   - stop the server
5. CI gate:
   - `npm ci`
   - `npm test`
   - `npm run typecheck`

## Blocking Criteria

CI must fail when:

- unapproved source content is selected
- any guardrail regression appears
- candidate output is not schema-valid
- lock-screen title/body contain full Quran text
- a route response suggests auto-publish or FCM send
- TypeScript strict typecheck fails

## Manual Review Still Required

Automation checks structure and safety flags, but all religious content remains draft content until a qualified human reviewer approves source, wording, translation policy, and market suitability.
