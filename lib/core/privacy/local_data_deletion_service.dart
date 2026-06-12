import '../repositories/content_cache_repository.dart';
import '../repositories/prayer_completion_repository.dart';
import '../repositories/saved_items_repository.dart';
import '../repositories/session_progress_repository.dart';
import '../repositories/user_preferences_repository.dart';
import '../services/notification_service.dart';

class LocalDataDeletionResult {
  const LocalDataDeletionResult({
    required this.preferencesReset,
    required this.contentCacheCleared,
    required this.notificationsCanceled,
  });

  final bool preferencesReset;
  final bool contentCacheCleared;
  final bool notificationsCanceled;
}

class LocalDataDeletionService {
  const LocalDataDeletionService({
    required this.preferencesRepository,
    required this.contentCacheRepository,
    required this.savedItemsRepository,
    required this.prayerCompletionRepository,
    required this.sessionProgressRepository,
    required this.notificationService,
  });

  final UserPreferencesRepository preferencesRepository;
  final ContentCacheRepository contentCacheRepository;
  final SavedItemsRepository savedItemsRepository;
  final PrayerCompletionRepository prayerCompletionRepository;
  final SessionProgressRepository sessionProgressRepository;
  final NotificationService notificationService;

  Future<LocalDataDeletionResult> deleteLocalData() async {
    await preferencesRepository.reset();
    await contentCacheRepository.clearAll();
    await savedItemsRepository.clear();
    await prayerCompletionRepository.clearAll();
    await sessionProgressRepository.clearAll();
    await notificationService.cancelAll();
    return const LocalDataDeletionResult(
      preferencesReset: true,
      contentCacheCleared: true,
      notificationsCanceled: true,
    );
  }
}
