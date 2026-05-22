# Sakinah Content Agent

MVP foundation for source-backed content pre-production. The local service uses deterministic placeholder generation and an in-memory review queue so tests never call live OpenAI APIs, live databases, CMS, FCM, or APNs.

## Commands

```sh
npm install
npm test
npm run typecheck
npm run dev
```

## Environment

- `PORT`: HTTP port, defaults to `8787`.
- `CONTENT_AGENT_DATABASE_URL`: reserved for the future Postgres adapter. Local MVP tests do not require it.
- Database and live LLM settings are intentionally not required for local MVP tests.

## Guardrails

- Approved sources only.
- Lock-screen copy length limits.
- No women/cycle-sensitive lock-screen terms.
- No full Quran text on lock screens unless explicitly allowed.
- No guaranteed outcome claims.
- No shaming tone.
- No fatwa-like claims.
- No invented sources, generated Quran/Hadith markers, auto-publish attempts, or FCM/APNs send attempts.

## Review Queue

- Runs, candidates, review packets, and feedback events go through the `AgentRepository` interface.
- `InMemoryAgentRepository` is the default runtime/test implementation.
- CMS promotion returns draft-only metadata: `cmsStatus=draft`, `autoPublished=false`.
- Human review is required before any approval or publishing outside this service.
