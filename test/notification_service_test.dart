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
    timezoneId: 'Asia/Riyadh',
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

  test('scheduled prayer reminders include a privacy-safe tap payload',
      () async {
    final service = LocalNotificationServiceStub();
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(settings, prayers);

    expect(scheduled.first.payload, contains('"type":"prayer"'));
    expect(scheduled.first.payload, contains('"fallbackRoute":"/prayer"'));
    expect(scheduled.first.payload, isNot(contains('menstruating')));
    expect(scheduled.first.payload, isNot(contains('postpartum')));
  });

  test('English Indonesian and Arabic notification copy can be generated', () {
    final en = PrayerNotificationCopy.forPrayer(
      languageCode: 'en',
      prayerName: 'Fajr',
    );
    final id = PrayerNotificationCopy.forPrayer(
      languageCode: 'id',
      prayerName: 'Fajr',
    );
    final ar = PrayerNotificationCopy.forPrayer(
      languageCode: 'ar',
      prayerName: 'Fajr',
    );

    expect(en.body, contains('Fajr'));
    expect(id.body, contains('Subuh'));
    expect(ar.body, contains('الفجر'));
  });

  test('women mode notification copy stays privacy-safe', () {
    final copy = PrayerNotificationCopy.forPrayer(
      languageCode: 'en',
      prayerName: 'Fajr',
      womenIbadahMode: const WomenIbadahMode(enabled: true),
    );

    expect(copy.body, isNot(contains('Fajr')));
    expect(copy.body, isNot(contains('prayer')));
  });
}
