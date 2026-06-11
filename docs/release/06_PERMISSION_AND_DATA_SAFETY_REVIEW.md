# Permission And Data Safety Review

Status: Draft for legal/store review.

## Current Permissions

Android:

- `POST_NOTIFICATIONS`
- `RECEIVE_BOOT_COMPLETED`

Current behavior:

- The app shows explanatory copy before requesting notification permission.
- Prayer reminders are scheduled locally where possible.
- Boot completion is used only so local scheduled reminders can be restored
  after device reboot or app package replacement.
- Women's Ibadah Mode notification copy remains privacy-safe on lock screen.
- A dev-only notification smoke-test button can be enabled with
  `SAKINAH_NOTIFICATION_QA_ENABLED=true` only in `dev`; it schedules a
  short-delay local notification with a privacy-safe prayer tap payload for
  real-device QA and is ignored in `staging`/`prod`.
- A dev-only prayer reminder smoke-test button uses the real
  `sakinah_prayer_reminders` Android channel and `/prayer` tap payload, also
  only when `SAKINAH_NOTIFICATION_QA_ENABLED=true` in `dev`.

Real-device evidence:

- On 2026-06-11, `SC65XWPZ7DLNUSTC` delivered the dev prayer reminder QA
  notification with channel `sakinah_prayer_reminders`, title `Sakinah Daily`,
  and body `It is time for Fajr prayer.`. Tapping it opened the Prayer tab.

## Not Currently Requested

Android:

- `ACCESS_COARSE_LOCATION`
- `ACCESS_FINE_LOCATION`

iOS:

- Exact location permission is not configured in this milestone.

Current prayer location behavior remains manual or preset by default. If exact
device location is added later, the app needs dedicated permission UX, privacy
copy, store declaration updates, and tests.

## Data Safety Consistency

Cross-check before submission:

- `docs/privacy/01_PRIVACY_DATA_INVENTORY.md`
- `docs/privacy/02_PRIVACY_POLICY_DRAFT.md`
- `docs/privacy/03_APP_STORE_PRIVACY_LABEL_DRAFT.md`
- `docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md`
- `docs/privacy/06_SDK_AND_API_INVENTORY.md`

Required statements remain true in MVP:

- No ads SDK.
- No tracking SDK.
- No analytics SDK.
- No crash-reporting SDK.
- No account login.
- No payments.
- Remote content requests may include language, market, app version, schema
  version, and detail bundle hint.
- Women's Ibadah Mode exact status is not sent to the remote content API.

## Store Review Questions

- Confirm treatment of local-only app preferences.
- Confirm whether remote content server logs exist and retention policy.
- Confirm final privacy policy hosting URL.
- Verify the final privacy policy URL and Testing feedback channel with
  `scripts/verify_google_play_public_links.sh`.
- Confirm whether notification permission copy is sufficient for each locale.
