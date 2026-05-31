# Sakinah Content Agent

MVP foundation for source-backed content pre-production. The local service uses deterministic placeholder generation and an in-memory review queue so tests never call live OpenAI APIs, live databases, CMS, FCM, or APNs.

## Commands

```sh
npm install
npm test
npm run typecheck
npm run dev
npm run content-pack:generate
npm run content-pack:schedule
npm run content-pack:serve
```

## Environment

- `PORT`: HTTP port, defaults to `8787`.
- `CONTENT_AGENT_DATABASE_URL`: reserved for the future Postgres adapter. Local MVP tests do not require it.
- `CONTENT_PACK_SOURCE_PATH`: local approved source JSON for content-pack generation. Defaults to the Flutter seed JSON for local dev only.
- `CONTENT_PACK_OUTPUT_DIR`: generated manifest/bundle output directory. Defaults to `.generated/content-pack`.
- `CONTENT_PACK_PROFILE`: `dev` or `beta`. Beta enforces reviewed beta-pack counts, source labels, `version`, and `reviewedAt`.
- `CONTENT_PACK_INTERVAL_MINUTES`: interval for `npm run content-pack:schedule`, default `1440`.
- Database and live LLM settings are intentionally not required for local MVP tests.

## Scheduled Content Pack Delivery

`content-pack:generate` runs the local generator once and writes:

- `manifest.json`
- `bundles/<bundle_id>.json`
- `detail-bundles.json`
- `audit-report.json`

`content-pack:schedule` runs once immediately, then repeats on the configured
interval. It never generates Quran, Dua, Dhikr, or Hadith text. It only packages
approved local source records into the existing generic client delivery contract.

`content-pack:serve` exposes the generated files for local client testing:

- `GET /manifest`
- `GET /bundles/<bundle_id>.json`
- `GET /detail-bundle?bundle_hint=<session_or_content_id>`

Use `CONTENT_PACK_PROFILE=beta npm run content-pack:generate` before beta. That
mode blocks delivery until the source inventory has 5-7 sessions, 30-50 duas,
20-30 dhikrs, 10-20 session Quran ayahs, and required source/review/version
metadata. The current seed file is allowed for dev delivery proof, but it is not
accepted as a beta content pack.

## Guardrails

- Approved sources only.
- Lock-screen copy length limits.
- No women/cycle-sensitive lock-screen terms.
- No full Quran text on lock screens unless explicitly allowed.
- No guaranteed outcome claims.
- No shaming tone.
- No fatwa-like claims.
- No invented sources, generated Quran/Hadith markers, auto-publish attempts, or FCM/APNs send attempts.
- Content-pack delivery never bypasses `published` + `approved` gating.

## Review Queue

- Runs, candidates, review packets, and feedback events go through the `AgentRepository` interface.
- `InMemoryAgentRepository` is the default runtime/test implementation.
- CMS promotion returns draft-only metadata: `cmsStatus=draft`, `autoPublished=false`.
- Human review is required before any approval or publishing outside this service.
