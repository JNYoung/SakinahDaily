import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('/quran/94:5 opens detail with seed ayah', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/94:5',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranVerseDetailPage), findsOneWidget);
    expect(find.text('فَإِنَّ مَعَ الْعُسْرِ يُسْرًا'), findsOneWidget);
    expect(
        find.text('For indeed, with hardship will be ease.'), findsOneWidget);
    expect(
      find.textContaining('Quran 94:5 · Tanzil Arabic'),
      findsOneWidget,
    );
    expect(find.textContaining('Kemenag RI ID'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('missing verse shows unavailable state', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/2:255',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.text('Quran verse unavailable'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran verse save and unsave works', (tester) async {
    final store = InMemorySavedItemsStore();
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/94:5',
      settleSplash: false,
      savedItemsStore: store,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.quranVerseSaveButton);

    expect(find.text('Saved ayah'), findsOneWidget);
    final saved = await SavedItemsRepository(store).listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.itemType, SavedItemType.quranVerse);
    expect(saved.single.itemId, '94:5');

    await tapByKey(tester, SakinahKeys.quranVerseSaveButton);

    expect(find.text('Save ayah'), findsOneWidget);
    expect(await SavedItemsRepository(store).listSavedItems(), isEmpty);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran verse detail can move through reviewed local verses',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/13:28',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranPreviousVerseButton), findsOneWidget);
    expect(find.byKey(SakinahKeys.quranNextVerseButton), findsOneWidget);

    await tapByKey(tester, SakinahKeys.quranNextVerseButton);

    expect(find.byKey(SakinahKeys.quranVerseDetailPage), findsOneWidget);
    expect(find.text('Quran 94:5'), findsWidgets);
    expect(find.byKey(SakinahKeys.quranNextVerseButton), findsNothing);
    expect(find.byKey(SakinahKeys.quranPreviousVerseButton), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran verse detail hides previous action on first local verse',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/1:1',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranPreviousVerseButton), findsNothing);
    expect(find.byKey(SakinahKeys.quranNextVerseButton), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran verse detail does not display generated content markers',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/94:5',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('AI-generated'), findsNothing);
    expect(find.textContaining('machine-generated'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Quran verse detail shows voice-only no-BGM no-TTS safety copy',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/quran/94:5',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranVerseSafetyCard), findsOneWidget);
    expect(find.text('Quran recitation is voice-only'), findsOneWidget);
    expect(find.text('No background music under Quran recitation'),
        findsOneWidget);
    expect(find.text('No Quran TTS'), findsOneWidget);
    expect(find.byKey(SakinahKeys.audioPlayPauseButton), findsNothing);
    expectNoFlutterErrors(tester);
  });
}
