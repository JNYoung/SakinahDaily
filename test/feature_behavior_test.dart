import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/models/session_progress.dart';
import 'package:sakinah_daily/core/repositories/prayer_completion_repository.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';
import 'package:sakinah_daily/core/services/audio_player_service.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Dhikr counter increments toward its target', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/dhikr',
      settleSplash: false,
    );

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

  testWidgets('Daily Session Quran step shows Quran Safety card',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.textContaining("Qur'an Safety"), findsOneWidget);
    expect(
      find.textContaining(
        'No background sound is played under Qur\'an recitation.',
      ),
      findsOneWidget,
    );
    expect(find.text('Text-only fallback'), findsWidgets);
    expect(find.byIcon(Icons.music_note), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily Session Quran step hides playback for text fallback',
      (tester) async {
    final player = FakeSakinahAudioPlayer();
    await pumpSakinahApp(tester, audioPlayer: player);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.byKey(SakinahKeys.audioPlayPauseButton), findsNothing);
    expect(find.text('Text-only fallback'), findsWidgets);
    expect(player.currentState.status, AudioPlaybackStatus.idle);
  });

  testWidgets('Daily Session records privacy-safe step view analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(tester, analyticsService: analytics);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    await tester.pumpAndSettle();
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(
      analytics.events.map((event) => event.name),
      containsAllInOrder([
        AnalyticsEventCatalog.dailySessionStarted,
        AnalyticsEventCatalog.dailySessionStepViewed,
        AnalyticsEventCatalog.dailySessionStepViewed,
      ]),
    );
    final stepEvents = analytics.events
        .where(
          (event) => event.name == AnalyticsEventCatalog.dailySessionStepViewed,
        )
        .toList();
    expect(stepEvents, hasLength(2));
    expect(stepEvents.first.properties, {
      'session_id': 'session_morning_ease',
      'step_id': 'intention',
      'step_index': 1,
      'source': 'daily_session',
    });
    expect(stepEvents.last.properties, {
      'session_id': 'session_morning_ease',
      'step_id': 'quran',
      'step_index': 2,
      'source': 'daily_session',
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily Session reflection step shows no-fatwa safety note',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.text('Step 3 of 6 · Reflect'), findsOneWidget);
    expect(find.byKey(SakinahKeys.sessionReflectionSafetyCard), findsOneWidget);
    expect(
      find.text(
        'Reflection is a gentle reminder, not a fatwa or religious ruling.',
      ),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Arabic RTL renders Daily Session without layout exception',
      (tester) async {
    await pumpSakinahApp(
      tester,
      languageCode: 'ar',
      viewport: mobileViewport,
    );
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.textContaining('سلامة القرآن'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua detail shows source and review status', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/dua',
      settleSplash: false,
    );
    await tapByKey(tester, SakinahKeys.duaListItem('dua_ease'));

    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('Transliteration'), findsOneWidget);
    expect(find.text('Meaning'), findsOneWidget);
    expect(find.text('Listen'), findsNothing);
    expect(find.text('Repeat slowly'), findsNothing);
    expect(find.text('Audio unavailable'), findsOneWidget);
    expect(find.text('Ibn Hibban · approved content'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(SakinahKeys.duaSourceCard),
        matching: find.textContaining('Ibn Hibban'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(SakinahKeys.duaSourceCard),
        matching: find.textContaining('approved content'),
      ),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua detail records privacy-safe view and save analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/dua/dua_ease',
      settleSplash: false,
      analyticsService: analytics,
    );

    final viewEvent = analytics.events.singleWhere(
      (event) => event.name == AnalyticsEventCatalog.duaViewed,
    );
    expect(viewEvent.properties, {
      'content_id': 'dua_ease',
      'screen': 'dua_detail',
      'source': 'direct',
    });

    await tapByKey(tester, SakinahKeys.duaSaveButton);

    final saveEvent = analytics.events.lastWhere(
      (event) => event.name == AnalyticsEventCatalog.duaSaved,
    );
    expect(saveEvent.properties, {
      'content_id': 'dua_ease',
      'enabled': true,
      'source': 'dua_detail',
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua library filters by category and searches content',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/dua',
      settleSplash: false,
    );
    await tapByKey(tester, SakinahKeys.duaCategoryChip('evening'));

    expect(find.byKey(SakinahKeys.duaListItem('dua_rest')), findsOneWidget);
    expect(find.byKey(SakinahKeys.duaListItem('dua_ease')), findsNothing);

    await tapByKey(tester, SakinahKeys.duaCategoryChip('all'));
    await tester.enterText(find.byKey(SakinahKeys.duaSearchField), 'easy');
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.duaListItem('dua_ease')), findsOneWidget);
    expect(find.byKey(SakinahKeys.duaListItem('dua_rest')), findsNothing);

    await tester.enterText(find.byKey(SakinahKeys.duaSearchField), 'missing');
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.duaEmptyState), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dhikr library filters by category and searches content',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/dhikr',
      settleSplash: false,
    );
    await tapByKey(tester, SakinahKeys.dhikrCategoryChip('forgiveness'));

    expect(
      find.byKey(SakinahKeys.dhikrListItem('dhikr_istighfar')),
      findsOneWidget,
    );
    expect(
      find.byKey(SakinahKeys.dhikrListItem('dhikr_subhanallah')),
      findsNothing,
    );

    await tapByKey(tester, SakinahKeys.dhikrCategoryChip('all'));
    await tester.enterText(
      find.byKey(SakinahKeys.dhikrSearchField),
      'Astaghfirullah',
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(SakinahKeys.dhikrListItem('dhikr_istighfar')),
      findsOneWidget,
    );
    expect(
      find.byKey(SakinahKeys.dhikrListItem('dhikr_subhanallah')),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(SakinahKeys.dhikrSearchField),
      'missing',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.dhikrEmptyState), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dhikr counter records start and completion analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/dhikr/dhikr_subhanallah',
      settleSplash: false,
      analyticsService: analytics,
    );

    final counter = find.byKey(SakinahKeys.dhikrCounter);
    expect(counter, findsOneWidget);

    await tester.tap(counter);
    await tester.pumpAndSettle();

    final startEvent = analytics.events.singleWhere(
      (event) => event.name == AnalyticsEventCatalog.dhikrStarted,
    );
    expect(startEvent.properties, {
      'content_id': 'dhikr_subhanallah',
      'source': 'dhikr_counter',
    });

    for (var tapCount = 1; tapCount < 33; tapCount += 1) {
      await tester.tap(counter);
      await tester.pump();
    }
    await tester.pumpAndSettle();

    final completionEvent = analytics.events.singleWhere(
      (event) => event.name == AnalyticsEventCatalog.dhikrCompleted,
    );
    expect(completionEvent.properties, {
      'content_id': 'dhikr_subhanallah',
      'source': 'dhikr_counter',
    });
    expect(find.text('33 / 33'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Women mode stays local and toggles sensitive-day state',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/women',
      settleSplash: false,
      analyticsService: analytics,
    );

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
    final enabledEvent = analytics.events.singleWhere(
      (event) => event.name == AnalyticsEventCatalog.womenIbadahModeChanged,
    );
    expect(enabledEvent.properties, {
      'enabled': true,
      'source': 'women_mode',
    });

    await tester.scrollUntilVisible(find.text('What changes locally'), 240);
    expect(find.text('What changes locally'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('What does not leave this device'),
      240,
    );
    expect(find.text('What does not leave this device'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Open Privacy Center'), 240);
    expect(find.text('Open Privacy Center'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Women mode discreet privacy toggle stays local', (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final preferencesRepository = UserPreferencesRepository(preferencesStore);
    final analytics = StubAnalyticsService(enabled: true);

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/women',
      settleSplash: false,
      preferencesStore: preferencesStore,
      analyticsService: analytics,
    );

    await tapByKey(tester, SakinahKeys.womenModeMenstruatingChip);
    await tester.scrollUntilVisible(
      find.byKey(SakinahKeys.womenModeDiscreetToggle),
      240,
    );
    await tapByKey(tester, SakinahKeys.womenModeDiscreetToggle);
    await tester.pumpAndSettle();

    final preferences = await preferencesRepository.load();
    expect(preferences.womenIbadahMode.enabled, isTrue);
    expect(preferences.womenIbadahMode.status, WomenIbadahStatus.menstruating);
    expect(preferences.womenIbadahMode.discreetModeEnabled, isTrue);
    expect(
      analytics.events
          .where(
            (event) =>
                event.name == AnalyticsEventCatalog.womenIbadahModeChanged,
          )
          .map((event) => event.properties),
      everyElement({
        'enabled': true,
        'source': 'women_mode',
      }),
    );
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

  testWidgets('Settings prayer location changes record safe analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings',
      settleSplash: false,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SakinahKeys.settingsPrayerLocationDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jakarta').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SakinahKeys.settingsPrayerMethodDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muslim World League').last);
    await tester.pumpAndSettle();

    final events = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.prayerLocationChanged)
        .toList(growable: false);
    expect(events, hasLength(2));
    expect(events.first.properties, {
      'location_method': 'preset',
      'calculation_method': 'indonesia',
      'source': 'settings_prayer_location',
      'change_type': 'preset_selected',
    });
    expect(events.last.properties, {
      'location_method': 'preset',
      'calculation_method': 'muslim_world_league',
      'source': 'settings_prayer_method',
      'change_type': 'method_selected',
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer page highlights current and next prayers',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: DateTime(2026, 5, 21, 6, 30),
    );

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.prayerListItem('Fajr')),
    );
    expect(
      find.descendant(
        of: find.byKey(SakinahKeys.prayerListItem('Fajr')),
        matching: find.text('Current'),
      ),
      findsOneWidget,
    );
    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.prayerListItem('Dhuhr')),
    );
    expect(
      find.descendant(
        of: find.byKey(SakinahKeys.prayerListItem('Dhuhr')),
        matching: find.text('Next'),
      ),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer page records a privacy-safe view event', (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer?source=home_progress_card',
      settleSplash: false,
      currentDateTime: DateTime(2026, 5, 21, 6, 30),
      analyticsService: analytics,
    );

    expect(analytics.events, hasLength(1));
    expect(analytics.events.single.name, AnalyticsEventCatalog.prayerViewed);
    expect(analytics.events.single.properties, {
      'screen': 'prayer',
      'route': '/prayer',
      'prayer_name': 'Dhuhr',
      'calculation_method': 'umm_al_qura',
      'location_method': 'preset',
      'source': 'home_progress_card',
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer page stores local prayer check-in and Home summarizes it',
      (tester) async {
    final completionStore = InMemoryPrayerCompletionStore();
    final analytics = StubAnalyticsService(enabled: true);
    final now = DateTime(2026, 5, 21, 6, 30);
    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: now,
      prayerCompletionStore: completionStore,
      analyticsService: analytics,
    );

    expect(find.text("Today's prayer check-in"), findsOneWidget);
    expect(find.text('0/5'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.prayerCompletionCheckbox('Fajr'));

    final repository = PrayerCompletionRepository(completionStore);
    expect(await repository.isCompleted('Fajr', now), isTrue);
    expect(await repository.completedCountForDate(now), 1);
    expect(find.text('1/5'), findsOneWidget);
    expect(
      analytics.events.map((event) => event.name),
      contains(AnalyticsEventCatalog.prayerChecklistUpdated),
    );
    expect(analytics.events.last.properties, {
      'screen': 'prayer',
      'completed_count': 1,
      'all_prayers_completed': false,
      'source': 'prayer_page_checklist',
    });

    await tapByKey(tester, SakinahKeys.bottomNavHome);
    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeProgressCard));

    expect(find.text('Prayers today'), findsOneWidget);
    expect(find.text('1/5'), findsOneWidget);
    expect(
      find.text('Prayer check-ins stay on this device only.'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer page shows complete state for five local check-ins',
      (tester) async {
    final completionStore = InMemoryPrayerCompletionStore();
    final repository = PrayerCompletionRepository(completionStore);
    final now = DateTime(2026, 5, 21, 21, 30);
    for (final prayerName in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      await repository.markCompleted(prayerName, completedAt: now);
    }

    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: now,
      prayerCompletionStore: completionStore,
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's prayers are checked in"), findsOneWidget);
    expect(
      find.text('Your five prayer check-ins are saved on this device only.'),
      findsOneWidget,
    );
    expect(find.text('5/5'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets(
      'Prayer complete state starts Daily Session with source analytics',
      (tester) async {
    final completionStore = InMemoryPrayerCompletionStore();
    final repository = PrayerCompletionRepository(completionStore);
    final analytics = StubAnalyticsService(enabled: true);
    final now = DateTime(2026, 5, 21, 21, 30);
    for (final prayerName in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      await repository.markCompleted(prayerName, completedAt: now);
    }

    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: now,
      prayerCompletionStore: completionStore,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's prayers are checked in"), findsOneWidget);
    await tapByKey(tester, SakinahKeys.prayerCompletionStartSessionButton);
    await tester.pumpAndSettle();

    expect(find.text('Step 1 of 6 · Set intention'), findsOneWidget);
    final startEvent = analytics.events.lastWhere(
      (event) => event.name == AnalyticsEventCatalog.dailySessionStarted,
    );
    expect(startEvent.properties, {
      'session_id': 'session_morning_ease',
      'source': 'prayer_completion',
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets(
      'Prayer complete state can open reminder settings with source analytics',
      (tester) async {
    final completionStore = InMemoryPrayerCompletionStore();
    final repository = PrayerCompletionRepository(completionStore);
    final notifications = LocalNotificationServiceStub();
    final analytics = StubAnalyticsService(enabled: true);
    final now = DateTime(2026, 5, 21, 21, 30);
    for (final prayerName in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      await repository.markCompleted(prayerName, completedAt: now);
    }

    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: now,
      prayerCompletionStore: completionStore,
      notificationService: notifications,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's prayers are checked in"), findsOneWidget);
    expect(
      find.byKey(SakinahKeys.prayerCompletionReminderSettingsButton),
      findsOneWidget,
    );

    await tapByKey(tester, SakinahKeys.prayerCompletionReminderSettingsButton);
    await tester.pumpAndSettle();
    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);

    await tester.tap(find.byKey(SakinahKeys.settingsNotificationSwitch));
    await tester.pumpAndSettle();
    expect(find.text('Enable prayer reminders?'), findsOneWidget);

    await tester.tap(find.text('Enable reminders'));
    await tester.pumpAndSettle();

    expect(notifications.scheduled, isNotEmpty);
    final prayerReminderEvent = analytics.events.lastWhere(
      (event) => event.name == AnalyticsEventCatalog.prayerReminderChanged,
    );
    expect(prayerReminderEvent.properties, {
      'prayer_name': 'all',
      'enabled': true,
      'source': 'prayer_completion_card',
      'reminder_offset_minutes': 0,
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Prayer complete state reviews completed Daily Session',
      (tester) async {
    final completionStore = InMemoryPrayerCompletionStore();
    final completionRepository = PrayerCompletionRepository(completionStore);
    final sessionProgressStore = InMemorySessionProgressStore();
    final sessionProgressRepository =
        SessionProgressRepository(sessionProgressStore);
    final now = DateTime(2026, 5, 21, 21, 30);
    for (final prayerName in ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      await completionRepository.markCompleted(prayerName, completedAt: now);
    }
    await sessionProgressRepository.markCompleted(
      SessionCompletionRecord(
        id: 'session_morning_ease_2026-05-21',
        sessionId: 'session_morning_ease',
        completedAt: now,
        durationSeconds: 360,
        languageCode: 'en',
        totalSteps: 6,
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/prayer',
      settleSplash: false,
      currentDateTime: now,
      prayerCompletionStore: completionStore,
      sessionProgressStore: sessionProgressStore,
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's prayers are checked in"), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(SakinahKeys.prayerCompletionSummaryCard),
        matching: find.text('Review'),
      ),
      findsOneWidget,
    );

    await tapByKey(tester, SakinahKeys.prayerCompletionStartSessionButton);
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.sessionCompletionPage), findsOneWidget);
    expect(find.text('Session complete'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily Session normalizes untrusted route source analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation:
          '/session/session_morning_ease?source=quran_arabic_text_private',
      settleSplash: false,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    final startEvent = analytics.events.singleWhere(
      (event) => event.name == AnalyticsEventCatalog.dailySessionStarted,
    );
    expect(startEvent.properties, {
      'session_id': 'session_morning_ease',
      'source': 'direct',
    });
    expectNoFlutterErrors(tester);
  });

  testWidgets('Daily Session completion records safe entry source analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease?source=prayer_completion',
      settleSplash: false,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i += 1) {
      await tapByKey(tester, SakinahKeys.sessionNextButton);
    }
    await tapByKey(tester, SakinahKeys.sessionFinishButton);
    await tester.pumpAndSettle();

    final completionEvent = analytics.events.lastWhere(
      (event) => event.name == AnalyticsEventCatalog.dailySessionCompleted,
    );
    expect(completionEvent.properties, {
      'session_id': 'session_morning_ease',
      'source': 'prayer_completion',
    });
    expect(find.byKey(SakinahKeys.sessionCompletionPage), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home shows prayer weekly progress and aggregate view analytics',
      (tester) async {
    final completionStore = InMemoryPrayerCompletionStore();
    final repository = PrayerCompletionRepository(completionStore);
    final now = DateTime(2026, 5, 21, 6, 30);
    await repository.markCompleted('Fajr', completedAt: now);
    await repository.markCompleted(
      'Dhuhr',
      completedAt: now.subtract(const Duration(days: 1)),
    );
    await repository.markCompleted(
      'Asr',
      completedAt: now.subtract(const Duration(days: 3)),
    );
    final analytics = StubAnalyticsService(enabled: true);

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      currentDateTime: now,
      prayerCompletionStore: completionStore,
      analyticsService: analytics,
    );
    await tester.pumpAndSettle();
    await scrollUntilFound(tester, find.byKey(SakinahKeys.homeProgressCard));

    expect(find.byKey(SakinahKeys.homePrayerWeekProgress), findsOneWidget);
    expect(find.text('Prayer week'), findsOneWidget);
    expect(find.text('Check-in days'), findsOneWidget);
    expect(find.text('3/7'), findsOneWidget);
    expect(find.text('Prayer streak'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    final homeEvent = analytics.events.singleWhere(
      (event) => event.name == AnalyticsEventCatalog.homeViewed,
    );
    expect(homeEvent.properties, {
      'screen': 'home',
      'route': '/home',
      'prayers_completed_today': 1,
      'prayer_checkins_7d': 3,
      'prayer_checkin_days_7d': 3,
      'prayer_checkin_streak_days': 2,
      'prayer_reminders_enabled': false,
    });
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

  testWidgets('Save Tonight button saves the current session locally',
      (tester) async {
    final savedStore = InMemorySavedItemsStore();
    await pumpSakinahApp(tester, savedItemsStore: savedStore);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSaveTonightButton);

    expect(find.text('Saved tonight'), findsOneWidget);
    final saved = await SavedItemsRepository(savedStore).listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.itemType, SavedItemType.dailySession);
    expect(saved.single.itemId, 'session_morning_ease');
  });

  testWidgets('Home hero voice-only button opens Quran audio policy sheet',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeVoiceOnlyButton);

    expect(find.text('Quran recitation is voice-only'), findsOneWidget);
    expect(find.textContaining('No background music'), findsOneWidget);
    expect(find.textContaining('No Quran TTS'), findsOneWidget);
    expectNoFlutterErrors(tester);
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
