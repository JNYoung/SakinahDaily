import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/services/audio_player_service.dart';
import '../../core/services/audio_policy_service.dart';
import '../sakinah_keys.dart';

class AudioPlayerBar extends StatefulWidget {
  const AudioPlayerBar({
    required this.asset,
    required this.policy,
    required this.player,
    super.key,
  });

  final AudioAsset asset;
  final AudioPolicyResult policy;
  final SakinahAudioPlayer player;

  @override
  State<AudioPlayerBar> createState() => _AudioPlayerBarState();
}

class _AudioPlayerBarState extends State<AudioPlayerBar> {
  late AudioPlaybackState state = widget.player.currentState;
  StreamSubscription<AudioPlaybackState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.player.stateStream.listen((nextState) {
      if (mounted) {
        setState(() => state = nextState);
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final isPlaying = state.status == AudioPlaybackStatus.playing;
    final textOnly = widget.policy.textOnlyFallback ||
        state.status == AudioPlaybackStatus.textOnlyFallback;
    final playable = widget.policy.playable && !textOnly;
    final icon = isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded;
    final tooltip =
        isPlaying ? l10n.t('pauseRecitation') : l10n.t('playRecitation');

    return DecoratedBox(
      decoration: BoxDecoration(
        color: SakinahColors.navyCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            IconButton.filled(
              key: SakinahKeys.audioPlayPauseButton,
              tooltip: textOnly ? l10n.t('audioUnavailable') : tooltip,
              onPressed: playable ? _togglePlayback : null,
              style: IconButton.styleFrom(
                backgroundColor: SakinahColors.sandGold,
                foregroundColor: SakinahColors.midnightNavy,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.12),
                disabledForegroundColor: Colors.white54,
              ),
              icon: Icon(textOnly ? Icons.article_outlined : icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    textOnly
                        ? l10n.t('textOnlyFallback')
                        : widget.asset.displayVoiceName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.asset.isQuranRecitation
                        ? l10n.t('noBackgroundMusic')
                        : l10n.t('approvedReciterLabel'),
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: widget.asset.isQuranRecitation
                  ? l10n.t('noBackgroundMusic')
                  : l10n.t('backgroundSoundAllowed'),
              child: Icon(
                widget.policy.backgroundSoundAllowed
                    ? Icons.music_note
                    : Icons.music_off_rounded,
                color: SakinahColors.sandGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayback() async {
    if (state.status == AudioPlaybackStatus.idle) {
      await widget.player.load(widget.asset);
    }
    if (state.status == AudioPlaybackStatus.playing) {
      await widget.player.pause();
      return;
    }
    await widget.player.play();
  }
}
