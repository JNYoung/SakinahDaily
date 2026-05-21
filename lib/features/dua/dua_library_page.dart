import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/source_chip.dart';

class DuaLibraryPage extends ConsumerWidget {
  const DuaLibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duas = ref.watch(duasProvider);
    final languageCode = ref.watch(userPreferencesProvider).languageCode;
    final l10n = SakinahLocalizations.of(context);

    return LanguageAwareScaffold(
      title: l10n.t('dua'),
      selectedNavIndex: 1,
      body: ListView.separated(
        itemCount: duas.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final dua = duas[index];
          return AppCard(
            key: SakinahKeys.duaListItem(dua.id),
            onTap: () => context.go('/dua/${dua.id}'),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.favorite_border_rounded,
                    color: SakinahColors.sandGold),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dua.translations.resolve(languageCode)),
                      const SizedBox(height: 4),
                      Text(
                        dua.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DuaPreview extends StatelessWidget {
  const DuaPreview({
    required this.source,
    required this.reviewStatus,
    super.key,
  });

  final String source;
  final String reviewStatus;

  @override
  Widget build(BuildContext context) {
    return SourceChip(source: source, reviewStatus: reviewStatus);
  }
}
