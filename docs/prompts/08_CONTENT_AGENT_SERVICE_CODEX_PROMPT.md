# 08 — Content Agent Service Codex Prompt

# Codex Prompt — Implement Content Agent Service Foundation

Read:
- docs/agent/01_CONTENT_AGENT_SERVICE_PRD.md
- docs/agent/02_AGENT_WORKFLOWS.md
- docs/agent/03_AGENT_OUTPUT_SCHEMAS.md
- docs/agent/04_AGENT_PROMPTS.md
- docs/agent/05_AGENT_SERVICE_OPENAPI.yaml
- docs/agent/06_EVAL_AND_GUARDRAILS.md
- docs/cms/03_AGENT_SERVICE_SCHEMA.sql
- docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md
- docs/cms/02_PUSH_CONTENT_SCHEMA.sql

Goal:
Implement the MVP foundation for the Content Agent Service.

Scope:
1. Create a backend service folder:
   - `services/content-agent/`
2. Use TypeScript.
3. Add:
   - package.json
   - src/index.ts
   - src/routes/agentRuns.ts
   - src/domain/schemas.ts
   - src/domain/validators.ts
   - src/domain/candidateSelector.ts
   - src/domain/safetyChecks.ts
   - src/repositories/agentRunRepository.ts
   - src/repositories/contentRepository.ts
   - src/llm/structuredOutputClient.ts
   - src/prompts/
   - test/
4. Implement HTTP endpoints from OpenAPI at a stub/functional level:
   - POST /agent-runs
   - GET /agent-runs
   - GET /agent-runs/:run_id
   - GET /agent-runs/:run_id/review-packet
   - POST /agent-candidates/:candidate_id/qa
   - POST /agent-candidates/:candidate_id/promote-to-cms-draft
5. Implement validators:
   - approved source only
   - lock-screen length
   - no women/cycle-sensitive lock-screen terms
   - no full Qur'an text on lock screen unless explicitly allowed
   - no guaranteed outcome claims
   - no shaming tone
   - no fatwa-like claims
6. Implement dry-run weekly_preproduction that:
   - loads seed source items if DB is not configured
   - selects candidate clusters
   - creates candidate push template payloads using deterministic placeholder generation first
   - marks them as `needs_human_review`
7. Add tests for all guardrails.
8. Do not call live OpenAI API in tests.
9. Do not auto-publish content.
10. Do not send live FCM.

Acceptance:
- Service starts locally.
- Tests pass.
- Candidate outputs are schema-valid.
- Unsafe candidates are rejected or flagged.
- README explains env vars and local run.

---


```text
Read docs/agent/*, docs/cms/03_AGENT_SERVICE_SCHEMA.sql, and docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md.

Implement the MVP foundation for Content Agent Service.

Scope:
- Create services/content-agent/
- Use TypeScript
- Implement agent run endpoints
- Implement schemas
- Implement validators
- Implement deterministic dry-run generation
- Add tests for guardrails
- Do not call live OpenAI API in tests
- Do not auto-publish content
- Do not send live FCM
```
