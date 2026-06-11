import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('Settings shows and copies configured testing feedback email',
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
      find.byKey(SakinahKeys.settingsTestingFeedbackTile),
    );
    expect(find.text('Testing feedback'), findsOneWidget);
    expect(find.text('support@sakinahdaily.app'), findsOneWidget);

    await tapByKey(tester, SakinahKeys.settingsTestingFeedbackTile);

    expect(copiedValues, contains('support@sakinahdaily.app'));
    expect(find.text('Testing feedback copied.'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('Settings rejects placeholder testing feedback channels',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/settings',
      settleSplash: false,
      appEnvironmentConfig: AppEnvironmentConfig.fromMap(
        const {
          'SAKINAH_APP_ENV': 'prod',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'https://example.com/feedback',
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.settingsTestingFeedbackTile), findsNothing);
    expect(find.textContaining('example.com'), findsNothing);
    expectNoFlutterErrors(tester);
  });
}
