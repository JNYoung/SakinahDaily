import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/content_api_config.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Settings Privacy tile opens Privacy Center', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsPrivacyTile);

    expect(find.byKey(SakinahKeys.privacyCenterPage), findsOneWidget);
    expect(find.text("Women's Ibadah Mode privacy"), findsOneWidget);
    expect(find.text('Prayer location privacy'), findsOneWidget);
    expect(find.text('Notifications privacy'), findsOneWidget);
    expect(find.text('Remote content cache'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Privacy Center never renders the content API token',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy',
      settleSplash: false,
      contentApiConfig: ContentApiConfig(
        enabled: false,
        provider: 'generic',
        baseUri: Uri.parse('https://content.example.test'),
        token: 'secret-token-that-must-not-render',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.privacyCenterPage), findsOneWidget);
    expect(find.textContaining('secret-token-that-must-not-render'),
        findsNothing);
  });

  testWidgets('Delete local data page requires confirmation and resets state',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final preferencesRepository = UserPreferencesRepository(preferencesStore);
    await preferencesRepository.save(
      UserPreferences.defaults().copyWith(
        languageCode: 'id',
        notificationsEnabled: true,
        womenIbadahMode: const WomenIbadahMode(
          enabled: true,
          status: WomenIbadahStatus.pregnancy,
        ),
      ),
    );
    final cacheStore = InMemoryContentCacheStore();
    final cacheRepository = ContentCacheRepository(cacheStore);
    await cacheRepository.saveActiveManifest(
      const ContentManifest(
        id: 'manifest_fixture',
        schemaVersion: 1,
        bundles: [],
      ),
    );
    final notifications = LocalNotificationServiceStub();
    notifications.scheduled.add(
      ScheduledPrayerReminder(
        prayerName: 'Fajr',
        time: DateTime(2026, 5, 22, 5),
        settings: UserPreferences.defaults().prayerSettings,
        title: 'Sakinah Daily',
        body: 'Local reminder',
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy/delete-local-data',
      settleSplash: false,
      preferencesStore: preferencesStore,
      contentCacheStore: cacheStore,
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.deleteLocalDataButton);
    expect(find.text('Confirm local reset'), findsOneWidget);
    expect((await preferencesRepository.load()).womenIbadahMode.enabled,
        isTrue);

    await tester.tap(find.text('Delete local data').last);
    await tester.pumpAndSettle();

    final resetPreferences = await preferencesRepository.load();
    expect(
      find.text('Local data has been reset on this device.'),
      findsOneWidget,
    );
    expect(resetPreferences.languageCode, 'en');
    expect(resetPreferences.womenIbadahMode.enabled, isFalse);
    expect(await cacheRepository.loadActiveManifest(), isNull);
    expect(notifications.scheduled, isEmpty);
  });

  testWidgets('privacy pages render in English Indonesian and Arabic',
      (tester) async {
    const routes = [
      '/settings/privacy',
      '/settings/privacy/data',
      '/settings/privacy/delete-local-data',
    ];
    const languages = ['en', 'id', 'ar'];

    for (final route in routes) {
      for (final languageCode in languages) {
        final store = InMemoryUserPreferencesStore();
        await UserPreferencesRepository(store).save(
          UserPreferences.defaults().copyWith(languageCode: languageCode),
        );

        await pumpSakinahApp(
          tester,
          initialLocation: route,
          settleSplash: false,
          preferencesStore: store,
        );
        await tester.pumpAndSettle();

        expect(find.byKey(_pageKeyFor(route)), findsOneWidget);
        expectNoFlutterErrors(tester);
      }
    }
  });
}

Key _pageKeyFor(String route) {
  return switch (route) {
    '/settings/privacy/data' => SakinahKeys.privacyDataInventoryPage,
    '/settings/privacy/delete-local-data' => SakinahKeys.deleteLocalDataPage,
    _ => SakinahKeys.privacyCenterPage,
  };
}
