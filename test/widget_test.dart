import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('app renders onboarding and reaches home', (tester) async {
    await pumpSakinahApp(tester);

    expect(find.text('Sakinah Daily'), findsOneWidget);
    expect(find.text('Begin with calm worship'), findsOneWidget);

    await continueToHome(tester);

    expect(find.text('Assalamu alaikum,'), findsOneWidget);
    expect(find.text("Today's Sakinah Session"), findsOneWidget);
  });

  testWidgets('onboarding sets preset prayer location without GPS permission',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();

    await pumpSakinahApp(tester, preferencesStore: preferencesStore);

    expect(
      find.text('Prayer times and Qibla use this local prayer location.'),
      findsOneWidget,
    );
    expect(
        find.text('No GPS permission is requested in v0.1.'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.onboardingPrayerLocationDropdown);
    await tester.tap(find.text('Jakarta').last);
    await tester.pumpAndSettle();

    await continueToHome(tester);

    expect(find.text('Prayer location · Jakarta'), findsOneWidget);
    expect(find.text('Prayer method · KEMENAG Indonesia'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Arabic locale uses RTL directionality', (tester) async {
    await pumpSakinahApp(tester, languageCode: 'ar');

    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text('ابدأ بعبادة هادئة'),
            matching: find.byType(Directionality),
          )
          .first,
    );

    expect(directionality.textDirection, TextDirection.rtl);
  });
}
