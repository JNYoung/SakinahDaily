# Eval And Guardrails

Guardrails reject or flag content that:

- Uses unapproved sources.
- Exceeds lock-screen length.
- Includes women/cycle-sensitive terms in lock-screen copy.
- Places full Quran text on lock screens without explicit allowance.
- Makes guaranteed outcome claims.
- Uses shaming tone.
- Makes fatwa-like claims.

Tests must not call live OpenAI APIs, publish content, or send FCM.

Additional dua content checks:

- Every dua seed must include Arabic text, transliteration, meaning summary, source label, and source URL.
- Lock-screen title/body must use short safe summaries instead of full Quran text.
- Dua candidates must remain `needs_human_review` until qualified human review.
