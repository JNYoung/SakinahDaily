import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/prayer_calculation_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class PrayerPage extends ConsumerStatefulWidget {
  const PrayerPage({super.key});

  @override
  ConsumerState<PrayerPage> createState() => _PrayerPageState();
}

class _PrayerPageState extends ConsumerState<PrayerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _trackPrayerViewed();
    });
  }

  void _trackPrayerViewed() {
    final preferences = ref.read(userPreferencesProvider);
    final settings = preferences.prayerSettings;
    final service = ref.read(prayerCalculationServiceProvider);
    final prayerStatus = service.dayStatus(
      ref.read(currentDateTimeProvider),
      settings,
    );
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.prayerViewed,
      {
        'screen': 'prayer',
        'route': '/prayer',
        'prayer_name': prayerStatus.nextPrayer.name,
        'calculation_method': settings.method,
        'location_method': _locationMethodFor(settings.locationLabel),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(userPreferencesProvider);
    final service = ref.watch(prayerCalculationServiceProvider);
    final l10n = SakinahLocalizations.of(context);
    final now = ref.watch(currentDateTimeProvider);
    final prayerStatus = service.dayStatus(
      now,
      preferences.prayerSettings,
    );
    final prayerCompletion = ref.watch(prayerCompletionControllerProvider);
    final sessionProgress = ref.watch(sessionProgressControllerProvider);
    final sessions = ref.watch(dailySessionsProvider);
    final dailySession = sessions.isEmpty ? null : sessions.first;
    final nextPrayer = prayerStatus.nextPrayer;

    return LanguageAwareScaffold(
      title: l10n.t('prayer'),
      selectedNavIndex: 1,
      body: ListView.separated(
        key: SakinahKeys.prayerContentList,
        scrollCacheExtent: const ScrollCacheExtent.pixels(1000),
        itemCount: prayerStatus.prayers.length + 4,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AppCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('nextPrayer'),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.prayerName(nextPrayer.name),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrayerTime(nextPrayer.time),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      PrimaryButton(
                        key: SakinahKeys.prayerTopReminderSettingsButton,
                        label: l10n.t('manageReminders'),
                        tonal: true,
                        onPressed: () => context.go(
                          '/settings/notifications?source=prayer_page_card',
                        ),
                      ),
                      PrimaryButton(
                        label: l10n.t('changeLocation'),
                        tonal: true,
                        onPressed: () =>
                            context.go('/settings/prayer-location'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          if (index == 1) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(preferences.prayerSettings.locationLabel),
              subtitle: Text(
                service.methodLabel(preferences.prayerSettings.method),
              ),
            );
          }
          if (index == 2) {
            final completedCount = prayerCompletion.completedCountForDate(now);
            final allPrayersCompleted =
                completedCount >= defaultPrayerReminderNames.length;
            final isDailySessionCompletedToday = dailySession != null &&
                sessionProgress.completionForDate(
                      now,
                      sessionId: dailySession.id,
                    ) !=
                    null;
            return AppCard(
              key: SakinahKeys.prayerCompletionSummaryCard,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        allPrayersCompleted
                            ? Icons.task_alt_rounded
                            : Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.t(
                                allPrayersCompleted
                                    ? 'todaysPrayerCheckInComplete'
                                    : 'todaysPrayerCheckIn',
                              ),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.t(
                                allPrayersCompleted
                                    ? 'prayerCheckInCompleteBody'
                                    : 'prayerCheckInBody',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$completedCount/${defaultPrayerReminderNames.length}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                  if (allPrayersCompleted && dailySession != null) ...[
                    const SizedBox(height: 14),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PrimaryButton(
                        key: SakinahKeys.prayerCompletionStartSessionButton,
                        label: l10n.t(
                          isDailySessionCompletedToday
                              ? 'reviewSession'
                              : 'startSession',
                        ),
                        tonal: true,
                        icon: Icons.nightlight_outlined,
                        onPressed: () => context.go(
                          isDailySessionCompletedToday
                              ? '/session/${dailySession.id}/completed'
                              : '/session/${dailySession.id}'
                                  '?source=prayer_completion',
                        ),
                      ),
                    ),
                  ],
                  if (allPrayersCompleted &&
                      !preferences.notificationsEnabled) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: PrimaryButton(
                        key: SakinahKeys.prayerCompletionReminderSettingsButton,
                        label: l10n.t('manageReminders'),
                        tonal: true,
                        icon: Icons.notifications_active_outlined,
                        onPressed: () => context.go(
                          '/settings/notifications'
                          '?source=prayer_completion_card',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
          if (index == 3) {
            return Padding(
              key: SakinahKeys.prayerTimesSectionHeader,
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n.t('todaysPrayerTimes'),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            );
          }
          final prayer = prayerStatus.prayers[index - 4];
          final isCurrent = prayerStatus.isCurrent(prayer);
          final isNext = prayerStatus.isNext(prayer);
          final isCompleted = prayerCompletion.isCompleted(prayer.name, now);
          final statusChips = [
            if (isCurrent || isNext)
              _PrayerStatusChip(
                key: SakinahKeys.prayerStatusChip(prayer.name),
                label: isCurrent
                    ? l10n.t('currentPrayerStatus')
                    : l10n.t('nextPrayerStatus'),
                isCurrent: isCurrent,
              ),
            if (isCompleted)
              _PrayerStatusChip(
                label: l10n.t('prayerCompletedStatus'),
                isCurrent: false,
              ),
          ];
          return ListTile(
            key: SakinahKeys.prayerListItem(prayer.name),
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isCurrent
                  ? Icons.radio_button_checked
                  : Icons.access_time_rounded,
            ),
            title: Text(l10n.prayerName(prayer.name)),
            subtitle: statusChips.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: statusChips,
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatPrayerTime(prayer.time),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: isCurrent || isNext
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  key: SakinahKeys.prayerCompletionCheckbox(prayer.name),
                  value: isCompleted,
                  onChanged: (value) => _setPrayerCompleted(
                    prayer.name,
                    value ?? false,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _setPrayerCompleted(String prayerName, bool completed) async {
    final now = ref.read(currentDateTimeProvider);
    final completedCount = await ref
        .read(prayerCompletionControllerProvider.notifier)
        .setPrayerCompleted(prayerName, completed, date: now);
    if (!mounted) {
      return;
    }
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.prayerChecklistUpdated,
      {
        'screen': 'prayer',
        'completed_count': completedCount,
        'all_prayers_completed':
            completedCount >= defaultPrayerReminderNames.length,
      },
    );
  }

  String _locationMethodFor(String locationLabel) {
    final usesPreset = PrayerCalculationService.locationPresets.any(
      (preset) => preset.label == locationLabel,
    );
    return usesPreset ? 'preset' : 'manual';
  }
}

class _PrayerStatusChip extends StatelessWidget {
  const _PrayerStatusChip({
    required this.label,
    required this.isCurrent,
    super.key,
  });

  final String label;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor =
        isCurrent ? colorScheme.primary : colorScheme.primaryContainer;
    final foregroundColor =
        isCurrent ? colorScheme.onPrimary : colorScheme.onPrimaryContainer;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w800,
              ),
        ),
      ),
    );
  }
}

String _formatPrayerTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
