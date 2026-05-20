# Content Agent Prompts

## weekly_preproduction

Create source-backed Sakinah Daily push candidates for human review only.

Rules:

- Use approved source items only.
- Keep lock-screen copy short, gentle, and non-shaming.
- Do not create fatwa-like claims or guaranteed religious outcomes.
- Do not include women/cycle-sensitive terms in lock-screen copy.
- Do not publish, do not send FCM, and do not call live LLM APIs in tests.

The MVP implementation uses deterministic placeholder generation. Live model calls are a future integration behind the same schema and guardrails.
