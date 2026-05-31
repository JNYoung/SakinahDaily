import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/content_api_config.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Settings opens Content Sources transparency page',
      (tester) async {
    await pumpSakinahApp(tester);
    await continueToHome(tester);

    await tapByKey(tester, SakinahKeys.bottomNavSettings);
    await tapByKey(tester, SakinahKeys.settingsContentSourcesTile);

    expect(find.byKey(SakinahKeys.contentSourcesPage), findsOneWidget);
    expect(find.text('Content Sources'), findsWidgets);
    expect(find.text('Bundled seed content'), findsOneWidget);
    expect(find.text('Reviewed CMS bundles'), findsOneWidget);
    expect(find.text('Review status meanings'), findsOneWidget);
    expect(find.text('No generated religious text'), findsOneWidget);
    expect(find.textContaining('Quran, dua, dhikr, Hadith'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Content Sources page never renders the content API token',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/content-sources',
      settleSplash: false,
      contentApiConfig: ContentApiConfig(
        enabled: true,
        provider: 'generic',
        baseUri: Uri.parse('https://content.example.test'),
        token: 'content-token-that-must-not-render',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.contentSourcesPage), findsOneWidget);
    expect(find.textContaining('content-token-that-must-not-render'),
        findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Content Sources page renders in English Indonesian and Arabic',
      (tester) async {
    const languages = ['en', 'id', 'ar'];

    for (final languageCode in languages) {
      final store = InMemoryUserPreferencesStore();
      await UserPreferencesRepository(store).save(
        UserPreferences.defaults().copyWith(languageCode: languageCode),
      );

      await pumpSakinahApp(
        tester,
        initialLocation: '/settings/content-sources',
        settleSplash: false,
        preferencesStore: store,
      );
      await tester.pumpAndSettle();

      expect(find.byKey(SakinahKeys.contentSourcesPage), findsOneWidget);
      expectNoFlutterErrors(tester);
    }
  });
}
