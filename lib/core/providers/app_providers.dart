import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_environment.dart';
import '../config/content_api_config.dart';
import '../models/sakinah_models.dart';
import '../privacy/local_data_deletion_service.dart';
import '../privacy/privacy_data_inventory.dart';
import '../repositories/content_cache_repository.dart';
import '../repositories/content_repository.dart';
import '../repositories/user_preferences_repository.dart';
import '../services/analytics_service.dart';
import '../services/audio_player_service.dart';
import '../services/audio_policy_service.dart';
import '../services/content_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_calculation_service.dart';
import '../services/push_candidate_selector.dart';
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

final privacyDataInventoryProvider =
    Provider<List<PrivacyDataCategory>>((ref) {
  return PrivacyDataInventory.categories;
});

final localDataDeletionServiceProvider = Provider<LocalDataDeletionService>(
  (ref) => LocalDataDeletionService(
    preferencesRepository: ref.watch(userPreferencesRepositoryProvider),
    contentCacheRepository: ref.watch(contentCacheRepositoryProvider),
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

enum NotificationPermissionFeedback { denied, scheduled }

final notificationPermissionFeedbackProvider =
    StateProvider<NotificationPermissionFeedback?>((ref) => null);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => FlutterLocalNotificationService(),
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
