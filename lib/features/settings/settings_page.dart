import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/prayer_calculation_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final controller = ref.read(userPreferencesProvider.notifier);
    final prayerService = ref.watch(prayerCalculationServiceProvider);
    final notificationService = ref.watch(notificationServiceProvider);

    return LanguageAwareScaffold(
      title: l10n.t('settings'),
      selectedNavIndex: 3,
      body: ListView(
        children: [
          SettingsTile(
            title: l10n.t('language'),
            subtitle: preferences.languageCode,
            trailing: DropdownButton<String>(
              value: preferences.languageCode,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'id', child: Text('Indonesia')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) {
                  unawaited(controller.setLanguage(value));
                }
              },
            ),
          ),
          const Divider(),
          SettingsTile(
            title: l10n.t('prayerMethod'),
            subtitle:
                prayerService.methodLabel(preferences.prayerSettings.method),
            trailing: DropdownButton<String>(
              key: SakinahKeys.settingsPrayerMethodDropdown,
              value: preferences.prayerSettings.method,
              items: [
                for (final methodId
                    in PrayerCalculationService.supportedMethodIds)
                  DropdownMenuItem(
                    value: methodId,
                    child: Text(prayerService.methodLabel(methodId)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  unawaited(
                    controller.setPrayerSettings(
                      preferences.prayerSettings.copyWith(method: value),
                    ),
                  );
                }
              },
            ),
          ),
          const Divider(),
          SettingsTile(
            title: l10n.t('prayerReminders'),
            subtitle: l10n.t('prayerReminderSubtitle'),
            trailing: Switch(
              key: SakinahKeys.settingsNotificationSwitch,
              value: preferences.notificationsEnabled,
              onChanged: (enabled) {
                unawaited(
                  _handleNotificationToggle(
                    enabled: enabled,
                    controller: controller,
                    notificationService: notificationService,
                    prayerService: prayerService,
                    settings: preferences.prayerSettings,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          SettingsTile(
            key: SakinahKeys.settingsWomenModeTile,
            title: l10n.t('womenMode'),
            subtitle: l10n.t('womenModeSubtitle'),
            trailing: Switch(
              value: preferences.womenIbadahMode.enabled,
              onChanged: (enabled) {
                unawaited(controller.setWomenMode(enabled));
              },
            ),
            onTap: () => context.go('/settings/women'),
          ),
          const Divider(),
          SettingsTile(
            title: l10n.t('privacy'),
            subtitle: l10n.t('privacySubtitle'),
          ),
        ],
      ),
    );
  }
}

Future<void> _handleNotificationToggle({
  required bool enabled,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required PrayerCalculationService prayerService,
  required PrayerSettings settings,
}) async {
  if (!enabled) {
    await notificationService.cancelAll();
    await controller.setNotificationsEnabled(false);
    return;
  }

  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!granted) {
    await notificationService.cancelAll();
    await controller.setNotificationsEnabled(false);
    return;
  }

  final now = DateTime.now();
  var prayers = prayerService.calculateForDate(now, settings);
  if (!prayers.any((prayer) => prayer.time.isAfter(now))) {
    prayers = prayerService.calculateForDate(
      now.add(const Duration(days: 1)),
      settings,
    );
  }
  final scheduled = await notificationService.schedulePrayerReminders(
    settings,
    prayers,
  );
  await controller.setNotificationsEnabled(scheduled.isNotEmpty);
}
