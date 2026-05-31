import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
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

  test('daily session reminder uses privacy-safe local tap payload', () async {
    final service = LocalNotificationServiceStub();
    final session = SeedContentRepository(
      SeedContent.demo(),
    ).getDailySession('session_morning_ease')!;

    final scheduled = await service.scheduleDailySessionReminder(
      session,
      languageCode: 'en',
      minutesAfterMidnight: 21 * 60 + 15,
      womenIbadahMode: const WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.menstruating,
      ),
    );

    expect(scheduled, isNotNull);
    expect(service.dailySessionReminder, scheduled);
    expect(scheduled!.time.hour, 21);
    expect(scheduled.time.minute, 15);
    expect(scheduled.payload, contains('"type":"daily_session"'));
    expect(scheduled.payload, contains('"contentId":"session_morning_ease"'));
    expect(scheduled.payload,
        contains('"fallbackRoute":"/session/session_morning_ease"'));
    _expectNoSensitiveTerms(scheduled.title);
    _expectNoSensitiveTerms(scheduled.body);
    _expectNoSensitiveTerms(scheduled.payload);
    expect(scheduled.payload, isNot(contains('women')));
    expect(scheduled.payload, isNot(contains('status')));
  });

  test('daily session reminder is not scheduled when permission is denied',
      () async {
    final service = LocalNotificationServiceStub()..permissionGranted = false;
    final session = SeedContentRepository(
      SeedContent.demo(),
    ).getDailySession('session_morning_ease')!;

    final scheduled = await service.scheduleDailySessionReminder(session);

    expect(scheduled, isNull);
    expect(service.dailySessionReminder, isNull);
  });

  test('next daily session reminder uses selected time and rolls forward', () {
    final sameDay = nextDailySessionReminderTime(
      minutesAfterMidnight: 21 * 60 + 15,
      now: DateTime(2026, 5, 21, 20, 0),
    );
    final nextDay = nextDailySessionReminderTime(
      minutesAfterMidnight: 21 * 60 + 15,
      now: DateTime(2026, 5, 21, 22, 0),
    );

    expect(sameDay, DateTime(2026, 5, 21, 21, 15));
    expect(nextDay, DateTime(2026, 5, 22, 21, 15));
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
