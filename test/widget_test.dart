import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('app renders onboarding and reaches home', (tester) async {
    final store = InMemoryUserPreferencesStore();
    final repository = UserPreferencesRepository(store);

    await pumpSakinahApp(tester, preferencesStore: store);

    expect(find.text('Sakinah Daily'), findsOneWidget);
    expect(find.text('Begin with calm worship'), findsOneWidget);

    await continueToHome(tester);

    expect(find.text('Assalamu alaikum,'), findsOneWidget);
    expect(find.text("Today's Sakinah Session"), findsOneWidget);
    expect((await repository.load()).hasCompletedOnboarding, isTrue);
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

  testWidgets('onboarding records privacy-safe funnel analytics',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);

    await pumpSakinahApp(tester, analyticsService: analytics);

    await tapByKey(tester, SakinahKeys.onboardingPrayerLocationDropdown);
    await tester.tap(find.text('Jakarta').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prefer not to say'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Female').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recitation only'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Text first').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Indonesia'));
    await tester.pumpAndSettle();

    await continueToHome(tester);

    expect(
      analytics.events.map((event) => event.name),
      containsAllInOrder([
        AnalyticsEventCatalog.onboardingStarted,
        AnalyticsEventCatalog.locationMethodSelected,
        AnalyticsEventCatalog.genderModeSelected,
        AnalyticsEventCatalog.audioPreferenceSelected,
        AnalyticsEventCatalog.languageSelected,
        AnalyticsEventCatalog.onboardingCompleted,
      ]),
    );
    expect(
      analytics.events
          .firstWhere(
            (event) => event.name == AnalyticsEventCatalog.onboardingStarted,
          )
          .properties,
      {
        'screen': 'onboarding',
        'source': 'onboarding',
      },
    );
    expect(
      analytics.events
          .firstWhere(
            (event) => event.name == AnalyticsEventCatalog.languageSelected,
          )
          .properties,
      {
        'language_code': 'id',
        'source': 'onboarding',
      },
    );
    expect(
      analytics.events
          .firstWhere(
            (event) =>
                event.name == AnalyticsEventCatalog.locationMethodSelected,
          )
          .properties,
      {
        'location_method': 'preset',
        'source': 'onboarding',
      },
    );
    expect(
      analytics.events
          .firstWhere(
            (event) => event.name == AnalyticsEventCatalog.genderModeSelected,
          )
          .properties,
      {
        'source': 'onboarding',
      },
    );
    expect(
      analytics.events
          .firstWhere(
            (event) =>
                event.name == AnalyticsEventCatalog.audioPreferenceSelected,
          )
          .properties,
      {
        'audio_preference': 'textFirst',
        'source': 'onboarding',
      },
    );
    expect(
      analytics.events
          .firstWhere(
            (event) => event.name == AnalyticsEventCatalog.onboardingCompleted,
          )
          .properties,
      {
        'language_code': 'id',
        'location_method': 'preset',
        'audio_preference': 'textFirst',
        'source': 'onboarding',
      },
    );
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
