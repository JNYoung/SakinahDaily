import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sakinah_models.dart';
import '../repositories/content_repository.dart';
import '../services/analytics_service.dart';
import '../services/content_service.dart';
import '../services/notification_service.dart';
import '../services/prayer_calculation_service.dart';
import '../services/push_candidate_selector.dart';

final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesController, UserPreferences>(
  (ref) => UserPreferencesController(ref),
);

class UserPreferencesController extends StateNotifier<UserPreferences> {
  UserPreferencesController(this.ref) : super(UserPreferences.defaults());

  final Ref ref;

  void setLanguage(String languageCode) {
    state = state.copyWith(languageCode: languageCode);
    ref.read(localeProvider.notifier).state = Locale(languageCode);
  }

  void setGenderMode(GenderMode mode) {
    state = state.copyWith(genderMode: mode);
  }

  void setAudioPreference(AudioPreference preference) {
    state = state.copyWith(audioPreference: preference);
  }

  void setNotificationsEnabled(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
  }

  void setWomenMode(bool enabled) {
    state = state.copyWith(
      womenIbadahMode: state.womenIbadahMode.copyWith(enabled: enabled),
    );
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
  (ref) => LocalNotificationServiceStub(),
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
