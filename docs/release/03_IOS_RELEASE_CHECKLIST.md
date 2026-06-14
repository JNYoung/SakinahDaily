# iOS Release Checklist

Status: Draft for release/store review.

The workspace includes the Flutter iOS Runner project, but signing,
provisioning, App Store metadata, and real-device screenshot evidence are still
release-owner tasks. Do not commit provisioning profiles or certificates.

Current native launch setup:

- Runner bundle identifier: `com.sakinahdaily.app`.
- Launch storyboard: `ios/Runner/Base.lproj/LaunchScreen.storyboard`.
- Launch artwork image set:
  `ios/Runner/Assets.xcassets/SakinahSplash.imageset`.
- The image set uses the shared Flutter splash artwork at
  `assets/branding/sakinah_splash.png`, matching the Android native splash bitmap.
- `UILaunchStoryboardName` is `LaunchScreen`.

Before iOS submission:

- Re-verify Runner bundle identifier after any Xcode project regeneration.
- Set display name to `Sakinah Daily`.
- Configure signing team in Xcode or CI secrets.
- Verify notification permission copy before requesting permission.
- Confirm App Privacy labels against `docs/privacy`.
- Capture iPhone 6.7-inch and 6.5-inch screenshots.
- Verify Arabic RTL, Bahasa Indonesia, and English screenshots.
- Verify the `SakinahSplash.imageset` launch screen on a real device.
- Do not add ATT prompt unless tracking is actually introduced and reviewed.

Future iOS submission checklist:

- Privacy policy URL selected.
- Store metadata reviewed in all languages.
- App icon and launch screen verified.
- Real device notification permission QA completed.
- No default-on analytics collection or crash SDK enabled before privacy
  review.
