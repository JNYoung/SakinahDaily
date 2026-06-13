import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/prayer_calculation_service.dart';
import '../../core/services/prayer_reminder_preview_service.dart';
import '../../shared/daily_session_reminder_toggle_flow.dart';
import '../../shared/prayer_reminder_toggle_flow.dart';
import '../../shared/sakinah_keys.dart';
import '../../shared/widgets/language_aware_scaffold.dart';
import '../../shared/widgets/settings_tile.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({this.entrySource, super.key});

  final String? entrySource;

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _trackNotificationSettingsViewed();
    });
  }

  void _trackNotificationSettingsViewed() {
    final preferences = ref.read(userPreferencesProvider);
    ref.read(analyticsServiceProvider).track(
      AnalyticsEventCatalog.notificationSettingsViewed,
      {
        'screen': 'notification_settings',
        'source': _normalizeNotificationSettingsSource(widget.entrySource),
        'prayer_reminders_enabled': preferences.notificationsEnabled,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = SakinahLocalizations.of(context);
    final preferences = ref.watch(userPreferencesProvider);
    final sessions = ref.watch(dailySessionsProvider);
    final session = sessions.isEmpty ? null : sessions.first;
    final controller = ref.read(userPreferencesProvider.notifier);
    final notificationService = ref.watch(notificationServiceProvider);
    final prayerService = ref.watch(prayerCalculationServiceProvider);
    final now = ref.watch(currentDateTimeProvider);
    final notificationFeedback =
        ref.watch(notificationPermissionFeedbackProvider);
    final environment = ref.watch(appEnvironmentConfigProvider);
    final prayerReminderAnalyticsSource =
        _normalizePrayerReminderSource(widget.entrySource);
    final dailySessionReminderAnalyticsSource =
        _normalizeDailySessionReminderSource(widget.entrySource);
    final nextPrayerReminderPreview = calculateNextPrayerReminderPreview(
      now: now,
      preferences: preferences,
      prayerService: prayerService,
    );

    return LanguageAwareScaffold(
      title: l10n.t('notificationSettingsTitle'),
      selectedNavIndex: 3,
      body: ListView(
        key: SakinahKeys.notificationSettingsPage,
        children: [
          SettingsTile(
            title: l10n.t('prayerReminders'),
            subtitle: _prayerReminderSubtitle(
              l10n,
              preferences,
              notificationFeedback,
            ),
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
                    analyticsSource: prayerReminderAnalyticsSource,
                  ),
                );
              },
            ),
          ),
          if (nextPrayerReminderPreview != null) ...[
            const SizedBox(height: 8),
            ListTile(
              key: SakinahKeys.settingsPrayerNextReminderPreview,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_outlined),
              title: Text(
                '${l10n.t('nextPrayerReminderPreview')} · '
                '${l10n.prayerName(nextPrayerReminderPreview.prayerName)} '
                '${formatPrayerReminderClockTime(
                  nextPrayerReminderPreview.reminderAt,
                )}',
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.t('prayerReminderChoicesTitle'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(l10n.t('prayerReminderChoicesBody')),
          const SizedBox(height: 8),
          Text(
            l10n.t('prayerReminderLeadTimeTitle'),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(l10n.t('prayerReminderLeadTimeBody')),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            key: SakinahKeys.settingsPrayerReminderLeadTimeDropdown,
            initialValue: sanitizePrayerReminderOffsetMinutes(
              preferences.prayerReminderOffsetMinutes,
            ),
            isExpanded: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              for (final minutes in prayerReminderOffsetMinuteOptions)
                DropdownMenuItem(
                  value: minutes,
                  child: Text(l10n.prayerReminderLeadTimeLabel(minutes)),
                ),
            ],
            onChanged: (minutes) {
              if (minutes == null) {
                return;
              }
              unawaited(
                _handlePrayerReminderLeadTimeChanged(
                  minutes: minutes,
                  ref: ref,
                  controller: controller,
                  notificationService: notificationService,
                  prayerService: prayerService,
                  analyticsSource: prayerReminderAnalyticsSource,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          for (final prayerName in defaultPrayerReminderNames)
            SettingsTile(
              title: l10n.prayerName(prayerName),
              subtitle: l10n.t('prayerReminderChoiceSubtitle'),
              trailing: Checkbox(
                key: SakinahKeys.settingsPrayerReminderPrayerSwitch(
                  prayerName,
                ),
                value: preferences.isPrayerReminderEnabled(prayerName),
                onChanged: (enabled) {
                  unawaited(
                    _handlePrayerReminderChoiceToggle(
                      prayerName: prayerName,
                      enabled: enabled ?? false,
                      ref: ref,
                      controller: controller,
                      notificationService: notificationService,
                      prayerService: prayerService,
                      analyticsSource: prayerReminderAnalyticsSource,
                    ),
                  );
                },
              ),
            ),
          const Divider(),
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
                        handleDailySessionReminderToggle(
                          enabled: enabled,
                          context: context,
                          ref: ref,
                          l10n: l10n,
                          controller: controller,
                          notificationService: notificationService,
                          preferences: preferences,
                          session: session,
                          analyticsSource: dailySessionReminderAnalyticsSource,
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
                        ref: ref,
                        l10n: l10n,
                        controller: controller,
                        notificationService: notificationService,
                        preferences: preferences,
                        session: session,
                        analyticsSource: dailySessionReminderAnalyticsSource,
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
          if (environment.notificationQaEnabled) ...[
            const Divider(height: 32),
            OutlinedButton.icon(
              key: SakinahKeys.notificationSmokeTestButton,
              onPressed: () {
                unawaited(
                  _scheduleNotificationSmokeTest(
                    context: context,
                    notificationService: notificationService,
                  ),
                );
              },
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('Send test notification'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: SakinahKeys.prayerReminderSmokeTestButton,
              onPressed: () {
                unawaited(
                  _schedulePrayerReminderSmokeTest(
                    context: context,
                    notificationService: notificationService,
                    preferences: preferences,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Send prayer reminder test'),
            ),
          ],
        ],
      ),
    );
  }
}

String _prayerReminderSubtitle(
  SakinahLocalizations l10n,
  UserPreferences preferences,
  NotificationPermissionFeedback? feedback,
) {
  final status = preferences.notificationsEnabled
      ? l10n.t('reminderStatusOn')
      : l10n.t('reminderStatusOff');
  final detail = switch (feedback) {
    NotificationPermissionFeedback.denied =>
      l10n.t('notificationPermissionDenied'),
    NotificationPermissionFeedback.scheduled => l10n.t('notificationScheduled'),
    null => l10n.t('prayerReminderSubtitle'),
  };
  if (!preferences.notificationsEnabled) {
    return '$status · $detail';
  }
  final enabledPrayers =
      preferences.enabledPrayerReminderNames.map(l10n.prayerName).join(', ');
  final leadTime = l10n.prayerReminderLeadTimeLabel(
    sanitizePrayerReminderOffsetMinutes(
        preferences.prayerReminderOffsetMinutes),
  );
  return '$status · $enabledPrayers · $leadTime · $detail';
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

Future<void> _handlePrayerReminderChoiceToggle({
  required String prayerName,
  required bool enabled,
  required WidgetRef ref,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required PrayerCalculationService prayerService,
  required String analyticsSource,
}) async {
  await controller.setPrayerReminderEnabled(prayerName, enabled);
  _trackPrayerReminderChanged(
    ref: ref,
    prayerName: prayerName,
    enabled: enabled,
    source: analyticsSource,
  );
  await _reschedulePrayerRemindersAfterPreferenceChange(
    ref: ref,
    controller: controller,
    notificationService: notificationService,
    prayerService: prayerService,
  );
}

void _trackPrayerReminderChanged({
  required WidgetRef ref,
  required String prayerName,
  required bool enabled,
  required String source,
}) {
  final preferences = ref.read(userPreferencesProvider);
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.prayerReminderChanged,
    {
      'prayer_name': prayerName,
      'enabled': enabled,
      'source': source,
      'reminder_offset_minutes': sanitizePrayerReminderOffsetMinutes(
        preferences.prayerReminderOffsetMinutes,
      ),
    },
  );
}

Future<void> _handlePrayerReminderLeadTimeChanged({
  required int minutes,
  required WidgetRef ref,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required PrayerCalculationService prayerService,
  required String analyticsSource,
}) async {
  await controller.setPrayerReminderOffsetMinutes(minutes);
  final preferences = ref.read(userPreferencesProvider);
  _trackPrayerReminderChanged(
    ref: ref,
    prayerName: 'all',
    enabled: preferences.notificationsEnabled,
    source: analyticsSource,
  );
  await _reschedulePrayerRemindersAfterPreferenceChange(
    ref: ref,
    controller: controller,
    notificationService: notificationService,
    prayerService: prayerService,
  );
}

Future<void> _reschedulePrayerRemindersAfterPreferenceChange({
  required WidgetRef ref,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required PrayerCalculationService prayerService,
}) async {
  final preferences = ref.read(userPreferencesProvider);
  if (!preferences.notificationsEnabled) {
    return;
  }

  final now = DateTime.now();
  final settings = preferences.prayerSettings;
  final offset = sanitizePrayerReminderOffsetMinutes(
    preferences.prayerReminderOffsetMinutes,
  );
  var prayers = prayerService.calculateForDate(now, settings);
  if (!prayers.any(
    (prayer) => prayerReminderTime(prayer, offset).isAfter(now),
  )) {
    prayers = prayerService.calculateForDate(
      now.add(const Duration(days: 1)),
      settings,
    );
  }
  final scheduled = await notificationService.schedulePrayerReminders(
    settings,
    prayers,
    languageCode: preferences.languageCode,
    enabledPrayerNames: preferences.enabledPrayerReminderNames,
    reminderOffsetMinutes: offset,
    womenIbadahMode: preferences.womenIbadahMode,
  );

  if (scheduled.isEmpty) {
    await notificationService.cancelPrayerReminders();
    await controller.setNotificationsEnabled(false);
    ref.read(notificationPermissionFeedbackProvider.notifier).state = null;
    return;
  }

  ref.read(notificationPermissionFeedbackProvider.notifier).state =
      NotificationPermissionFeedback.scheduled;
}

Future<void> _changeDailySessionReminderTime({
  required BuildContext context,
  required WidgetRef ref,
  required SakinahLocalizations l10n,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required UserPreferences preferences,
  required DailySession session,
  required String analyticsSource,
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
    trackDailySessionReminderChanged(
      ref: ref,
      sessionId: session.id,
      enabled: false,
      source: analyticsSource,
      changeType: 'time_saved',
    );
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
    trackDailySessionReminderPermissionResult(
      ref: ref,
      sessionId: session.id,
      enabled: false,
      source: analyticsSource,
      changeType: 'permission_denied',
    );
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
    trackDailySessionReminderPermissionResult(
      ref: ref,
      sessionId: session.id,
      enabled: false,
      source: analyticsSource,
      changeType: 'schedule_failed',
    );
    _showSnackBar(context, l10n.t('notificationPermissionDenied'));
    return;
  }
  trackDailySessionReminderChanged(
    ref: ref,
    sessionId: session.id,
    enabled: true,
    source: analyticsSource,
    changeType: 'time_updated',
  );
  _showSnackBar(context, l10n.t('reminderTimeSaved'));
}

String _normalizePrayerReminderSource(String? source) {
  return switch (source) {
    'home_prayer_card' => 'home_prayer_card',
    'prayer_page_card' => 'prayer_page_card',
    'prayer_completion_card' => 'prayer_completion_card',
    'settings' || null => 'settings',
    _ => 'settings',
  };
}

String _normalizeNotificationSettingsSource(String? source) {
  return switch (source) {
    'home_prayer_card' => 'home_prayer_card',
    'prayer_page_card' => 'prayer_page_card',
    'prayer_completion_card' => 'prayer_completion_card',
    'home_session_completion' => 'home_session_completion',
    'session_completion' => 'session_completion',
    'settings' || null => 'settings',
    _ => 'settings',
  };
}

String _normalizeDailySessionReminderSource(String? source) {
  return switch (source) {
    'home_session_completion' => 'home_session_completion',
    'session_completion' => 'session_completion',
    'settings' || null => 'settings',
    _ => 'settings',
  };
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

Future<void> _scheduleNotificationSmokeTest({
  required BuildContext context,
  required NotificationService notificationService,
}) async {
  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!context.mounted) {
    return;
  }
  if (!granted) {
    _showSnackBar(
      context,
      'Notifications are off. You can enable them from system settings.',
    );
    return;
  }

  final scheduled = await notificationService.scheduleNotificationSmokeTest();
  if (!context.mounted) {
    return;
  }
  _showSnackBar(
    context,
    scheduled == null
        ? 'Notifications are off. You can enable them from system settings.'
        : 'Test notification scheduled.',
  );
}

Future<void> _schedulePrayerReminderSmokeTest({
  required BuildContext context,
  required NotificationService notificationService,
  required UserPreferences preferences,
}) async {
  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!context.mounted) {
    return;
  }
  if (!granted) {
    _showSnackBar(
      context,
      'Notifications are off. You can enable them from system settings.',
    );
    return;
  }

  final scheduled = await notificationService.schedulePrayerReminderSmokeTest(
    languageCode: preferences.languageCode,
    womenIbadahMode: preferences.womenIbadahMode,
  );
  if (!context.mounted) {
    return;
  }
  _showSnackBar(
    context,
    scheduled == null
        ? 'Notifications are off. You can enable them from system settings.'
        : 'Prayer reminder test scheduled.',
  );
}
