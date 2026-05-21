# Daily Push Content System

The MVP push system selects source-backed, human-reviewed content. It does not send live FCM and does not generate religious content.

Rules:

- Return only `published` and `approved` content.
- Prefer the user's language and fall back to English.
- Apply simple cluster cooldown to avoid repeated lock-screen content.
- When Women's Ibadah Mode requires lock-screen safety, hide cycle-sensitive content.
