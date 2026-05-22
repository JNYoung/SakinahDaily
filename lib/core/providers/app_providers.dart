import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_environment.dart';
import '../config/content_api_config.dart';
import '../models/saved_item.dart';
import '../models/sakinah_models.dart';
import '../models/session_progress.dart';
import '../privacy/local_data_deletion_service.dart';
import '../privacy/privacy_data_inventory.dart';
import '../repositories/content_cache_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/saved_items_repository.dart';
import '../repositories/session_progress_repository.dart';
import '../repositories/user_preferences_repository.dart';
import '../services/analytics_service.dart';
import '../services/audio_player_service.dart';
import '../services/audio_policy_service.dart';
import '../services/content_service.dart';
import '../services/local_push_receiver.dart';
import '../services/notification_service.dart';
import '../services/notification_tap_service.dart';
import '../services/prayer_calculation_service.dart';
import '../services/push_candidate_selector.dart';
import '../services/qibla_service.dart';
import '../services/remote_content_api_client.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

final appEnvironmentConfigProvider = Provider<AppEnvironmentConfig>((ref) {
  return AppEnvironmentConfig.fromDartDefine();
});

final userPreferencesStoreProvider = Provider<UserPreferencesStore>((ref) {
  return SharedPreferencesUserPreferencesStore();
});

final userPreferencesRepositoryProvider =
    Provider<UserPreferencesRepository>((ref) {
  return UserPreferencesRepository(ref.watch(userPreferencesStoreProvider));
});

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesController, UserPreferences>(
  (ref) {
    final controller = UserPreferencesController(
      ref,
      ref.watch(userPreferencesRepositoryProvider),
    );
    unawaited(controller.load());
    return controller;
  },
);

class UserPreferencesController extends StateNotifier<UserPreferences> {
  UserPreferencesController(this.ref, this.repository)
      : super(UserPreferences.defaults());

  final Ref ref;
  final UserPreferencesRepository repository;
  bool _hasLocalChanges = false;

  Future<void> load() async {
    final preferences = await repository.load();
    if (!mounted || _hasLocalChanges) {
      return;
    }
    state = preferences;
    ref.read(localeProvider.notifier).state = Locale(preferences.languageCode);
  }

  Future<void> setLanguage(String languageCode) async {
    await _commit(state.copyWith(languageCode: languageCode));
  }

  Future<void> setGenderMode(GenderMode mode) async {
    await _commit(state.copyWith(genderMode: mode));
  }

  Future<void> setAudioPreference(AudioPreference preference) async {
    await _commit(state.copyWith(audioPreference: preference));
  }

  Future<void> setPrayerSettings(PrayerSettings settings) async {
    await _commit(state.copyWith(prayerSettings: settings));
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _commit(state.copyWith(notificationsEnabled: enabled));
  }

  Future<void> setWomenMode(bool enabled) async {
    final status = enabled
        ? (state.womenIbadahMode.status == WomenIbadahStatus.normal
            ? WomenIbadahStatus.menstruating
            : state.womenIbadahMode.status)
        : WomenIbadahStatus.normal;
    await _commit(
      state.copyWith(
        womenIbadahMode: state.womenIbadahMode.copyWith(
          enabled: enabled,
          status: status,
        ),
      ),
    );
  }

  Future<void> setWomenModeStatus(WomenIbadahStatus status) async {
    await _commit(
      state.copyWith(
        womenIbadahMode: state.womenIbadahMode.copyWith(
          enabled: status != WomenIbadahStatus.normal,
          status: status,
        ),
      ),
    );
  }

  Future<void> saveCurrent() async {
    await repository.save(state);
  }

  Future<void> resetToDefaults() async {
    _hasLocalChanges = true;
    await repository.reset();
    final defaults = UserPreferences.defaults();
    state = defaults;
    ref.read(localeProvider.notifier).state = Locale(defaults.languageCode);
  }

  Future<void> _commit(UserPreferences preferences) async {
    _hasLocalChanges = true;
    state = preferences;
    ref.read(localeProvider.notifier).state = Locale(preferences.languageCode);
    await repository.save(preferences);
  }
}

final seedContentProvider = Provider<SeedContent>((ref) => SeedContent.demo());

final seedContentRepositoryProvider = Provider<ContentRepository>((ref) {
  return SeedContentRepository(ref.watch(seedContentProvider));
});

final contentCacheStoreProvider = Provider<ContentCacheStore>((ref) {
  return const SharedPreferencesContentCacheStore();
});

final contentCacheRepositoryProvider = Provider<ContentCacheRepository>((ref) {
  return ContentCacheRepository(ref.watch(contentCacheStoreProvider));
});

