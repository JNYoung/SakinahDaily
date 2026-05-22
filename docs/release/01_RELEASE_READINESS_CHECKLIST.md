# Release Readiness Checklist

Status: Draft for release/store review.

## Client Build Identity

- [x] Android namespace uses `com.sakinahdaily.app`.
- [x] Android `applicationId` uses `com.sakinahdaily.app`.
- [x] Android display label is `Sakinah Daily`.
- [ ] iOS bundle identifier is verified after an iOS project is generated or
  restored.
- [ ] App version and build number are approved for the release train.

## Configuration

- [x] Default app environment is `dev`.
- [x] `staging` and `prod` are selected with `SAKINAH_APP_ENV`.
- [x] Remote content is disabled unless explicitly enabled.
- [x] Analytics and crash reporting remain disabled.
- [ ] Staging content API endpoint is approved before any staging build.
- [ ] Production content API endpoint is approved before any production build.

## Safety And Privacy

- [x] Privacy Center exists in Settings.
- [x] Local data deletion exists.
- [x] Privacy docs are marked draft for legal/store review.
- [x] Store privacy label drafts exist.
- [x] No ads, tracking, analytics SDK, or crash SDK is added.
- [x] No exact GPS permission is added.
- [x] No production CMS token is committed.

## Release Assets

- [ ] Store screenshots captured on required device sizes.
- [ ] Store title, subtitle, descriptions, and keywords reviewed.
- [ ] App icon and splash assets reviewed on Android devices.
- [ ] Privacy policy hosting URL selected before store submission.

## Validation

- [ ] `flutter pub get`
- [ ] `flutter test`
- [ ] `dart analyze`
- [ ] `flutter build apk --debug`
- [ ] `flutter run -d emulator-5554`
- [ ] Real device notification permission QA.

## Not Included In This Milestone

- Production signing keys.
- Provisioning profiles.
- App Store / Google Play submission.
- Analytics or crash SDK.
- Ads or tracking.
- Live CMS calls.
- Full Quran corpus or licensed audio.
