import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/saved_item.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/content_discovery.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/dhikr_counter_circle.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/source_chip.dart';

class DhikrPage extends ConsumerStatefulWidget {
  const DhikrPage({this.initialDhikrId, super.key});

  final String? initialDhikrId;

  @override
  ConsumerState<DhikrPage> createState() => _DhikrPageState();
}

class _DhikrPageState extends ConsumerState<DhikrPage> {
  final _searchController = TextEditingController();
  String selectedCategory = allContentCategory;
  String? selectedId;
  int count = 0;

  @override
  void initState() {
    super.initState();
    selectedId = widget.initialDhikrId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dhikrs = ref.watch(dhikrsProvider);
    final languageCode = ref.watch(userPreferencesProvider).languageCode;
    final savedItems = ref.watch(savedItemsProvider);
    final l10n = SakinahLocalizations.of(context);
    final categories = discoverCategories(
      dhikrs.map((dhikr) => dhikr.category),
    );
    final filteredDhikrs = dhikrs.where((dhikr) {
      final matchesCategory = selectedCategory == allContentCategory ||
          dhikr.category == selectedCategory;
      final matchesQuery = contentMatchesQuery(
        _searchController.text,
        [
          dhikr.category,
          dhikr.title.resolve(languageCode),
          dhikr.arabicText,
          dhikr.transliteration,
          dhikr.translations.resolve(languageCode),
          dhikr.source,
        ],
      );
      return matchesCategory && matchesQuery;
    }).toList();
    final selected = _selectedDhikr(filteredDhikrs);
    final isSaved = savedItems.any(
      (item) =>
          selected != null &&
          item.itemType == SavedItemType.dhikr &&
          item.itemId == selected.id,
    );

    return LanguageAwareScaffold(
      title: l10n.t('dhikr'),
      body: ListView(
        children: [
          TextField(
            key: SakinahKeys.dhikrSearchField,
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.t('searchDhikrHint'),
              prefixIcon: const Icon(Icons.search_rounded),
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.search,
            onChanged: (_) {
              setState(() {
                selectedId = null;
                count = 0;
              });
            },
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final category in categories)
                FilterChip(
                  key: SakinahKeys.dhikrCategoryChip(category),
                  label: Text(contentCategoryLabel(l10n, category)),
                  selected: category == selectedCategory,
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                      selectedId = null;
                      count = 0;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (selected == null)
            AppCard(
              key: SakinahKeys.dhikrEmptyState,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('noDhikrResultsTitle'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(l10n.t('noDhikrResultsBody')),
                ],
              ),
            )
          else ...[
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filteredDhikrs.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final dhikr = filteredDhikrs[index];
                  final isSelected = selected.id == dhikr.id;
                  return SizedBox(
                    width: 220,
                    child: AppCard(
                      key: SakinahKeys.dhikrListItem(dhikr.id),
                      color: isSelected
                          ? const Color(0xFFEAF3E7)
                          : Theme.of(context).cardColor,
                      onTap: () {
                        setState(() {
                          selectedId = dhikr.id;
                          count = 0;
                        });
                      },
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: SakinahColors.deepEmerald,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            dhikr.title.resolve(languageCode),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            contentCategoryLabel(l10n, dhikr.category),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              selected.arabicText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(selected.transliteration, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Center(
              child: DhikrCounterCircle(
                key: SakinahKeys.dhikrCounter,
                count: count,
                target: selected.targetCount,
                onTap: () => setState(() => count += 1),
              ),
            ),
            const SizedBox(height: 24),
            SourceChip(
              source: selected.source,
              reviewStatus: selected.reviewStatus.name,
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              key: SakinahKeys.dhikrSaveButton,
              label: isSaved ? l10n.t('unsave') : l10n.t('save'),
              tonal: true,
              onPressed: () {
                final item = SavedItem(
                  id: SavedItem.stableId(SavedItemType.dhikr, selected.id),
                  itemType: SavedItemType.dhikr,
                  itemId: selected.id,
                  titleSnapshot: selected.title.resolve(languageCode),
                  subtitleSnapshot: l10n.t('dhikr'),
                  sourceLabel: selected.source,
                  createdAt: DateTime.now(),
                  languageCode: languageCode,
                );
                unawaited(ref.read(savedItemsProvider.notifier).toggle(item));
              },
            ),
          ],
        ],
      ),
    );
  }

  DhikrItem? _selectedDhikr(List<DhikrItem> filteredDhikrs) {
    if (filteredDhikrs.isEmpty) {
      return null;
    }
    return filteredDhikrs
            .where((dhikr) => dhikr.id == selectedId)
            .firstOrNull ??
        filteredDhikrs.first;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
