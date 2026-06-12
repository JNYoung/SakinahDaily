import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/prayer_calculation_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('onboarding continues to home and prayer badge opens prayer list',
      (tester) async {
    await pumpSakinahApp(tester);

    await continueToHome(tester);

    expect(find.text('Assalamu alaikum,'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.homePrayerBadge);

    expect(find.byKey(SakinahKeys.prayerListItem('Fajr')), findsOneWidget);
    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.prayerListItem('Dhuhr')),
    );
    expect(find.byKey(SakinahKeys.prayerListItem('Dhuhr')), findsOneWidget);
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
    expect(find.byKey(SakinahKeys.prayerListItem('Fajr')), findsOneWidget);
    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.prayerListItem('Dhuhr')),
    );
    expect(find.byKey(SakinahKeys.prayerListItem('Dhuhr')), findsOneWidget);

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

  testWidgets('home is daily prayer companion rather than a tool stack',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      currentDateTime: DateTime(2026, 6, 11, 12),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assalamu alaikum,'), findsOneWidget);
    expect(find.text('Tuesday · 12 Ramadan'), findsOneWidget);
    expect(find.byKey(SakinahKeys.homePrayerPrimaryCard), findsOneWidget);
    expect(find.byKey(SakinahKeys.homeSessionCard), findsOneWidget);
    expect(find.text('Daily prayer at the center'), findsOneWidget);
    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expect(find.text('Quick Actions'), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionsCard), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionQuran), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionDua), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionDhikr), findsNothing);
    expect(find.byKey(SakinahKeys.homeQuickActionQibla), findsNothing);

    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeProgressCard));
    expect(find.text('Local progress'), findsOneWidget);
    expect(find.text('Current streak'), findsOneWidget);
    expect(find.text('Completed this week'), findsOneWidget);
    expect(find.text('Progress stays on this device only.'), findsOneWidget);

    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeNightCard));
    expect(find.text('Tonight'), findsOneWidget);
    expect(find.text('Sleep with Ayat al-Kursi'), findsOneWidget);

    expectNoFlutterErrors(tester);
  });

  testWidgets('home prayer card explains location method and reminder status',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final now = DateTime(2026, 5, 21, 3);
    final preferences = UserPreferences.defaults().copyWith(
      notificationsEnabled: true,
      prayerReminderOffsetMinutes: 10,
      prayerSettings: const PrayerSettings(
        latitude: -6.2088,
        longitude: 106.8456,
        method: 'indonesia',
        locationLabel: 'Jakarta',
        timezoneId: 'Asia/Jakarta',
      ),
    );
    final expectedPrayer = PrayerCalculationService()
        .dayStatus(now, preferences.prayerSettings)
        .nextPrayer;
    final expectedReminderAt = expectedPrayer.time.subtract(
      Duration(
        minutes: sanitizePrayerReminderOffsetMinutes(
          preferences.prayerReminderOffsetMinutes,
        ),
      ),
    );
    await UserPreferencesRepository(preferencesStore).save(
      preferences,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: preferencesStore,
      currentDateTime: now,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homePrayerPrimaryCard), findsOneWidget);
    expect(find.text('Prayer location · Jakarta'), findsOneWidget);
    expect(find.text('Prayer method · KEMENAG Indonesia'), findsOneWidget);
    expect(find.text('Prayer reminders · On'), findsOneWidget);
    expect(
      find.text(
        'Next prayer reminder · ${expectedPrayer.name} '
        '${_formatClockTime(expectedReminderAt)}',
      ),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('home surfaces closed testing guide when feedback is configured',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeClosedTestingGuideCard), findsOneWidget);
    expect(find.text('Closed testing guide'), findsOneWidget);
    expect(
        find.textContaining('Day 1 / Day 3 / Day 7 / Day 14'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.homeClosedTestingGuideButton);

    expect(find.byKey(SakinahKeys.closedTestingGuidePage), findsOneWidget);
    expect(find.text('Daily tester checklist'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home hides closed testing guide without feedback configuration',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeClosedTestingGuideCard), findsNothing);
    expect(find.byKey(SakinahKeys.homeClosedTestingGuideButton), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('prayer page shows all five daily prayer times', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: DateTime(2026, 6, 11, 12),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's prayer times"), findsOneWidget);
    for (final prayerName in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      await scrollUntilFound(
        tester,
        find.byKey(SakinahKeys.prayerListItem(prayerName)),
      );
      expect(
          find.byKey(SakinahKeys.prayerListItem(prayerName)), findsOneWidget);
    }
    expectNoFlutterErrors(tester);
  });

  testWidgets('home session card shows enabled daily reminder time',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    await UserPreferencesRepository(preferencesStore).save(
      UserPreferences.defaults().copyWith(
        dailySessionReminderEnabled: true,
        dailySessionReminderMinutesAfterMidnight: 5 * 60 + 30,
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: preferencesStore,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeSessionCard), findsOneWidget);
    expect(find.text('Daily session reminder · 05:30'), findsOneWidget);
    expect(find.byKey(SakinahKeys.homeSessionReminderCtaButton), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home shows recent saved items as a local continue rail',
      (tester) async {
    final savedItemsStore = InMemorySavedItemsStore();
    await SavedItemsRepository(savedItemsStore).save(_savedDua());

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      savedItemsStore: savedItemsStore,
    );
    await tester.pumpAndSettle();

    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeSavedRail));

    expect(find.byKey(SakinahKeys.homeSavedRail), findsOneWidget);
    expect(find.text('Continue from saved'), findsOneWidget);
    expect(find.text('Saved locally on this device.'), findsOneWidget);
    expect(find.text('Ease'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.homeSavedItemTile('dua_dua_ease'));

    expect(find.text('Make Dua'), findsWidgets);
    expect(find.text('Ibn Hibban · approved content'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('home hides saved rail until there is local saved content',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      savedItemsStore: InMemorySavedItemsStore(),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeSavedRail), findsNothing);
    expect(find.text('Continue from saved'), findsNothing);
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
    expect(find.byKey(SakinahKeys.prayerListItem('Fajr')), findsOneWidget);

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

  testWidgets('daily session dark layout renders one readable title',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
    );

    expect(find.text('Morning Ease'), findsOneWidget);
    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);
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

SavedItem _savedDua() {
  return SavedItem(
    id: SavedItem.stableId(SavedItemType.dua, 'dua_ease'),
    itemType: SavedItemType.dua,
    itemId: 'dua_ease',
    titleSnapshot: 'Ease',
    subtitleSnapshot: 'Dua',
    sourceLabel: 'Ibn Hibban',
    createdAt: DateTime.utc(2026, 6, 10),
    languageCode: 'en',
  );
}

String _formatClockTime(DateTime time) {
  return '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}';
}
