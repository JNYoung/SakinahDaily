import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/sakinah_theme.dart';
import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/saved_item.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final testingFeedbackChannel =
        ref.watch(appEnvironmentConfigProvider).testingFeedbackChannel;
    final sessions = ref.watch(dailySessionsProvider);
    final prayerService = ref.watch(prayerCalculationServiceProvider);
    final savedItems = ref.watch(savedItemsProvider);
    final sessionProgress = ref.watch(sessionProgressControllerProvider);
    final prayerCompletion = ref.watch(prayerCompletionControllerProvider);
    final womenModeDecision = ref
        .watch(womenModeContentPolicyProvider)
        .evaluate(preferences.womenIbadahMode);
    final now = ref.watch(currentDateTimeProvider);
    final nextPrayer =
        prayerService.nextPrayer(now, preferences.prayerSettings);
    final session = sessions.first;
    final activeProgress = sessionProgress.progressFor(session.id);
    final completedToday =
        sessionProgress.completionForDate(now, sessionId: session.id) != null;
    final sessionButtonLabel = completedToday
        ? l10n.t('reviewSession')
        : activeProgress != null
            ? l10n.t('resumeSession')
            : l10n.t('start');
    final sessionStatusLabel = completedToday
        ? l10n.t('completedToday')
        : activeProgress != null
            ? l10n.t('resumeSession')
            : null;
    final sessionReminderLabel = preferences.dailySessionReminderEnabled
        ? _statusLabel(
            l10n.t('dailySessionReminderTitle'),
            formatDailySessionReminderTime(
              preferences.dailySessionReminderMinutesAfterMidnight,
            ),
          )
        : null;
    final showSessionReminderCta =
        completedToday && !preferences.dailySessionReminderEnabled;
    final showWomenModeSupport = preferences.womenIbadahMode.enabled &&
        womenModeDecision.flags.any(
          (flag) =>
              flag == 'prefer_dua_dhikr_reflection' ||
              flag == 'gentle_support' ||
              flag == 'privacy_safe_copy',
        );
    final isTonightSaved = savedItems.any(
      (item) =>
          item.itemType == SavedItemType.dailySession &&
          item.itemId == session.id,
    );
    final recentSavedItems = savedItems.take(2).toList(growable: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LanguageAwareScaffold(
      title: l10n.t('appTitle'),
      showAppBar: false,
      selectedNavIndex: 0,
      actions: [
        IconButton(
          tooltip: l10n.t('settings'),
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: ListView(
        key: SakinahKeys.homeContentList,
        children: [
          _HomeAnalyticsTracker(
            prayerCompletion: prayerCompletion,
            now: now,
            prayerRemindersEnabled: preferences.notificationsEnabled,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.t('homeGreeting')},',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark
                                ? Colors.white70
                                : SakinahColors.mutedText,
                          ),
                    ),
                    Text(
                      preferences.genderMode.name == 'female'
                          ? l10n.t('homeFemaleName')
                          : l10n.t('homeFriend'),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      l10n.t('homeDateLabel'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.white60
                                : SakinahColors.mutedText,
                          ),
                    ),
                  ],
                ),
              ),
              _PrayerBadge(
                key: SakinahKeys.homePrayerBadge,
                label: l10n.prayerCountdown(
                  nextPrayer.name,
                  nextPrayer.time.difference(now).inHours.clamp(0, 24),
                  nextPrayer.time
                      .difference(now)
                      .inMinutes
                      .remainder(60)
                      .clamp(0, 59),
                ),
                onTap: () => context.push('/prayer'),
              ),
            ],
          ),
          const SizedBox(height: 26),
          _PrayerReleaseCard(
            key: SakinahKeys.homePrayerPrimaryCard,
            title: l10n.t('dailyPrayerHomeTitle'),
            nextPrayerLabel: l10n.t('nextPrayer'),
            nextPrayerName: l10n.prayerName(nextPrayer.name),
            nextPrayerTime: _formatPrayerTime(nextPrayer.time),
            locationLabel: _statusLabel(
              l10n.t('prayerLocation'),
              preferences.prayerSettings.locationLabel,
            ),
            methodLabel: _statusLabel(
              l10n.t('prayerMethod'),
              prayerService.methodLabel(
                preferences.prayerSettings.method,
              ),
            ),
            remindersLabel: _statusLabel(
              l10n.t('prayerReminders'),
              preferences.notificationsEnabled
                  ? l10n.t('reminderStatusOn')
                  : l10n.t('reminderStatusOff'),
            ),
            openPrayerLabel: l10n.t('viewPrayerTimes'),
            reminderSettingsLabel: l10n.t('manageReminders'),
            onOpenPrayer: () => context.push('/prayer'),
            onReminderSettings: () => context.go('/settings/notifications'),
          ),
          const SizedBox(height: 18),
          if (testingFeedbackChannel != null) ...[
            _ClosedTestingHomeCard(
              key: SakinahKeys.homeClosedTestingGuideCard,
              title: l10n.t('closedTestingGuideTitle'),
              body: l10n.t('closedTestingHomeBody'),
              buttonLabel: l10n.t('closedTestingHomeButton'),
              onOpenGuide: () => context.go('/settings/testing-guide'),
            ),
            const SizedBox(height: 14),
          ],
          _HeroSessionCard(
            key: SakinahKeys.homeSessionCard,
            eyebrow: l10n.t('todaySession'),
            title: session.title.resolve(preferences.languageCode),
            subtitle: l10n.t('sessionSubtitleMeta'),
            statusLabel: sessionStatusLabel,
            reminderLabel: sessionReminderLabel,
            supportLabel:
                showWomenModeSupport ? l10n.t('womenModePrivatePath') : null,
            supportBody: showWomenModeSupport
                ? l10n.t('womenModeHomeSupportBody')
                : null,
            localOnlyLabel:
                showWomenModeSupport ? l10n.t('localOnlyMode') : null,
            startButtonKey: SakinahKeys.homeSessionStartButton,
            startLabel: sessionButtonLabel,
            reminderCtaLabel:
                showSessionReminderCta ? l10n.t('setDailyReminder') : null,
            voiceOnlyLabel: l10n.t('voiceOnly'),
            onStart: () => completedToday
                ? context.go('/session/${session.id}/completed')
                : context.go('/session/${session.id}?source=home'),
            onReminderCta: showSessionReminderCta
                ? () => context.go('/settings/notifications')
                : null,
            onVoiceOnly: () => _showQuranVoiceOnlySheet(context, l10n),
          ),
          if (recentSavedItems.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SavedItemsRail(
              key: SakinahKeys.homeSavedRail,
              title: l10n.t('continueFromSaved'),
              localNote: l10n.t('savedRailLocalNote'),
              openSavedItemsLabel: l10n.t('openSavedItems'),
              items: recentSavedItems,
              onOpenSavedItems: () => context.go('/saved'),
              onOpenItem: (item) => context.go(_routeForSavedItem(item)),
            ),
          ],
          const SizedBox(height: 14),
          AppCard(
            key: SakinahKeys.homeProgressCard,
            color: isDark ? SakinahColors.navyCard : null,
            radius: 8,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('localProgress'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ProgressMetric(
                        label: l10n.t('currentStreak'),
                        value: '${sessionProgress.currentStreakDays}',
                      ),
                    ),
                    Expanded(
                      child: _ProgressMetric(
                        label: l10n.t('completedThisWeek'),
                        value: '${sessionProgress.completionCountLast7Days}',
                      ),
                    ),
                    Expanded(
                      child: _ProgressMetric(
                        key: SakinahKeys.homePrayerCompletionMetric,
                        label: l10n.t('prayersToday'),
                        value: '${prayerCompletion.completedCountForDate(now)}/'
                            '${defaultPrayerReminderNames.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  key: SakinahKeys.homePrayerWeekProgress,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      l10n.t('prayerWeekProgress'),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ProgressMetric(
                            key: SakinahKeys.homePrayerWeekDaysMetric,
                            label: l10n.t('prayerWeekCheckInDays'),
                            value: '${prayerCompletion.completionDaysLast7}/7',
                          ),
                        ),
                        Expanded(
                          child: _ProgressMetric(
                            key: SakinahKeys.homePrayerWeekStreakMetric,
                            label: l10n.t('prayerWeekStreak'),
                            value: '${prayerCompletion.currentStreakDays}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.t('progressLocalOnly')),
                const SizedBox(height: 4),
                Text(l10n.t('prayerCheckInsLocalOnly')),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppCard(
            key: SakinahKeys.homeNightCard,
            color: isDark ? SakinahColors.navyCard : null,
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('tonight'),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color:
                            isDark ? Colors.white60 : SakinahColors.mutedText,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.t('sleepAyatKursi'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.t('sleepSessionDescription'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 170,
                  child: PrimaryButton(
                    key: SakinahKeys.homeSaveTonightButton,
                    label: isTonightSaved
                        ? l10n.t('savedTonight')
                        : l10n.t('saveTonight'),
                    tonal: true,
                    onPressed: isTonightSaved
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
                                      titleSnapshot: l10n.t('sleepAyatKursi'),
                                      subtitleSnapshot: session.title
                                          .resolve(preferences.languageCode),
                                      createdAt: DateTime.now(),
                                      languageCode: preferences.languageCode,
                                    ),
                                  ),
                            );
                          },
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

class _HomeAnalyticsTracker extends ConsumerStatefulWidget {
  const _HomeAnalyticsTracker({
    required this.prayerCompletion,
    required this.now,
    required this.prayerRemindersEnabled,
  });

  final PrayerCompletionState prayerCompletion;
  final DateTime now;
  final bool prayerRemindersEnabled;

  @override
  ConsumerState<_HomeAnalyticsTracker> createState() =>
      _HomeAnalyticsTrackerState();
}

class _HomeAnalyticsTrackerState extends ConsumerState<_HomeAnalyticsTracker> {
  bool _tracked = false;

  @override
  void initState() {
    super.initState();
    _scheduleTrack();
  }

  @override
  void didUpdateWidget(covariant _HomeAnalyticsTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleTrack();
  }

  @override
  Widget build(BuildContext context) {
    _scheduleTrack();
    return const SizedBox.shrink();
  }

  void _scheduleTrack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackIfReady();
    });
  }

  void _trackIfReady() {
    if (_tracked || !mounted || !widget.prayerCompletion.isLoaded) {
      return;
    }
    _tracked = true;
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.homeViewed,
      {
        'screen': 'home',
        'route': '/home',
        'prayers_completed_today':
            widget.prayerCompletion.completedCountForDate(widget.now),
        'prayer_checkins_7d': widget.prayerCompletion.completionCountLast7Days,
        'prayer_checkin_days_7d': widget.prayerCompletion.completionDaysLast7,
        'prayer_checkin_streak_days': widget.prayerCompletion.currentStreakDays,
        'prayer_reminders_enabled': widget.prayerRemindersEnabled,
      },
    );
  }
}

