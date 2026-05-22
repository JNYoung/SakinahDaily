import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Saved Items page lists saved item', (tester) async {
    final store = InMemorySavedItemsStore();
    await SavedItemsRepository(store).save(_savedDua());

    await pumpSakinahApp(
      tester,
      initialLocation: '/saved',
      settleSplash: false,
      savedItemsStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.savedItemsPage), findsOneWidget);
    expect(find.text('Ease'), findsOneWidget);
    expect(find.text('Ibn Hibban'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('tapping saved dua opens Dua Detail', (tester) async {
    final store = InMemorySavedItemsStore();
    await SavedItemsRepository(store).save(_savedDua());

    await pumpSakinahApp(
      tester,
      initialLocation: '/saved',
      settleSplash: false,
      savedItemsStore: store,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.savedItemTile('dua_dua_ease'));

    expect(find.text('Make Dua'), findsWidgets);
    expect(find.text('Ibn Hibban · approved content'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Saved Items page shows empty state', (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/saved',
      settleSplash: false,
      savedItemsStore: InMemorySavedItemsStore(),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.textContaining('Saved items stay on this device'),
        findsOneWidget);
    expectNoFlutterErrors(tester);
  });
}

SavedItem _savedDua() {
  return SavedItem(
    id: SavedItem.stableId(SavedItemType.dua, 'dua_ease'),
    itemType: SavedItemType.dua,
    itemId: 'dua_ease',
    titleSnapshot: 'Ease',
    subtitleSnapshot: 'Dua',
    sourceLabel: 'Ibn Hibban',
    createdAt: DateTime.utc(2026, 5, 22),
    languageCode: 'en',
  );
}
