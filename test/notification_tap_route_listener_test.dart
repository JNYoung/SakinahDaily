import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/app/sakinah_app.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/core/services/notification_tap_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  for (final scenario in _coldStartScenarios) {
    testWidgets(
      'cold-start notification payload routes to ${scenario.name}',
      (tester) async {
        final notifications = LocalNotificationServiceStub()
          ..launchPayload = scenario.payload;

        await pumpSakinahApp(
          tester,
          initialLocation: '/home',
          settleSplash: false,
          notificationService: notifications,
        );
        await tester.pumpAndSettle();

        expect(find.byKey(scenario.expectedKey), findsOneWidget);
        expect(await notifications.takeLaunchPayload(), isNull);

        final container = _container(tester);
        expect(container.read(notificationTapResultProvider), isNull);
        expectNoFlutterErrors(tester);
      },
    );
  }

  testWidgets('notification tap result navigates to prayer route',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
    );
    final container = _container(tester);

    container.read(notificationTapResultProvider.notifier).state =
        const NotificationTapResult(
      handled: true,
      route: '/prayer',
      flags: ['notification_tap_fallback_prayer'],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.prayerContentList), findsOneWidget);
    expect(container.read(notificationTapResultProvider), isNull);
    expectNoFlutterErrors(tester);
  });

  testWidgets('invalid notification tap result clears without navigation',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
    );
    final container = _container(tester);

    container.read(notificationTapResultProvider.notifier).state =
        const NotificationTapResult(
      handled: false,
      route: '/prayer',
      flags: ['malformed_payload'],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeContentList), findsOneWidget);
    expect(find.byKey(SakinahKeys.prayerContentList), findsNothing);
    expect(container.read(notificationTapResultProvider), isNull);
    expectNoFlutterErrors(tester);
  });

  testWidgets('handled notification tap is not replayed after rebuild',
      (tester) async {
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
    );
    final container = _container(tester);

    container.read(notificationTapResultProvider.notifier).state =
        const NotificationTapResult(
      handled: true,
      route: '/prayer',
      flags: ['notification_tap_fallback_prayer'],
    );
    await tester.pumpAndSettle();
    expect(container.read(notificationTapResultProvider), isNull);

    container.read(localeProvider.notifier).state = const Locale('id');
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.prayerContentList), findsOneWidget);
    expect(container.read(notificationTapResultProvider), isNull);
    expectNoFlutterErrors(tester);
  });
}

final _coldStartScenarios = [
  _ColdStartScenario(
    name: 'prayer',
    payload: prayerNotificationPayload(),
    expectedKey: SakinahKeys.prayerContentList,
  ),
  _ColdStartScenario(
    name: 'daily session',
    payload: _localPushPayload(
      type: 'daily_session',
      contentId: 'session_morning_ease',
      fallbackRoute: '/home',
    ),
    expectedKey: SakinahKeys.sessionProgressBar,
  ),
  _ColdStartScenario(
    name: 'Quran verse',
    payload: _localPushPayload(
      type: 'quran',
      contentId: '94:5',
      fallbackRoute: '/quran',
    ),
    expectedKey: SakinahKeys.quranVerseDetailPage,
  ),
  _ColdStartScenario(
    name: 'Dua detail',
    payload: _localPushPayload(
      type: 'dua',
      contentId: 'dua_ease',
      fallbackRoute: '/dua',
    ),
    expectedKey: SakinahKeys.duaSourceCard,
  ),
];

class _ColdStartScenario {
  const _ColdStartScenario({
    required this.name,
    required this.payload,
    required this.expectedKey,
  });

  final String name;
  final String payload;
  final Key expectedKey;
}

String _localPushPayload({
  required String type,
  required String contentId,
  required String fallbackRoute,
}) {
  return jsonEncode({
    'id': 'cold_start_${type}_$contentId',
    'type': type,
    'contentId': contentId,
    'languageCode': 'en',
    'title': 'Sakinah Daily',
    'body': 'Open your Sakinah reminder.',
    'lockScreenSafe': true,
    'fallbackRoute': fallbackRoute,
    'data': {
      'type': type,
      'contentId': contentId,
      'fallbackRoute': fallbackRoute,
    },
  });
}

ProviderContainer _container(WidgetTester tester) {
  return ProviderScope.containerOf(
    tester.element(find.byType(SakinahApp)),
    listen: false,
  );
}
