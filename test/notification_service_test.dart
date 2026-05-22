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

  test('all women mode statuses produce privacy-safe notification copy', () {
    for (final status in WomenIbadahStatus.values) {
      final copy = PrayerNotificationCopy.forPrayer(
        languageCode: 'en',
        prayerName: 'Fajr',
        womenIbadahMode: WomenIbadahMode(enabled: true, status: status),
      );

      _expectNoSensitiveTerms(copy.title);
      _expectNoSensitiveTerms(copy.body);
      expect(copy.body, isNot(contains(status.name)));
    }
  });

  test('notification payload does not include women status', () async {
    final service = LocalNotificationServiceStub();
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(
      settings,
      prayers,
      womenIbadahMode: const WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.postpartum,
      ),
    );

    expect(scheduled, isNotEmpty);
    _expectNoSensitiveTerms(scheduled.first.payload);
    expect(scheduled.first.payload, isNot(contains('women')));
    expect(scheduled.first.payload, isNot(contains('status')));
  });
}

void _expectNoSensitiveTerms(String value) {
  final lower = value.toLowerCase();
  for (final term in const [
    'menstruat',
    'period',
    'postpartum',
    'pregnan',
    'cycle',
    'haidh',
    'nifas',
  ]) {
    expect(lower, isNot(contains(term)));
  }
}
