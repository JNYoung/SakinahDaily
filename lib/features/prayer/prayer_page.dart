import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/primary_button.dart';

class PrayerPage extends ConsumerWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(userPreferencesProvider);
    final service = ref.watch(prayerCalculationServiceProvider);
    final l10n = SakinahLocalizations.of(context);
    final prayers = service.calculateForDate(
      DateTime.now(),
      preferences.prayerSettings,
    );
    final nextPrayer = service.nextPrayer(
      DateTime.now(),
      preferences.prayerSettings,
    );

    return LanguageAwareScaffold(
      title: l10n.t('prayer'),
      selectedNavIndex: 1,
      body: ListView.separated(
        key: SakinahKeys.prayerContentList,
        itemCount: prayers.length + 2,
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
          final prayer = prayers[index - 2];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded),
            title: Text(l10n.prayerName(prayer.name)),
            trailing: Text(_formatPrayerTime(prayer.time)),
          );
        },
      ),
    );
  }
}

String _formatPrayerTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
