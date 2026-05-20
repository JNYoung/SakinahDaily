# Daily Push Content System

The MVP push system selects source-backed, human-reviewed content. It does not send live FCM and does not generate religious content.

Rules:

- Return only `published` and `approved` source items.
- Prefer the requested language and allow English fallback.
- Filter by ritual moment.
- Apply simple cluster cooldown to avoid repeated lock-screen content.
- When Women's Ibadah Mode requires lock-screen safety, hide cycle-sensitive content.
- Candidate outputs are drafts for human review.
