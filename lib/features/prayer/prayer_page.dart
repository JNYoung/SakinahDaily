import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';

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

    return LanguageAwareScaffold(
      title: l10n.t('prayer'),
      selectedNavIndex: 0,
      body: ListView.separated(
        key: SakinahKeys.prayerContentList,
        itemCount: prayers.length + 1,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(preferences.prayerSettings.locationLabel),
              subtitle: Text(
                service.methodLabel(preferences.prayerSettings.method),
              ),
            );
          }
          final prayer = prayers[index - 1];
          final time =
              '${prayer.time.hour.toString().padLeft(2, '0')}:${prayer.time.minute.toString().padLeft(2, '0')}';
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time_rounded),
            title: Text(l10n.prayerName(prayer.name)),
            trailing: Text(time),
          );
        },
      ),
    );
  }
}
