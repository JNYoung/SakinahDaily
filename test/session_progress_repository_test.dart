import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/session_progress.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';

void main() {
  test('SessionProgressRepository saves and loads in-progress state',
      () async {
    final repository = SessionProgressRepository(
      InMemorySessionProgressStore(),
    );
    final startedAt = DateTime.utc(2026, 5, 22, 5);

    await repository.saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 1,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: startedAt,
        updatedAt: startedAt,
        languageCode: 'en',
      ),
    );

    final progress = await repository.loadProgress('session_morning_ease');

    expect(progress, isNotNull);
    expect(progress!.currentStepIndex, 1);
    expect(progress.status, SessionProgressStatus.inProgress);
    expect(progress.languageCode, 'en');
  });

  test('updating step persists currentStepIndex', () async {
    final repository = SessionProgressRepository(
      InMemorySessionProgressStore(),
    );
    final now = DateTime.utc(2026, 5, 22, 5);

    await repository.saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 0,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: now,
        updatedAt: now,
        languageCode: 'en',
      ),
    );
    await repository.saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 4,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: now,
        updatedAt: now.add(const Duration(minutes: 2)),
        languageCode: 'en',
      ),
    );

    final progress = await repository.loadProgress('session_morning_ease');

    expect(progress!.currentStepIndex, 4);
  });

  test('completing session creates completion record and clears progress',
      () async {
    final repository = SessionProgressRepository(
      InMemorySessionProgressStore(),
    );
    final now = DateTime.utc(2026, 5, 22, 5);
    await repository.saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 5,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: now,
        updatedAt: now,
        languageCode: 'en',
      ),
    );

    await repository.markCompleted(
      SessionCompletionRecord(
        id: 'session_morning_ease_2026-05-22T05:07:00.000Z',
        sessionId: 'session_morning_ease',
        completedAt: now.add(const Duration(minutes: 7)),
        durationSeconds: 420,
        languageCode: 'en',
        totalSteps: 6,
      ),
    );
    await repository.clearProgress('session_morning_ease');

    expect(await repository.loadProgress('session_morning_ease'), isNull);
    final records = await repository.listCompletionRecords();
    expect(records, hasLength(1));
    expect(records.single.sessionId, 'session_morning_ease');
    expect(records.single.durationSeconds, 420);
  });

  test('completionCountLast7Days works', () async {
    final repository = SessionProgressRepository(
      InMemorySessionProgressStore(),
    );
    final now = DateTime.utc(2026, 5, 22, 12);
    await repository.markCompleted(_record('a', now));
    await repository.markCompleted(
      _record('b', now.subtract(const Duration(days: 6))),
    );
    await repository.markCompleted(
      _record('c', now.subtract(const Duration(days: 7))),
    );

    expect(repository.completionCountLast7Days(now: now), completion(2));
  });

  test('currentStreakDays calculates simple consecutive days', () async {
    final repository = SessionProgressRepository(
      InMemorySessionProgressStore(),
    );
    final now = DateTime.utc(2026, 5, 22, 12);
    await repository.markCompleted(_record('today', now));
    await repository.markCompleted(
      _record('yesterday', now.subtract(const Duration(days: 1))),
    );
    await repository.markCompleted(
      _record('two_days_ago', now.subtract(const Duration(days: 2))),
    );
    await repository.markCompleted(
      _record('gap', now.subtract(const Duration(days: 4))),
    );

    expect(repository.currentStreakDays(now: now), completion(3));
  });
}

SessionCompletionRecord _record(String id, DateTime completedAt) {
  return SessionCompletionRecord(
    id: id,
    sessionId: 'session_morning_ease',
    completedAt: completedAt,
    durationSeconds: 420,
    languageCode: 'en',
    totalSteps: 6,
  );
}
