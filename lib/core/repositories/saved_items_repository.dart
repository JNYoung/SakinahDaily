import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_item.dart';

abstract class SavedItemsStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SharedPreferencesSavedItemsStore implements SavedItemsStore {
  const SharedPreferencesSavedItemsStore({
    this.storageKey = 'sakinah_saved_items_v1',
  });

  final String storageKey;

  @override
  Future<String?> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(storageKey);
  }

  @override
  Future<void> write(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, value);
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }
}

class InMemorySavedItemsStore implements SavedItemsStore {
  String? _value;

  @override
  Future<String?> read() async => _value;

  @override
  Future<void> write(String value) async {
    _value = value;
  }

  @override
  Future<void> clear() async {
    _value = null;
  }
}

class SavedItemsRepository {
  const SavedItemsRepository(this.store);

  final SavedItemsStore store;

  Future<List<SavedItem>> listSavedItems() async {
    final raw = await store.read();
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final items = _safeDecode(raw);
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(items);
  }

  Future<bool> isSaved(SavedItemType itemType, String itemId) async {
    final saved = await listSavedItems();
    return saved.any(
      (item) => item.itemType == itemType && item.itemId == itemId,
    );
  }

  Future<void> save(SavedItem item) async {
    final saved = await listSavedItems();
    final withoutDuplicate = saved
        .where(
          (existing) =>
              existing.itemType != item.itemType ||
              existing.itemId != item.itemId,
        )
        .toList();
    await store.write(savedItemsToJson([item, ...withoutDuplicate]));
  }

  Future<void> remove(SavedItemType itemType, String itemId) async {
    final saved = await listSavedItems();
    final next = saved
        .where(
          (item) => item.itemType != itemType || item.itemId != itemId,
        )
        .toList();
    await store.write(savedItemsToJson(next));
  }

  Future<bool> toggle(SavedItem item) async {
    if (await isSaved(item.itemType, item.itemId)) {
      await remove(item.itemType, item.itemId);
      return false;
    }
    await save(item);
    return true;
  }

  Future<void> clear() async {
    await store.clear();
  }

  List<SavedItem> _safeDecode(String raw) {
    try {
      return savedItemsFromJson(raw);
    } on Object {
      return const [];
    }
  }
}
