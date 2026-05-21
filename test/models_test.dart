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
  });
}
