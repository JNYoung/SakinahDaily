import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sakinah_models.dart';

abstract class ContentCacheStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<List<String>> keys();
}

class InMemoryContentCacheStore implements ContentCacheStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<List<String>> keys() async => _values.keys.toList();
}

class SharedPreferencesContentCacheStore implements ContentCacheStore {
  const SharedPreferencesContentCacheStore();

  @override
  Future<String?> read(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  }

  @override
  Future<List<String>> keys() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getKeys().toList();
  }
}

class ContentCacheRepository {
  ContentCacheRepository(
    this.store, {
    this.activeManifestKey = 'sakinah_content_active_manifest_v1',
    this.revokedContentKey = 'sakinah_content_revoked_ids_v1',
    this.bundlePrefix = 'sakinah_content_bundle_v1:',
  });

  final ContentCacheStore store;
  final String activeManifestKey;
  final String revokedContentKey;
  final String bundlePrefix;

  Future<void> saveActiveManifest(ContentManifest manifest) async {
    await store.write(activeManifestKey, jsonEncode(manifest.toJson()));
    if (manifest.revokedContentIds.isNotEmpty) {
      await markRevoked(manifest.revokedContentIds);
    }
  }

  Future<ContentManifest?> loadActiveManifest() async {
    final raw = await store.read(activeManifestKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return ContentManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<void> saveBundle(CacheEntry entry) async {
    await store.write(_bundleKey(entry.bundleId), jsonEncode(entry.toJson()));
  }

  Future<CacheEntry?> loadBundle(String bundleId) async {
    final raw = await store.read(_bundleKey(bundleId));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return CacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

  Future<List<CacheEntry>> listBundles() async {
    final allKeys = await store.keys();
    final entries = <CacheEntry>[];
    for (final key in allKeys.where((key) => key.startsWith(bundlePrefix))) {
      final raw = await store.read(key);
      if (raw == null || raw.isEmpty) {
        continue;
      }
      try {
        entries.add(
          CacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } on Object {
        continue;
      }
    }
    entries.sort((a, b) => a.bundleId.compareTo(b.bundleId));
    return entries;
  }

  Future<void> deleteBundle(String bundleId) async {
    await store.delete(_bundleKey(bundleId));
  }

  Future<void> markRevoked(Iterable<String> contentIds) async {
    final revoked = await revokedContentIds();
    revoked.addAll(contentIds.where((id) => id.isNotEmpty));
    await store.write(revokedContentKey, jsonEncode(revoked.toList()..sort()));
  }

  Future<Set<String>> revokedContentIds() async {
    final raw = await store.read(revokedContentKey);
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return decoded.map((item) => '$item').toSet();
      }
    } on Object {
      return <String>{};
    }
    return <String>{};
  }

  Future<bool> isRevoked(String contentId) async {
    return (await revokedContentIds()).contains(contentId);
  }

  Future<void> clearStaleOptionalBundles(DateTime now) async {
    final entries = await listBundles();
    for (final entry in entries) {
      if (!entry.pinned &&
          entry.expiresAt != null &&
          now.isAfter(entry.expiresAt!)) {
        await deleteBundle(entry.bundleId);
      }
    }
  }

  String _bundleKey(String bundleId) => '$bundlePrefix$bundleId';
}
