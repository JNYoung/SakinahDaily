import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
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

    expect(
      find.text('Stored locally. No GPS permission is required.'),
      findsOneWidget,
    );

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
    expect(find.text('Manual prayer location'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  test('AndroidManifest has no location or sensor permission', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
    expect(manifest, isNot(contains('ACCESS_COARSE_LOCATION')));
    expect(manifest, isNot(contains('BODY_SENSORS')));
  });
}
