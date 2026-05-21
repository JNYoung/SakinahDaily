import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

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
}
