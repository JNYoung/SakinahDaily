# Agent Review Queue Implementation

Date: 2026-05-22

## Architecture

The Content Agent service now has a repository-backed review queue foundation.
The local implementation remains deterministic and testable: it creates source-
backed draft candidates, stores review packets, records feedback, and supports
CMS draft promotion without approving, publishing, or sending push traffic.

Core modules:

- `AgentRunWorkflow`: executes local deterministic runs.
- `AgentRepository`: DB-ready persistence interface.
- `InMemoryAgentRepository`: local/test repository.
- `PostgresAgentRepository`: future adapter skeleton, not used by tests.
- `buildContentPack`: packages approved source records into local client
  manifest/bundle payloads without generating religious text.
- `FileContentPackStore` and `ContentDeliveryRoute`: serve generated local
  manifest, bundle, and detail-bundle refs for client delivery tests.
- `runCandidateQa`: repeatable automated QA checks.
- `buildReviewPacket`: human review packet builder.
- HTTP routes for health, runs, candidates, QA, draft promotion, and feedback.
  Local content delivery routes are read-only and serve only generated files.

## Repository Modes

`InMemoryAgentRepository` is the default for local dev and tests. It stores runs,
candidates, review packets, and feedback events in process memory.

`PostgresAgentRepository` is intentionally a skeleton. A future Supabase/Postgres
adapter should implement the same interface behind explicit environment config,
RLS/service-role review, and migration approval. Tests must continue to use the
in-memory repository only.

## Run Lifecycle

Run statuses:

- `queued`
- `running`
- `completed`
- `completed_with_warnings`
- `failed`
- `cancelled`

`POST /agent-runs` creates a run and executes it synchronously for the MVP.
Supported run types are `weekly_preproduction`, `cluster_production`, and
`qa_only`.

## Candidate Lifecycle

Candidate review statuses:

- `agent_draft`
- `agent_rejected`
- `needs_human_review`
- `promoted_to_cms_draft`
- `discarded`

Generated candidates default to `needs_human_review`. The agent service never
creates `approved` or `published` candidate states.

## Review Packets

Every workflow run stores a review packet with selected sources, draft
candidates, risk flags, automated checks, and the reviewer checklist.

Every packet includes:

> Agent output is draft only. Human review required before approval or publishing.

Checklist items cover source correctness, invented references, fatwa-like claims,
lock-screen safety, women privacy safety, localization, guaranteed claims,
shaming tone, content cluster fit, and CMS draft-only handling.

## Feedback Events

`POST /agent-candidates/:candidate_id/feedback` stores reviewer feedback with
role, decision, reason, optional edited payload, and timestamp. Feedback never
publishes or approves content.

## CMS Draft Promotion

Promotion means draft only:

```json
{
  "cmsStatus": "draft",
  "autoPublished": false,
  "reviewStatus": "promoted_to_cms_draft"
}
```

Candidates with blocking safety flags return `409` unless `forceDraft=true`.
Forced promotion still creates a draft-only handoff and still requires human
review before approval or publishing.

## Safety Rules

Automated QA flags:

- unapproved source
- missing source reference
- long lock-screen copy
- women/cycle-sensitive lock-screen copy
- full Quran-like Arabic on lock screen
- guaranteed outcome claims
- shaming tone
- fatwa-like claims
- invented source id
- unsupported language
- auto-publish attempt
- FCM/APNs send attempt
- generated Quran marker
- generated Hadith marker

The service does not call live OpenAI in tests, does not send FCM/APNs, does not
generate Quran or Hadith text, and does not invent source references.

Scheduled content-pack generation follows the same boundary:

- It packages approved local source records only.
- It does not generate Quran, Dua, Dhikr, Hadith, translations, or source
  labels.
- Beta mode requires reviewed inventory targets and `source`, `version`, and
  `reviewedAt` metadata before delivery.
- Generated files are local `.generated/` artifacts and are not committed.

## Running Tests

```sh
cd services/content-agent
npm install
npm test
npm run typecheck
CONTENT_PACK_PROFILE=beta npm run content-pack:generate
```

## Future Directus/Supabase Integration

Future CMS integration should:

- write only CMS draft rows
- keep approval and publish actions inside human CMS workflows
- never put service-role keys in the client
- keep source-corpus references immutable and reviewed
- keep tests on fake/in-memory repositories unless an explicit integration test
  environment is configured
- avoid sending FCM/APNs from the agent service
