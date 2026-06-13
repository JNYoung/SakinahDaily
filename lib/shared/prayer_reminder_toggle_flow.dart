import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/sakinah_localizations.dart';
import '../core/models/sakinah_models.dart';
import '../core/providers/app_providers.dart';
import '../core/services/analytics_service.dart';
import '../core/services/notification_service.dart';
import '../core/services/prayer_calculation_service.dart';
import 'notification_analytics.dart';

Future<void> handlePrayerReminderToggle({
  required bool enabled,
  required BuildContext context,
  required WidgetRef ref,
  required SakinahLocalizations l10n,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required PrayerCalculationService prayerService,
  required UserPreferences preferences,
  required String analyticsSource,
}) async {
  if (!enabled) {
    await notificationService.cancelPrayerReminders();
    await controller.setNotificationsEnabled(false);
    ref.read(notificationPermissionFeedbackProvider.notifier).state = null;
    _trackGlobalPrayerReminderChanged(
      ref: ref,
      preferences: preferences,
      enabled: false,
      source: analyticsSource,
    );
    trackNotificationScheduleResult(
      ref: ref,
      reminderType: 'prayer',
      enabled: false,
      source: analyticsSource,
      changeType: 'disabled',
      scheduledCount: 0,
      reminderOffsetMinutes: sanitizePrayerReminderOffsetMinutes(
        preferences.prayerReminderOffsetMinutes,
      ),
    );
    return;
  }

  final accepted = await showPrayerReminderExplanation(context, l10n);
  if (accepted != true || !context.mounted) {
    await controller.setNotificationsEnabled(false);
    if (context.mounted) {
      _trackPrayerReminderPermissionResult(
        ref: ref,
        preferences: preferences,
        enabled: false,
        source: analyticsSource,
        changeType: 'explanation_dismissed',
      );
    }
    return;
  }

  final granted = await notificationService.requestPermissionAfterExplanation();
  if (!context.mounted) {
    return;
  }
  if (!granted) {
    await notificationService.cancelPrayerReminders();
    await controller.setNotificationsEnabled(false);
    ref.read(notificationPermissionFeedbackProvider.notifier).state =
        NotificationPermissionFeedback.denied;
    _trackPrayerReminderPermissionResult(
      ref: ref,
      preferences: preferences,
      enabled: false,
      source: analyticsSource,
      changeType: 'permission_denied',
    );
    return;
  }

  final now = DateTime.now();
  final settings = preferences.prayerSettings;
  final offset = sanitizePrayerReminderOffsetMinutes(
    preferences.prayerReminderOffsetMinutes,
  );
  var prayers = prayerService.calculateForDate(now, settings);
  if (!prayers.any((prayer) => _reminderTime(prayer, offset).isAfter(now))) {
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
  final scheduledAny = scheduled.isNotEmpty;
  await controller.setNotificationsEnabled(scheduledAny);
  ref.read(notificationPermissionFeedbackProvider.notifier).state = scheduledAny
      ? NotificationPermissionFeedback.scheduled
      : NotificationPermissionFeedback.denied;
  if (scheduledAny) {
    _trackPrayerReminderPermissionResult(
      ref: ref,
      preferences: preferences,
      enabled: true,
      source: analyticsSource,
      changeType: 'scheduled',
    );
    trackNotificationScheduleResult(
      ref: ref,
      reminderType: 'prayer',
      enabled: true,
      source: analyticsSource,
      changeType: 'scheduled',
      scheduledCount: scheduled.length,
      reminderOffsetMinutes: offset,
    );
    _trackGlobalPrayerReminderChanged(
      ref: ref,
      preferences: preferences,
      enabled: true,
      source: analyticsSource,
    );
  } else {
    _trackPrayerReminderPermissionResult(
      ref: ref,
      preferences: preferences,
      enabled: false,
      source: analyticsSource,
      changeType: 'schedule_empty',
    );
    trackNotificationScheduleResult(
      ref: ref,
      reminderType: 'prayer',
      enabled: false,
      source: analyticsSource,
      changeType: 'schedule_empty',
      scheduledCount: 0,
      reminderOffsetMinutes: offset,
    );
  }
}

void _trackGlobalPrayerReminderChanged({
  required WidgetRef ref,
  required UserPreferences preferences,
  required bool enabled,
  required String source,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.prayerReminderChanged,
    {
      'prayer_name': 'all',
      'enabled': enabled,
      'source': source,
      'reminder_offset_minutes': sanitizePrayerReminderOffsetMinutes(
        preferences.prayerReminderOffsetMinutes,
      ),
    },
  );
}

void _trackPrayerReminderPermissionResult({
  required WidgetRef ref,
  required UserPreferences preferences,
  required bool enabled,
  required String source,
  required String changeType,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.prayerReminderPermissionResult,
    {
      'enabled': enabled,
      'source': source,
      'change_type': changeType,
      'reminder_offset_minutes': sanitizePrayerReminderOffsetMinutes(
        preferences.prayerReminderOffsetMinutes,
      ),
    },
  );
}

DateTime _reminderTime(PrayerTime prayer, int offsetMinutes) {
  return prayer.time.subtract(Duration(minutes: offsetMinutes));
}

Future<bool?> showPrayerReminderExplanation(
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

void showPrayerReminderFeedbackSnackBar({
  required BuildContext context,
  required SakinahLocalizations l10n,
  required NotificationPermissionFeedback? feedback,
}) {
  final message = switch (feedback) {
    NotificationPermissionFeedback.scheduled => l10n.t('notificationScheduled'),
    NotificationPermissionFeedback.denied =>
      l10n.t('notificationPermissionDenied'),
    null => null,
  };
  if (message == null) {
    return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
