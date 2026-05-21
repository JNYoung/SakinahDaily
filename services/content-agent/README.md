# Sakinah Content Agent

MVP foundation for source-backed content pre-production. The local service uses deterministic placeholder generation so tests never call live OpenAI APIs.

## Commands

```sh
npm install
npm test
npm run typecheck
npm run dev
```

## Environment

- `PORT`: HTTP port, defaults to `8787`.
- Database and live LLM settings are intentionally not required for local MVP tests.

## Guardrails

- Approved sources only.
- Lock-screen copy length limits.
- No women/cycle-sensitive lock-screen terms.
- No full Quran text on lock screens unless explicitly allowed.
- No guaranteed outcome claims.
- No shaming tone.
- No fatwa-like claims.
