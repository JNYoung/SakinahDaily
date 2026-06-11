import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/saved_item.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class QuranVerseDetailPage extends ConsumerWidget {
  const QuranVerseDetailPage({required this.verseKey, super.key});

  final String verseKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(contentRepositoryProvider);
    final preferences = ref.watch(userPreferencesProvider);
    final savedItems = ref.watch(savedItemsProvider);
    final l10n = SakinahLocalizations.of(context);
    final ayah = repo.getQuranAyah(verseKey);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (ayah == null) {
      return LanguageAwareScaffold(
        title: l10n.t('quranPageTitle'),
        body: Center(child: Text(l10n.t('quranVerseUnavailable'))),
      );
    }

    final audio = ayah.audioAssetId == null
        ? null
        : repo.getAudioAsset(ayah.audioAssetId!);
    final isSaved = savedItems.any(
      (item) =>
          item.itemType == SavedItemType.quranVerse &&
          item.itemId == ayah.verseKey,
    );

    return LanguageAwareScaffold(
      title: l10n.quranVerseLabel(ayah.verseKey),
      body: ListView(
        key: SakinahKeys.quranVerseDetailPage,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quranVerseLabel(ayah.verseKey),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 140,
                child: PrimaryButton(
                  key: SakinahKeys.quranVerseSaveButton,
                  label: isSaved ? l10n.t('savedAyah') : l10n.t('saveAyah'),
                  tonal: true,
                  onPressed: () {
                    final item = SavedItem(
                      id: SavedItem.stableId(
                        SavedItemType.quranVerse,
                        ayah.verseKey,
                      ),
                      itemType: SavedItemType.quranVerse,
                      itemId: ayah.verseKey,
                      titleSnapshot: l10n.quranVerseLabel(ayah.verseKey),
                      subtitleSnapshot:
                          ayah.translations.resolve(preferences.languageCode),
                      sourceLabel: ayah.source,
                      createdAt: DateTime.now(),
                      languageCode: preferences.languageCode,
                    );
                    unawaited(
                      ref.read(savedItemsProvider.notifier).toggle(item),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ayah.arabicText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        height: 1.9,
                        color:
                            isDark ? Colors.white : SakinahColors.deepEmerald,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Divider(height: 34),
                Text(
                  ayah.translations.resolve(preferences.languageCode),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Text(
                  ayah.source,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            key: SakinahKeys.quranVerseSafetyCard,
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
                      if (audio != null && audio.displayVoiceName.isNotEmpty)
                        Text(l10n.recitedBy(audio.displayVoiceName)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
