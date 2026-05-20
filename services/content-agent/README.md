# Sakinah Content Agent Service

MVP foundation for source-backed daily push content pre-production. The service creates deterministic draft candidates for human review and never publishes content, sends FCM, or calls live OpenAI APIs in tests.

## Commands

```sh
npm install
npm test
npm run typecheck
npm run dev
```

## Environment

| Variable | Required | Purpose |
|---|---:|---|
| `PORT` | No | HTTP port. Defaults to `8787`. |
| `CONTENT_AGENT_REPOSITORY` | No | Reserved for future DB-backed repository selection. Defaults to seed data. |
| `OPENAI_API_KEY` | No | Reserved for future live generation. Not used by tests or MVP deterministic generation. |

## Endpoints

- `POST /agent-runs`
- `GET /agent-runs`
- `GET /agent-runs/:run_id`
- `GET /agent-runs/:run_id/review-packet`
- `POST /agent-candidates/:candidate_id/qa`
- `POST /agent-candidates/:candidate_id/promote-to-cms-draft`

## Guardrails

- Approved source only.
- Lock-screen length.
- No women/cycle-sensitive lock-screen terms.
- No full Quran text on lock screens unless explicitly allowed.
- No guaranteed outcome claims.
- No shaming tone.
- No fatwa-like claims.
