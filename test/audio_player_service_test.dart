import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/localization/sakinah_localizations.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/services/audio_player_service.dart';
import 'package:sakinah_daily/core/services/audio_policy_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';
import 'package:sakinah_daily/shared/widgets/audio_player_bar.dart';

void main() {
  const playableAsset = AudioAsset(
    id: 'quran_ok',
    audioType: AudioType.quranRecitation,
    reciterName: 'Approved reciter',
    url: 'asset://approved-quran.mp3',
    approved: true,
    bgmAllowed: false,
  );

  test('fake player transitions idle loading ready playing paused completed',
      () async {
    final player = FakeSakinahAudioPlayer();
    final statuses = <AudioPlaybackStatus>[];
    final subscription = player.stateStream.listen(
      (state) => statuses.add(state.status),
    );

    statuses.add(player.currentState.status);
    await player.load(playableAsset);
    await player.play();
    await player.pause();
    await player.complete();
    await subscription.cancel();

    expect(statuses, [
      AudioPlaybackStatus.idle,
      AudioPlaybackStatus.loading,
      AudioPlaybackStatus.ready,
      AudioPlaybackStatus.playing,
      AudioPlaybackStatus.paused,
      AudioPlaybackStatus.completed,
    ]);
  });

  test('fake player enters text-only fallback for missing audio source',
      () async {
    final player = FakeSakinahAudioPlayer();

    await player.load(
      const AudioAsset(
        id: 'quran_missing',
        audioType: AudioType.quranRecitation,
        reciterName: 'Approved reciter',
        approved: true,
        bgmAllowed: false,
      ),
    );

    expect(player.currentState.status, AudioPlaybackStatus.textOnlyFallback);
  });

  testWidgets('AudioPlayerBar play and pause button calls fake player',
      (tester) async {
    final player = FakeSakinahAudioPlayer();
    final policy = const AudioPolicyService().evaluate(playableAsset);
    await player.load(playableAsset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [SakinahLocalizations.delegate],
        home: Scaffold(
          body: AudioPlayerBar(
            asset: playableAsset,
            policy: policy,
            player: player,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SakinahKeys.audioPlayPauseButton));
    await tester.pumpAndSettle();

    expect(player.currentState.status, AudioPlaybackStatus.playing);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);

    await tester.tap(find.byKey(SakinahKeys.audioPlayPauseButton));
    await tester.pumpAndSettle();

    expect(player.currentState.status, AudioPlaybackStatus.paused);
  });
}
