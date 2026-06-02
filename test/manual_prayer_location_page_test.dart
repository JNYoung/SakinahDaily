import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/backend_api_config.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/remote_content_api_client.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/fake_content_http_client.dart';
import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('city preset fills coordinates timezone and method',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining(
        'Prayer times need both city coordinates and timezone.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(SakinahKeys.manualLocationPresetDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Jakarta').last);
    await tester.pumpAndSettle();

    expect(find.text('-6.2088'), findsOneWidget);
    expect(find.text('106.8456'), findsOneWidget);
    expect(find.text('Asia/Jakarta'), findsOneWidget);
    expect(find.text('KEMENAG Indonesia'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.manualLocationSaveButton);

    final preferences = await UserPreferencesRepository(store).load();
    expect(preferences.prayerSettings.locationLabel, 'Jakarta');
    expect(preferences.prayerSettings.latitude, -6.2088);
    expect(preferences.prayerSettings.longitude, 106.8456);
    expect(preferences.prayerSettings.timezoneId, 'Asia/Jakarta');
    expect(preferences.prayerSettings.method, 'indonesia');
    expect(preferences.prayerSettings.locationMode.name, 'preset');
    expectNoFlutterErrors(tester);
  });

  testWidgets('backend city catalog fills dropdown for API integration',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    final http = FakeContentHttpClient({
      _backendCitiesUri().toString():
          ContentHttpResponse.ok(_backendCitiesJson()),
    });
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
      preferencesStore: store,
      backendApiConfig: BackendApiConfig(
        enabled: true,
        baseUri: Uri.parse('https://backend.example.test'),
      ),
      contentHttpClient: http,
    );
    await tester.pumpAndSettle();

    expect(http.requests.single.uri, _backendCitiesUri());

    await tester.tap(find.byKey(SakinahKeys.manualLocationPresetDropdown));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makassar').last);
    await tester.pumpAndSettle();

    expect(find.text('-5.1477'), findsOneWidget);
    expect(find.text('119.4327'), findsOneWidget);
    expect(find.text('Asia/Makassar'), findsOneWidget);
    expect(find.text('KEMENAG Indonesia'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.manualLocationSaveButton);

    final preferences = await UserPreferencesRepository(store).load();
    expect(preferences.prayerSettings.locationLabel, 'Makassar');
    expect(preferences.prayerSettings.latitude, -5.1477);
    expect(preferences.prayerSettings.longitude, 119.4327);
    expect(preferences.prayerSettings.timezoneId, 'Asia/Makassar');
    expect(preferences.prayerSettings.method, 'indonesia');
    expect(preferences.prayerSettings.locationMode.name, 'preset');
    expectNoFlutterErrors(tester);
  });

  testWidgets('manual prayer location page saves valid coordinates',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SakinahKeys.manualLocationLabelField),
      'Jakarta Selatan',
    );
    await tester.enterText(
      find.byKey(SakinahKeys.manualLatitudeField),
      '-6.2088',
    );
    await tester.enterText(
      find.byKey(SakinahKeys.manualLongitudeField),
      '106.8456',
    );
    await tester.enterText(
      find.byKey(SakinahKeys.manualTimezoneField),
      'Asia/Jakarta',
    );
    await tapByKey(tester, SakinahKeys.manualLocationSaveButton);

    expect(find.text('Location saved'), findsOneWidget);
    final preferences = await UserPreferencesRepository(store).load();
    expect(preferences.prayerSettings.locationLabel, 'Jakarta Selatan');
    expect(preferences.prayerSettings.latitude, -6.2088);
    expect(preferences.prayerSettings.longitude, 106.8456);
    expect(preferences.prayerSettings.timezoneId, 'Asia/Jakarta');
    expectNoFlutterErrors(tester);
  });

  testWidgets('manual prayer location page rejects invalid coordinates',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SakinahKeys.manualLocationLabelField),
      'Nowhere',
    );
    await tester.enterText(find.byKey(SakinahKeys.manualLatitudeField), '91');
    await tester.enterText(find.byKey(SakinahKeys.manualLongitudeField), '181');
    await tapByKey(tester, SakinahKeys.manualLocationSaveButton);

    expect(find.text('Latitude must be between -90 and 90.'), findsOneWidget);
    expect(
        find.text('Longitude must be between -180 and 180.'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Qibla page uses updated manual location', (tester) async {
    final store = InMemoryUserPreferencesStore();
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(SakinahKeys.manualLocationLabelField),
      'Jakarta Selatan',
    );
    await tester.enterText(
      find.byKey(SakinahKeys.manualLatitudeField),
      '-6.2088',
    );
    await tester.enterText(
      find.byKey(SakinahKeys.manualLongitudeField),
      '106.8456',
    );
    await tapByKey(tester, SakinahKeys.manualLocationSaveButton);

    await pumpSakinahApp(
      tester,
      initialLocation: '/qibla',
      settleSplash: false,
      preferencesStore: store,
    );
    await tester.pumpAndSettle();

    expect(find.text('Jakarta Selatan'), findsOneWidget);
    expect(find.textContaining('295'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('settings prayer location tile opens manual page',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsPrayerLocationTile);

    expect(find.byKey(SakinahKeys.manualPrayerLocationPage), findsOneWidget);
    expect(find.text('Prayer location'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  test(
      'AndroidManifest has foreground coarse location without sensor permission',
      () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, contains('ACCESS_COARSE_LOCATION'));
    expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
    expect(manifest, isNot(contains('ACCESS_BACKGROUND_LOCATION')));
    expect(manifest, isNot(contains('FOREGROUND_SERVICE_LOCATION')));
    expect(manifest, isNot(contains('BODY_SENSORS')));
  });
}

Uri _backendCitiesUri() {
  return Uri.parse('https://backend.example.test/locations/cities').replace(
    queryParameters: const {
      'locale': 'en',
      'limit': '50',
    },
  );
}

String _backendCitiesJson() {
  return jsonEncode({
    'results': [
      {
        'id': 'id-makassar',
        'label': 'Makassar',
        'countryCode': 'ID',
        'countryName': 'Indonesia',
        'coordinates': {
          'latitude': -5.1477,
          'longitude': 119.4327,
        },
        'timezone': 'Asia/Makassar',
        'prayerCalculationMethod': 'indonesia',
        'source': 'mvp_curated_city_catalog',
      },
    ],
  });
}
