import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/core/services/prayer_calculation_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Settings exposes notification settings entry', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsNotificationSettingsTile);

    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    expect(find.text('Notification settings'), findsWidgets);
    await scrollUntilFound(tester, find.text('Daily session reminder'));
    expect(find.text('Daily session reminder'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification QA smoke test is hidden by default',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.notificationSmokeTestButton), findsNothing);
    expect(
      find.byKey(SakinahKeys.prayerReminderSmokeTestButton),
      findsNothing,
    );
    expect(find.text('Send test notification'), findsNothing);
    expect(find.text('Send prayer reminder test'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification QA smoke test can schedule dev notification',
      (tester) async {
    final notifications = LocalNotificationServiceStub();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      notificationService: notifications,
      appEnvironmentConfig: const AppEnvironmentConfig(
        environment: AppEnvironment.dev,
        appName: 'Sakinah Daily Dev',
        remoteContentEnabled: false,
        notificationQaEnabled: true,
      ),
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.notificationSmokeTestButton);

    expect(notifications.smokeTestReminder, isNotNull);
    expect(notifications.smokeTestReminder!.payload, contains('/prayer'));
    expect(find.text('Test notification scheduled.'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer reminder QA smoke test can schedule dev prayer reminder',
      (tester) async {
    final notifications = LocalNotificationServiceStub();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      notificationService: notifications,
      appEnvironmentConfig: const AppEnvironmentConfig(
        environment: AppEnvironment.dev,
        appName: 'Sakinah Daily Dev',
        remoteContentEnabled: false,
        notificationQaEnabled: true,
      ),
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.prayerReminderSmokeTestButton);

    expect(notifications.prayerReminderSmokeTest, isNotNull);
    expect(notifications.prayerReminderSmokeTest!.payload, contains('/prayer'));
    expect(notifications.prayerReminderSmokeTest!.body, contains('Fajr'));
    expect(find.text('Prayer reminder test scheduled.'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings manage daily session reminder time',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.settingsDailySessionReminderSwitch),
    );
    expect(find.text('Off · 20:00'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.settingsDailySessionReminderSwitch);
    expect(find.text('Set daily reminder?'), findsOneWidget);

    await tester.tap(find.text('Set reminder'));
    await tester.pumpAndSettle();

    var preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderEnabled, isTrue);
    expect(notifications.dailySessionReminder, isNotNull);
    expect(notifications.dailySessionReminder!.time.hour, 20);
    expect(notifications.dailySessionReminder!.time.minute, 0);
    var reminderEvents = _eventsNamed(
      analytics,
      AnalyticsEventCatalog.dailySessionReminderChanged,
    );
    expect(reminderEvents, hasLength(1));
    expect(
      reminderEvents.single.name,
      AnalyticsEventCatalog.dailySessionReminderChanged,
    );
    expect(reminderEvents.single.properties, {
      'session_id': 'session_morning_ease',
      'enabled': true,
      'source': 'settings',
      'change_type': 'enabled',
    });
    expect(find.text('On · 20:00'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.settingsDailySessionReminderTimeButton);
    expect(find.text('Reminder time'), findsWidgets);

    await tester.tap(
      find.byKey(SakinahKeys.settingsDailySessionReminderHourDropdown),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('21').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(SakinahKeys.settingsDailySessionReminderMinuteDropdown),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(SakinahKeys.settingsDailySessionReminderTimeSaveButton),
    );
    await tester.pumpAndSettle();

    preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderMinutesAfterMidnight, 21 * 60 + 15);
    expect(preferences.dailySessionReminderEnabled, isTrue);
    expect(notifications.dailySessionReminder!.time.hour, 21);
    expect(notifications.dailySessionReminder!.time.minute, 15);
    reminderEvents = _eventsNamed(
      analytics,
      AnalyticsEventCatalog.dailySessionReminderChanged,
    );
    expect(reminderEvents, hasLength(2));
    expect(reminderEvents.last.properties, {
      'session_id': 'session_morning_ease',
      'enabled': true,
      'source': 'settings',
      'change_type': 'time_updated',
    });
    expect(find.text('On · 21:15'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.settingsDailySessionReminderSwitch);

    preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderEnabled, isFalse);
    expect(notifications.dailySessionReminder, isNull);
    reminderEvents = _eventsNamed(
      analytics,
      AnalyticsEventCatalog.dailySessionReminderChanged,
    );
    expect(reminderEvents, hasLength(3));
    expect(reminderEvents.last.properties, {
      'session_id': 'session_morning_ease',
      'enabled': false,
      'source': 'settings',
      'change_type': 'disabled',
    });
    expect(find.text('Off · 21:15'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings manage prayer reminders', (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    expect(find.text('Prayer reminders'), findsOneWidget);
    expect(
      find.text('Off · Permission is requested after explanation.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    var preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.notificationsEnabled, isTrue);
    expect(notifications.scheduled, isNotEmpty);
    var prayerReminderEvents = _eventsNamed(
      analytics,
      AnalyticsEventCatalog.prayerReminderChanged,
    );
    expect(prayerReminderEvents, hasLength(1));
    expect(
      prayerReminderEvents.single.name,
      AnalyticsEventCatalog.prayerReminderChanged,
    );
    expect(prayerReminderEvents.single.properties, {
      'prayer_name': 'all',
      'enabled': true,
      'source': 'settings',
      'reminder_offset_minutes': 0,
    });
    expect(
      find.text(
        'On · Fajr, Dhuhr, Asr, Maghrib, Isha · At prayer time · '
        'Local prayer reminders are scheduled.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();

    preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.notificationsEnabled, isFalse);
    expect(notifications.scheduled, isEmpty);
    prayerReminderEvents = _eventsNamed(
      analytics,
      AnalyticsEventCatalog.prayerReminderChanged,
    );
    expect(prayerReminderEvents, hasLength(2));
    expect(prayerReminderEvents.last.properties, {
      'prayer_name': 'all',
      'enabled': false,
      'source': 'settings',
      'reminder_offset_minutes': 0,
    });
    expect(
      find.text('Off · Permission is requested after explanation.'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home prayer reminder CTA records home source analytics',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.homePrayerReminderSettingsButton);
    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    final prayerReminderEvents = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.prayerReminderChanged)
        .toList();
    expect(prayerReminderEvents, hasLength(1));
    expect(prayerReminderEvents.single.properties, {
      'prayer_name': 'all',
      'enabled': true,
      'source': 'home_prayer_card',
      'reminder_offset_minutes': 0,
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer page reminder CTA records prayer page source analytics',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.prayerTopReminderSettingsButton);
    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    final prayerReminderEvents = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.prayerReminderChanged)
        .toList();
    expect(prayerReminderEvents, hasLength(1));
    expect(prayerReminderEvents.single.properties, {
      'prayer_name': 'all',
      'enabled': true,
      'source': 'prayer_page_card',
      'reminder_offset_minutes': 0,
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings records view analytics with safe source',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications?source=home_session_completion',
      settleSplash: false,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    final viewEvents = analytics.events
        .where(
          (event) =>
              event.name == AnalyticsEventCatalog.notificationSettingsViewed,
        )
        .toList();
    expect(viewEvents, hasLength(1));
    expect(viewEvents.single.properties, {
      'screen': 'notification_settings',
      'source': 'home_session_completion',
      'prayer_reminders_enabled': false,
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer reminder permission denial keeps app usable',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub()
      ..permissionGranted = false;
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    final preferences =
        await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.notificationsEnabled, isFalse);
    expect(notifications.scheduled, isEmpty);
    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    expect(
      find.text(
          'Off · Notifications are off. You can enable them from system settings.'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings can disable a single prayer reminder',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    expect(find.text('Prayer reminder choices'), findsOneWidget);

    await tester.tap(
      find.byKey(SakinahKeys.settingsPrayerReminderPrayerSwitch('Dhuhr')),
    );
    await tester.pumpAndSettle();

    var preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.enabledPrayerReminderNames, isNot(contains('Dhuhr')));

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.notificationsEnabled, isTrue);
    expect(
      notifications.scheduled.map((reminder) => reminder.prayerName),
      isNot(contains('Dhuhr')),
    );
    expect(
      notifications.scheduled.map((reminder) => reminder.prayerName),
      containsAll(['Fajr', 'Asr', 'Maghrib', 'Isha']),
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings summarizes enabled prayer reminders',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(SakinahKeys.settingsPrayerReminderPrayerSwitch('Dhuhr')),
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.settingsPrayerReminderLeadTimeDropdown);
    await tester.tap(find.text('10 minutes before').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'On · Fajr, Asr, Maghrib, Isha · 10 minutes before · '
        'Local prayer reminders are scheduled.',
      ),
      findsOneWidget,
    );
    expect(notifications.scheduled, isNotEmpty);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings previews the next local prayer reminder',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    final now = DateTime(2026, 5, 21, 3);
    final preferences = UserPreferences.defaults();
    final expectedPrayer = PrayerCalculationService()
        .dayStatus(now, preferences.prayerSettings)
        .nextPrayer;
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      currentDateTime: now,
      preferencesStore: preferencesStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(SakinahKeys.settingsPrayerNextReminderPreview),
      findsNothing,
    );

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(SakinahKeys.settingsPrayerNextReminderPreview),
      findsOneWidget,
    );
    expect(
      find.text(
        'Next prayer reminder · ${expectedPrayer.name} '
        '${_formatClockTime(expectedPrayer.time)}',
      ),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings records prayer reminder choice analytics',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(SakinahKeys.settingsPrayerReminderPrayerSwitch('Dhuhr')),
    );
    await tester.pumpAndSettle();

    final prayerReminderEvents = _eventsNamed(
      analytics,
      AnalyticsEventCatalog.prayerReminderChanged,
    );
    expect(prayerReminderEvents, hasLength(1));
    expect(
      prayerReminderEvents.single.name,
      AnalyticsEventCatalog.prayerReminderChanged,
    );
    expect(prayerReminderEvents.single.properties, {
      'prayer_name': 'Dhuhr',
      'enabled': false,
      'source': 'settings',
      'reminder_offset_minutes': 0,
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings can set prayer reminder lead time',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    expect(find.text('At prayer time'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.settingsPrayerReminderLeadTimeDropdown);
    await tester.tap(find.text('10 minutes before').last);
    await tester.pumpAndSettle();

    var preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.prayerReminderOffsetMinutes, 10);

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.notificationsEnabled, isTrue);
    expect(notifications.scheduled, isNotEmpty);
    expect(
      notifications.scheduled.map((reminder) => reminder.body),
      everyElement(contains('10 minutes')),
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily session reminder permission denial keeps app usable',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final notifications = LocalNotificationServiceStub()
      ..permissionGranted = false;
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/notifications',
      settleSplash: false,
      preferencesStore: preferencesStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.settingsDailySessionReminderSwitch),
    );
    await tapByKey(tester, SakinahKeys.settingsDailySessionReminderSwitch);
    expect(find.text('Set daily reminder?'), findsOneWidget);

    await tester.tap(find.text('Set reminder'));
    await tester.pumpAndSettle();

    final preferences =
        await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderEnabled, isFalse);
    expect(notifications.dailySessionReminder, isNull);
    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    expect(
      find.text(
          'Notifications are off. You can enable them from system settings.'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });
}

List<AnalyticsEvent> _eventsNamed(
  StubAnalyticsService analytics,
  String eventName,
) {
  return analytics.events
      .where((event) => event.name == eventName)
      .toList(growable: false);
}

String _formatClockTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
