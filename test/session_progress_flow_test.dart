import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/session_progress.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Daily Session resumes from saved step', (tester) async {
    final store = InMemorySessionProgressStore();
    final now = DateTime.utc(2026, 5, 22, 5);
    await SessionProgressRepository(store).saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 2,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: now,
        updatedAt: now,
        languageCode: 'en',
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      sessionProgressStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.text('Step 3 of 6 · Reflect'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Finish routes to completion page', (tester) async {
    final store = InMemorySessionProgressStore();
    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease',
      settleSplash: false,
      sessionProgressStore: store,
    );
    await tester.pumpAndSettle();

    for (var i = 0; i < 5; i += 1) {
      await tapByKey(tester, SakinahKeys.sessionNextButton);
    }
    await tapByKey(tester, SakinahKeys.sessionFinishButton);

    expect(find.byKey(SakinahKeys.sessionCompletionPage), findsOneWidget);
    expect(find.text('Session complete'), findsWidgets);
    final records =
        await SessionProgressRepository(store).listCompletionRecords();
    expect(records, hasLength(1));
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home shows Resume for in-progress session', (tester) async {
    final store = InMemorySessionProgressStore();
    final now = DateTime.utc(2026, 5, 22, 5);
    await SessionProgressRepository(store).saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 2,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: now,
        updatedAt: now,
        languageCode: 'en',
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      sessionProgressStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.text('Resume'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home shows Completed Today after completion', (tester) async {
    final store = InMemorySessionProgressStore();
    final preferencesStore = InMemoryUserPreferencesStore();
    final analytics = StubAnalyticsService(enabled: true);
    final notifications = LocalNotificationServiceStub();
    await SessionProgressRepository(store).markCompleted(
      SessionCompletionRecord(
        id: 'session_morning_ease_${DateTime.now().toIso8601String()}',
        sessionId: 'session_morning_ease',
        completedAt: DateTime.now(),
        durationSeconds: 420,
        languageCode: 'en',
        totalSteps: 6,
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      preferencesStore: preferencesStore,
      sessionProgressStore: store,
      analyticsService: analytics,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    expect(find.text('Completed today'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.homeSessionReminderCtaButton);
    expect(find.text('Set daily reminder?'), findsOneWidget);

    await tester.tap(find.text('Set reminder').last);
    await tester.pumpAndSettle();

    final preferences =
        await UserPreferencesRepository(preferencesStore).load();
    expect(preferences.dailySessionReminderEnabled, isTrue);
    expect(notifications.dailySessionReminder, isNotNull);
    expect(find.byKey(SakinahKeys.homeSessionCard), findsOneWidget);
    expect(
      find.byKey(SakinahKeys.homeSessionReminderStatusChip),
      findsOneWidget,
    );
    expect(find.byKey(SakinahKeys.homeSessionReminderCtaButton), findsNothing);
    expect(find.text('Daily reminder set'), findsOneWidget);

    final permissionEvents = analytics.events.where(
      (event) =>
          event.name ==
          AnalyticsEventCatalog.dailySessionReminderPermissionResult,
    );
    expect(permissionEvents, hasLength(1));
    expect(permissionEvents.single.properties, {
      'session_id': 'session_morning_ease',
      'enabled': true,
      'source': 'home_session_completion',
      'change_type': 'scheduled',
    });
    final reminderEvents = analytics.events.where(
      (event) =>
          event.name == AnalyticsEventCatalog.dailySessionReminderChanged,
    );
    expect(reminderEvents, hasLength(1));
    expect(reminderEvents.single.properties, {
      'session_id': 'session_morning_ease',
      'enabled': true,
      'source': 'home_session_completion',
      'change_type': 'enabled',
    });
    expectNoFlutterErrors(tester);
  });
}
