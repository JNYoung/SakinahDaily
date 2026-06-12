import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/repositories/prayer_completion_repository.dart';

void main() {
  test('PrayerCompletionRepository marks and clears a prayer for one day',
      () async {
    final repository = PrayerCompletionRepository(
      InMemoryPrayerCompletionStore(),
    );
    final now = DateTime.utc(2026, 6, 12, 5, 20);

    await repository.markCompleted('Fajr', completedAt: now);

    expect(await repository.isCompleted('Fajr', now), isTrue);
    expect(await repository.isCompleted('Dhuhr', now), isFalse);
    expect(await repository.completedCountForDate(now), 1);

    await repository.clearCompletion('Fajr', now);

    expect(await repository.isCompleted('Fajr', now), isFalse);
    expect(await repository.completedCountForDate(now), 0);
  });

  test('completion records are deduplicated by prayer and local day', () async {
    final repository = PrayerCompletionRepository(
      InMemoryPrayerCompletionStore(),
    );
    final now = DateTime.utc(2026, 6, 12, 5, 20);

    await repository.markCompleted('Fajr', completedAt: now);
    await repository.markCompleted(
      'Fajr',
      completedAt: now.add(const Duration(minutes: 5)),
    );

    final records = await repository.listCompletionRecords();

    expect(records, hasLength(1));
    expect(records.single.prayerName, 'Fajr');
    expect(records.single.completedAt, now.add(const Duration(minutes: 5)));
  });

  test('completionCountLast7Days counts prayer records in local window',
      () async {
    final repository = PrayerCompletionRepository(
      InMemoryPrayerCompletionStore(),
    );
    final now = DateTime.utc(2026, 6, 12, 12);

    await repository.markCompleted('Fajr', completedAt: now);
    await repository.markCompleted(
      'Dhuhr',
      completedAt: now.subtract(const Duration(days: 6)),
    );
    await repository.markCompleted(
      'Asr',
      completedAt: now.subtract(const Duration(days: 7)),
    );

    expect(await repository.completionCountLast7Days(now: now), 2);
  });

  test('completionDaysLast7 and currentStreakDays count local check-in days',
      () async {
    final repository = PrayerCompletionRepository(
      InMemoryPrayerCompletionStore(),
    );
    final now = DateTime(2026, 6, 12, 12);

    await repository.markCompleted('Fajr', completedAt: now);
    await repository.markCompleted('Dhuhr', completedAt: now);
    await repository.markCompleted(
      'Isha',
      completedAt: now.subtract(const Duration(days: 1)),
    );
    await repository.markCompleted(
      'Asr',
      completedAt: now.subtract(const Duration(days: 3)),
    );
    await repository.markCompleted(
      'Maghrib',
      completedAt: now.subtract(const Duration(days: 8)),
    );

    expect(await repository.completionDaysLast7(now: now), 3);
    expect(await repository.currentStreakDays(now: now), 2);
  });

  test('invalid persisted prayer completion data fails closed', () async {
    final store = InMemoryPrayerCompletionStore();
    await store.write('{bad json');
    final repository = PrayerCompletionRepository(store);

    expect(await repository.listCompletionRecords(), isEmpty);
  });
}
