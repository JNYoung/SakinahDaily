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
    final notificationFeedback =
        ref.watch(notificationPermissionFeedbackProvider);

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
            title: l10n.t('prayerLocation'),
            subtitle: preferences.prayerSettings.locationLabel,
            trailing: DropdownButton<String>(
              key: SakinahKeys.settingsPrayerLocationDropdown,
              value: _presetIdFor(preferences.prayerSettings),
              hint: Text(preferences.prayerSettings.locationLabel),
              items: [
                for (final preset in PrayerCalculationService.locationPresets)
                  DropdownMenuItem(
                    value: preset.id,
                    child: Text(preset.label),
                  ),
              ],
              onChanged: (value) {
                final preset = _presetById(value);
                if (preset != null) {
                  unawaited(controller.setPrayerSettings(
                    preset.toPrayerSettings(),
                  ));
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
            subtitle: _notificationSubtitle(l10n, notificationFeedback),
            trailing: Switch(
              key: SakinahKeys.settingsNotificationSwitch,
              value: preferences.notificationsEnabled,
              onChanged: (enabled) {
                unawaited(
                  _handleNotificationToggle(
                    enabled: enabled,
                    context: context,
                    ref: ref,
                    l10n: l10n,
                    controller: controller,
                    notificationService: notificationService,
                    prayerService: prayerService,
                    preferences: preferences,
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
            key: SakinahKeys.settingsSavedItemsTile,
            title: l10n.t('savedItems'),
            subtitle: l10n.t('savedItemsPrivacyNotes'),
            onTap: () => context.go('/saved'),
          ),
          const Divider(),
          SettingsTile(
            key: SakinahKeys.settingsPrivacyTile,
            title: l10n.t('privacy'),
            subtitle: l10n.t('privacySubtitle'),
            onTap: () => context.go('/settings/privacy'),
          ),
        ],
      ),
    );
  }
}

String? _presetIdFor(PrayerSettings settings) {
  for (final preset in PrayerCalculationService.locationPresets) {
    if (preset.label == settings.locationLabel &&
        preset.latitude == settings.latitude &&
        preset.longitude == settings.longitude) {
      return preset.id;
    }
  }
  return null;
}

PrayerLocationPreset? _presetById(String? id) {
  for (final preset in PrayerCalculationService.locationPresets) {
    if (preset.id == id) {
      return preset;
    }
  }
  return null;
}

String _notificationSubtitle(
  SakinahLocalizations l10n,
  NotificationPermissionFeedback? feedback,
) {
  return switch (feedback) {
    NotificationPermissionFeedback.denied =>
      l10n.t('notificationPermissionDenied'),
    NotificationPermissionFeedback.scheduled => l10n.t('notificationScheduled'),
    null => l10n.t('prayerReminderSubtitle'),
  };
}

Future<void> _handleNotificationToggle({
  required bool enabled,
  required BuildContext context,
  required WidgetRef ref,
  required SakinahLocalizations l10n,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required PrayerCalculationService prayerService,
  required UserPreferences preferences,
}) async {
  if (!enabled) {
    await notificationService.cancelAll();
    await controller.setNotificationsEnabled(false);
    ref.read(notificationPermissionFeedbackProvider.notifier).state = null;
    return;
  }

  final accepted = await _showNotificationExplanation(context, l10n);
  if (accepted != true) {
    await controller.setNotificationsEnabled(false);
    return;
  }

  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!granted) {
    await notificationService.cancelAll();
    await controller.setNotificationsEnabled(false);
    ref.read(notificationPermissionFeedbackProvider.notifier).state =
        NotificationPermissionFeedback.denied;
    return;
  }

  final now = DateTime.now();
  final settings = preferences.prayerSettings;
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
    languageCode: preferences.languageCode,
    womenIbadahMode: preferences.womenIbadahMode,
  );
  await controller.setNotificationsEnabled(scheduled.isNotEmpty);
  ref.read(notificationPermissionFeedbackProvider.notifier).state =
      scheduled.isEmpty
          ? NotificationPermissionFeedback.denied
          : NotificationPermissionFeedback.scheduled;
}

Future<bool?> _showNotificationExplanation(
  BuildContext context,
  SakinahLocalizations l10n,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.t('notificationPermissionTitle')),
        content: Text(l10n.t('notificationPermissionBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.t('notificationPermissionNotNow')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.t('notificationPermissionAllow')),
          ),
        ],
      );
    },
  );
}
