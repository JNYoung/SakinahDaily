import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Dhikr counter increments toward its target', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDhikr);

    expect(find.text('0 / 33'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.dhikrCounter);

    expect(find.text('1 / 33'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily session advances through steps and counts dhikr',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);

    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);

    for (var i = 0; i < 4; i += 1) {
      await tapByKey(tester, SakinahKeys.sessionNextButton);
    }

    expect(find.text('Step 5 of 6 · Dhikr counter'), findsOneWidget);
    expect(find.byKey(SakinahKeys.sessionDhikrCounter), findsOneWidget);
    expect(find.text('0 / 33'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.sessionDhikrCounter);

    expect(find.text('1 / 33'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily session player renders progress, audio and safety cards',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/daily-session/session_morning_ease',
      settleSplash: false,
    );

    expect(find.byKey(SakinahKeys.sessionProgressBar), findsOneWidget);
    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.byKey(SakinahKeys.sessionAudioPlayerBar), findsOneWidget);
    expect(find.byKey(SakinahKeys.sessionSafetyCard), findsOneWidget);
    expect(find.text("Qur'an Safety"), findsOneWidget);
    expect(find.text("No background sound is played under Qur'an recitation."),
        findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua detail shows source and review status', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDua);
    await tapByKey(tester, SakinahKeys.duaListItem('dua_ease'));

    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('Transliteration'), findsOneWidget);
    expect(find.text('Meaning'), findsOneWidget);
    expect(find.text('Ibn Hibban · approved content'), findsOneWidget);
    expect(find.byKey(SakinahKeys.duaSourceCard), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Women mode stays local and toggles sensitive-day state',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsWomenModeTile);

    expect(find.text('Data stays local by default'), findsOneWidget);
    expect(
        _choiceChip(tester, SakinahKeys.womenModeNormalChip).selected, isTrue);

    await tapByKey(tester, SakinahKeys.womenModeMenstruatingChip);

    expect(
      _choiceChip(tester, SakinahKeys.womenModeMenstruatingChip).selected,
      isTrue,
    );
    expect(
        _choiceChip(tester, SakinahKeys.womenModeNormalChip).selected, isFalse);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Women mode selected status persists locally', (tester) async {
    final store = InMemoryUserPreferencesStore();
    await pumpSakinahApp(tester, preferencesStore: store);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsWomenModeTile);
    await tapByKey(tester, SakinahKeys.womenModePostpartumChip);

    final loaded = await UserPreferencesRepository(store).load();
    expect(loaded.womenIbadahMode.status, WomenIbadahStatus.postpartum);
    expect(loaded.womenIbadahMode.enabled, isTrue);
    expect(loaded.womenIbadahMode.localOnly, isTrue);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await pumpSakinahApp(tester, preferencesStore: store);
    await continueToHome(tester);
    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsWomenModeTile);

    expect(
      _choiceChip(tester, SakinahKeys.womenModePostpartumChip).selected,
      isTrue,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home supports Arabic RTL and dark themed surfaces',
      (tester) async {
    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      platformBrightness: Brightness.dark,
      viewport: mobileViewport,
    );
    await continueToHome(tester);

    final context = tester.element(find.byKey(SakinahKeys.homeContentList));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(find.byKey(SakinahKeys.homeSessionCard), findsOneWidget);
    expect(find.byKey(SakinahKeys.homeQuickActionsCard), findsOneWidget);
    expect(find.byKey(SakinahKeys.homeNightCard), findsOneWidget);
    expect(find.text('جلسة السكينة اليوم'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Settings update prayer method and notification toggle',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(
        find.byKey(SakinahKeys.settingsPrayerMethodDropdown), findsOneWidget);
    expect(find.byKey(SakinahKeys.settingsNotificationSwitch), findsOneWidget);

    await tester.tap(find.byKey(SakinahKeys.settingsPrayerMethodDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muslim World League').last);
    await tester.pumpAndSettle();

    expect(find.text('Muslim World League'), findsWidgets);

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);
    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    final notificationSwitch = tester.widget<Switch>(
      find.byKey(SakinahKeys.settingsNotificationSwitch),
    );
    expect(notificationSwitch.value, isTrue);
    expectNoFlutterErrors(tester);
  });

  testWidgets(
      'Selecting prayer location preset persists and updates prayer page',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    await pumpSakinahApp(tester, preferencesStore: store);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tester.tap(find.byKey(SakinahKeys.settingsPrayerLocationDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dubai').last);
    await tester.pumpAndSettle();

    expect(find.text('Dubai'), findsWidgets);
    final loaded = await UserPreferencesRepository(store).load();
    expect(loaded.prayerSettings.locationLabel, 'Dubai');
    expect(loaded.prayerSettings.timezoneId, 'Asia/Dubai');

    await tapByKey(tester, SakinahKeys.bottomNavHome);
    await tapByKey(tester, SakinahKeys.homePrayerBadge);

    expect(find.text('Dubai'), findsOneWidget);
    expect(find.text('Muslim World League'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Notification permission denied keeps toggle off',
      (tester) async {
    final notifications = LocalNotificationServiceStub()
      ..permissionGranted = false;
    await pumpSakinahApp(tester, notificationService: notifications);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    final notificationSwitch = tester.widget<Switch>(
      find.byKey(SakinahKeys.settingsNotificationSwitch),
    );
    expect(notificationSwitch.value, isFalse);
    expect(
        find.text(
            'Notifications are off. You can enable them from system settings.'),
        findsOneWidget);
    expect(notifications.scheduled, isEmpty);
  });

  testWidgets('Notification permission granted schedules reminders',
      (tester) async {
    final notifications = LocalNotificationServiceStub();
    await pumpSakinahApp(tester, notificationService: notifications);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    final notificationSwitch = tester.widget<Switch>(
      find.byKey(SakinahKeys.settingsNotificationSwitch),
    );
    expect(notificationSwitch.value, isTrue);
    expect(notifications.scheduled, isNotEmpty);
    expect(notifications.scheduled.first.title, 'Sakinah Daily');
    expect(notifications.scheduled.first.body, isNotEmpty);
  });
}

ChoiceChip _choiceChip(WidgetTester tester, Key wrapperKey) {
  return tester.widget<ChoiceChip>(
    find.descendant(
      of: find.byKey(wrapperKey),
      matching: find.byType(ChoiceChip),
    ),
  );
}
