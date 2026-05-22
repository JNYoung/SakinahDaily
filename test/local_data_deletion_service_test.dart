import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/saved_item.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/models/session_progress.dart';
import 'package:sakinah_daily/core/privacy/local_data_deletion_service.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/content_service.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';

void main() {
  test('delete local data resets preferences clears cache and cancels reminders',
      () async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final preferencesRepository = UserPreferencesRepository(preferencesStore);
    final cacheStore = InMemoryContentCacheStore();
    final cacheRepository = ContentCacheRepository(cacheStore);
    final savedStore = InMemorySavedItemsStore();
    final savedRepository = SavedItemsRepository(savedStore);
    final progressStore = InMemorySessionProgressStore();
    final progressRepository = SessionProgressRepository(progressStore);
    final notifications = LocalNotificationServiceStub();
    await preferencesRepository.save(
      UserPreferences.defaults().copyWith(
        languageCode: 'id',
        notificationsEnabled: true,
        womenIbadahMode: const WomenIbadahMode(
          enabled: true,
          status: WomenIbadahStatus.postpartum,
        ),
      ),
    );
    await cacheRepository.saveActiveManifest(
      const ContentManifest(
        id: 'manifest_fixture',
        schemaVersion: 1,
        revokedContentIds: ['cached_dua'],
        bundles: [],
      ),
    );
    await cacheRepository.saveBundle(
      CacheEntry.fromBundle(
        const ContentBundle(
          id: 'home_bundle_fixture',
          schemaVersion: 1,
          status: ContentStatus.published,
          reviewStatus: ReviewStatus.approved,
          payload: {'dailySessions': []},
        ),
        sha256: 'fixture-sha',
      ),
    );
    await savedRepository.save(
      SavedItem(
        id: SavedItem.stableId(SavedItemType.dua, 'dua_ease'),
        itemType: SavedItemType.dua,
        itemId: 'dua_ease',
        titleSnapshot: 'Ease',
        createdAt: DateTime.utc(2026, 5, 22),
        languageCode: 'en',
      ),
    );
    await progressRepository.saveProgress(
      SessionProgress(
        sessionId: 'session_morning_ease',
        currentStepIndex: 2,
        totalSteps: 6,
        status: SessionProgressStatus.inProgress,
        startedAt: DateTime.utc(2026, 5, 22, 5),
        updatedAt: DateTime.utc(2026, 5, 22, 5, 2),
        languageCode: 'en',
      ),
    );
    await progressRepository.markCompleted(
      SessionCompletionRecord(
        id: 'session_morning_ease_2026-05-22T05:07:00.000Z',
        sessionId: 'session_morning_ease',
        completedAt: DateTime.utc(2026, 5, 22, 5, 7),
        durationSeconds: 420,
        languageCode: 'en',
        totalSteps: 6,
      ),
    );
    notifications.scheduled.add(
      ScheduledPrayerReminder(
        prayerName: 'Fajr',
        time: DateTime(2026, 5, 22, 5),
        settings: UserPreferences.defaults().prayerSettings,
        title: 'Sakinah Daily',
        body: 'Local reminder',
      ),
    );

    final result = await LocalDataDeletionService(
      preferencesRepository: preferencesRepository,
      contentCacheRepository: cacheRepository,
      savedItemsRepository: savedRepository,
      sessionProgressRepository: progressRepository,
      notificationService: notifications,
    ).deleteLocalData();

    final resetPreferences = await preferencesRepository.load();
    expect(result.preferencesReset, isTrue);
    expect(result.contentCacheCleared, isTrue);
    expect(result.notificationsCanceled, isTrue);
    expect(resetPreferences.languageCode, 'en');
    expect(resetPreferences.notificationsEnabled, isFalse);
    expect(resetPreferences.womenIbadahMode.enabled, isFalse);
    expect(await cacheRepository.loadActiveManifest(), isNull);
    expect(await cacheRepository.listBundles(), isEmpty);
    expect(await cacheRepository.revokedContentIds(), isEmpty);
    expect(await savedRepository.listSavedItems(), isEmpty);
    expect(await progressRepository.loadProgress('session_morning_ease'), isNull);
    expect(await progressRepository.listCompletionRecords(), isEmpty);
    expect(notifications.scheduled, isEmpty);
  });

  test('delete local data keeps bundled seed content available', () async {
    final cacheRepository =
        ContentCacheRepository(InMemoryContentCacheStore());
    await LocalDataDeletionService(
      preferencesRepository:
          UserPreferencesRepository(InMemoryUserPreferencesStore()),
      contentCacheRepository: cacheRepository,
      savedItemsRepository:
          SavedItemsRepository(InMemorySavedItemsStore()),
      sessionProgressRepository: SessionProgressRepository(
        InMemorySessionProgressStore(),
      ),
      notificationService: LocalNotificationServiceStub(),
    ).deleteLocalData();

    final service = ContentService(
      seedRepository: SeedContentRepository(SeedContent.demo()),
      cacheRepository: cacheRepository,
    );
    await service.restoreCachedContent();

    expect(service.loadDailySession('session_morning_ease'), isNotNull);
  });
}
