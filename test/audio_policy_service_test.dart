import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/services/audio_policy_service.dart';

void main() {
  const service = AudioPolicyService();

  test('approved Quran recitation without BGM is voice-only playable', () {
    const asset = AudioAsset(
      id: 'quran_ok',
      audioType: AudioType.quranRecitation,
      reciterName: 'Approved reciter',
      url: 'asset://approved-quran.mp3',
      approved: true,
      bgmAllowed: false,
    );

    final result = service.evaluate(asset);

    expect(result.playable, isTrue);
    expect(result.textOnlyFallback, isFalse);
    expect(result.backgroundSoundAllowed, isFalse);
    expect(result.flags, contains('quran_recitation_voice_only'));
    expect(service.assertQuranNoBgm(asset), isTrue);
  });

  test('Quran recitation with BGM allowed is blocked', () {
    const asset = AudioAsset(
      id: 'quran_bgm',
      audioType: AudioType.quranRecitation,
      reciterName: 'Approved reciter',
      url: 'asset://approved-quran.mp3',
      approved: true,
      bgmAllowed: true,
    );

    final result = service.evaluate(asset);

    expect(result.playable, isFalse);
    expect(result.backgroundSoundAllowed, isFalse);
    expect(result.flags, contains('quran_bgm_blocked'));
    expect(service.assertQuranNoBgm(asset), isFalse);
  });

  test('unapproved Quran audio is not playable', () {
    const asset = AudioAsset(
      id: 'quran_unapproved',
      audioType: AudioType.quranRecitation,
      reciterName: 'Unapproved reciter',
      url: 'asset://unapproved-quran.mp3',
      approved: false,
      bgmAllowed: false,
    );

    final result = service.evaluate(asset);

    expect(result.playable, isFalse);
    expect(result.flags, contains('unapproved_audio'));
  });

  test('missing audio source returns text-only fallback', () {
    const asset = AudioAsset(
      id: 'quran_missing',
      audioType: AudioType.quranRecitation,
      reciterName: 'Approved reciter',
      approved: true,
      bgmAllowed: false,
    );

    final result = service.evaluate(asset);

    expect(result.playable, isFalse);
    expect(result.textOnlyFallback, isTrue);
    expect(result.flags, contains('missing_audio_source'));
    expect(result.flags, contains('text_only_fallback'));
  });

  test('non-Quran guidance can play with explicit BGM policy', () {
    const asset = AudioAsset(
      id: 'reflection_guidance',
      audioType: AudioType.reflectionGuidance,
      voiceName: 'Guide voice',
      assetPath: 'assets/audio/reflection-placeholder.mp3',
      approved: true,
      bgmAllowed: true,
    );

    final result = service.evaluate(asset);

    expect(result.playable, isTrue);
    expect(result.backgroundSoundAllowed, isTrue);
    expect(result.flags, isEmpty);
  });
}
