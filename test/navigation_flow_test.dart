import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
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
    expect(find.byType(NavigationBar), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('bottom navigation reaches Home, Dua, Dhikr, and Settings',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDua);
    expect(find.byKey(SakinahKeys.duaListItem('dua_rabbana_atina')),
        findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavDhikr);
    expect(find.byKey(SakinahKeys.dhikrCounter), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    expect(find.text('Prayer method'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavHome);
    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home quick actions route to their feature surfaces',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeQuickActionDua);
    expect(find.byKey(SakinahKeys.duaListItem('dua_rabbana_atina')),
        findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavHome);
    await tapByKey(tester, SakinahKeys.homeQuickActionDhikr);
    expect(find.byKey(SakinahKeys.dhikrCounter), findsOneWidget);

    await tapByKey(tester, SakinahKeys.bottomNavHome);
    await tapByKey(tester, SakinahKeys.homeQuickActionQuran);
    expect(find.byKey(SakinahKeys.quranPage), findsOneWidget);
    expect(find.text('Featured ayah'), findsOneWidget);

    expectNoFlutterErrors(tester);
  });

  testWidgets('home Qibla quick action opens Qibla page', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeQuickActionQibla);

    expect(find.byKey(SakinahKeys.qiblaPage), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua list opens detail', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDua);
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
    expect(_bottomNav(tester).selectedIndex, 0);
    expectNoFlutterErrors(tester);

    await pumpSakinahApp(
      tester,
      initialLocation: '/dhikr/dhikr_subhanallah',
      settleSplash: false,
    );
    expect(find.text('Subhanallah'), findsOneWidget);
    expect(find.text('0 / 33'), findsOneWidget);
    expect(_bottomNav(tester).selectedIndex, 2);
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

  testWidgets('QA initial route opens a direct page in dev builds',
      (tester) async {
    await pumpSakinahApp(
      tester,
      settleSplash: false,
      appEnvironmentConfig: const AppEnvironmentConfig(
        environment: AppEnvironment.dev,
        appName: 'Sakinah Daily Dev',
        remoteContentEnabled: false,
        initialRoute: '/settings/privacy',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.privacyCenterPage), findsOneWidget);
    expect(find.text('Privacy Center'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  testWidgets(
      'settings secondary completion returns home with Home tab selected',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsWomenModeTile);

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
