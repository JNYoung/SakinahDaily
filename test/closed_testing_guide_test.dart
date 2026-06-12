import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Settings opens closed testing guide when feedback is configured',
      (tester) async {
    final copiedValues = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        copiedValues.add(data['text'] as String);
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings',
      settleSplash: false,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
        },
      ),
    );
    await tester.pumpAndSettle();

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.settingsClosedTestingGuideTile),
    );
    await tapByKey(tester, SakinahKeys.settingsClosedTestingGuideTile);

    expect(find.byKey(SakinahKeys.closedTestingGuidePage), findsOneWidget);
    expect(find.text('Closed testing guide'), findsWidgets);
    expect(find.text('Daily tester checklist'), findsOneWidget);
    expect(find.textContaining('Open the app once each day'), findsOneWidget);
    expect(find.textContaining('Check the next prayer time'), findsOneWidget);
    expect(
        find.textContaining('Start Today’s Sakinah Session'), findsOneWidget);
    expect(find.textContaining('Review Privacy Center'), findsOneWidget);
    expect(find.text('Feedback prompts'), findsOneWidget);
    expect(find.byKey(SakinahKeys.closedTestingPromptDay1), findsOneWidget);
    expect(find.byKey(SakinahKeys.closedTestingPromptDay3), findsOneWidget);
    expect(find.byKey(SakinahKeys.closedTestingPromptDay7), findsOneWidget);
    expect(find.byKey(SakinahKeys.closedTestingPromptDay14), findsOneWidget);
    expect(
      find.textContaining('Did onboarding explain location'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Suggested theme: onboarding_location_clarity'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Were prayer times, location, and reminder'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Suggested theme: prayer_time_trust'),
      findsOneWidget,
    );
    expect(
      find.textContaining('What made you want to reopen'),
      findsOneWidget,
    );
    expect(
      find.textContaining('What one change would most improve daily use'),
      findsOneWidget,
    );
    await scrollUntilFound(
      tester,
      find.textContaining('support@sakinahdaily.app'),
    );
    expect(find.textContaining('support@sakinahdaily.app'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.closedTestingFeedbackCopyButton);

    expect(copiedValues, contains('support@sakinahdaily.app'));
    expect(find.text('Testing feedback copied.'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Closed testing prompt copy buttons prepare safe feedback text',
      (tester) async {
    final copiedValues = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        copiedValues.add(data['text'] as String);
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/testing-guide',
      settleSplash: false,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
        },
      ),
    );
    await tester.pumpAndSettle();

    final promptCases = [
      (
        key: SakinahKeys.closedTestingPromptDay1CopyButton,
        day: 'Day 1',
        prompt:
            'Did onboarding explain location and notification choices clearly?',
        theme: 'onboarding_location_clarity',
      ),
      (
        key: SakinahKeys.closedTestingPromptDay3CopyButton,
        day: 'Day 3',
        prompt:
            'Were prayer times, location, and reminder controls easy to trust?',
        theme: 'prayer_time_trust',
      ),
      (
        key: SakinahKeys.closedTestingPromptDay7CopyButton,
        day: 'Day 7',
        prompt: 'What made you want to reopen or ignore the app this week?',
        theme: 'retention_reason_to_return',
      ),
      (
        key: SakinahKeys.closedTestingPromptDay14CopyButton,
        day: 'Day 14',
        prompt:
            'What one change would most improve daily use before wider release?',
        theme: 'retention_reason_to_return',
      ),
    ];

    for (final promptCase in promptCases) {
      await tapByKey(tester, promptCase.key);

      expect(
        copiedValues.last,
        allOf(
          contains('Sakinah Daily closed test feedback'),
          contains(promptCase.day),
          contains('Prompt: ${promptCase.prompt}'),
          contains('Suggested theme: ${promptCase.theme}'),
          contains('Feedback channel: support@sakinahdaily.app'),
          contains('Please avoid personal or sensitive health details.'),
        ),
      );
      expect(find.text('Feedback prompt copied.'), findsOneWidget);
    }

    expect(copiedValues, hasLength(4));
    expectNoFlutterErrors(tester);
  });

  testWidgets('Closed testing prompt completion is local and persistent',
      (tester) async {
    final preferencesStore = InMemoryUserPreferencesStore();
    final config = AppEnvironmentConfig.fromMap(
      const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
      },
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/testing-guide',
      settleSplash: false,
      preferencesStore: preferencesStore,
      appEnvironmentConfig: config,
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(SakinahKeys.closedTestingPromptDay1CompletedCheckbox),
          )
          .value,
      isFalse,
    );
    expect(find.text('Feedback sent'), findsWidgets);
    expect(find.text('Stored only on this device.'), findsWidgets);

    await tapByKey(
      tester,
      SakinahKeys.closedTestingPromptDay1CompletedCheckbox,
    );

    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(SakinahKeys.closedTestingPromptDay1CompletedCheckbox),
          )
          .value,
      isTrue,
    );

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/testing-guide',
      settleSplash: false,
      preferencesStore: preferencesStore,
      appEnvironmentConfig: config,
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(SakinahKeys.closedTestingPromptDay1CompletedCheckbox),
          )
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(SakinahKeys.closedTestingPromptDay3CompletedCheckbox),
          )
          .value,
      isFalse,
    );
    expect(
      tester
          .widget<CheckboxListTile>(
            find.byKey(SakinahKeys.closedTestingPromptDay7CompletedCheckbox),
          )
          .value,
      isFalse,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Closed testing prompt analytics uses aggregate metadata',
      (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final analytics = StubAnalyticsService(enabled: true);

    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/testing-guide',
      settleSplash: false,
      analyticsService: analytics,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
        },
      ),
    );
    await tester.pumpAndSettle();

    await tapByKey(tester, SakinahKeys.closedTestingPromptDay3CopyButton);
    await tapByKey(
      tester,
      SakinahKeys.closedTestingPromptDay3CompletedCheckbox,
    );

    expect(
      analytics.events.map((event) => event.name),
      containsAllInOrder([
        AnalyticsEventCatalog.closedTestPromptCopied,
        AnalyticsEventCatalog.closedTestPromptMarkedSent,
      ]),
    );
    expect(
      analytics.events
          .firstWhere(
            (event) =>
                event.name == AnalyticsEventCatalog.closedTestPromptCopied,
          )
          .properties,
      {
        'prompt_day': 'day3',
        'theme_key': 'prayer_time_trust',
        'source': 'closed_testing_guide',
      },
    );
    expect(
      analytics.events
          .firstWhere(
            (event) =>
                event.name == AnalyticsEventCatalog.closedTestPromptMarkedSent,
          )
          .properties,
      {
        'prompt_day': 'day3',
        'theme_key': 'prayer_time_trust',
        'source': 'closed_testing_guide',
      },
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('Settings hides closed testing guide without feedback channel',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(SakinahKeys.settingsClosedTestingGuideTile),
      findsNothing,
    );
    expect(find.text('Closed testing guide'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Closed testing guide explains missing configuration safely',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings/testing-guide',
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.closedTestingGuidePage), findsOneWidget);
    expect(find.text('Closed testing guide'), findsWidgets);
    await scrollUntilFound(
      tester,
      find.text('Testing feedback is not configured yet.'),
    );
    expect(
        find.text('Testing feedback is not configured yet.'), findsOneWidget);
    expect(
        find.byKey(SakinahKeys.closedTestingFeedbackCopyButton), findsNothing);
    expect(
      find.byKey(SakinahKeys.closedTestingPromptDay1CopyButton),
      findsNothing,
    );
    expect(
      find.byKey(SakinahKeys.closedTestingPromptDay3CopyButton),
      findsNothing,
    );
    expect(
      find.byKey(SakinahKeys.closedTestingPromptDay7CopyButton),
      findsNothing,
    );
    expect(
      find.byKey(SakinahKeys.closedTestingPromptDay14CopyButton),
      findsNothing,
    );
    expectNoFlutterErrors(tester);
  });
}
