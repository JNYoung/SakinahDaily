import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/session_progress.dart';

abstract class SessionProgressStore {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

class SharedPreferencesSessionProgressStore implements SessionProgressStore {
  const SharedPreferencesSessionProgressStore({
    this.storageKey = 'sakinah_session_progress_v1',
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

class InMemorySessionProgressStore implements SessionProgressStore {
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

class SessionProgressRepository {
  const SessionProgressRepository(this.store);

  final SessionProgressStore store;

  Future<SessionProgress?> loadProgress(String sessionId) async {
    final snapshot = await _loadSnapshot();
    final progress = snapshot.progress[sessionId];
    if (progress?.status != SessionProgressStatus.inProgress) {
      return null;
    }
    return progress;
  }

  Future<Map<String, SessionProgress>> listActiveProgress() async {
    final snapshot = await _loadSnapshot();
    return Map.unmodifiable(
      Map.fromEntries(
        snapshot.progress.entries.where(
          (entry) => entry.value.status == SessionProgressStatus.inProgress,
        ),
      ),
    );
  }

  Future<void> saveProgress(SessionProgress progress) async {
    final snapshot = await _loadSnapshot();
    final nextProgress = {...snapshot.progress, progress.sessionId: progress};
    await _writeSnapshot(
      _SessionProgressSnapshot(
        progress: nextProgress,
        records: snapshot.records,
      ),
    );
  }

  Future<void> clearProgress(String sessionId) async {
    final snapshot = await _loadSnapshot();
    final nextProgress = {...snapshot.progress}..remove(sessionId);
    await _writeSnapshot(
      _SessionProgressSnapshot(
        progress: nextProgress,
        records: snapshot.records,
      ),
    );
  }

  Future<void> markCompleted(SessionCompletionRecord record) async {
    final snapshot = await _loadSnapshot();
    final records = [
      record,
      ...snapshot.records.where((existing) => existing.id != record.id),
    ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    await _writeSnapshot(
      _SessionProgressSnapshot(
        progress: snapshot.progress,
        records: records,
      ),
    );
  }

  Future<List<SessionCompletionRecord>> listCompletionRecords() async {
    final snapshot = await _loadSnapshot();
    final records = [...snapshot.records]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return List.unmodifiable(records);
  }

  Future<SessionCompletionRecord?> completionForDate(
    DateTime date, {
    String? sessionId,
  }) async {
    final day = _dayKey(date);
    final records = await listCompletionRecords();
    for (final record in records) {
      if (_dayKey(record.completedAt) == day &&
          (sessionId == null || record.sessionId == sessionId)) {
        return record;
      }
    }
    return null;
  }

  Future<int> completionCountLast7Days({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final start = DateTime(
      reference.year,
      reference.month,
      reference.day,
    ).subtract(const Duration(days: 6));
    final records = await listCompletionRecords();
    return records.where((record) {
      final day = DateTime(
        record.completedAt.year,
        record.completedAt.month,
        record.completedAt.day,
      );
      return !day.isBefore(start) && !day.isAfter(reference);
    }).length;
  }

  Future<int> currentStreakDays({DateTime? now}) async {
    final reference = now ?? DateTime.now();
    final records = await listCompletionRecords();
    final completedDays = records.map((record) => _dayKey(record.completedAt));
    final completed = completedDays.toSet();
    var streak = 0;
    var cursor = DateTime(reference.year, reference.month, reference.day);
    while (completed.contains(_dayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  Future<void> clearAll() async {
    await store.clear();
  }

  Future<_SessionProgressSnapshot> _loadSnapshot() async {
    final raw = await store.read();
    if (raw == null || raw.isEmpty) {
      return const _SessionProgressSnapshot();
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return const _SessionProgressSnapshot();
      }
      return _SessionProgressSnapshot(
        progress: sessionProgressMapFromJson(decoded['progress']),
        records: sessionCompletionRecordsFromJson(decoded['records']),
      );
    } on Object {
      return const _SessionProgressSnapshot();
    }
  }

  Future<void> _writeSnapshot(_SessionProgressSnapshot snapshot) async {
    await store.write(
      encodeSessionProgressStore(
        progress: snapshot.progress,
        records: snapshot.records,
      ),
    );
  }

  String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class _SessionProgressSnapshot {
  const _SessionProgressSnapshot({
    this.progress = const {},
    this.records = const [],
  });

  final Map<String, SessionProgress> progress;
  final List<SessionCompletionRecord> records;
}
