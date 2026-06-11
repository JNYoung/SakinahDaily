# Android Upload Signing Setup

Status: Local operator checklist. Do not commit generated signing files.

This document prepares the first Google Play closed-testing upload for
Sakinah Daily. It does not create or store production secrets in the repository.

## Safety Rules

- Create the upload keystore outside the repository.
- Do not commit `android/key.properties`, `.jks`, `.keystore`, `.env`, or
  service-account files.
- Keep passwords in a local password manager or CI secret store.
- Review Google Play App Signing before uploading the first signed AAB.
- Do not reuse debug signing material for Play uploads.

The repository already ignores `key.properties`, `*.jks`, and `*.keystore`.

## Create A Local Upload Keystore

Choose a path outside the repository, then run the helper with explicit local
values:

```sh
SAKINAH_UPLOAD_KEYSTORE_PATH="$HOME/secure/sakinah/upload-keystore.jks" \
SAKINAH_UPLOAD_STORE_PASSWORD="use-a-local-password" \
SAKINAH_UPLOAD_KEY_ALIAS="upload" \
SAKINAH_UPLOAD_KEY_PASSWORD="use-a-local-key-password" \
SAKINAH_WRITE_KEY_PROPERTIES=true \
scripts/create_android_upload_keystore.sh
```

The helper uses `keytool -genkeypair` with RSA 2048 and a 10000-day validity
period. It refuses to create the keystore inside the repository. It writes
`android/key.properties` only when `SAKINAH_WRITE_KEY_PROPERTIES=true`.

If `android/key.properties` already exists, the helper refuses to overwrite it
unless `SAKINAH_OVERWRITE_KEY_PROPERTIES=true` is set. If the keystore already
exists, the helper refuses to overwrite it unless
`SAKINAH_OVERWRITE_KEYSTORE=true` is set.

## CI Secret Option

Instead of writing `android/key.properties`, CI can pass the signing values as
environment variables:

- `SAKINAH_UPLOAD_STORE_FILE`
- `SAKINAH_UPLOAD_STORE_PASSWORD`
- `SAKINAH_UPLOAD_KEY_ALIAS`
- `SAKINAH_UPLOAD_KEY_PASSWORD`

The keystore file referenced by `SAKINAH_UPLOAD_STORE_FILE` must already exist
on the CI worker or be restored from a secure secret store.

## Verify Signing

After local signing is configured:

```sh
SAKINAH_REQUIRE_RELEASE_SIGNING=true \
flutter build appbundle --release \
  --dart-define=SAKINAH_APP_ENV=prod
```

Then run the release gate:

```sh
scripts/verify_google_play_internal_release.sh
```

When the privacy policy URL, testing feedback channel, Google Group, closed
testing track, app-content declarations, and store listing are ready, run:

```sh
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
SAKINAH_PLAY_TESTER_GROUP_EMAIL=sakinah-daily-testers@googlegroups.com \
SAKINAH_PLAY_TESTER_GROUP_CREATED=true \
SAKINAH_PLAY_CLOSED_TRACK_READY=true \
SAKINAH_PLAY_APP_CONTENT_READY=true \
SAKINAH_PLAY_STORE_LISTING_READY=true \
scripts/verify_google_play_upload_preflight.sh
```

The preflight must pass before treating the AAB as a Google Play upload
candidate.

## Recovery Notes

Keep the upload keystore backed up securely. Losing it can block future
updates unless Play App Signing recovery is available for the account.

If a test keystore was created with weak local passwords, delete it and create
a new one before the first Play upload.
