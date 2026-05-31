# Permission And Data Safety Review

Status: Draft for legal/store review.

## Current Permissions

Android:

- `POST_NOTIFICATIONS`
- `ACCESS_COARSE_LOCATION`

Current behavior:

- The app shows explanatory copy before requesting notification permission.
- The app shows explanatory copy before requesting device location for prayer
  time and Qibla setup.
- Device location is stored locally as the active prayer location and is not
  sent to the remote content API in MVP.
- If location permission is denied, permanently denied, location services are
  off, or location is unavailable, the manual location form remains available.
- Prayer reminders are scheduled locally where possible.
- Women's Ibadah Mode notification copy remains privacy-safe on lock screen.

## Not Currently Requested

Android:

- `ACCESS_FINE_LOCATION`
- `ACCESS_BACKGROUND_LOCATION`
- `FOREGROUND_SERVICE_LOCATION`

iOS:

- iOS location permission is not configured because no iOS project is currently
  present. Future iOS work must use `NSLocationWhenInUseUsageDescription` and
  avoid Always/background location unless a separate review approves it.

Current prayer location behavior supports device, manual, and preset choices.
If fine, background, foreground-service location, compass, or sensor permissions
are added later, the app needs a fresh permission UX, privacy copy, store
declaration updates, and tests.

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
- Confirm whether foreground coarse location copy is sufficient for each
  locale.
- Confirm real-device Android behavior for allow, approximate/coarse, deny,
  deny forever/system settings, and location-services-off states.
