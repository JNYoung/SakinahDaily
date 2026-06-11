import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/prayer_calculation_service.dart';

Future<void> handlePrayerReminderToggle({
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
    await notificationService.cancelPrayerReminders();
    await controller.setNotificationsEnabled(false);
    ref.read(notificationPermissionFeedbackProvider.notifier).state = null;
    _trackGlobalPrayerReminderChanged(
      ref: ref,
      preferences: preferences,
      enabled: false,
    );
    return;
  }

  final accepted = await showPrayerReminderExplanation(context, l10n);
  if (accepted != true || !context.mounted) {
    await controller.setNotificationsEnabled(false);
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
    _trackGlobalPrayerReminderChanged(
      ref: ref,
      preferences: preferences,
      enabled: true,
    );
  }
}

void _trackGlobalPrayerReminderChanged({
  required WidgetRef ref,
  required UserPreferences preferences,
  required bool enabled,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.prayerReminderChanged,
    {
      'prayer_name': 'all',
      'enabled': enabled,
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
