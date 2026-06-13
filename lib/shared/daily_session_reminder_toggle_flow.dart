import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/localization/sakinah_localizations.dart';
import '../core/models/sakinah_models.dart';
import '../core/providers/app_providers.dart';
import '../core/services/analytics_service.dart';
import '../core/services/notification_service.dart';

Future<void> handleDailySessionReminderToggle({
  required bool enabled,
  required BuildContext context,
  required WidgetRef ref,
  required SakinahLocalizations l10n,
  required UserPreferencesController controller,
  required NotificationService notificationService,
  required UserPreferences preferences,
  required DailySession session,
  required String analyticsSource,
}) async {
  if (!enabled) {
    await notificationService.cancelDailySessionReminder();
    await controller.setDailySessionReminderEnabled(false);
    trackDailySessionReminderChanged(
      ref: ref,
      sessionId: session.id,
      enabled: false,
      source: analyticsSource,
      changeType: 'disabled',
    );
    return;
  }

  final accepted = await showDailySessionReminderExplanation(context, l10n);
  if (accepted != true || !context.mounted) {
    await controller.setDailySessionReminderEnabled(false);
    if (context.mounted) {
      trackDailySessionReminderPermissionResult(
        ref: ref,
        sessionId: session.id,
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

  await controller.setDailySessionReminderEnabled(true);
  trackDailySessionReminderPermissionResult(
    ref: ref,
    sessionId: session.id,
    enabled: true,
    source: analyticsSource,
    changeType: 'scheduled',
  );
  trackDailySessionReminderChanged(
    ref: ref,
    sessionId: session.id,
    enabled: true,
    source: analyticsSource,
    changeType: 'enabled',
  );
  if (context.mounted) {
    _showSnackBar(context, l10n.t('dailyReminderSet'));
  }
}

void trackDailySessionReminderChanged({
  required WidgetRef ref,
  required String sessionId,
  required bool enabled,
  required String source,
  required String changeType,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.dailySessionReminderChanged,
    {
      'session_id': sessionId,
      'enabled': enabled,
      'source': source,
      'change_type': changeType,
    },
  );
}

void trackDailySessionReminderPermissionResult({
  required WidgetRef ref,
  required String sessionId,
  required bool enabled,
  required String source,
  required String changeType,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.dailySessionReminderPermissionResult,
    {
      'session_id': sessionId,
      'enabled': enabled,
      'source': source,
      'change_type': changeType,
    },
  );
}

Future<bool?> showDailySessionReminderExplanation(
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

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
