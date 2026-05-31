import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/services/audio_player_service.dart';
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

  testWidgets('Daily Session Quran step disables playback for text fallback',
      (tester) async {
    final player = FakeSakinahAudioPlayer();
    await pumpSakinahApp(tester, audioPlayer: player);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeSessionStartButton);
    await tapByKey(tester, SakinahKeys.sessionNextButton);

    expect(find.byKey(SakinahKeys.audioPlayPauseButton), findsOneWidget);
    expect(find.text('Text-only fallback'), findsWidgets);

    final button = tester.widget<IconButton>(
      find.byKey(SakinahKeys.audioPlayPauseButton),
    );
    expect(button.onPressed, isNull);
    expect(player.currentState.status, AudioPlaybackStatus.idle);
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
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDua);
    await tapByKey(tester, SakinahKeys.duaListItem('dua_ease'));

    expect(find.text('Arabic'), findsOneWidget);
    expect(find.text('Transliteration'), findsOneWidget);
    expect(find.text('Meaning'), findsOneWidget);
    expect(find.text('Ibn Hibban · approved content'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua detail marks audio as unavailable instead of no-op CTAs',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDua);
    await tapByKey(tester, SakinahKeys.duaListItem('dua_ease'));

    expect(find.text('Listen'), findsNothing);
    expect(find.text('Repeat slowly'), findsNothing);
    expect(find.byKey(SakinahKeys.duaAudioUnavailableCard), findsOneWidget);
    expect(find.text('Dua audio unavailable'), findsOneWidget);
    expect(find.textContaining('reviewed audio asset'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Dua library filters by category and searches content',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDua);
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
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavDhikr);
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
