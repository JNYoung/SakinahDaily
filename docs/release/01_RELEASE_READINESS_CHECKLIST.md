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
- [x] v0.1 daily-prayer release baseline does not require staging CMS.
- [x] v0.1 daily-prayer release baseline does not require production CMS.

## Safety And Privacy

- [x] Privacy Center exists in Settings.
- [x] Local data deletion exists.
- [x] Saved items are local-only and cleared by local data deletion.
- [x] Qibla uses selected prayer location without GPS or compass permission.
- [x] Manual prayer location updates prayer/Qibla settings without GPS or sensor permission.
- [x] Quran entry/detail routes use local approved seed/cache content only.
- [x] Quran recitation copy remains voice-only with no BGM and no Quran TTS.
- [x] Daily Session progress/history is local-only and cleared by Delete local data.
- [x] Daily Session completion UX avoids social sharing and guaranteed outcome claims.
- [x] Local notification tap payloads avoid Women's Ibadah Mode exact status.
- [x] Resolved local notification taps navigate and clear the pending tap result.
- [x] Android cold-start local notification taps route prayer, session, Quran,
  and Dua payloads through the same safe resolver.
- [x] Privacy docs are marked draft for legal/store review.
- [x] Store privacy label drafts exist.
- [x] No ads, tracking, analytics SDK, or crash SDK is added.
- [x] No exact GPS permission is added.
- [x] No production CMS token is committed.
- [x] Home and bottom navigation are scoped to Home / Prayer / Session / Settings.
- [ ] No visible audio CTA is a no-op in the release path.

## Release Assets

- [ ] Store screenshots captured on required device sizes.
- [ ] Store title, subtitle, descriptions, and keywords reviewed.
- [ ] App icon and splash assets reviewed on Android devices.
- [ ] Privacy policy hosting URL selected before store submission.
- [ ] Daily-prayer focused screenshots captured for Home, Prayer, Notification Settings, Manual Location, Privacy Center, and optional Session.

## Validation

- [ ] `flutter pub get`
- [ ] `flutter test`
- [ ] `dart analyze`
- [ ] `flutter build apk --debug`
- [ ] `flutter run -d emulator-5554`
- [ ] Real device notification permission QA.
- [ ] Real device local prayer reminder delivery QA.
- [ ] iOS cold-start notification tap QA after iOS runtime is available.

## Not Included In This Milestone

- Production signing keys.
- Provisioning profiles.
- App Store / Google Play submission.
- Analytics or crash SDK.
- Ads or tracking.
- Live CMS calls.
- GPS, compass, or sensor permissions.
- Remote saved-item sync.
- Full Quran corpus or licensed audio.
