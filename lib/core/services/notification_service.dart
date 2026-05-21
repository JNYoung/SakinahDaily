import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

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

class FlutterLocalNotificationService implements NotificationService {
  FlutterLocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
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
    List<PrayerTime> prayerTimes,
  ) async {
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
        final reminder = ScheduledPrayerReminder(
          prayerName: prayer.name,
          time: prayer.time,
          settings: settings,
        );
        await _plugin.zonedSchedule(
          id: _notificationId(prayer.name),
          title: 'Sakinah Daily',
          body: '${prayer.name} prayer reminder',
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
