# Public Links Hosting Packet

Status: Store-prep draft. Final hosting requires legal/store approval.

Last checked against Google Play Help on 2026-06-11.

## Purpose

This packet prepares public web files for the Google Play privacy policy URL
and optional HTTPS testing-feedback page. It does not replace legal review or
actual hosting. It gives the app owner a static, reviewable folder before the
final `SAKINAH_PRIVACY_POLICY_URL` and `SAKINAH_PLAY_TESTING_FEEDBACK` values
are entered into Play Console and production Dart defines.

Public links hosting packet output is written to `build/play-public-links`.

## Export

Template-mode export:

```sh
scripts/export_google_play_public_links_packet.sh
scripts/verify_google_play_public_links_packet.sh
```

Output:

- `build/play-public-links/privacy/index.html`
- `build/play-public-links/feedback/index.html`
- `build/play-public-links/manifest.txt`
- copied source drafts and `scripts/verify_google_play_public_links.sh`

The QA verifier checks the generated pages for required privacy/data sections,
viewport/readability metadata, no placeholder copy, no `example.com` /
localhost links, no script tags, and no form/input fields on the feedback page.

The privacy page is based on:

- `docs/privacy/02_PRIVACY_POLICY_DRAFT.md`
- `docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md`
- `docs/privacy/06_SDK_AND_API_INVENTORY.md`

The feedback page mirrors the in-app closed-testing prompts and keeps the same
privacy rule: no tester personal data, no sensitive health details, no private
messages, and no Women's Ibadah Mode exact status.

## Strict Gate

After hosting the reviewed pages on public HTTPS URLs, run:

```sh
SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY=true \
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=https://privacy.sakinahdaily.app/feedback \
scripts/export_google_play_public_links_packet.sh
```

If feedback uses an email instead of the hosted page, use the final support
email:

```sh
SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY=true \
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/export_google_play_public_links_packet.sh
```

Strict mode delegates to `scripts/verify_google_play_public_links.sh`, so it
fails until the final privacy policy URL is reachable without login over HTTPS
and the feedback channel is a real public email or HTTPS URL.

## Where To Use Final Values

- Play Console > App content > Privacy policy:
  `SAKINAH_PRIVACY_POLICY_URL`
- Play Console > Data safety:
  same privacy policy URL
- Play Console > Closed testing > Testing feedback:
  `SAKINAH_PLAY_TESTING_FEEDBACK`
- Production or closed-test build:
  `--dart-define=SAKINAH_PRIVACY_POLICY_URL=...`
  `--dart-define=SAKINAH_PLAY_TESTING_FEEDBACK=...`
- Upload preflight:
  `scripts/verify_google_play_upload_preflight.sh`

## Publishing Notes

- Host with HTTPS only.
- Do not require login, invitation, VPN, private network access, or region-only
  access for the privacy policy.
- Do not use `example.com`, localhost, `.test`, `.invalid`, or placeholder
  emails.
- Review the effective date, contact channel, and data-safety wording before
  publishing.
- Keep the page aligned with v0.1 behavior: no ads, tracking SDK, crash SDK,
  default-on analytics collection, exact GPS permission, account login, social
  features, AI fatwa, religious Q&A, or remote Women's Ibadah Mode exact
  status.

## Related Gates

```sh
scripts/verify_google_play_public_links_packet.sh
scripts/verify_google_play_public_links.sh
scripts/export_google_play_upload_packet.sh
scripts/verify_google_play_upload_preflight.sh
scripts/verify_google_play_submission_pack.sh
```

## Official References

- Google Play Console Help, Prepare your app for review:
  https://support.google.com/googleplay/android-developer/answer/9859455
- Google Play User Data policy:
  https://support.google.com/googleplay/android-developer/answer/10144311
