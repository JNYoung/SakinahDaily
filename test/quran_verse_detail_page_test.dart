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
      find.textContaining('Seed metadata; replace with approved Quran source'),
      findsOneWidget,
    );
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
}
