import 'package:flutter/material.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/services/prayer_calculation_service.dart';

class PrayerCountdownPill extends StatelessWidget {
  const PrayerCountdownPill({
    required this.prayer,
    required this.now,
    this.inLabel = 'in',
    super.key,
  });

  final PrayerTime prayer;
  final DateTime now;
  final String inLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final remaining = prayer.time.difference(now);
    final hours = remaining.inHours.clamp(0, 24);
    final minutes = remaining.inMinutes.remainder(60).clamp(0, 59);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          l10n.prayerCountdown(prayer.name, hours, minutes),
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ),
    );
  }
}
