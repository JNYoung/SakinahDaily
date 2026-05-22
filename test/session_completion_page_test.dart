import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/session_progress.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('completion page shows local-only note', (tester) async {
    final progressStore = InMemorySessionProgressStore();
    await SessionProgressRepository(progressStore).markCompleted(_record());

    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease/completed',
      settleSplash: false,
      sessionProgressStore: progressStore,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.sessionCompletionPage), findsOneWidget);
    expect(find.text('Session complete'), findsWidgets);
    expect(find.textContaining('Progress stays on this device'), findsOneWidget);
    expect(find.textContaining('No guaranteed spiritual outcome'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Save Session from completion page creates saved item',
      (tester) async {
    final progressStore = InMemorySessionProgressStore();
    final savedStore = InMemorySavedItemsStore();
    await SessionProgressRepository(progressStore).markCompleted(_record());

    await pumpSakinahApp(
      tester,
      initialLocation: '/session/session_morning_ease/completed',
      settleSplash: false,
      sessionProgressStore: progressStore,
      savedItemsStore: savedStore,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.sessionCompletionSaveButton);

    expect(find.text('Session saved'), findsOneWidget);
    final saved = await SavedItemsRepository(savedStore).listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.itemType, SavedItemType.dailySession);
    expect(saved.single.itemId, 'session_morning_ease');
    expectNoFlutterErrors(tester);
  });
}

SessionCompletionRecord _record() {
  return SessionCompletionRecord(
    id: 'session_morning_ease_2026-05-22T05:07:00.000Z',
    sessionId: 'session_morning_ease',
    completedAt: DateTime.utc(2026, 5, 22, 5, 7),
    durationSeconds: 420,
    languageCode: 'en',
    totalSteps: 6,
  );
}
