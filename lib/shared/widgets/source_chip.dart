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

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3E7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD6E6D0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined, color: Color(0xFF0E3B2E)),
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
