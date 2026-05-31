import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/notification_service.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/settings_tile.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final sessions = ref.watch(dailySessionsProvider);
    final session = sessions.isEmpty ? null : sessions.first;
    final controller = ref.read(userPreferencesProvider.notifier);
    final notificationService = ref.watch(notificationServiceProvider);

    return LanguageAwareScaffold(
      title: l10n.t('notificationSettingsTitle'),
      selectedNavIndex: 3,
      body: ListView(
        key: SakinahKeys.notificationSettingsPage,
        children: [
          SettingsTile(
            title: l10n.t('dailySessionReminderTitle'),
            subtitle: _dailySessionReminderSubtitle(l10n, preferences),
            trailing: Switch(
              key: SakinahKeys.settingsDailySessionReminderSwitch,
              value: preferences.dailySessionReminderEnabled,
              onChanged: session == null
                  ? null
                  : (enabled) {
                      unawaited(
                        _handleDailySessionReminderToggle(
                          enabled: enabled,
                          context: context,
                          l10n: l10n,
                          controller: controller,
                          notificationService: notificationService,
                          preferences: preferences,
                          session: session,
                        ),
                      );
                    },
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            key: SakinahKeys.settingsDailySessionReminderTimeButton,
            onPressed: session == null
                ? null
                : () {
                    unawaited(
                      _changeDailySessionReminderTime(
                        context: context,
                        l10n: l10n,
                        controller: controller,
                        notificationService: notificationService,
                        preferences: preferences,
                        session: session,
                      ),
                    );
                  },
            icon: const Icon(Icons.schedule_outlined),
            label: Text(
              '${l10n.t('reminderTime')}: '
              '${formatDailySessionReminderTime(
                preferences.dailySessionReminderMinutesAfterMidnight,
              )}',
            ),
          ),
          const SizedBox(height: 12),
          Text(l10n.t('dailySessionReminderPrivacyNote')),
        ],
      ),
    );
  }
}

String _dailySessionReminderSubtitle(
  SakinahLocalizations l10n,
  UserPreferences preferences,
) {
  final status = preferences.dailySessionReminderEnabled
      ? l10n.t('reminderStatusOn')
      : l10n.t('reminderStatusOff');
  return '$status · ${formatDailySessionReminderTime(
    preferences.dailySessionReminderMinutesAfterMidnight,
  )}';
}

Future<void> _handleDailySessionReminderToggle({
  required bool enabled,
  required BuildContext context,
  required SakinahLocalizations l10n,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required UserPreferences preferences,
  required DailySession session,
}) async {
  if (!enabled) {
    await notificationService.cancelDailySessionReminder();
    await controller.setDailySessionReminderEnabled(false);
    return;
  }

  final accepted = await _showSessionReminderExplanation(context, l10n);
  if (accepted != true || !context.mounted) {
    await controller.setDailySessionReminderEnabled(false);
    return;
  }

  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!context.mounted) {
    return;
  }
  if (!granted) {
    await controller.setDailySessionReminderEnabled(false);
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, l10n.t('notificationPermissionDenied'));
    return;
  }

  final scheduled = await notificationService.scheduleDailySessionReminder(
    session,
    languageCode: preferences.languageCode,
    minutesAfterMidnight: preferences.dailySessionReminderMinutesAfterMidnight,
    womenIbadahMode: preferences.womenIbadahMode,
  );
  if (!context.mounted) {
    return;
  }
  if (scheduled == null) {
    await controller.setDailySessionReminderEnabled(false);
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, l10n.t('notificationPermissionDenied'));
    return;
  }

  await controller.setDailySessionReminderEnabled(true);
  if (context.mounted) {
    _showSnackBar(context, l10n.t('dailyReminderSet'));
  }
}

Future<void> _changeDailySessionReminderTime({
  required BuildContext context,
  required SakinahLocalizations l10n,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required UserPreferences preferences,
  required DailySession session,
}) async {
  final minutes = await _showReminderTimeDialog(
    context,
    l10n,
    preferences.dailySessionReminderMinutesAfterMidnight,
  );
  if (minutes == null || !context.mounted) {
    return;
  }

  await controller.setDailySessionReminderTime(minutes);
  if (!preferences.dailySessionReminderEnabled) {
    if (context.mounted) {
      _showSnackBar(context, l10n.t('reminderTimeSaved'));
    }
    return;
  }

  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!context.mounted) {
    return;
  }
  if (!granted) {
    await controller.setDailySessionReminderEnabled(false);
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, l10n.t('notificationPermissionDenied'));
    return;
  }

  final scheduled = await notificationService.scheduleDailySessionReminder(
    session,
    languageCode: preferences.languageCode,
    minutesAfterMidnight: minutes,
    womenIbadahMode: preferences.womenIbadahMode,
  );
  if (!context.mounted) {
    return;
  }
  if (scheduled == null) {
    await controller.setDailySessionReminderEnabled(false);
    if (!context.mounted) {
      return;
    }
    _showSnackBar(context, l10n.t('notificationPermissionDenied'));
    return;
  }
  _showSnackBar(context, l10n.t('reminderTimeSaved'));
}

Future<bool?> _showSessionReminderExplanation(
  BuildContext context,
  SakinahLocalizations l10n,
) {
  return showDialog<bool>(
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
}

Future<int?> _showReminderTimeDialog(
  BuildContext context,
  SakinahLocalizations l10n,
  int currentMinutes,
) {
  final sanitized = sanitizeDailySessionReminderMinutes(currentMinutes);
  var selectedHour = sanitized ~/ 60;
  var selectedMinute = (sanitized % 60 ~/ 5) * 5;
  return showDialog<int>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(l10n.t('reminderTime')),
            content: Row(
              children: [
                Expanded(
                  child: DropdownButton<int>(
                    key: SakinahKeys.settingsDailySessionReminderHourDropdown,
                    value: selectedHour,
                    isExpanded: true,
                    items: [
                      for (var hour = 0; hour < 24; hour += 1)
                        DropdownMenuItem(
                          value: hour,
                          child: Text(hour.toString().padLeft(2, '0')),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedHour = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<int>(
                    key: SakinahKeys.settingsDailySessionReminderMinuteDropdown,
                    value: selectedMinute,
                    isExpanded: true,
                    items: [
                      for (var minute = 0; minute < 60; minute += 5)
                        DropdownMenuItem(
                          value: minute,
                          child: Text(minute.toString().padLeft(2, '0')),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMinute = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.t('deleteLocalDataCancel')),
              ),
              FilledButton(
                key: SakinahKeys.settingsDailySessionReminderTimeSaveButton,
                onPressed: () {
                  Navigator.of(context).pop(
                    selectedHour * 60 + selectedMinute,
                  );
                },
                child: Text(l10n.t('saveReminderTime')),
              ),
            ],
          );
        },
      );
    },
  );
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
