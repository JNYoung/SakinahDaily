# Play Public Links And Feedback

Status: Store-prep checklist. Final URLs require legal/store approval.

Google Play upload needs two public contact surfaces before closed testing:

- A public privacy policy URL.
- A testing feedback email or URL for Closed testing.

Prepare the local static hosting packet first:

```sh
scripts/export_google_play_public_links_packet.sh
scripts/verify_google_play_public_links_packet.sh
```

This writes `build/play-public-links/privacy/index.html`,
`build/play-public-links/feedback/index.html`, and
`build/play-public-links/manifest.txt` for legal/store review before the final
public URLs are configured. The verifier checks required sections, safe tester
feedback wording, no placeholder URLs/copy, and no form fields that could
collect sensitive details on the feedback page.

Run this gate before treating any AAB as upload-ready:

```sh
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/verify_google_play_public_links.sh
```

Use `SAKINAH_SKIP_PUBLIC_LINK_NETWORK=true` only for local script-control QA.
do not use example.com, localhost, 127.0.0.1, `.test`, `.invalid`, or private
URLs for Play upload.

## Privacy Policy URL

The hosted page should be based on `docs/privacy/02_PRIVACY_POLICY_DRAFT.md`
after legal/store review. It must be public, reachable without login, and use
HTTPS.

The page should include:

- App name: Sakinah Daily.
- Effective date.
- Contact channel.
- Data stored on device.
- Data that may leave the device.
- Local-first Women's Ibadah Mode privacy language.
- No ads, tracking SDK, crash SDK, or default-on analytics collection in v0.1.
- Delete local data instructions through Settings > Privacy.

Use the final URL in:

- Play Console > App content > Privacy policy.
- Play Console > Data safety.
- `SAKINAH_PRIVACY_POLICY_URL` for
  `scripts/verify_google_play_upload_preflight.sh`.
- `--dart-define=SAKINAH_PRIVACY_POLICY_URL=...` for the production app build,
  so Settings > Privacy shows the same hosted policy.

## Testing Feedback

Closed testing needs a feedback email or URL. The default recommendation is a
stable support email controlled by the app owner.

If using an HTTPS feedback page, start from
`build/play-public-links/feedback/index.html`. If using email, host only the
privacy page and set `SAKINAH_PLAY_TESTING_FEEDBACK` to the final support
email.

Use the final feedback channel in:

- Play Console > Closed testing > Testing feedback.
- `SAKINAH_PLAY_TESTING_FEEDBACK` for
  `scripts/verify_google_play_upload_preflight.sh`.
- `--dart-define=SAKINAH_PLAY_TESTING_FEEDBACK=...` for production or
  closed-test builds, so Settings shows the configured feedback channel.
- The Sakinah Daily Alpha Testers invitation copy when recruiting testers.

Settings shows the configured feedback email or HTTPS URL only when it passes
the same placeholder checks used by the public-links gate. The Settings feedback
tile copies the channel so closed-test users can report onboarding, prayer-time,
notification, RTL, and retention issues without searching the store listing.
The same Dart define also enables the Settings > Closed testing guide checklist
for daily tester coverage.

## In-App Link Readiness

Settings > Privacy provides the Privacy Center and local data controls. The
Privacy Center copies the approved hosted policy URL for the user when
`SAKINAH_PRIVACY_POLICY_URL` is supplied as a Dart define. If the value is
missing, HTTP-only, localhost, `example.com`, `.test`, `.invalid`, or another
placeholder shape, the app keeps the draft policy copy instead of showing an
unsafe link.

## Validation

```sh
scripts/export_google_play_public_links_packet.sh
scripts/verify_google_play_public_links_packet.sh

SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/verify_google_play_public_links.sh
```

Strict hosting check after publishing:

```sh
SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY=true \
SAKINAH_PRIVACY_POLICY_URL=https://privacy.sakinahdaily.app/privacy \
SAKINAH_PLAY_TESTING_FEEDBACK=support@sakinahdaily.app \
scripts/export_google_play_public_links_packet.sh
```

Then run:

```sh
scripts/verify_google_play_upload_preflight.sh
```

The upload preflight calls the public-links gate automatically.

## Official Reference

- Google Play Console Help, Prepare your app for review:
  https://support.google.com/googleplay/android-developer/answer/9859455
