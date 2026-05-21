import '../models/sakinah_models.dart';

class AudioPolicyResult {
  const AudioPolicyResult({
    required this.playable,
    required this.textOnlyFallback,
    required this.backgroundSoundAllowed,
    required this.flags,
  });

  final bool playable;
  final bool textOnlyFallback;
  final bool backgroundSoundAllowed;
  final List<String> flags;
}

class AudioPolicyService {
  const AudioPolicyService();

  AudioPolicyResult evaluate(AudioAsset? asset) {
    if (asset == null) {
      return const AudioPolicyResult(
        playable: false,
        textOnlyFallback: true,
        backgroundSoundAllowed: false,
        flags: ['missing_audio_source', 'text_only_fallback'],
      );
    }

    final flags = <String>[];
    if (!asset.approved) {
      flags.add('unapproved_audio');
    }
    if (asset.textOnlyFallbackRequired) {
      flags
        ..add('missing_audio_source')
        ..add('text_only_fallback');
    }
    if (asset.isQuranRecitation && asset.bgmAllowed) {
      flags.add('quran_bgm_blocked');
    }
    if (asset.isQuranRecitation && !asset.bgmAllowed) {
      flags.add('quran_recitation_voice_only');
    }

    final hasBlockingFlag = flags.any(
      (flag) =>
          flag == 'unapproved_audio' ||
          flag == 'missing_audio_source' ||
          flag == 'quran_bgm_blocked',
    );

    return AudioPolicyResult(
      playable: !hasBlockingFlag,
      textOnlyFallback: flags.contains('text_only_fallback'),
      backgroundSoundAllowed:
          !asset.isQuranRecitation && asset.bgmAllowed && !hasBlockingFlag,
      flags: List.unmodifiable(flags),
    );
  }

  bool canPlay(AudioAsset? asset) => evaluate(asset).playable;

  bool mustUseTextFallback(AudioAsset? asset) {
    return evaluate(asset).textOnlyFallback;
  }

  bool canUseBackgroundSound(AudioAsset? asset) {
    return evaluate(asset).backgroundSoundAllowed;
  }

  bool assertQuranNoBgm(AudioAsset asset) {
    return !(asset.isQuranRecitation && asset.bgmAllowed);
  }

  String displayPolicyLabel(AudioAsset? asset, {String languageCode = 'en'}) {
    final result = evaluate(asset);
    if (result.textOnlyFallback) {
      return switch (languageCode) {
        'id' => 'Fallback teks saja',
        'ar' => 'الرجوع إلى النص فقط',
        _ => 'Text-only fallback',
      };
    }
    if (asset?.isQuranRecitation ?? false) {
      return switch (languageCode) {
        'id' => 'Tilawah tanpa suara latar',
        'ar' => 'تلاوة بلا صوت خلفي',
        _ => 'Voice-only Quran recitation',
      };
    }
    return switch (languageCode) {
      'id' => 'Audio disetujui',
      'ar' => 'صوت معتمد',
      _ => 'Approved audio',
    };
  }
}
