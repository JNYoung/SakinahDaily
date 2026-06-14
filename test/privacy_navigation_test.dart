import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/config/content_api_config.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
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
    expect(
      find.text(
        "Women’s Ibadah Mode is designed local-first. Exact status is not sent with remote content requests.",
      ),
      findsOneWidget,
    );
    expect(find.text('Prayer location privacy'), findsOneWidget);
    expect(
      find.text(
        'Prayer location uses manual or preset choices by default for prayer time calculation.',
      ),
      findsOneWidget,
    );
    expect(find.text('Notifications privacy'), findsOneWidget);
    await scrollUntilFound(tester, find.text('Remote content cache'));
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
    expect(
        find.textContaining('secret-token-that-must-not-render'), findsNothing);
  });

  testWidgets('Privacy Center disables analytics control in default builds',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.privacyAnalyticsSwitch),
    );
    final analyticsSwitch = tester.widget<Switch>(
      find.byKey(SakinahKeys.privacyAnalyticsSwitch),
    );

    expect(analyticsSwitch.value, isFalse);
    expect(analyticsSwitch.onChanged, isNull);
    expect(find.text('Analytics collection is off in this build.'),
        findsOneWidget);
  });

  testWidgets('Privacy Center stores analytics opt-in when build allows it',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final preferencesRepository = UserPreferencesRepository(preferencesStore);

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy',
      settleSplash: false,
      preferencesStore: preferencesStore,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_ANALYTICS_ENABLED': 'true',
        },
      ),
    );
    await tester.pumpAndSettle();

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.privacyAnalyticsSwitch),
    );
    await tester.tap(find.byKey(SakinahKeys.privacyAnalyticsSwitch));
    await tester.pumpAndSettle();

    final analyticsSwitch = tester.widget<Switch>(
      find.byKey(SakinahKeys.privacyAnalyticsSwitch),
    );
    expect(analyticsSwitch.value, isTrue);
    expect((await preferencesRepository.load()).analyticsOptIn, isTrue);
  });

  testWidgets('Privacy Center records analytics consent changes safely',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final preferencesRepository = UserPreferencesRepository(preferencesStore);
    final analytics = StubAnalyticsService(enabled: true);

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy',
      settleSplash: false,
      preferencesStore: preferencesStore,
      analyticsService: analytics,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_ANALYTICS_ENABLED': 'true',
        },
      ),
    );
    await tester.pumpAndSettle();

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.privacyAnalyticsSwitch),
    );
    await tester.tap(find.byKey(SakinahKeys.privacyAnalyticsSwitch));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SakinahKeys.privacyAnalyticsSwitch));
    await tester.pumpAndSettle();

    expect((await preferencesRepository.load()).analyticsOptIn, isFalse);
    expect(
      analytics.events.map((event) => event.name),
      [
        AnalyticsEventCatalog.analyticsConsentChanged,
        AnalyticsEventCatalog.analyticsConsentChanged,
      ],
    );
    expect(analytics.events.first.properties, {
      'enabled': true,
      'source': 'privacy_center',
    });
    expect(analytics.events.last.properties, {
      'enabled': false,
      'source': 'privacy_center',
    });
  });

  testWidgets('Privacy Center shows and copies configured public policy URL',
      (tester) async {
    final copiedValues = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        copiedValues.add(data['text'] as String);
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy',
      settleSplash: false,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PRIVACY_POLICY_URL': 'https://sakinahdaily.app/privacy',
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.privacyCenterPage), findsOneWidget);
    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.privacyPolicyLinkTile),
    );
    expect(find.text('Published privacy policy'), findsOneWidget);
    expect(find.text('https://sakinahdaily.app/privacy'), findsOneWidget);
    expect(find.text('Privacy policy draft'), findsNothing);

    await tapByKey(tester, SakinahKeys.privacyPolicyLinkTile);

    expect(copiedValues, contains('https://sakinahdaily.app/privacy'));
    expect(find.text('Privacy policy link copied.'), findsOneWidget);
  });

  testWidgets('Privacy Center rejects placeholder privacy policy URLs',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/privacy',
      settleSplash: false,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PRIVACY_POLICY_URL': 'https://example.com/privacy',
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.privacyCenterPage), findsOneWidget);
    await scrollUntilFound(tester, find.text('Privacy policy draft'));
    expect(find.text('Privacy policy draft'), findsOneWidget);
    expect(find.textContaining('example.com'), findsNothing);
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
      savedItemsStore: InMemorySavedItemsStore(),
      notificationService: notifications,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.deleteLocalDataButton);
    expect(find.text('Konfirmasi reset lokal'), findsOneWidget);
    expect(
        (await preferencesRepository.load()).womenIbadahMode.enabled, isTrue);

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Hapus data lokal'),
      ),
    );
    await tester.pumpAndSettle();

    final resetPreferences = await preferencesRepository.load();
    await scrollUntilFound(
      tester,
      find.text('Local data has been reset on this device.'),
    );
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