class _ClosedTestingHomeCard extends StatelessWidget {
  const _ClosedTestingHomeCard({
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onOpenGuide,
    super.key,
  });

  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onOpenGuide;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      color: isDark ? SakinahColors.navyCard : null,
      radius: 8,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.rate_review_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              key: SakinahKeys.homeClosedTestingGuideButton,
              onPressed: onOpenGuide,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}

String _statusLabel(String label, String value) => '$label · $value';

String _routeForSavedItem(SavedItem item) {
  return switch (item.itemType) {
    SavedItemType.dailySession => '/session/${item.itemId}',
    SavedItemType.dua => '/dua/${item.itemId}',
    SavedItemType.dhikr => '/dhikr/${item.itemId}',
    SavedItemType.quranVerse => '/quran/${item.itemId}',
  };
}

class _PrayerBadge extends StatelessWidget {
  const _PrayerBadge({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      avatar: const Icon(Icons.circle, size: 8, color: SakinahColors.sandGold),
      label: Text(label),
      onPressed: onTap,
      backgroundColor:
          isDark ? SakinahColors.navyCard : const Color(0xFFEAF3E7),
      side: BorderSide.none,
      labelStyle: TextStyle(
        color: isDark ? Colors.white : SakinahColors.deepEmerald,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PrayerReleaseCard extends StatelessWidget {
  const _PrayerReleaseCard({
    required this.title,
    required this.nextPrayerLabel,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.locationLabel,
    required this.methodLabel,
    required this.remindersLabel,
    required this.openPrayerLabel,
    required this.reminderSettingsLabel,
    required this.onOpenPrayer,
    required this.onReminderSettings,
    super.key,
  });

  final String title;
  final String nextPrayerLabel;
  final String nextPrayerName;
  final String nextPrayerTime;
  final String locationLabel;
  final String methodLabel;
  final String remindersLabel;
  final String openPrayerLabel;
  final String reminderSettingsLabel;
  final VoidCallback onOpenPrayer;
  final VoidCallback onReminderSettings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      color: isDark ? SakinahColors.navyCard : const Color(0xFFEAF3E7),
      radius: 8,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextPrayerLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: isDark
                                ? Colors.white70
                                : SakinahColors.mutedText,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayerName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              Text(
                nextPrayerTime,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: SakinahColors.deepEmerald,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PrayerInfoChip(
                icon: Icons.location_on_outlined,
                label: locationLabel,
              ),
              _PrayerInfoChip(
                icon: Icons.calculate_outlined,
                label: methodLabel,
              ),
              _PrayerInfoChip(
                icon: Icons.notifications_active_outlined,
                label: remindersLabel,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              key: SakinahKeys.homePrayerTimesButton,
              label: openPrayerLabel,
              onPressed: onOpenPrayer,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              key: SakinahKeys.homePrayerReminderSettingsButton,
              label: reminderSettingsLabel,
              tonal: true,
              onPressed: onReminderSettings,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerInfoChip extends StatelessWidget {
  const _PrayerInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}

class _SavedItemsRail extends StatelessWidget {
  const _SavedItemsRail({
    required this.title,
    required this.localNote,
    required this.openSavedItemsLabel,
    required this.items,
    required this.onOpenSavedItems,
    required this.onOpenItem,
    super.key,
  });

  final String title;
  final String localNote;
  final String openSavedItemsLabel;
  final List<SavedItem> items;
  final VoidCallback onOpenSavedItems;
  final ValueChanged<SavedItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      color: isDark ? SakinahColors.navyCard : null,
      radius: 8,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                key: SakinahKeys.homeSavedItemsButton,
                onPressed: onOpenSavedItems,
                icon: const Icon(Icons.bookmarks_outlined, size: 18),
                label: Text(openSavedItemsLabel),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            localNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.white60 : SakinahColors.mutedText,
                ),
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            _SavedItemRow(
              key: SakinahKeys.homeSavedItemTile(item.id),
              item: item,
              onTap: () => onOpenItem(item),
            ),
            if (item != items.last) const Divider(height: 18),
          ],
        ],
      ),
    );
  }
}

class _SavedItemRow extends StatelessWidget {
  const _SavedItemRow({
    required this.item,
    required this.onTap,
    super.key,
  });

