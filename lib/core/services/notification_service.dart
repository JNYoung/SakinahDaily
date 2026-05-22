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
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) {
    if (womenIbadahMode.enabled) {
      return PrayerNotificationCopy(
        title: _title(languageCode),
        body: _privacySafeBody(languageCode),
      );
    }
    final localizedPrayer = _prayerName(languageCode, prayerName);
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

abstract class NotificationService {
  Future<bool> requestPermissionAfterExplanation();
  Future<List<ScheduledPrayerReminder>> schedulePrayerReminders(
    PrayerSettings settings,
    List<PrayerTime> prayerTimes, {
    String languageCode = 'en',
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  });
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
    List<PrayerTime> prayerTimes, {
    String languageCode = 'en',
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!permissionGranted) {
      return [];
    }
    scheduled
      ..clear()
      ..addAll(
        prayerTimes.map(
          (prayer) {
            final copy = PrayerNotificationCopy.forPrayer(
              languageCode: languageCode,
              prayerName: prayer.name,
              womenIbadahMode: womenIbadahMode,
            );
            return ScheduledPrayerReminder(
              prayerName: prayer.name,
              time: prayer.time,
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

  @override
  Future<void> cancelAll() async {
    await _ensureInitialized();
    await _plugin.cancelAllPendingNotifications();
    await _plugin.cancelAll();
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
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
  }) async {
    if (!_permissionGranted) {
      return [];
    }
    try {
      await _ensureInitialized();
      await cancelAll();
      final now = DateTime.now();
      final scheduled = <ScheduledPrayerReminder>[];
      for (final prayer in prayerTimes.where(
        (prayer) => prayer.time.isAfter(now),
      )) {
        final copy = PrayerNotificationCopy.forPrayer(
          languageCode: languageCode,
          prayerName: prayer.name,
          womenIbadahMode: womenIbadahMode,
        );
        final reminder = ScheduledPrayerReminder(
          prayerName: prayer.name,
          time: prayer.time,
          settings: settings,
          title: copy.title,
          body: copy.body,
          payload: prayerNotificationPayload(),
        );
        await _plugin.zonedSchedule(
          id: _notificationId(prayer.name),
          title: copy.title,
          body: copy.body,
          scheduledDate: timezone.TZDateTime.from(prayer.time, timezone.local),
          notificationDetails: const NotificationDetails(
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

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    timezone_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
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
}

String prayerNotificationPayload() {
  return jsonEncode(NotificationTapPayload.prayer().toJson());
}
