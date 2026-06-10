import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/content_discovery.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/source_chip.dart';

class DuaLibraryPage extends ConsumerStatefulWidget {
  const DuaLibraryPage({super.key});

  @override
  ConsumerState<DuaLibraryPage> createState() => _DuaLibraryPageState();
}

class _DuaLibraryPageState extends ConsumerState<DuaLibraryPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = allContentCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duas = ref.watch(duasProvider);
    final languageCode = ref.watch(userPreferencesProvider).languageCode;
    final l10n = SakinahLocalizations.of(context);
    final categories = discoverCategories(duas.map((dua) => dua.category));
    final filteredDuas = duas.where((dua) {
      final matchesCategory = _selectedCategory == allContentCategory ||
          dua.category == _selectedCategory;
      final matchesQuery = contentMatchesQuery(
        _searchController.text,
        [
          dua.category,
          dua.arabicText,
          dua.transliteration,
          dua.translations.resolve(languageCode),
          dua.source,
        ],
      );
      return matchesCategory && matchesQuery;
    }).toList();

    return LanguageAwareScaffold(
      title: l10n.t('dua'),
      body: ListView(
        children: [
          TextField(
            key: SakinahKeys.duaSearchField,
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.t('searchDuaHint'),
              prefixIcon: const Icon(Icons.search_rounded),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                FilterChip(
                  key: SakinahKeys.duaCategoryChip(category),
                  label: Text(contentCategoryLabel(l10n, category)),
                  selected: category == _selectedCategory,
                  onSelected: (_) {
                    setState(() => _selectedCategory = category);
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (filteredDuas.isEmpty)
            AppCard(
              key: SakinahKeys.duaEmptyState,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('noDuaResultsTitle'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.t('noDuaResultsBody')),
                ],
              ),
            )
          else
            for (final dua in filteredDuas) ...[
              AppCard(
                key: SakinahKeys.duaListItem(dua.id),
                onTap: () => context.go('/dua/${dua.id}'),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_border_rounded,
                      color: SakinahColors.sandGold,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dua.translations.resolve(languageCode)),
                          const SizedBox(height: 4),
                          Text(
                            contentCategoryLabel(l10n, dua.category),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
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
