import '../models/sakinah_models.dart';
import 'prayer_calculation_service.dart';

class PrayerReminderPreview {
  const PrayerReminderPreview({
    required this.prayerName,
    required this.reminderAt,
  });

  final String prayerName;
  final DateTime reminderAt;
}

PrayerReminderPreview? calculateNextPrayerReminderPreview({
  required DateTime now,
  required UserPreferences preferences,
  required PrayerCalculationService prayerService,
}) {
  if (!preferences.notificationsEnabled ||
      preferences.enabledPrayerReminderNames.isEmpty) {
    return null;
  }

  final offset = sanitizePrayerReminderOffsetMinutes(
    preferences.prayerReminderOffsetMinutes,
  );
  for (final date in [now, now.add(const Duration(days: 1))]) {
    final prayers = prayerService.calculateForDate(
      date,
      preferences.prayerSettings,
    );
    for (final prayer in prayers) {
      if (!preferences.enabledPrayerReminderNames.contains(prayer.name)) {
        continue;
      }
      final reminderAt = prayerReminderTime(prayer, offset);
      if (reminderAt.isAfter(now)) {
        return PrayerReminderPreview(
          prayerName: prayer.name,
          reminderAt: reminderAt,
        );
      }
    }
  }

  return null;
}

DateTime prayerReminderTime(PrayerTime prayer, int offsetMinutes) {
  return prayer.time.subtract(Duration(minutes: offsetMinutes));
}

String formatPrayerReminderClockTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
