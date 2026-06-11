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

  test('prayer reminders can be scheduled for selected prayers only', () async {
    final service = LocalNotificationServiceStub();
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(
      settings,
      prayers,
      enabledPrayerNames: const ['Fajr', 'Maghrib'],
    );

    expect(
      scheduled.map((reminder) => reminder.prayerName),
      ['Fajr', 'Maghrib'],
    );
    expect(
      service.scheduled.map((reminder) => reminder.prayerName),
      ['Fajr', 'Maghrib'],
    );
  });

  test('prayer reminders can be scheduled before prayer time', () async {
    final service = LocalNotificationServiceStub();
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);

    final scheduled = await service.schedulePrayerReminders(
      settings,
      prayers,
      reminderOffsetMinutes: 10,
    );

    expect(scheduled, hasLength(5));
    expect(
      scheduled.first.time,
      prayers.first.time.subtract(const Duration(minutes: 10)),
    );
    expect(scheduled.first.body, contains('10 minutes'));
    expect(scheduled.first.body, isNot(contains('It is time')));
  });

  test('prayer reminder cancellation preserves daily session reminder',
      () async {
    final service = LocalNotificationServiceStub();
    final prayers = PrayerCalculationService()
        .calculateForDate(DateTime(2026, 5, 21), settings);
    final session = SeedContentRepository(
      SeedContent.demo(),
    ).getDailySession('session_morning_ease')!;

    await service.schedulePrayerReminders(settings, prayers);
    await service.scheduleDailySessionReminder(session);

    expect(service.scheduled, isNotEmpty);
    expect(service.dailySessionReminder, isNotNull);

    await service.cancelPrayerReminders();

    expect(service.scheduled, isEmpty);
    expect(service.dailySessionReminder, isNotNull);
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

  test('notification copy stays gentle brief and policy safe', () {
    final copies = <({String body, String title})>[
      _prayerCopyParts(PrayerNotificationCopy.forPrayer(
        languageCode: 'en',
        prayerName: 'Fajr',
      )),
      _prayerCopyParts(PrayerNotificationCopy.forPrayer(
        languageCode: 'en',
        prayerName: 'Fajr',
        reminderOffsetMinutes: 10,
      )),
      _prayerCopyParts(PrayerNotificationCopy.forPrayer(
        languageCode: 'id',
        prayerName: 'Fajr',
      )),
      _prayerCopyParts(PrayerNotificationCopy.forPrayer(
        languageCode: 'ar',
        prayerName: 'Fajr',
      )),
      _prayerCopyParts(PrayerNotificationCopy.forPrayer(
        languageCode: 'en',
        prayerName: 'Fajr',
        womenIbadahMode: const WomenIbadahMode(
          enabled: true,
          status: WomenIbadahStatus.menstruating,
        ),
      )),
      _dailySessionCopyParts(
        DailySessionNotificationCopy.forSession(languageCode: 'en'),
      ),
      _dailySessionCopyParts(
        DailySessionNotificationCopy.forSession(languageCode: 'id'),
      ),
      _dailySessionCopyParts(
        DailySessionNotificationCopy.forSession(languageCode: 'ar'),
      ),
    ];

    for (final copy in copies) {
      _expectGentleNotificationCopy(copy.title);
      _expectGentleNotificationCopy(copy.body);
      expect(copy.title.length, lessThanOrEqualTo(32));
      expect(copy.body.length, lessThanOrEqualTo(72));
    }
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

  test('notification smoke test uses short delay and privacy-safe payload',
      () async {
    final service = LocalNotificationServiceStub();

    final scheduled = await service.scheduleNotificationSmokeTest(
      delay: const Duration(seconds: 15),
    );

    expect(scheduled, isNotNull);
    expect(scheduled!.time.difference(DateTime.now()).inSeconds, lessThan(20));
    expect(scheduled.payload, contains('"type":"prayer"'));
    expect(scheduled.payload, contains('"fallbackRoute":"/prayer"'));
    _expectNoSensitiveTerms(scheduled.title);
    _expectNoSensitiveTerms(scheduled.body);
    _expectNoSensitiveTerms(scheduled.payload);
  });

  test('notification smoke test respects denied permission', () async {
    final service = LocalNotificationServiceStub()..permissionGranted = false;

    final scheduled = await service.scheduleNotificationSmokeTest();

    expect(scheduled, isNull);
  });

  test('prayer reminder smoke test uses prayer copy and safe route payload',
      () async {
    final service = LocalNotificationServiceStub();

    final scheduled = await service.schedulePrayerReminderSmokeTest(
      languageCode: 'id',
      prayerName: 'Fajr',
      delay: const Duration(seconds: 15),
    );

    expect(scheduled, isNotNull);
    expect(service.prayerReminderSmokeTest, scheduled);
    expect(scheduled!.prayerName, 'Fajr');
    expect(scheduled.body, contains('Subuh'));
    expect(scheduled.time.difference(DateTime.now()).inSeconds, lessThan(20));
    expect(scheduled.payload, contains('"type":"prayer"'));
    expect(scheduled.payload, contains('"fallbackRoute":"/prayer"'));
    _expectNoSensitiveTerms(scheduled.title);
    _expectNoSensitiveTerms(scheduled.body);
    _expectNoSensitiveTerms(scheduled.payload);
  });

  test('prayer reminder smoke test respects denied permission', () async {
    final service = LocalNotificationServiceStub()..permissionGranted = false;

    final scheduled = await service.schedulePrayerReminderSmokeTest();

    expect(scheduled, isNull);
    expect(service.prayerReminderSmokeTest, isNull);
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

({String body, String title}) _prayerCopyParts(
  PrayerNotificationCopy copy,
) {
  return (body: copy.body, title: copy.title);
}

({String body, String title}) _dailySessionCopyParts(
  DailySessionNotificationCopy copy,
) {
  return (body: copy.body, title: copy.title);
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

void _expectGentleNotificationCopy(String value) {
  _expectNoSensitiveTerms(value);
  final lower = value.toLowerCase();
  for (final pattern in const [
    r'(^|[^a-z])sin(s|ful)?([^a-z]|$)',
    r'(^|[^a-z])punish(ment|ed|es|ing)?([^a-z]|$)',
    r'(^|[^a-z])haram([^a-z]|$)',
    r'(^|[^a-z])guilt(y)?([^a-z]|$)',
    r'(^|[^a-z])shame([^a-z]|$)',
    r'(^|[^a-z])missed([^a-z]|$)',
    r'(^|[^a-z])overdue([^a-z]|$)',
    r'(^|[^a-z])urgent([^a-z]|$)',
    r'(^|[^a-z])guaranteed([^a-z]|$)',
    r'(^|[^a-z])fatwa([^a-z]|$)',
    r'(^|[^a-z])medical([^a-z]|$)',
  ]) {
    expect(RegExp(pattern).hasMatch(lower), isFalse, reason: value);
  }
  expect(value, isNot(contains('!')));
}
