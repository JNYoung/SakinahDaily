# Agent Workflows

- `weekly_preproduction`: load approved source items, select safe clusters, create deterministic candidate drafts, run QA, store candidates, and mark candidates as `needs_human_review`.
- `cluster_production`: same as weekly preproduction but scoped to a requested cluster.
- `qa_only`: re-run QA against existing candidates and update risk flags.

All workflows are draft-only. Human review is required before any approval,
publishing, CMS publish action, or push send.
