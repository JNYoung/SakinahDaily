import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/saved_item.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/repositories/content_repository.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class QuranPage extends ConsumerStatefulWidget {
  const QuranPage({super.key});

  @override
  ConsumerState<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends ConsumerState<QuranPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final repo = ref.watch(contentRepositoryProvider);
    final savedItems = ref.watch(savedItemsProvider);
    final featured = _featuredAyah(ref, repo);
    final savedVerses = savedItems
        .where((item) => item.itemType == SavedItemType.quranVerse)
        .toList();
    final ayahs = _filterAyahs(
      repo.getQuranAyahs(),
      preferences.languageCode,
      _query,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LanguageAwareScaffold(
      title: l10n.t('quranPageTitle'),
      body: ListView(
        key: SakinahKeys.quranPage,
        children: [
          Text(
            l10n.t('quranPageTitle'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l10n.t('quranVoiceOnlyBody')),
          const SizedBox(height: 18),
          if (featured != null)
            _FeaturedAyahCard(
              ayah: featured,
              languageCode: preferences.languageCode,
            ),
          const SizedBox(height: 18),
          AppCard(
            color: isDark ? SakinahColors.navyCard : const Color(0xFFEAF3E7),
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined,
                    color: SakinahColors.sandGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.t('quranVoiceOnlyTitle'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.t('noQuranBgm')),
                      Text(l10n.t('noQuranTts')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _QuranVerseBrowser(
            ayahs: ayahs,
            languageCode: preferences.languageCode,
            onQueryChanged: (value) {
              setState(() => _query = value);
            },
          ),
          const SizedBox(height: 22),
          Text(
            l10n.t('savedItems'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          if (savedVerses.isEmpty)
            Text(l10n.t('savedItemsEmptyBody'))
          else
            for (final item in savedVerses) ...[
              AppCard(
                onTap: () => context.go('/quran/${item.itemId}'),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.titleSnapshot),
                          if (item.subtitleSnapshot != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.subtitleSnapshot!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  List<QuranAyah> _filterAyahs(
    List<QuranAyah> ayahs,
    String languageCode,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    final sorted = [...ayahs]..sort((a, b) {
        final surahCompare = a.surah.compareTo(b.surah);
        if (surahCompare != 0) {
          return surahCompare;
        }
        return a.ayah.compareTo(b.ayah);
      });

    if (normalizedQuery.isEmpty) {
      return sorted;
    }

    return sorted.where((ayah) {
      final haystack = [
        ayah.verseKey,
        ayah.surah.toString(),
        ayah.ayah.toString(),
        ayah.arabicText,
        ayah.translations.resolve(languageCode),
        ayah.source,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList();
  }

  QuranAyah? _featuredAyah(WidgetRef ref, ContentRepository repo) {
    final sessions = ref.watch(dailySessionsProvider);
    for (final session in sessions) {
      for (final step in session.steps) {
        if (step.type == 'quran' && step.contentId != null) {
          return repo.getQuranAyah(step.contentId!);
        }
      }
    }
    return repo.getQuranAyah('94:5');
  }
}

class _QuranVerseBrowser extends StatelessWidget {
  const _QuranVerseBrowser({
    required this.ayahs,
    required this.languageCode,
    required this.onQueryChanged,
  });

  final List<QuranAyah> ayahs;
  final String languageCode;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.t('quranAvailableVerses'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 6),
        Text(l10n.t('quranLocalOnlyBrowserBody')),
        const SizedBox(height: 12),
        TextField(
          key: SakinahKeys.quranVerseSearchField,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded),
            labelText: l10n.t('quranVerseSearchHint'),
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.search,
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 12),
        if (ayahs.isEmpty)
          AppCard(
            key: SakinahKeys.quranVerseEmptyState,
            color: isDark ? SakinahColors.navyCard : const Color(0xFFEAF3E7),
            padding: const EdgeInsets.all(18),
            child: Text(l10n.t('quranVerseNoResults')),
          )
        else
          for (final ayah in ayahs) ...[
            AppCard(
              key: SakinahKeys.quranVerseCard(ayah.verseKey),
              onTap: () => context.go('/quran/${ayah.verseKey}'),
              color: isDark ? SakinahColors.navyCard : null,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.quranVerseLabel(ayah.verseKey),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    ayah.arabicText,
                    textAlign: TextAlign.end,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          height: 1.7,
                          color:
                              isDark ? Colors.white : SakinahColors.deepEmerald,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(ayah.translations.resolve(languageCode)),
                  const SizedBox(height: 8),
                  Text(
                    ayah.source,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _FeaturedAyahCard extends StatelessWidget {
  const _FeaturedAyahCard({
    required this.ayah,
    required this.languageCode,
  });

  final QuranAyah ayah;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      color: isDark ? SakinahColors.navyCard : null,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.t('featuredAyah'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 18),
          Text(
            ayah.arabicText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  height: 1.8,
                  color: isDark ? Colors.white : SakinahColors.deepEmerald,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.quranVerseLabel(ayah.verseKey),
            textAlign: TextAlign.center,
            style: const TextStyle(color: SakinahColors.sandGold),
          ),
          const SizedBox(height: 14),
          Text(
            ayah.translations.resolve(languageCode),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            ayah.source,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            key: SakinahKeys.quranOpenFeaturedButton,
            label: l10n.t('openAyah'),
            icon: Icons.open_in_new_rounded,
            tonal: true,
            onPressed: () => context.go('/quran/${ayah.verseKey}'),
          ),
        ],
      ),
    );
  }
}
