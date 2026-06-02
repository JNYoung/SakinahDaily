import 'package:flutter/material.dart';

import '../../core/localization/sakinah_localizations.dart';

class SourceChip extends StatelessWidget {
  const SourceChip({
    required this.source,
    required this.reviewStatus,
    this.onTap,
    super.key,
  });

  final String source;
  final String reviewStatus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(22);
    final borderColor =
        isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFD6E6D0);
    final iconColor =
        isDark ? const Color(0xFFC9A45C) : const Color(0xFF0E3B2E);
    final trailingIcon = Directionality.of(context) == TextDirection.rtl
        ? Icons.chevron_left
        : Icons.chevron_right;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$source · ${l10n.reviewContentLabel(reviewStatus)}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Icon(trailingIcon, color: iconColor, size: 20),
          ],
        ],
      ),
    );

    final chip = Material(
      color: isDark ? const Color(0xFF18263D) : const Color(0xFFEAF3E7),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              child: content,
            ),
    );

    if (onTap == null) {
      return chip;
    }

    return Semantics(
      button: true,
      child: chip,
    );
  }
}
