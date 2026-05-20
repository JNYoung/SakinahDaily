# Content Agent Workflows

## weekly_preproduction

1. Load approved source items from the configured repository, falling back to local seed items.
2. Select candidate clusters for the requested language and ritual moment.
3. Apply cooldown and women lock-screen safety filters.
4. Create deterministic candidate push payloads.
5. Run guardrails.
6. Store candidates as `needs_human_review`.
7. Return a review packet for human approval.

## Human Review

Human reviewers inspect each candidate, safety flags, source attribution, and intended lock-screen surface before any CMS draft promotion. Promotion creates a CMS draft only; it never publishes or sends FCM.
