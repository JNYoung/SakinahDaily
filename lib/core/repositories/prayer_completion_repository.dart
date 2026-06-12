import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_completion.dart';
import '../models/sakinah_models.dart';

abstract class PrayerCompletionStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SharedPreferencesPrayerCompletionStore implements PrayerCompletionStore {
  const SharedPreferencesPrayerCompletionStore({
    this.storageKey = 'sakinah_prayer_completion_v1',
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

class InMemoryPrayerCompletionStore implements PrayerCompletionStore {
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

class PrayerCompletionRepository {
  const PrayerCompletionRepository(this.store);

  final PrayerCompletionStore store;

  Future<void> markCompleted(
    String prayerName, {
    required DateTime completedAt,
  }) async {
    if (!defaultPrayerReminderNames.contains(prayerName)) {
      return;
    }
    final snapshot = await _loadSnapshot();
    final record = PrayerCompletionRecord(
      id: prayerCompletionRecordId(prayerName, completedAt),
      prayerName: prayerName,
      completedAt: completedAt,
    );
    final records = [
      record,
      ...snapshot.records.where((existing) => existing.id != record.id),
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    await _writeSnapshot(_PrayerCompletionSnapshot(records: records));
  }

  Future<void> clearCompletion(String prayerName, DateTime date) async {
    final snapshot = await _loadSnapshot();
    final id = prayerCompletionRecordId(prayerName, date);
    final records = snapshot.records
        .where((record) => record.id != id)
        .toList(growable: false);
    await _writeSnapshot(_PrayerCompletionSnapshot(records: records));
  }

  Future<bool> isCompleted(String prayerName, DateTime date) async {
    final snapshot = await _loadSnapshot();
    final id = prayerCompletionRecordId(prayerName, date);
    return snapshot.records.any((record) => record.id == id);
  }

  Future<List<PrayerCompletionRecord>> completionsForDate(DateTime date) async {
    final snapshot = await _loadSnapshot();
    final day = prayerCompletionDayKey(date);
    final records = snapshot.records
        .where((record) => record.localDayKey == day)
        .toList(growable: false)
      ..sort(
        (a, b) => defaultPrayerReminderNames
            .indexOf(a.prayerName)
            .compareTo(defaultPrayerReminderNames.indexOf(b.prayerName)),
      );
    return List.unmodifiable(records);
  }

  Future<int> completedCountForDate(DateTime date) async {
    return (await completionsForDate(date)).length;
  }

  Future<int> completionCountLast7Days({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final snapshot = await _loadSnapshot();
    return snapshot.records.where((record) {
      return _isInLast7DayWindow(record.localDayKey, reference);
    }).length;
  }

  Future<int> completionDaysLast7({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final snapshot = await _loadSnapshot();
    final days = snapshot.records
        .where((record) => _isInLast7DayWindow(record.localDayKey, reference))
        .map((record) => record.localDayKey)
        .toSet();
    return days.length;
  }

  Future<int> currentStreakDays({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final snapshot = await _loadSnapshot();
    final completedDays = snapshot.records
        .map((record) => record.localDayKey)
        .where((day) => _dayFromKey(day) != null)
        .toSet();
    var cursor = DateTime(reference.year, reference.month, reference.day);
    var streak = 0;
    while (completedDays.contains(prayerCompletionDayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<List<PrayerCompletionRecord>> listCompletionRecords() async {
    final snapshot = await _loadSnapshot();
    final records = [...snapshot.records]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return List.unmodifiable(records);
  }

  Future<void> clearAll() async {
    await store.clear();
  }

  Future<_PrayerCompletionSnapshot> _loadSnapshot() async {
    final raw = await store.read();
    if (raw == null || raw.isEmpty) {
      return const _PrayerCompletionSnapshot();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const _PrayerCompletionSnapshot();
      }
      return _PrayerCompletionSnapshot(
        records: prayerCompletionRecordsFromJson(decoded['records']),
      );
    } on Object {
      return const _PrayerCompletionSnapshot();
    }
  }

  Future<void> _writeSnapshot(_PrayerCompletionSnapshot snapshot) async {
    await store.write(
      encodePrayerCompletionStore(records: snapshot.records),
    );
  }

  bool _isInLast7DayWindow(String localDayKey, DateTime reference) {
    final day = _dayFromKey(localDayKey);
    if (day == null) {
      return false;
    }
    final referenceDay = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final start = referenceDay.subtract(const Duration(days: 6));
    return !day.isBefore(start) && !day.isAfter(referenceDay);
  }

  DateTime? _dayFromKey(String localDayKey) {
    final dayParts = localDayKey.split('-');
    if (dayParts.length != 3) {
      return null;
    }
    final year = int.tryParse(dayParts[0]);
    final month = int.tryParse(dayParts[1]);
    final day = int.tryParse(dayParts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }
}

class _PrayerCompletionSnapshot {
  const _PrayerCompletionSnapshot({this.records = const []});

  final List<PrayerCompletionRecord> records;
}
