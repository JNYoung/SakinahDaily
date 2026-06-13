import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('splash page matches saved opening screen and enters onboarding',
      (tester) async {
    await pumpSakinahApp(tester, settleSplash: false);

    expect(find.byKey(SakinahKeys.splashPage), findsOneWidget);
    expect(find.byKey(SakinahKeys.splashBrand), findsOneWidget);
    expect(find.text('Sakinah\nDaily'), findsOneWidget);
    expect(find.text('Calm for the heart,\nremembrance for the day'),
        findsOneWidget);
    expect(find.text('سكينة يومية'), findsOneWidget);
    expect(
        find.text('QURAN   ·   DUA   ·   DHIKR   ·   PRAYER'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    expect(find.text('Begin with calm worship'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('splash opens home when onboarding has completed',
      (tester) async {
    final store = InMemoryUserPreferencesStore();
    final repository = UserPreferencesRepository(store);
    await repository.save(
      UserPreferences.defaults().copyWith(hasCompletedOnboarding: true),
    );

    await pumpSakinahApp(
      tester,
      preferencesStore: store,
      settleSplash: false,
    );

    expect(find.byKey(SakinahKeys.splashPage), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2200));
    await tester.pumpAndSettle();

    expect(find.text('Assalamu alaikum,'), findsOneWidget);
    expect(find.text('Begin with calm worship'), findsNothing);
    expectNoFlutterErrors(tester);
  });
}
