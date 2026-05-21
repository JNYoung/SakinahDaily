import 'package:flutter/material.dart';

import '../../core/localization/sakinah_localizations.dart';

class SourceChip extends StatelessWidget {
  const SourceChip({
    required this.source,
    required this.reviewStatus,
    super.key,
  });

  final String source;
  final String reviewStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18263D) : const Color(0xFFEAF3E7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : const Color(0xFFD6E6D0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.verified_outlined,
              color: isDark ? const Color(0xFFC9A45C) : const Color(0xFF0E3B2E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$source · ${l10n.reviewContentLabel(reviewStatus)}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
