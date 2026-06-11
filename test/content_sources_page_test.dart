import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Settings opens Content Sources trust page', (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsContentSourcesTile);

    expect(find.byKey(SakinahKeys.contentSourcesPage), findsOneWidget);
    expect(find.text('Content Sources'), findsWidgets);
    expect(find.text('Reviewed seed and approved bundles'), findsOneWidget);
    expect(find.text('Published + approved only'), findsOneWidget);
    expect(find.text('Not generated'), findsOneWidget);
    expect(find.text('No AI fatwa or religious Q&A'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Content Sources page is localized in English Indonesian Arabic',
      (tester) async {
    final cases = [
      (
        languageCode: 'en',
        title: 'Content Sources',
        seedTitle: 'Reviewed seed and approved bundles',
        generatedTitle: 'Not generated',
      ),
      (
        languageCode: 'id',
        title: 'Sumber Konten',
        seedTitle: 'Seed yang ditinjau dan bundle yang disetujui',
        generatedTitle: 'Tidak dibuat otomatis',
      ),
      (
        languageCode: 'ar',
        title: 'مصادر المحتوى',
        seedTitle: 'محتوى مبدئي مراجع وحزم معتمدة',
        generatedTitle: 'غير مولد',
      ),
    ];

    for (final entry in cases) {
      await pumpSakinahApp(
        tester,
        settleSplash: false,
        appEnvironmentConfig: AppEnvironmentConfig.fromMap({
          'SAKINAH_APP_ENV': 'dev',
          'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
          'SAKINAH_STORE_SCREENSHOT_LOCALE': entry.languageCode,
          'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings/content-sources',
        }),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(SakinahKeys.contentSourcesPage), findsOneWidget);
      expect(find.text(entry.title), findsWidgets);
      expect(find.text(entry.seedTitle), findsOneWidget);
      expect(find.text(entry.generatedTitle), findsOneWidget);
      if (entry.languageCode != 'en') {
        expect(find.text('Content Sources'), findsNothing);
        expect(find.text('Not generated'), findsNothing);
      }
      expectNoFlutterErrors(tester);
    }
  });
}
