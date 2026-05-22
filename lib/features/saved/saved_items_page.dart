import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/saved_item.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';

class SavedItemsPage extends ConsumerWidget {
  const SavedItemsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final items = ref.watch(savedItemsProvider);

    return LanguageAwareScaffold(
      title: l10n.t('savedItems'),
      selectedNavIndex: 3,
      body: ListView(
        key: SakinahKeys.savedItemsPage,
        children: [
          Text(
            l10n.t('savedItems'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(l10n.t('savedLocalOnly')),
          const SizedBox(height: 18),
          if (items.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('savedItemsEmptyTitle'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.t('savedItemsEmptyBody')),
                ],
              ),
            )
          else
            for (final item in items) ...[
              AppCard(
                key: SakinahKeys.savedItemTile(item.id),
                onTap: () => context.go(_routeFor(item)),
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    Icon(_iconFor(item.itemType)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.titleSnapshot),
                          if ((item.sourceLabel ?? item.subtitleSnapshot) !=
                              null) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.sourceLabel ?? item.subtitleSnapshot!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      key: SakinahKeys.savedItemRemoveButton(item.id),
                      tooltip: l10n.t('removeSavedItem'),
                      onPressed: () {
                        unawaited(
                          ref
                              .read(savedItemsProvider.notifier)
                              .remove(item.itemType, item.itemId),
                        );
                      },
                      icon: const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  String _routeFor(SavedItem item) {
    return switch (item.itemType) {
      SavedItemType.dailySession => '/session/${item.itemId}',
      SavedItemType.dua => '/dua/${item.itemId}',
      SavedItemType.dhikr => '/dhikr/${item.itemId}',
      SavedItemType.quranVerse => '/home',
    };
  }

  IconData _iconFor(SavedItemType itemType) {
    return switch (itemType) {
      SavedItemType.dailySession => Icons.nightlight_round,
      SavedItemType.dua => Icons.favorite_border_rounded,
      SavedItemType.dhikr => Icons.radio_button_checked_rounded,
      SavedItemType.quranVerse => Icons.menu_book_outlined,
    };
  }
}
