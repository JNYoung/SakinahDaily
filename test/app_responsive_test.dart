import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';
import 'package:sakinah_daily/shared/widgets/sakinah_scroll_behavior.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  final viewports = {
    'mobile': mobileViewport,
    'tablet': tabletViewport,
    'desktop': desktopViewport,
  };

  for (final entry in viewports.entries) {
    testWidgets('onboarding and home adapt on ${entry.key}', (tester) async {
      await pumpSakinahApp(tester, viewport: entry.value);

      expect(find.text('Begin with calm worship'), findsOneWidget);
      expect(find.byKey(SakinahKeys.onboardingContinueButton), findsOneWidget);
      expectNoFlutterErrors(tester);

      await continueToHome(tester);

      expect(find.text("Today's Sakinah Session"), findsOneWidget);
      expect(find.byKey(SakinahKeys.homeSessionStartButton), findsOneWidget);
      expectNoFlutterErrors(tester);
    });
  }

  testWidgets('home scroll does not stretch at vertical edges', (tester) async {
    await pumpSakinahApp(tester, viewport: mobileViewport);
    await continueToHome(tester);

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).scrollBehavior,
      isA<SakinahScrollBehavior>(),
    );

    final homeList = find.byKey(SakinahKeys.homeContentList);
    expect(homeList, findsOneWidget);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);

    await tester.drag(homeList, const Offset(0, 260));
    await tester.pumpAndSettle();

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('prayer scroll does not stretch at vertical edges',
      (tester) async {
    await pumpSakinahApp(tester, viewport: mobileViewport);
    await continueToHome(tester);
    await tapByKey(tester, SakinahKeys.homePrayerBadge);

    final prayerList = find.byKey(SakinahKeys.prayerContentList);
    expect(prayerList, findsOneWidget);
    expect(find.byType(StretchingOverscrollIndicator), findsNothing);

    await tester.drag(prayerList, const Offset(0, 260));
    await tester.pumpAndSettle();

    expect(find.byType(StretchingOverscrollIndicator), findsNothing);
    expectNoFlutterErrors(tester);
  });
}
