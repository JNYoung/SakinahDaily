import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';

void main() {
  test('seed content loads approved sessions and religious metadata', () {
    final repo = SeedContentRepository(SeedContent.demo());

    expect(repo.getDailySessions(), isNotEmpty);
    expect(repo.getDuas(), hasLength(5));
    expect(repo.getDhikrs(), hasLength(5));

    final dua = repo.getDua('dua_ease')!;
    expect(dua.source, isNotEmpty);
    expect(dua.reviewStatus, ReviewStatus.approved);
  });

  test('Quran audio assets disallow background music', () {
    final repo = SeedContentRepository(SeedContent.demo());
    final ayah = repo.getQuranAyah('94:5')!;
    final audio = repo.getAudioAsset(ayah.audioAssetId!)!;

    expect(audio.bgmAllowed, isFalse);
    expect(audio.approved, isTrue);
  });

  test('user preferences keep women mode local-only by default', () {
    final preferences = UserPreferences.defaults().copyWith(
      womenIbadahMode: const WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.menstruating,
      ),
    );

    expect(preferences.womenIbadahMode.status, WomenIbadahStatus.menstruating);
    expect(preferences.womenIbadahMode.localOnly, isTrue);
    expect(
        preferences.womenIbadahMode.hideCycleSensitiveLockScreenCopy, isTrue);
    expect(preferences.womenIbadahMode.discreetModeEnabled, isFalse);
  });

  test('user preferences persist prayer reminder lead time safely', () {
    final preferences = UserPreferences.defaults().copyWith(
      prayerReminderOffsetMinutes: 10,
    );

    final decoded = UserPreferences.fromJson(preferences.toJson());

    expect(decoded.prayerReminderOffsetMinutes, 10);
    expect(
      UserPreferences.fromJson(const {
        'prayerReminderOffsetMinutes': 999,
      }).prayerReminderOffsetMinutes,
      defaultPrayerReminderOffsetMinutes,
    );
  });

  test('user preferences persist closed testing prompt completion safely', () {
    final preferences = UserPreferences.defaults().copyWith(
      completedClosedTestingPromptDays: [
        'day7',
        'unknown',
        'day3',
        'day1',
        'day1',
      ],
    );

    final decoded = UserPreferences.fromJson(preferences.toJson());

    expect(decoded.completedClosedTestingPromptDays, ['day1', 'day3', 'day7']);
    expect(decoded.isClosedTestingPromptCompleted('day1'), isTrue);
    expect(decoded.isClosedTestingPromptCompleted('day3'), isTrue);
    expect(decoded.isClosedTestingPromptCompleted('day14'), isFalse);
    expect(
      UserPreferences.fromJson(const {
        'completedClosedTestingPromptDays': ['day14', 'bad-day'],
      }).completedClosedTestingPromptDays,
      ['day14'],
    );
  });
}
