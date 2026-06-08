import 'package:flutter/material.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';

class ContentSourcesPage extends StatelessWidget {
  const ContentSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);

    return LanguageAwareScaffold(
      key: SakinahKeys.contentSourcesPage,
      title: l10n.t('contentSourcesTitle'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          _SourceSection(
            icon: Icons.inventory_2_outlined,
            title: l10n.t('contentSourcesSeedTitle'),
            body: l10n.t('contentSourcesSeedBody'),
          ),
          _SourceSection(
            icon: Icons.cloud_queue_outlined,
            title: l10n.t('contentSourcesCmsTitle'),
            body: l10n.t('contentSourcesCmsBody'),
          ),
          _SourceSection(
            icon: Icons.verified_outlined,
            title: l10n.t('contentSourcesReviewTitle'),
            body: l10n.t('contentSourcesReviewBody'),
          ),
          _SourceSection(
            icon: Icons.block_outlined,
            title: l10n.t('contentSourcesNotGeneratedTitle'),
            body: l10n.t('contentSourcesNotGeneratedBody'),
          ),
        ],
      ),
    );
  }
}

class _SourceSection extends StatelessWidget {
  const _SourceSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        radius: 8,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
