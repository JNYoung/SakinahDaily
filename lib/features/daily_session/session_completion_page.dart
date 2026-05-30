import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/saved_item.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class SessionCompletionPage extends ConsumerWidget {
  const SessionCompletionPage({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final languageCode = preferences.languageCode;
    final session = ref.watch(contentRepositoryProvider).getDailySession(
          sessionId,
        );
    final progress = ref.watch(sessionProgressControllerProvider);
    final savedItems = ref.watch(savedItemsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaved = savedItems.any(
      (item) =>
          item.itemType == SavedItemType.dailySession &&
          item.itemId == sessionId,
    );

    return LanguageAwareScaffold(
      title: l10n.t('sessionCompletedTitle'),
      selectedNavIndex: 0,
      body: ListView(
        key: SakinahKeys.sessionCompletionPage,
        children: [
          AppCard(
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: SakinahColors.sandGold,
                  size: 42,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.t('sessionCompletedTitle'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(l10n.t('sessionCompletedBody')),
                if (session != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    session.title.resolve(languageCode),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
                const SizedBox(height: 14),
                Text(l10n.t('noGuaranteedOutcome')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            key: SakinahKeys.homeProgressCard,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l10n.t('currentStreak'),
                    value: '${progress.currentStreakDays}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: l10n.t('completedThisWeek'),
                    value: '${progress.completionCountLast7Days}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.t('progressLocalOnly')),
          const SizedBox(height: 18),
          PrimaryButton(
            key: SakinahKeys.sessionCompletionBackHomeButton,
            label: l10n.t('backHome'),
            icon: Icons.home_outlined,
            onPressed: () => context.go('/home'),
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            key: SakinahKeys.sessionCompletionSaveButton,
            label: isSaved ? l10n.t('sessionSaved') : l10n.t('saveSession'),
            tonal: true,
            icon: Icons.bookmark_border_rounded,
            onPressed: session == null || isSaved
                ? null
                : () {
                    unawaited(
                      ref.read(savedItemsProvider.notifier).save(
                            SavedItem(
                              id: SavedItem.stableId(
                                SavedItemType.dailySession,
                                session.id,
                              ),
                              itemType: SavedItemType.dailySession,
                              itemId: session.id,
                              titleSnapshot:
                                  session.title.resolve(languageCode),
                              subtitleSnapshot: l10n.t('session'),
                              createdAt: DateTime.now(),
                              languageCode: languageCode,
                            ),
                          ),
                    );
                  },
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            key: SakinahKeys.sessionCompletionReminderButton,
            label: preferences.dailySessionReminderEnabled
                ? l10n.t('dailyReminderSet')
                : l10n.t('setDailyReminder'),
            tonal: true,
            icon: Icons.notifications_active_outlined,
            onPressed:
                session == null || preferences.dailySessionReminderEnabled
                    ? null
                    : () async {
                        await _setDailyReminder(
                          context: context,
                          ref: ref,
                          l10n: l10n,
                          session: session,
                          languageCode: languageCode,
                          preferences: preferences,
                        );
                      },
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            key: SakinahKeys.sessionCompletionSavedItemsButton,
            label: l10n.t('openSavedItems'),
            tonal: true,
            icon: Icons.bookmarks_outlined,
            onPressed: () => context.go('/saved'),
          ),
        ],
      ),
    );
  }
}

Future<void> _setDailyReminder({
  required BuildContext context,
  required WidgetRef ref,
  required SakinahLocalizations l10n,
  required DailySession session,
  required String languageCode,
  required UserPreferences preferences,
}) async {
  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.t('sessionReminderPermissionTitle')),
        content: Text(l10n.t('sessionReminderPermissionBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('sessionReminderPermissionNotNow')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('sessionReminderPermissionAllow')),
          ),
        ],
      );
    },
  );
  if (accepted != true || !context.mounted) {
    return;
  }

  final notificationService = ref.read(notificationServiceProvider);
  final permissionGranted =
      await notificationService.requestPermissionAfterExplanation();
  if (!context.mounted) {
    return;
  }
  if (!permissionGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('notificationPermissionDenied'))),
    );
    return;
  }

  final scheduled = await notificationService.scheduleDailySessionReminder(
    session,
    languageCode: languageCode,
    womenIbadahMode: preferences.womenIbadahMode,
  );
  if (!context.mounted) {
    return;
  }
  if (scheduled == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('notificationPermissionDenied'))),
    );
    return;
  }

  await ref
      .read(userPreferencesProvider.notifier)
      .setDailySessionReminderEnabled(true);
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('dailyReminderSet'))),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}
