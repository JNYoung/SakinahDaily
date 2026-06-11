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
          Text(l10n.t('contentSourcesIntro')),
          const SizedBox(height: 12),
          _ContentSourceCard(
            icon: Icons.verified_outlined,
            title: l10n.t('contentSourcesSeedTitle'),
            body: l10n.t('contentSourcesSeedBody'),
          ),
          _ContentSourceCard(
            icon: Icons.fact_check_outlined,
            title: l10n.t('contentSourcesApprovalTitle'),
            body: l10n.t('contentSourcesApprovalBody'),
          ),
          _ContentSourceCard(
            icon: Icons.auto_fix_off_outlined,
            title: l10n.t('contentSourcesGeneratedTitle'),
            body: l10n.t('contentSourcesGeneratedBody'),
          ),
          _ContentSourceCard(
            icon: Icons.record_voice_over_outlined,
            title: l10n.t('contentSourcesAudioTitle'),
            body: l10n.t('contentSourcesAudioBody'),
          ),
          _ContentSourceCard(
            icon: Icons.balance_outlined,
            title: l10n.t('contentSourcesFatwaTitle'),
            body: l10n.t('contentSourcesFatwaBody'),
          ),
        ],
      ),
    );
  }
}

class _ContentSourceCard extends StatelessWidget {
  const _ContentSourceCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        radius: 8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title, style: textTheme.titleMedium),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(body),
          ],
        ),
      ),
    );
  }
}
