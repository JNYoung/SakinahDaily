import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../models/sakinah_models.dart';
import 'notification_tap_service.dart';
import 'prayer_calculation_service.dart';

class ScheduledPrayerReminder {
  const ScheduledPrayerReminder({
    required this.prayerName,
    required this.time,
    required this.settings,
    required this.title,
    required this.body,
    this.payload = '',
  });

  final String prayerName;
  final DateTime time;
  final PrayerSettings settings;
  final String title;
  final String body;
  final String payload;
}

class ScheduledDailySessionReminder {
  const ScheduledDailySessionReminder({
    required this.sessionId,
    required this.time,
    required this.title,
    required this.body,
    required this.payload,
  });

  final String sessionId;
  final DateTime time;
  final String title;
  final String body;
  final String payload;
}

class ScheduledNotificationSmokeTest {
  const ScheduledNotificationSmokeTest({
    required this.time,
    required this.title,
    required this.body,
    required this.payload,
  });

  final DateTime time;
  final String title;
  final String body;
  final String payload;
}

class PrayerNotificationCopy {
  const PrayerNotificationCopy({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  factory PrayerNotificationCopy.forPrayer({
    required String languageCode,
    required String prayerName,
    int reminderOffsetMinutes = defaultPrayerReminderOffsetMinutes,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) {
    if (womenIbadahMode.enabled) {
      return PrayerNotificationCopy(
        title: _title(languageCode),
        body: _privacySafeBody(languageCode),
      );
    }
    final localizedPrayer = _prayerName(languageCode, prayerName);
    final offset = sanitizePrayerReminderOffsetMinutes(reminderOffsetMinutes);
    if (offset > 0) {
      return PrayerNotificationCopy(
        title: _title(languageCode),
        body: switch (languageCode) {
          'id' => 'Shalat $localizedPrayer dalam $offset menit.',
          'ar' => 'صلاة $localizedPrayer بعد $offset دقائق.',
          _ => '$localizedPrayer prayer is in $offset minutes.',
        },
      );
    }
    return PrayerNotificationCopy(
      title: _title(languageCode),
      body: switch (languageCode) {
        'id' => 'Waktu shalat $localizedPrayer.',
        'ar' => 'حان وقت صلاة $localizedPrayer.',
        _ => 'It is time for $localizedPrayer prayer.',
      },
    );
  }

  static String _title(String languageCode) {
    return switch (languageCode) {
      'ar' => 'سكينة يومية',
      _ => 'Sakinah Daily',
    };
  }

  static String _privacySafeBody(String languageCode) {
    return switch (languageCode) {
      'id' => 'Pengingat Sakinah yang lembut sudah siap.',
      'ar' => 'تذكير سكينة لطيف جاهز.',
      _ => 'A gentle Sakinah reminder is ready.',
    };
  }

  static String _prayerName(String languageCode, String prayerName) {
    return switch ((languageCode, prayerName)) {
      ('id', 'Fajr') => 'Subuh',
      ('id', 'Dhuhr') => 'Zuhur',
      ('id', 'Asr') => 'Asar',
      ('id', 'Maghrib') => 'Magrib',
      ('id', 'Isha') => 'Isya',
      ('ar', 'Fajr') => 'الفجر',
      ('ar', 'Dhuhr') => 'الظهر',
      ('ar', 'Asr') => 'العصر',
      ('ar', 'Maghrib') => 'المغرب',
      ('ar', 'Isha') => 'العشاء',
      _ => prayerName,
    };
  }
}

class DailySessionNotificationCopy {
  const DailySessionNotificationCopy({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  factory DailySessionNotificationCopy.forSession({
    required String languageCode,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) {
    return DailySessionNotificationCopy(
      title: switch (languageCode) {
        'ar' => 'سكينة يومية',
        _ => 'Sakinah Daily',
      },
      body: switch (languageCode) {
        'id' => 'Sesi Sakinah singkat sudah siap.',
        'ar' => 'جلسة سكينة قصيرة جاهزة.',
        _ => 'A short Sakinah session is ready.',
      },
    );
  }
}

abstract class NotificationService {
  Future<String?> takeLaunchPayload();
  Future<bool> requestPermissionAfterExplanation();
  Future<List<ScheduledPrayerReminder>> schedulePrayerReminders(
    PrayerSettings settings,
    List<PrayerTime> prayerTimes, {
    String languageCode = 'en',
    List<String> enabledPrayerNames = defaultPrayerReminderNames,
    int reminderOffsetMinutes = defaultPrayerReminderOffsetMinutes,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  });
  Future<ScheduledDailySessionReminder?> scheduleDailySessionReminder(
    DailySession session, {
    String languageCode = 'en',
    int minutesAfterMidnight = defaultDailySessionReminderMinutesAfterMidnight,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  });
  Future<ScheduledNotificationSmokeTest?> scheduleNotificationSmokeTest({
    Duration delay = const Duration(seconds: 15),
  });
  Future<ScheduledPrayerReminder?> schedulePrayerReminderSmokeTest({
    String languageCode = 'en',
    String prayerName = 'Fajr',
    Duration delay = const Duration(seconds: 15),
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  });
  Future<void> cancelPrayerReminders();
  Future<void> cancelDailySessionReminder();
  Future<void> cancelAll();
}

class LocalNotificationServiceStub implements NotificationService {
  bool permissionGranted = true;
  String? launchPayload;
  final List<ScheduledPrayerReminder> scheduled = [];
  ScheduledDailySessionReminder? dailySessionReminder;
  ScheduledNotificationSmokeTest? smokeTestReminder;
  ScheduledPrayerReminder? prayerReminderSmokeTest;

  @override
  Future<void> cancelAll() async {
    scheduled.clear();
    dailySessionReminder = null;
    smokeTestReminder = null;
    prayerReminderSmokeTest = null;
  }

  @override
  Future<void> cancelPrayerReminders() async {
    scheduled.clear();
    prayerReminderSmokeTest = null;
  }

  @override
  Future<void> cancelDailySessionReminder() async {
    dailySessionReminder = null;
  }

  @override
  Future<String?> takeLaunchPayload() async {
    final payload = launchPayload;
    launchPayload = null;
    return payload;
  }

  @override
  Future<bool> requestPermissionAfterExplanation() async {
    return permissionGranted;
  }

  @override
  Future<List<ScheduledPrayerReminder>> schedulePrayerReminders(
    PrayerSettings settings,
    List<PrayerTime> prayerTimes, {
    String languageCode = 'en',
    List<String> enabledPrayerNames = defaultPrayerReminderNames,
    int reminderOffsetMinutes = defaultPrayerReminderOffsetMinutes,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!permissionGranted) {
      return [];
    }
    final enabled = sanitizePrayerReminderNames(enabledPrayerNames).toSet();
    final offset = sanitizePrayerReminderOffsetMinutes(reminderOffsetMinutes);
    scheduled
      ..clear()
      ..addAll(
        prayerTimes.where((prayer) => enabled.contains(prayer.name)).map(
          (prayer) {
            final copy = PrayerNotificationCopy.forPrayer(
              languageCode: languageCode,
              prayerName: prayer.name,
              reminderOffsetMinutes: offset,
              womenIbadahMode: womenIbadahMode,
            );
            return ScheduledPrayerReminder(
              prayerName: prayer.name,
              time: prayer.time.subtract(Duration(minutes: offset)),
              settings: settings,
              title: copy.title,
              body: copy.body,
              payload: prayerNotificationPayload(),
            );
          },
        ),
      );
    return List.unmodifiable(scheduled);
  }

  @override
  Future<ScheduledDailySessionReminder?> scheduleDailySessionReminder(
    DailySession session, {
    String languageCode = 'en',
    int minutesAfterMidnight = defaultDailySessionReminderMinutesAfterMidnight,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!permissionGranted) {
      return null;
    }
    final copy = DailySessionNotificationCopy.forSession(
      languageCode: languageCode,
      womenIbadahMode: womenIbadahMode,
    );
    dailySessionReminder = ScheduledDailySessionReminder(
      sessionId: session.id,
      time: nextDailySessionReminderTime(
        minutesAfterMidnight: minutesAfterMidnight,
      ),
      title: copy.title,
      body: copy.body,
      payload: dailySessionNotificationPayload(session.id),
    );
    return dailySessionReminder;
  }

  @override
  Future<ScheduledNotificationSmokeTest?> scheduleNotificationSmokeTest({
    Duration delay = const Duration(seconds: 15),
  }) async {
    if (!permissionGranted) {
      return null;
    }
    smokeTestReminder = ScheduledNotificationSmokeTest(
      time: DateTime.now().add(delay),
      title: 'Sakinah Daily',
      body: 'Test notification scheduled for QA.',
      payload: prayerNotificationPayload(),
    );
    return smokeTestReminder;
  }

  @override
  Future<ScheduledPrayerReminder?> schedulePrayerReminderSmokeTest({
    String languageCode = 'en',
    String prayerName = 'Fajr',
    Duration delay = const Duration(seconds: 15),
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!permissionGranted) {
      return null;
    }
    final copy = PrayerNotificationCopy.forPrayer(
      languageCode: languageCode,
      prayerName: prayerName,
      womenIbadahMode: womenIbadahMode,
    );
    prayerReminderSmokeTest = ScheduledPrayerReminder(
      prayerName: prayerName,
      time: DateTime.now().add(delay),
      settings: _qaPrayerSettings,
      title: copy.title,
      body: copy.body,
      payload: prayerNotificationPayload(),
    );
    return prayerReminderSmokeTest;
  }
}

class FlutterLocalNotificationService implements NotificationService {
  FlutterLocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    this.onNotificationTap,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final FutureOr<void> Function(String? payload)? onNotificationTap;
  bool _initialized = false;
  bool _permissionGranted = false;
  bool _launchPayloadConsumed = false;

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAllPendingNotifications();
    await _plugin.cancelAll();
  }

  @override
  Future<void> cancelPrayerReminders() async {
    await _ensureInitialized();
    await _cancelPrayerReminders();
  }

  @override
  Future<void> cancelDailySessionReminder() async {
    await _ensureInitialized();
    await _plugin.cancel(_dailySessionNotificationId);
  }

  @override
  Future<String?> takeLaunchPayload() async {
    if (_launchPayloadConsumed) {
      return null;
    }
    _launchPayloadConsumed = true;
    try {
      await _ensureInitialized();
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp ?? false) {
        return details?.notificationResponse?.payload;
      }
    } on Object {
      return null;
    }
    return null;
  }

  @override
  Future<bool> requestPermissionAfterExplanation() async {
    try {
      await _ensureInitialized();
      final androidGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      final iosGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      final macosGranted = await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      _permissionGranted = androidGranted ?? iosGranted ?? macosGranted ?? true;
      return _permissionGranted;
    } on Object {
      _permissionGranted = false;
      return false;
    }
  }

  @override
  Future<List<ScheduledPrayerReminder>> schedulePrayerReminders(
    PrayerSettings settings,
    List<PrayerTime> prayerTimes, {
    String languageCode = 'en',
    List<String> enabledPrayerNames = defaultPrayerReminderNames,
    int reminderOffsetMinutes = defaultPrayerReminderOffsetMinutes,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!_permissionGranted) {
      return [];
    }
    try {
      await _ensureInitialized();
      await _cancelPrayerReminders();
      final now = DateTime.now();
      final enabled = sanitizePrayerReminderNames(enabledPrayerNames).toSet();
      final offset = sanitizePrayerReminderOffsetMinutes(reminderOffsetMinutes);
      final scheduled = <ScheduledPrayerReminder>[];
      for (final prayer in prayerTimes.where((prayer) {
        final reminderTime = prayer.time.subtract(Duration(minutes: offset));
        return reminderTime.isAfter(now) && enabled.contains(prayer.name);
      })) {
        final copy = PrayerNotificationCopy.forPrayer(
          languageCode: languageCode,
          prayerName: prayer.name,
          reminderOffsetMinutes: offset,
          womenIbadahMode: womenIbadahMode,
        );
        final reminderTime = prayer.time.subtract(Duration(minutes: offset));
        final reminder = ScheduledPrayerReminder(
          prayerName: prayer.name,
          time: reminderTime,
          settings: settings,
          title: copy.title,
          body: copy.body,
          payload: prayerNotificationPayload(),
        );
        await _plugin.zonedSchedule(
          _notificationId(prayer.name),
          copy.title,
          copy.body,
          timezone.TZDateTime.from(reminderTime, timezone.local),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'sakinah_prayer_reminders',
              'Prayer reminders',
              channelDescription: 'Local prayer time reminders',
            ),
            iOS: DarwinNotificationDetails(),
            macOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: reminder.payload,
        );
        scheduled.add(reminder);
      }
      return List.unmodifiable(scheduled);
    } on Object {
      return [];
    }
  }

  @override
  Future<ScheduledDailySessionReminder?> scheduleDailySessionReminder(
    DailySession session, {
    String languageCode = 'en',
    int minutesAfterMidnight = defaultDailySessionReminderMinutesAfterMidnight,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!_permissionGranted) {
      return null;
    }
    try {
      await _ensureInitialized();
      final copy = DailySessionNotificationCopy.forSession(
        languageCode: languageCode,
        womenIbadahMode: womenIbadahMode,
      );
      final reminder = ScheduledDailySessionReminder(
        sessionId: session.id,
        time: nextDailySessionReminderTime(
          minutesAfterMidnight: minutesAfterMidnight,
        ),
        title: copy.title,
        body: copy.body,
        payload: dailySessionNotificationPayload(session.id),
      );
      await _plugin.cancel(_dailySessionNotificationId);
      await _plugin.zonedSchedule(
        _dailySessionNotificationId,
        reminder.title,
        reminder.body,
        timezone.TZDateTime.from(reminder.time, timezone.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sakinah_daily_session_reminders',
            'Daily session reminders',
            channelDescription: 'Local daily Sakinah session reminders',
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: reminder.payload,
      );
      return reminder;
    } on Object {
      return null;
    }
  }

  @override
  Future<ScheduledNotificationSmokeTest?> scheduleNotificationSmokeTest({
    Duration delay = const Duration(seconds: 15),
  }) async {
    if (!_permissionGranted) {
      return null;
    }
    try {
      await _ensureInitialized();
      final reminder = ScheduledNotificationSmokeTest(
        time: DateTime.now().add(delay),
        title: 'Sakinah Daily',
        body: 'Test notification scheduled for QA.',
        payload: prayerNotificationPayload(),
      );
      await _plugin.cancel(_notificationSmokeTestId);
      await _plugin.zonedSchedule(
        _notificationSmokeTestId,
        reminder.title,
        reminder.body,
        timezone.TZDateTime.from(reminder.time, timezone.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sakinah_notification_qa',
            'Notification QA',
            channelDescription: 'Local notification smoke tests',
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.payload,
      );
      return reminder;
    } on Object {
      return null;
    }
  }

  @override
  Future<ScheduledPrayerReminder?> schedulePrayerReminderSmokeTest({
    String languageCode = 'en',
    String prayerName = 'Fajr',
    Duration delay = const Duration(seconds: 15),
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!_permissionGranted) {
      return null;
    }
    try {
      await _ensureInitialized();
      final copy = PrayerNotificationCopy.forPrayer(
        languageCode: languageCode,
        prayerName: prayerName,
        womenIbadahMode: womenIbadahMode,
      );
      final reminder = ScheduledPrayerReminder(
        prayerName: prayerName,
        time: DateTime.now().add(delay),
        settings: _qaPrayerSettings,
        title: copy.title,
        body: copy.body,
        payload: prayerNotificationPayload(),
      );
      await _plugin.cancel(_prayerReminderSmokeTestId);
      await _plugin.zonedSchedule(
        _prayerReminderSmokeTestId,
        reminder.title,
        reminder.body,
        timezone.TZDateTime.from(reminder.time, timezone.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sakinah_prayer_reminders',
            'Prayer reminders',
            channelDescription: 'Local prayer time reminders',
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.payload,
      );
      return reminder;
    } on Object {
      return null;
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    timezone_data.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final callback = onNotificationTap;
        if (callback != null) {
          unawaited(Future.sync(() => callback(response.payload)));
        }
      },
    );
    _initialized = true;
  }

  int _notificationId(String prayerName) {
    return switch (prayerName) {
      'Fajr' => 101,
      'Dhuhr' => 102,
      'Asr' => 103,
      'Maghrib' => 104,
      'Isha' => 105,
      _ => 199,
    };
  }

  Future<void> _cancelPrayerReminders() async {
    for (final prayerName in const [
      'Fajr',
      'Dhuhr',
      'Asr',
      'Maghrib',
      'Isha'
    ]) {
      await _plugin.cancel(_notificationId(prayerName));
    }
    await _plugin.cancel(_prayerReminderSmokeTestId);
  }
}

String prayerNotificationPayload() {
  return jsonEncode(NotificationTapPayload.prayer().toJson());
}

String dailySessionNotificationPayload(String sessionId) {
  return jsonEncode(
    NotificationTapPayload(
      id: 'daily_session_$sessionId',
      type: 'daily_session',
      contentId: sessionId,
      fallbackRoute: '/session/$sessionId',
      data: {
        'type': 'daily_session',
        'contentId': sessionId,
        'fallbackRoute': '/session/$sessionId',
      },
    ).toJson(),
  );
}

DateTime nextDailySessionReminderTime({
  int minutesAfterMidnight = defaultDailySessionReminderMinutesAfterMidnight,
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final minutes = sanitizeDailySessionReminderMinutes(minutesAfterMidnight);
  final todayReminder = DateTime(
    current.year,
    current.month,
    current.day,
    minutes ~/ 60,
    minutes % 60,
  );
  if (todayReminder.isAfter(current)) {
    return todayReminder;
  }
  return todayReminder.add(const Duration(days: 1));
}

const _dailySessionNotificationId = 201;
const _prayerReminderSmokeTestId = 298;
const _notificationSmokeTestId = 299;
const _qaPrayerSettings = PrayerSettings(
  latitude: 21.3891,
  longitude: 39.8579,
  method: 'umm_al_qura',
  locationLabel: 'Makkah',
  timezoneId: 'Asia/Riyadh',
);