  final SavedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(_iconForSavedItem(item.itemType)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.titleSnapshot,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  if ((item.sourceLabel ?? item.subtitleSnapshot) != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.sourceLabel ?? item.subtitleSnapshot!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

IconData _iconForSavedItem(SavedItemType itemType) {
  return switch (itemType) {
    SavedItemType.dailySession => Icons.nightlight_round,
    SavedItemType.dua => Icons.favorite_border_rounded,
    SavedItemType.dhikr => Icons.radio_button_checked_rounded,
    SavedItemType.quranVerse => Icons.menu_book_outlined,
  };
}

class _HeroSessionCard extends StatelessWidget {
  const _HeroSessionCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    this.reminderLabel,
    this.supportLabel,
    this.supportBody,
    this.localOnlyLabel,
    required this.startButtonKey,
    required this.startLabel,
    this.reminderCtaLabel,
    required this.voiceOnlyLabel,
    required this.onStart,
    this.onReminderCta,
    required this.onVoiceOnly,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String? statusLabel;
  final String? reminderLabel;
  final String? supportLabel;
  final String? supportBody;
  final String? localOnlyLabel;
  final Key startButtonKey;
  final String startLabel;
  final String? reminderCtaLabel;
  final String voiceOnlyLabel;
  final VoidCallback onStart;
  final VoidCallback? onReminderCta;
  final VoidCallback onVoiceOnly;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: SakinahColors.deepEmerald,
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          PositionedDirectional(
            end: 6,
            top: 16,
            child: Icon(
              Icons.nightlight_round,
              size: 72,
              color: SakinahColors.sandGold.withValues(alpha: 0.82),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.78)),
              ),
              if (supportLabel != null && supportBody != null) ...[
                const SizedBox(height: 14),
                Container(
                  key: SakinahKeys.homeWomenModeSupportCard,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            supportLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (localOnlyLabel != null)
                            Chip(
                              key: SakinahKeys.homeWomenModeLocalChip,
                              avatar: const Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                              ),
                              label: Text(localOnlyLabel!),
                              visualDensity: VisualDensity.compact,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.16),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              side: BorderSide.none,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        supportBody!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (statusLabel != null || reminderLabel != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (statusLabel != null)
                      _SessionStatusChip(label: statusLabel!),
                    if (reminderLabel != null)
                      _SessionStatusChip(
                        key: SakinahKeys.homeSessionReminderStatusChip,
                        icon: Icons.alarm_outlined,
                        label: reminderLabel!,
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      key: startButtonKey,
                      label: startLabel,
                      onPressed: onStart,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: PrimaryButton(
                      key: SakinahKeys.homeVoiceOnlyButton,
                      label: voiceOnlyLabel,
                      tonal: true,
                      onPressed: onVoiceOnly,
                    ),
                  ),
                ],
              ),
              if (reminderCtaLabel != null && onReminderCta != null) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  key: SakinahKeys.homeSessionReminderCtaButton,
                  label: reminderCtaLabel!,
                  icon: Icons.notifications_active_outlined,
                  tonal: true,
                  onPressed: onReminderCta,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionStatusChip extends StatelessWidget {
  const _SessionStatusChip({
    required this.label,
    this.icon,
    super.key,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: icon == null
          ? null
          : Icon(
              icon,
              size: 16,
              color: Colors.white,
            ),
      label: Text(label),
      backgroundColor: Colors.white.withValues(alpha: 0.14),
      labelStyle: const TextStyle(color: Colors.white),
      side: BorderSide.none,
    );
  }
}

class _ProgressMetric extends StatelessWidget {
  const _ProgressMetric({
    required this.label,
    required this.value,
    super.key,
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

Future<void> _showQuranVoiceOnlySheet(
  BuildContext context,
  SakinahLocalizations l10n,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('quranVoiceOnlyTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(l10n.t('quranVoiceOnlyBody')),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.music_off_outlined),
              title: Text(l10n.t('noQuranBgm')),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.record_voice_over_outlined),
              title: Text(l10n.t('noQuranTts')),
            ),
          ],
        ),
      );
    },
  );
}

String _formatPrayerTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
