import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/prayer_calculation_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/settings_tile.dart';
import 'prayer_reminder_toggle_flow.dart';

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
    final appEnvironment = ref.watch(appEnvironmentConfigProvider);
    final testingFeedbackChannel = appEnvironment.testingFeedbackChannel;

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
            key: SakinahKeys.settingsPrayerLocationTile,
            title: l10n.t('prayerLocation'),
            subtitle: preferences.prayerSettings.locationLabel,
            onTap: () => context.go('/settings/prayer-location'),
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
                  final settings = preset.toPrayerSettings();
                  unawaited(controller.setPrayerSettings(settings));
                  _trackPrayerLocationChanged(
                    ref,
                    settings: settings,
                    locationMethod: 'preset',
                    source: 'settings_prayer_location',
                    changeType: 'preset_selected',
                  );
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
                  final settings =
                      preferences.prayerSettings.copyWith(method: value);
                  unawaited(
                    controller.setPrayerSettings(
                      settings,
                    ),
                  );
                  _trackPrayerLocationChanged(
                    ref,
                    settings: settings,
                    locationMethod: _locationMethodForSettings(settings),
                    source: 'settings_prayer_method',
                    changeType: 'method_selected',
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
                  handlePrayerReminderToggle(
                    enabled: enabled,
                    context: context,
                    ref: ref,
                    l10n: l10n,
                    controller: controller,
                    notificationService: notificationService,
                    prayerService: prayerService,
                    preferences: preferences,
                    analyticsSource: 'settings',
                  ),
                );
              },
            ),
          ),
          const Divider(),
          SettingsTile(
            key: SakinahKeys.settingsNotificationSettingsTile,
            title: l10n.t('notificationSettingsTitle'),
            subtitle: l10n.t('notificationSettingsSubtitle'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go('/settings/notifications'),
          ),
          const Divider(),
          SettingsTile(
            key: SakinahKeys.settingsContentSourcesTile,
            title: l10n.t('contentSourcesTitle'),
            subtitle: l10n.t('contentSourcesSubtitle'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.go('/settings/content-sources'),
          ),
          const Divider(),
          if (testingFeedbackChannel != null) ...[
            SettingsTile(
              key: SakinahKeys.settingsClosedTestingGuideTile,
              title: l10n.t('closedTestingGuideTitle'),
              subtitle: l10n.t('closedTestingGuideSubtitle'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/settings/testing-guide'),
            ),
            const Divider(),
            SettingsTile(
              key: SakinahKeys.settingsTestingFeedbackTile,
              title: l10n.t('testingFeedbackTitle'),
              subtitle: testingFeedbackChannel,
              trailing: const Icon(Icons.copy),
              onTap: () => _copyTestingFeedbackChannel(
                context,
                l10n,
                testingFeedbackChannel,
              ),
            ),
            const Divider(),
          ],
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

String _locationMethodForSettings(PrayerSettings settings) {
  return _presetIdFor(settings) == null ? 'manual' : 'preset';
}

void _trackPrayerLocationChanged(
  WidgetRef ref, {
  required PrayerSettings settings,
  required String locationMethod,
  required String source,
  required String changeType,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.prayerLocationChanged,
    {
      'location_method': locationMethod,
      'calculation_method': settings.method,
      'source': source,
      'change_type': changeType,
    },
  );
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

void _copyTestingFeedbackChannel(
  BuildContext context,
  SakinahLocalizations l10n,
  String testingFeedbackChannel,
) {
  Clipboard.setData(ClipboardData(text: testingFeedbackChannel));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(l10n.t('testingFeedbackCopied'))),
    );
}
