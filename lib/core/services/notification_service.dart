import '../models/sakinah_models.dart';
import 'prayer_calculation_service.dart';

class ScheduledPrayerReminder {
  const ScheduledPrayerReminder({
    required this.prayerName,
    required this.time,
    required this.settings,
  });

  final String prayerName;
  final DateTime time;
  final PrayerSettings settings;
}

abstract class NotificationService {
  Future<bool> requestPermissionAfterExplanation();
  Future<List<ScheduledPrayerReminder>> schedulePrayerReminders(
    PrayerSettings settings,
    List<PrayerTime> prayerTimes,
  );
  Future<void> cancelAll();
}

class LocalNotificationServiceStub implements NotificationService {
  bool permissionGranted = true;
  final List<ScheduledPrayerReminder> scheduled = [];

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
  }

  @override
  Future<bool> requestPermissionAfterExplanation() async {
    return permissionGranted;
  }

  @override
  Future<List<ScheduledPrayerReminder>> schedulePrayerReminders(
    PrayerSettings settings,
    List<PrayerTime> prayerTimes,
  ) async {
    if (!permissionGranted) {
      return [];
    }
    scheduled
      ..clear()
      ..addAll(
        prayerTimes.map(
          (prayer) => ScheduledPrayerReminder(
            prayerName: prayer.name,
            time: prayer.time,
            settings: settings,
          ),
        ),
      );
    return List.unmodifiable(scheduled);
  }
}
