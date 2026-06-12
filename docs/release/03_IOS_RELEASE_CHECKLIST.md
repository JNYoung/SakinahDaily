# iOS Release Checklist

Status: Draft for release/store review.

The current workspace does not include an iOS project. Do not manually create
or edit provisioning artifacts unless Flutter tooling is available and the
release owner approves the platform setup.

When iOS is available:

- Verify Runner bundle identifier, for example `com.sakinahdaily.app`.
- Set display name to `Sakinah Daily`.
- Configure signing team in Xcode or CI secrets.
- Do not commit provisioning profiles or certificates.
- Verify notification permission copy before requesting permission.
- Confirm App Privacy labels against `docs/privacy`.
- Capture iPhone 6.7-inch and 6.5-inch screenshots.
- Verify Arabic RTL, Bahasa Indonesia, and English screenshots.
- Do not add ATT prompt unless tracking is actually introduced and reviewed.

Future iOS submission checklist:

- Privacy policy URL selected.
- Store metadata reviewed in all languages.
- App icon and launch screen verified.
- Real device notification permission QA completed.
- No default-on analytics collection or crash SDK enabled before privacy
  review.
