import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/sakinah_models.dart';

abstract class UserPreferencesStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
}

class SharedPreferencesUserPreferencesStore implements UserPreferencesStore {
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
}

class InMemoryUserPreferencesStore implements UserPreferencesStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }
}

class UserPreferencesRepository {
  const UserPreferencesRepository(
    this.store, {
    this.storageKey = 'sakinah_user_preferences_v1',
  });

  final UserPreferencesStore store;
  final String storageKey;

  Future<UserPreferences> load() async {
    final raw = await store.read(storageKey);
    if (raw == null || raw.isEmpty) {
      return UserPreferences.defaults();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserPreferences.fromJson(json);
    } on Object {
      return UserPreferences.defaults();
    }
  }

  Future<void> save(UserPreferences preferences) async {
    await store.write(storageKey, jsonEncode(preferences.toJson()));
  }
}
