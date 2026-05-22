import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Qibla page renders selected prayer location', (tester) async {
    final store = InMemoryUserPreferencesStore();
    await UserPreferencesRepository(store).save(
      UserPreferences.defaults().copyWith(
        prayerSettings: const PrayerSettings(
          latitude: -6.2088,
          longitude: 106.8456,
          method: 'indonesia',
          locationLabel: 'Jakarta',
          timezoneId: 'Asia/Jakarta',
        ),
      ),
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/qibla',
      settleSplash: false,
      preferencesStore: store,
    );

    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.qiblaPage), findsOneWidget);
    expect(find.text('Jakarta'), findsOneWidget);
    expect(find.textContaining('Exact GPS is not required'), findsOneWidget);
    expect(find.textContaining('295'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Home Qibla quick action opens Qibla page', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.homeQuickActionQibla);

    expect(find.byKey(SakinahKeys.qiblaPage), findsOneWidget);
    expect(find.text('Qibla'), findsWidgets);
    expectNoFlutterErrors(tester);
  });

  test('AndroidManifest does not request exact or coarse location', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

    expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
    expect(manifest, isNot(contains('ACCESS_COARSE_LOCATION')));
  });
}
