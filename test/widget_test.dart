import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
