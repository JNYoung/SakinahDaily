# Session Progress And Local History

Status: MVP client foundation.

This milestone adds local-only Daily Session progress, completion records, a
completion page, and a small Home progress summary. It does not add analytics,
account sync, remote progress sync, social sharing, live CMS calls, AI
religious content, full Quran corpus downloads, Quran TTS, or licensed audio.

## Local-Only Progress Design

Session progress is stored through `SessionProgressRepository` using local
`SharedPreferences` storage in production and an in-memory store in tests.

The active progress record stores:

- session ID
- current step index
- total step count
- status
- started/updated/completed timestamps
- language code

It intentionally does not store Quran text, Dua text, Dhikr text, Hadith text,
translations, reflections, or user notes.

## Completion Records

When a session is finished, the app stores a `SessionCompletionRecord` with:

- record ID
- session ID
- completed timestamp
- duration in seconds
- language code
- total step count

The in-progress state for that session is cleared after completion. The
completion page at `/session/:sessionId/completed` shows a gentle completion
message, local-only progress note, current streak, completed-this-week count,
links back Home or to Saved Items, and offers a privacy-safe Set daily reminder
CTA. When the reminder is already enabled, the same CTA becomes a Manage daily
reminder entry that opens Settings > Notification settings.

## Resume Behavior

Opening a Daily Session resumes the saved step when local progress has status
`inProgress`. Moving to the next step updates the local step index. Completing
the session records local history and routes to the completion page.

Home uses the same local state to show:

- Start for not-started sessions.
- Resume for in-progress sessions.
- Completed today / Review for sessions completed today.
- Current streak and completed-this-week summary.

The Prayer completion card uses the same local completion state. After all five
daily prayers are checked in, it starts Today's Sakinah session when the session
has not been completed yet, and changes to Review with a direct completion-page
route once today's session is already complete.

Women's Ibadah Mode may add a local-only support note around the session entry,
but session progress records still store only IDs and timestamps.

## Streak Calculation

The MVP streak is a simple consecutive-day count ending today. It is calculated
from local completion record dates only. Completed-this-week counts completion
records in the last seven local calendar days.

This is a quiet personal progress cue, not a leaderboard and not a social or
reward claim.

## Privacy Notes

- Progress and completion records remain on device.
- The daily session reminder enabled state and selected reminder time are stored
  locally in user preferences.
- Daily session notification payloads contain only route/session IDs and do not
  include women mode status or religious text.
- Records are not synced to an account.
- Records are not sent to analytics or crash reporting.
- Delete Local Data clears active progress and completion history.
- No guaranteed spiritual outcome is claimed from completing a session.

## Future Work

- Optional richer completion insights after privacy review.
- Multi-session history filters if the client adds more daily sessions.
- Next-session suggestions after the reviewed session pack expands beyond one
  seed session.
- Account sync only after explicit account, consent, deletion, and privacy
  review.
- Real Flutter CI execution once the local and remote toolchains are available.
