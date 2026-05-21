import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/source_chip.dart';

class DuaDetailPage extends ConsumerWidget {
  const DuaDetailPage({required this.duaId, super.key});

  final String duaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);
    final languageCode = ref.watch(userPreferencesProvider).languageCode;
    final l10n = SakinahLocalizations.of(context);
    final dua = repo.getDua(duaId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (dua == null) {
      return LanguageAwareScaffold(
        title: l10n.t('dua'),
        body: Center(child: Text(l10n.t('duaUnavailable'))),
      );
    }

    return LanguageAwareScaffold(
      title: l10n.t('makeDua'),
      selectedNavIndex: 1,
      body: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.t('makeDua'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.t('duaContext'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Chip(label: Text(l10n.t('saved'))),
            ],
          ),
          const SizedBox(height: 22),
          AppCard(
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.t('arabicLabel'),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 18),
                Text(
                  dua.arabicText,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 29,
                    height: 1.9,
                    fontWeight: FontWeight.w800,
                  ).copyWith(
                    color: isDark ? Colors.white : SakinahColors.deepEmerald,
                  ),
                ),
                const Divider(height: 34),
                Text(
                  l10n.t('transliteration'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  dua.transliteration,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 34),
                Text(l10n.t('meaning'),
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 10),
                Text(dua.translations.resolve(languageCode)),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.t('listen'),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.t('repeatSlowly'),
                        tonal: true,
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppCard(
            key: SakinahKeys.duaSourceCard,
            color: isDark ? SakinahColors.navyCard : const Color(0xFFEAF3E7),
            padding: EdgeInsets.zero,
            child: SourceChip(
              source: dua.source,
              reviewStatus: dua.reviewStatus.name,
            ),
          ),
        ],
      ),
    );
  }
}
