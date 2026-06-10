import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('onboarding continues to home and prayer badge opens prayer list',
      (tester) async {
    await pumpSakinahApp(tester);

    await continueToHome(tester);

    expect(find.text('Assalamu alaikum,'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.homePrayerBadge);

    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('bottom navigation reaches Home, Prayer, Session, and Settings',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavPrayer);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavSession);
    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    expect(find.text('Prayer method'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavHome);
    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home is scoped to prayer-first release actions', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    expect(find.byKey(SakinahKeys.homePrayerPrimaryCard), findsOneWidget);
    expect(find.byKey(SakinahKeys.homePrayerTimesButton), findsOneWidget);
    expect(
      find.byKey(SakinahKeys.homePrayerReminderSettingsButton),
      findsOneWidget,
    );
    expect(find.byKey(SakinahKeys.homeQuickActionDua), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionDhikr), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionQuran), findsNothing);

    expectNoFlutterErrors(tester);
  });

  testWidgets('Qibla route remains available as a secondary surface',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/qibla',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.qiblaPage), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home prayer actions open prayer and reminder settings',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homePrayerTimesButton);
    expect(find.text('Fajr'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.homePrayerReminderSettingsButton);
    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('settings main path is scoped to prayer release controls',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);

    expect(find.text('Prayer location'), findsOneWidget);
    expect(find.text('Prayer method'), findsOneWidget);
    expect(find.text('Prayer reminders'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text("Women's Ibadah Mode"), findsNothing);
    expect(find.text('Saved Items'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua list opens detail', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/dua',
      settleSplash: false,
    );
    await tapByKey(tester, SakinahKeys.duaListItem('dua_ease'));

    expect(find.text('Make Dua'), findsWidgets);
    expect(find.text('Ibn Hibban · approved content'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('daily session start advances and finishes to completion',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);

    for (var i = 0; i < 5; i += 1) {
      await tapByKey(tester, SakinahKeys.sessionNextButton);
    }

    expect(find.byKey(SakinahKeys.sessionFinishButton), findsOneWidget);

    await tapByKey(tester, SakinahKeys.sessionFinishButton);

    expect(find.byKey(SakinahKeys.sessionCompletionPage), findsOneWidget);
    expect(find.text('Session complete'), findsWidgets);

    await tapByKey(tester, SakinahKeys.sessionCompletionBackHomeButton);

    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('PRD route aliases deep-link into session, dhikr and women mode',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/daily-session/session_morning_ease',
      settleSplash: false,
    );
    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);
    expect(_bottomNav(tester).selectedIndex, 2);
    expectNoFlutterErrors(tester);

    await pumpSakinahApp(
      tester,
      initialLocation: '/dhikr/dhikr_subhanallah',
      settleSplash: false,
    );
    expect(find.text('Subhanallah'), findsOneWidget);
    expect(find.text('0 / 33'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expectNoFlutterErrors(tester);

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/women-ibadah',
      settleSplash: false,
    );
    expect(find.text("Women's Ibadah Mode"), findsWidgets);
    expect(_bottomNav(tester).selectedIndex, 3);
    expectNoFlutterErrors(tester);

    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/94:5',
      settleSplash: false,
    );
    expect(find.byKey(SakinahKeys.quranVerseDetailPage), findsOneWidget);
    expect(
        find.text('For indeed, with hardship will be ease.'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets(
      'women mode secondary route completion returns home with Home tab selected',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/women',
      settleSplash: false,
    );

    expect(_bottomNav(tester).selectedIndex, 3);

    await tapByKey(tester, SakinahKeys.womenModeStartButton);

    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expect(_bottomNav(tester).selectedIndex, 0);
    expectNoFlutterErrors(tester);
  });
}

NavigationBar _bottomNav(WidgetTester tester) {
  return tester.widget<NavigationBar>(find.byType(NavigationBar));
}
