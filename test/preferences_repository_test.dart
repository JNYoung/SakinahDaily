import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';

void main() {
  test('preferences save and load all user choices', () async {
    final store = InMemoryUserPreferencesStore();
    final repository = UserPreferencesRepository(store);
    const saved = UserPreferences(
      languageCode: 'id',
      genderMode: GenderMode.female,
      audioPreference: AudioPreference.quietGuidance,
      hasCompletedOnboarding: true,
      notificationsEnabled: true,
      dailySessionReminderEnabled: true,
      dailySessionReminderMinutesAfterMidnight: 21 * 60 + 15,
      completedClosedTestingPromptDays: ['day1', 'day3', 'day7'],
      analyticsOptIn: true,
      prayerSettings: PrayerSettings(
        latitude: -6.2088,
        longitude: 106.8456,
        method: 'indonesia',
        locationLabel: 'Jakarta',
        timezoneId: 'Asia/Jakarta',
      ),
      womenIbadahMode: WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.pregnancy,
        discreetModeEnabled: true,
      ),
    );

    await repository.save(saved);

    final loaded = await repository.load();
    expect(loaded.languageCode, 'id');
    expect(loaded.genderMode, GenderMode.female);
    expect(loaded.audioPreference, AudioPreference.quietGuidance);
    expect(loaded.hasCompletedOnboarding, isTrue);
    expect(loaded.notificationsEnabled, isTrue);
    expect(loaded.dailySessionReminderEnabled, isTrue);
    expect(loaded.dailySessionReminderMinutesAfterMidnight, 21 * 60 + 15);
    expect(loaded.completedClosedTestingPromptDays, ['day1', 'day3', 'day7']);
    expect(loaded.analyticsOptIn, isTrue);
    expect(loaded.prayerSettings.method, 'indonesia');
    expect(loaded.prayerSettings.locationLabel, 'Jakarta');
    expect(loaded.prayerSettings.timezoneId, 'Asia/Jakarta');
    expect(loaded.womenIbadahMode.enabled, isTrue);
    expect(loaded.womenIbadahMode.status, WomenIbadahStatus.pregnancy);
    expect(loaded.womenIbadahMode.localOnly, isTrue);
    expect(loaded.womenIbadahMode.discreetModeEnabled, isTrue);
  });

  test('onboarding completion defaults to false until setup is finished',
      () async {
    final repository =
        UserPreferencesRepository(InMemoryUserPreferencesStore());

    final loaded = await repository.load();

    expect(loaded.hasCompletedOnboarding, isFalse);
  });

  test('legacy saved preferences count as completed onboarding', () async {
    final store = InMemoryUserPreferencesStore();
    final repository = UserPreferencesRepository(store);
    await store.write(repository.storageKey, '{"languageCode":"en"}');

    final loaded = await repository.load();

    expect(loaded.hasCompletedOnboarding, isTrue);
  });

  test('preferences reset returns defaults and disables women mode', () async {
    final store = InMemoryUserPreferencesStore();
    final repository = UserPreferencesRepository(store);
    await repository.save(
      UserPreferences.defaults().copyWith(
        languageCode: 'ar',
        hasCompletedOnboarding: true,
        notificationsEnabled: true,
        dailySessionReminderEnabled: true,
        dailySessionReminderMinutesAfterMidnight: 6 * 60 + 30,
        analyticsOptIn: true,
        womenIbadahMode: const WomenIbadahMode(
          enabled: true,
          status: WomenIbadahStatus.menstruating,
        ),
      ),
    );

    await repository.reset();

    final loaded = await repository.load();
    expect(loaded.languageCode, 'en');
    expect(loaded.hasCompletedOnboarding, isFalse);
    expect(loaded.notificationsEnabled, isFalse);
    expect(loaded.dailySessionReminderEnabled, isFalse);
    expect(loaded.dailySessionReminderMinutesAfterMidnight, 20 * 60);
    expect(loaded.completedClosedTestingPromptDays, isEmpty);
    expect(loaded.analyticsOptIn, isFalse);
    expect(loaded.womenIbadahMode.enabled, isFalse);
    expect(loaded.womenIbadahMode.discreetModeEnabled, isFalse);
  });

  test('locale is restored after a fake app restart', () async {
    final store = InMemoryUserPreferencesStore();
    final firstContainer = ProviderContainer(
      overrides: [userPreferencesStoreProvider.overrideWithValue(store)],
    );
    addTearDown(firstContainer.dispose);

    await firstContainer
        .read(userPreferencesProvider.notifier)
        .setLanguage('ar');
    expect(firstContainer.read(localeProvider), const Locale('ar'));

    final restartedContainer = ProviderContainer(
      overrides: [userPreferencesStoreProvider.overrideWithValue(store)],
    );
    addTearDown(restartedContainer.dispose);
    await restartedContainer.read(userPreferencesProvider.notifier).load();

    expect(restartedContainer.read(userPreferencesProvider).languageCode, 'ar');
    expect(restartedContainer.read(localeProvider), const Locale('ar'));
  });
}
