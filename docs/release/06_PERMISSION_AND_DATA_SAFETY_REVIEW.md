# Permission And Data Safety Review

Status: Draft for legal/store review.

## Current Permissions

Android:

- `POST_NOTIFICATIONS`

Current behavior:

- The app shows explanatory copy before requesting notification permission.
- Prayer reminders are scheduled locally where possible.
- Women's Ibadah Mode notification copy remains privacy-safe on lock screen.

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
- Confirm whether notification permission copy is sufficient for each locale.