final savedItemsStoreProvider = Provider<SavedItemsStore>((ref) {
  return const SharedPreferencesSavedItemsStore();
});

final savedItemsRepositoryProvider = Provider<SavedItemsRepository>((ref) {
  return SavedItemsRepository(ref.watch(savedItemsStoreProvider));
});

final savedItemsProvider =
    StateNotifierProvider<SavedItemsController, List<SavedItem>>((ref) {
  final controller = SavedItemsController(
    ref.watch(savedItemsRepositoryProvider),
  );
  unawaited(controller.load());
  return controller;
});

class SavedItemsController extends StateNotifier<List<SavedItem>> {
  SavedItemsController(this.repository) : super(const []);

  final SavedItemsRepository repository;

  Future<void> load() async {
    state = await repository.listSavedItems();
  }

  bool isSaved(SavedItemType itemType, String itemId) {
    return state.any(
      (item) => item.itemType == itemType && item.itemId == itemId,
    );
  }

  Future<void> save(SavedItem item) async {
    await repository.save(item);
    state = await repository.listSavedItems();
  }

  Future<void> remove(SavedItemType itemType, String itemId) async {
    await repository.remove(itemType, itemId);
    state = await repository.listSavedItems();
  }

  Future<bool> toggle(SavedItem item) async {
    final saved = await repository.toggle(item);
    state = await repository.listSavedItems();
    return saved;
  }
}

final sessionProgressStoreProvider = Provider<SessionProgressStore>((ref) {
  return const SharedPreferencesSessionProgressStore();
});

final sessionProgressRepositoryProvider =
    Provider<SessionProgressRepository>((ref) {
  return SessionProgressRepository(ref.watch(sessionProgressStoreProvider));
});

final sessionProgressControllerProvider = StateNotifierProvider<
    SessionProgressController, SessionProgressState>((ref) {
  final controller = SessionProgressController(
    ref.watch(sessionProgressRepositoryProvider),
  );
  unawaited(controller.reload());
  return controller;
});

class SessionProgressState {
  const SessionProgressState({
    this.activeProgress = const {},
    this.completionRecords = const [],
    this.currentStreakDays = 0,
    this.completionCountLast7Days = 0,
  });

  final Map<String, SessionProgress> activeProgress;
  final List<SessionCompletionRecord> completionRecords;
  final int currentStreakDays;
  final int completionCountLast7Days;

  SessionProgress? progressFor(String sessionId) {
    return activeProgress[sessionId];
  }

  SessionCompletionRecord? completionForDate(
    DateTime date, {
    String? sessionId,
  }) {
    final day = _dayKey(date);
    for (final record in completionRecords) {
      if (_dayKey(record.completedAt) == day &&
          (sessionId == null || record.sessionId == sessionId)) {
        return record;
      }
    }
    return null;
  }

  static String _dayKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}

class SessionProgressController extends StateNotifier<SessionProgressState> {
  SessionProgressController(this.repository)
      : super(const SessionProgressState());

  final SessionProgressRepository repository;

  Future<void> reload() async {
    final activeProgress = await repository.listActiveProgress();
    final records = await repository.listCompletionRecords();
    final streak = await repository.currentStreakDays();
    final weekCount = await repository.completionCountLast7Days();
    state = SessionProgressState(
      activeProgress: activeProgress,
      completionRecords: records,
      currentStreakDays: streak,
      completionCountLast7Days: weekCount,
    );
  }

  Future<SessionProgress> startSession(
    DailySession session, {
    required String languageCode,
  }) async {
    final existing = await repository.loadProgress(session.id);
    if (existing != null) {
      await reload();
      return existing;
    }
    final now = DateTime.now();
    final progress = SessionProgress(
      sessionId: session.id,
      currentStepIndex: 0,
      totalSteps: session.steps.length,
      status: SessionProgressStatus.inProgress,
      startedAt: now,
      updatedAt: now,
      languageCode: languageCode,
    );
    await repository.saveProgress(progress);
    await reload();
    return progress;
  }

  Future<void> updateStep(String sessionId, int index) async {
    final progress = await repository.loadProgress(sessionId);
    if (progress == null) {
      return;
    }
    final maxIndex =
        (progress.totalSteps - 1).clamp(0, progress.totalSteps).toInt();
    await repository.saveProgress(
      progress.copyWith(
        currentStepIndex: index.clamp(0, maxIndex).toInt(),
        updatedAt: DateTime.now(),
      ),
    );
    await reload();
  }

