import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/core/services/prayer_calculation_service.dart';

void main() {
  const settings = PrayerSettings(
    latitude: 21.3891,
    longitude: 39.8579,
    method: 'umm_al_qura',
    locationLabel: 'Makkah',
  );

  test('notification denied state returns no scheduled reminders', () async {
    final service = LocalNotificationServiceStub()..permissionGranted = false;
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(settings, prayers);

    expect(scheduled, isEmpty);
    expect(service.scheduled, isEmpty);
  });

  test('notification scheduling is cancelable', () async {
    final service = LocalNotificationServiceStub();
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(settings, prayers);
    expect(scheduled, hasLength(5));

    await service.cancelAll();

    expect(service.scheduled, isEmpty);
  });
}
