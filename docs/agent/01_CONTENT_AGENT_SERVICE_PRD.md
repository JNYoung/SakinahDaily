# Content Agent Service PRD

## Goal

Content Agent Service prepares source-backed daily push content drafts for Sakinah Daily. It is a pre-production assistant for content teams, not an auto-publisher and not a religious Q&A surface.

## MVP Boundaries

- Use approved source items only.
- Produce deterministic local placeholder candidates first.
- Mark all generated candidates as `needs_human_review`.
- Provide review packets for human editors.
- Do not call live OpenAI APIs in tests.
- Do not auto-publish content to CMS.
- Do not send live FCM.
- Do not produce fatwa-like claims, guaranteed outcomes, shaming tone, or lock-screen copy that exposes sensitive women mode state.

## Runtime Shape

The MVP runs as a TypeScript HTTP service under `services/content-agent/`. When a database is not configured, it uses seed source items from the local repository. Future work can replace the repository with Supabase/Directus-backed data without changing route contracts.

## Acceptance

- Service starts locally.
- Agent run endpoints return schema-valid JSON.
- Unsafe candidates are rejected or flagged.
- Tests cover every guardrail.
- README explains local run and env vars.