  Future<SessionCompletionRecord> completeSession(
    DailySession session, {
    required String languageCode,
  }) async {
    final now = DateTime.now();
    final progress = await repository.loadProgress(session.id);
    final startedAt = progress?.startedAt ?? now;
    final record = SessionCompletionRecord(
      id: '${session.id}_${now.toUtc().toIso8601String()}',
      sessionId: session.id,
      completedAt: now,
      durationSeconds:
          now.difference(startedAt).inSeconds.clamp(0, 86400).toInt(),
      languageCode: languageCode,
      totalSteps: session.steps.length,
    );
    await repository.markCompleted(record);
    await repository.clearProgress(session.id);
    await reload();
    return record;
  }

  Future<void> clearSession(String sessionId) async {
    await repository.clearProgress(sessionId);
    await reload();
  }
}

final privacyDataInventoryProvider =
    Provider<List<PrivacyDataCategory>>((ref) {
  return PrivacyDataInventory.categories;
});

final localDataDeletionServiceProvider = Provider<LocalDataDeletionService>(
  (ref) => LocalDataDeletionService(
    preferencesRepository: ref.watch(userPreferencesRepositoryProvider),
    contentCacheRepository: ref.watch(contentCacheRepositoryProvider),
    savedItemsRepository: ref.watch(savedItemsRepositoryProvider),
    sessionProgressRepository: ref.watch(sessionProgressRepositoryProvider),
    notificationService: ref.watch(notificationServiceProvider),
  ),
);

final contentApiConfigProvider = Provider<ContentApiConfig>((ref) {
  return ContentApiConfig.fromEnvironment();
});

final contentHttpClientProvider = Provider<ContentHttpClient>((ref) {
  final client = DartHttpContentClient();
  ref.onDispose(client.close);
  return client;
});

final remoteManifestClientProvider = Provider<RemoteManifestClient?>((ref) {
  final config = ref.watch(contentApiConfigProvider);
  if (!config.isUsable) {
    return null;
  }
  return HttpRemoteManifestClient(
    config: config,
    httpClient: ref.watch(contentHttpClientProvider),
  );
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ref.watch(contentServiceProvider);
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return StubAnalyticsService();
});

final prayerCalculationServiceProvider = Provider<PrayerCalculationService>(
  (ref) => PrayerCalculationService(),
);

final qiblaServiceProvider = Provider<QiblaService>((ref) => QiblaService());

enum NotificationPermissionFeedback { denied, scheduled }

final notificationPermissionFeedbackProvider =
    StateProvider<NotificationPermissionFeedback?>((ref) => null);

final notificationTapResultProvider =
    StateProvider<NotificationTapResult?>((ref) => null);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => FlutterLocalNotificationService(
    onNotificationTap: (payload) async {
      final result =
          await ref.read(notificationTapServiceProvider).resolveRawPayload(
                payload,
              );
      ref.read(notificationTapResultProvider.notifier).state = result;
    },
  ),
);

final contentServiceProvider = Provider<ContentService>((ref) {
  final remoteClient = ref.watch(remoteManifestClientProvider);
  final languageCode = ref.watch(localeProvider).languageCode;
  final context = ContentRequestContext(
    languageCode: languageCode,
    market: 'global',
    appVersion: '0.1.0',
    womenIbadahMode: UserPreferences.defaults().womenIbadahMode,
  );
  final service = ContentService(
    seedRepository: ref.watch(seedContentRepositoryProvider),
    cacheRepository: ref.watch(contentCacheRepositoryProvider),
    remoteClient: remoteClient,
    defaultContext: context,
  );
  unawaited(() async {
    await service.restoreCachedContent();
    if (remoteClient != null) {
      await service.refreshRemoteContent(context);
    }
  }());
  return service;
});

final localPushReceiverProvider = Provider<LocalPushReceiver>((ref) {
  return LocalPushReceiver(contentService: ref.watch(contentServiceProvider));
});

final notificationTapServiceProvider = Provider<NotificationTapService>((ref) {
  return NotificationTapService(
    localPushReceiver: ref.watch(localPushReceiverProvider),
  );
});

final pushCandidateSelectorProvider = Provider<PushCandidateSelector>(
  (ref) => PushCandidateSelector(),
);

final audioPolicyServiceProvider = Provider<AudioPolicyService>(
  (ref) => const AudioPolicyService(),
);

final audioPlayerProvider = Provider<SakinahAudioPlayer>(
  (ref) {
    final player = JustAudioSakinahPlayer();
    ref.onDispose(player.dispose);
    return player;
  },
);

final dailySessionsProvider = Provider<List<DailySession>>((ref) {
  return ref.watch(contentRepositoryProvider).getDailySessions();
});

final duasProvider = Provider<List<DuaItem>>((ref) {
  return ref.watch(contentRepositoryProvider).getDuas();
});

final dhikrsProvider = Provider<List<DhikrItem>>((ref) {
  return ref.watch(contentRepositoryProvider).getDhikrs();
});
