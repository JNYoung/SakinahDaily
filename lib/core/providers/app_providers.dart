import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sakinah_models.dart';
import '../repositories/content_repository.dart';
import '../repositories/user_preferences_repository.dart';
import '../services/analytics_service.dart';
import '../services/content_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_calculation_service.dart';
import '../services/push_candidate_selector.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

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
    await _commit(
      state.copyWith(
        womenIbadahMode: state.womenIbadahMode.copyWith(enabled: enabled),
      ),
    );
  }

  Future<void> saveCurrent() async {
    await repository.save(state);
  }

  Future<void> _commit(UserPreferences preferences) async {
    _hasLocalChanges = true;
    state = preferences;
    ref.read(localeProvider.notifier).state = Locale(preferences.languageCode);
    await repository.save(preferences);
  }
}

final seedContentProvider = Provider<SeedContent>((ref) => SeedContent.demo());

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return SeedContentRepository(ref.watch(seedContentProvider));
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return StubAnalyticsService();
});

final prayerCalculationServiceProvider = Provider<PrayerCalculationService>(
  (ref) => PrayerCalculationService(),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => FlutterLocalNotificationService(),
);

final contentServiceProvider = Provider<ContentService>((ref) {
  return ContentService(
    seedRepository: ref.watch(contentRepositoryProvider),
    cache: InMemoryContentCache(),
  );
});

final pushCandidateSelectorProvider = Provider<PushCandidateSelector>(
  (ref) => PushCandidateSelector(),
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
