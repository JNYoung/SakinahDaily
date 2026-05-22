import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';

void main() {
  test('saves and loads local saved item', () async {
    final repository = SavedItemsRepository(InMemorySavedItemsStore());
    final item = _savedDua();

    await repository.save(item);

    final saved = await repository.listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.itemType, SavedItemType.dua);
    expect(saved.single.itemId, 'dua_ease');
  });

  test('saving same item twice does not duplicate', () async {
    final repository = SavedItemsRepository(InMemorySavedItemsStore());
    final item = _savedDua();

    await repository.save(item);
    await repository.save(item.copyWith(titleSnapshot: 'Updated title'));

    final saved = await repository.listSavedItems();
    expect(saved, hasLength(1));
    expect(saved.single.titleSnapshot, 'Updated title');
  });

  test('removing item works', () async {
    final repository = SavedItemsRepository(InMemorySavedItemsStore());

    await repository.save(_savedDua());
    await repository.remove(SavedItemType.dua, 'dua_ease');

    expect(await repository.listSavedItems(), isEmpty);
    expect(await repository.isSaved(SavedItemType.dua, 'dua_ease'), isFalse);
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
