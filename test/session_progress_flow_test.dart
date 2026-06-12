import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/session_progress.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';
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
      sessionProgressStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.text('Completed today'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.homeSessionReminderCtaButton);

    expect(find.byKey(SakinahKeys.notificationSettingsPage), findsOneWidget);
    await scrollUntilFound(tester, find.text('Daily session reminder'));
    expect(find.text('Daily session reminder'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });
}
