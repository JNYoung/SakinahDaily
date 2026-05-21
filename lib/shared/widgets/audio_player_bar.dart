import 'package:flutter/material.dart';

import '../../core/localization/sakinah_localizations.dart';

class AudioPlayerBar extends StatelessWidget {
  const AudioPlayerBar({
    required this.reciterName,
    required this.bgmAllowed,
    super.key,
  });

  final String reciterName;
  final bool bgmAllowed;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF18263D),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('voiceOnly'),
                    style: const TextStyle(
                      color: Color(0xFFC9A45C),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reciterName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: bgmAllowed
                  ? l10n.t('backgroundSoundAllowed')
                  : l10n.t('noBackgroundMusic'),
              child: Icon(
                bgmAllowed ? Icons.music_note : Icons.music_off_rounded,
                color: const Color(0xFFC9A45C),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: l10n.t('playRecitation'),
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFC9A45C),
                foregroundColor: const Color(0xFF101B2D),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
