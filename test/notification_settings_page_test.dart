import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
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
    expect(find.text('Daily session reminder'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification settings manage daily session reminder time',
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

    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    expect(find.text('Off · 20:00'), findsOneWidget);

    await tester.tap(
      find.byKey(SakinahKeys.settingsDailySessionReminderSwitch),
    );
    await tester.pumpAndSettle();
    expect(find.text('Set daily reminder?'), findsOneWidget);

    await tester.tap(find.text('Set reminder'));
    await tester.pumpAndSettle();

    var preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderEnabled, isTrue);
    expect(notifications.dailySessionReminder, isNotNull);
    expect(notifications.dailySessionReminder!.time.hour, 20);
    expect(notifications.dailySessionReminder!.time.minute, 0);
    expect(find.text('On · 20:00'), findsOneWidget);

    await tester.tap(
      find.byKey(SakinahKeys.settingsDailySessionReminderTimeButton),
    );
    await tester.pumpAndSettle();
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
    expect(find.text('On · 21:15'), findsOneWidget);

    await tester.tap(
      find.byKey(SakinahKeys.settingsDailySessionReminderSwitch),
    );
    await tester.pumpAndSettle();

    preferences = await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderEnabled, isFalse);
    expect(notifications.dailySessionReminder, isNull);
    expect(find.text('Off · 21:15'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });
}
