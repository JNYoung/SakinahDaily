import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
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
    final nextPrayer = prayerStatus.nextPrayer;

    return LanguageAwareScaffold(
      title: l10n.t('prayer'),
      selectedNavIndex: 1,
      body: ListView.separated(
        key: SakinahKeys.prayerContentList,
        itemCount: prayerStatus.prayers.length + 3,
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
                        label: l10n.t('manageReminders'),
                        tonal: true,
                        onPressed: () => context.go('/settings/notifications'),
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
          final prayer = prayerStatus.prayers[index - 3];
          final isCurrent = prayerStatus.isCurrent(prayer);
          final isNext = prayerStatus.isNext(prayer);
          return ListTile(
            key: SakinahKeys.prayerListItem(prayer.name),
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              isCurrent
                  ? Icons.radio_button_checked
                  : Icons.access_time_rounded,
            ),
            title: Text(l10n.prayerName(prayer.name)),
            subtitle: isCurrent || isNext
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _PrayerStatusChip(
                        key: SakinahKeys.prayerStatusChip(prayer.name),
                        label: isCurrent
                            ? l10n.t('currentPrayerStatus')
                            : l10n.t('nextPrayerStatus'),
                        isCurrent: isCurrent,
                      ),
                    ),
                  )
                : null,
            trailing: Text(
              _formatPrayerTime(prayer.time),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight:
                        isCurrent || isNext ? FontWeight.w800 : FontWeight.w600,
                  ),
            ),
          );
        },
      ),
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
