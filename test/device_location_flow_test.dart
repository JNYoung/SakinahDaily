import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/device_location_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('onboarding explains and saves device prayer location',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    final deviceLocation = FakeDeviceLocationService(
      const DeviceLocationRequestResult.granted(
        DevicePrayerLocation(
          latitude: 24.7136,
          longitude: 46.6753,
          approximate: true,
        ),
      ),
    );

    await pumpSakinahApp(
      tester,
      preferencesStore: store,
      deviceLocationService: deviceLocation,
    );

    expect(
      find.text('Sakinah uses your device location only to calculate prayer '
          'times and Qibla. If permission is denied, you can enter the '
          'location manually.'),
      findsOneWidget,
    );

    await tapByKey(tester, SakinahKeys.onboardingUseDeviceLocationButton);

    expect(deviceLocation.requestCount, 1);
    expect(find.text('Device location saved'), findsOneWidget);
    final preferences = await UserPreferencesRepository(store).load();
    expect(preferences.prayerSettings.locationMode, PrayerLocationMode.device);
    expect(preferences.prayerSettings.locationLabel, 'Device location');
    expect(preferences.prayerSettings.latitude, 24.7136);
    expect(preferences.prayerSettings.longitude, 46.6753);
    expect(preferences.prayerSettings.timezoneId, isNull);
    expectNoFlutterErrors(tester);
  });

  testWidgets('manual page saves device location from permission CTA',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    final deviceLocation = FakeDeviceLocationService(
      const DeviceLocationRequestResult.granted(
        DevicePrayerLocation(
          latitude: -6.2088,
          longitude: 106.8456,
          approximate: true,
        ),
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
      preferencesStore: store,
      deviceLocationService: deviceLocation,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.manualUseDeviceLocationButton);

    expect(deviceLocation.requestCount, 1);
    expect(find.text('Device location saved'), findsOneWidget);
    final preferences = await UserPreferencesRepository(store).load();
    expect(preferences.prayerSettings.locationMode, PrayerLocationMode.device);
    expect(preferences.prayerSettings.locationLabel, 'Device location');
    expect(preferences.prayerSettings.latitude, -6.2088);
    expect(preferences.prayerSettings.longitude, 106.8456);
    expectNoFlutterErrors(tester);
  });

  testWidgets('denied device location keeps manual fallback available',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    final deviceLocation = FakeDeviceLocationService(
      const DeviceLocationRequestResult.permissionDenied(),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/prayer-location',
      settleSplash: false,
      preferencesStore: store,
      deviceLocationService: deviceLocation,
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.manualUseDeviceLocationButton);

    expect(
      find.text('Location permission was denied. Enter location manually '
          'instead.'),
      findsOneWidget,
    );
    expect(find.byKey(SakinahKeys.manualLocationLabelField), findsOneWidget);
    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.manualLocationSaveButton),
    );
    expect(find.byKey(SakinahKeys.manualLocationSaveButton), findsOneWidget);
    final preferences = await UserPreferencesRepository(store).load();
    expect(preferences.prayerSettings.locationMode, PrayerLocationMode.preset);
    expect(preferences.prayerSettings.locationLabel, 'Makkah');
    expectNoFlutterErrors(tester);
  });
}

class FakeDeviceLocationService implements DeviceLocationService {
  FakeDeviceLocationService(this.result);

  final DeviceLocationRequestResult result;
  int requestCount = 0;

  @override
  Future<DeviceLocationRequestResult> requestCurrentPrayerLocation() async {
    requestCount += 1;
    return result;
  }
}
