import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/app_providers.dart';
import '../core/services/analytics_service.dart';

void trackNotificationScheduleResult({
  required WidgetRef ref,
  required String reminderType,
  required bool enabled,
  required String source,
  required String changeType,
  required int scheduledCount,
  int? reminderOffsetMinutes,
}) {
  ref.read(analyticsServiceProvider).track(
    AnalyticsEventCatalog.notificationScheduleResult,
    {
      'reminder_type': reminderType,
      'enabled': enabled,
      'source': source,
      'change_type': changeType,
      'scheduled_count': scheduledCount,
      if (reminderOffsetMinutes != null)
        'reminder_offset_minutes': reminderOffsetMinutes,
    },
  );
}
