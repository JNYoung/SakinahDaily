import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/app/sakinah_app.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
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
        final analytics = StubAnalyticsService(enabled: true);

        await pumpSakinahApp(
          tester,
          initialLocation: '/home',
          settleSplash: false,
          notificationService: notifications,
          analyticsService: analytics,
        );
        await tester.pumpAndSettle();

        expect(find.byKey(scenario.expectedKey), findsOneWidget);
        expect(await notifications.takeLaunchPayload(), isNull);
        final notificationTapEvents = analytics.events
            .where((event) =>
                event.name == AnalyticsEventCatalog.notificationTapOpened)
            .toList();
        final notificationTapResultEvents = analytics.events
            .where((event) =>
                event.name == AnalyticsEventCatalog.notificationTapResult)
            .toList();
        final localPushResolutionEvents = analytics.events
            .where((event) =>
                event.name == AnalyticsEventCatalog.localPushResolutionResult)
            .toList();
        expect(notificationTapEvents, hasLength(1));
        expect(notificationTapEvents.single.properties, {
          'content_type': scenario.expectedContentType,
          'source': 'local_notification',
        });
        expect(notificationTapResultEvents, hasLength(1));
        expect(notificationTapResultEvents.single.properties, {
          'content_type': scenario.expectedContentType,
          'source': 'local_notification',
          'change_type': 'opened',
        });
        expect(localPushResolutionEvents, hasLength(1));
        expect(localPushResolutionEvents.single.properties, {
          'content_type': scenario.expectedContentType,
          'source': 'local_notification',
          'change_type': 'opened',
        });

        final container = _container(tester);
        expect(container.read(notificationTapResultProvider), isNull);
        expectNoFlutterErrors(tester);
      },
    );
  }

  testWidgets('notification tap result navigates to prayer route',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      analyticsService: analytics,
    );
    final container = _container(tester);

    container.read(notificationTapResultProvider.notifier).state =
        const NotificationTapResult(
      handled: true,
      route: '/prayer',
      analyticsContentType: 'prayer',
      flags: ['notification_tap_fallback_prayer'],
    );
    await tester.pumpAndSettle();

    final notificationTapEvents = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.notificationTapOpened)
        .toList();
    final notificationTapResultEvents = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.notificationTapResult)
        .toList();
    final localPushResolutionEvents = analytics.events
        .where(
          (event) =>
              event.name == AnalyticsEventCatalog.localPushResolutionResult,
        )
        .toList();
    expect(find.byKey(SakinahKeys.prayerContentList), findsOneWidget);
    expect(notificationTapEvents, hasLength(1));
    expect(notificationTapEvents.single.properties, {
      'content_type': 'prayer',
      'source': 'local_notification',
    });
    expect(notificationTapResultEvents, hasLength(1));
    expect(notificationTapResultEvents.single.properties, {
      'content_type': 'prayer',
      'source': 'local_notification',
      'change_type': 'opened',
    });
    expect(localPushResolutionEvents, hasLength(1));
    expect(localPushResolutionEvents.single.properties, {
      'content_type': 'prayer',
      'source': 'local_notification',
      'change_type': 'opened',
    });
    expect(container.read(notificationTapResultProvider), isNull);
    expectNoFlutterErrors(tester);
  });

  testWidgets('invalid notification tap result clears without navigation',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      analyticsService: analytics,
    );
    final container = _container(tester);

    container.read(notificationTapResultProvider.notifier).state =
        const NotificationTapResult(
      handled: false,
      route: '/prayer',
      analyticsContentType: 'prayer',
      flags: ['malformed_payload'],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.homeContentList), findsOneWidget);
    expect(find.byKey(SakinahKeys.prayerContentList), findsNothing);
    final notificationTapEvents = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.notificationTapOpened)
        .toList();
    final notificationTapResultEvents = analytics.events
        .where((event) =>
            event.name == AnalyticsEventCatalog.notificationTapResult)
        .toList();
    final localPushResolutionEvents = analytics.events
        .where(
          (event) =>
              event.name == AnalyticsEventCatalog.localPushResolutionResult,
        )
        .toList();
    expect(notificationTapEvents, isEmpty);
    expect(notificationTapResultEvents, hasLength(1));
    expect(notificationTapResultEvents.single.properties, {
      'content_type': 'prayer',
      'source': 'local_notification',
      'change_type': 'malformed_payload',
    });
    expect(localPushResolutionEvents, hasLength(1));
    expect(localPushResolutionEvents.single.properties, {
      'content_type': 'prayer',
      'source': 'local_notification',
      'change_type': 'malformed_payload',
    });
    expect(container.read(notificationTapResultProvider), isNull);
    expectNoFlutterErrors(tester);
  });

  testWidgets('handled notification tap is not replayed after rebuild',
      (tester) async {
    final analytics = StubAnalyticsService(enabled: true);
    await pumpSakinahApp(
      tester,
      initialLocation: '/home',
      settleSplash: false,
      analyticsService: analytics,
    );
    final container = _container(tester);

    container.read(notificationTapResultProvider.notifier).state =
        const NotificationTapResult(
      handled: true,
      route: '/prayer',
      analyticsContentType: 'prayer',
      flags: ['notification_tap_fallback_prayer'],
    );
    await tester.pumpAndSettle();
    expect(container.read(notificationTapResultProvider), isNull);

    container.read(localeProvider.notifier).state = const Locale('id');
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.prayerContentList), findsOneWidget);
    expect(
      analytics.events.where(
          (event) => event.name == AnalyticsEventCatalog.notificationTapOpened),
      hasLength(1),
    );
    expect(
      analytics.events.where(
        (event) =>
            event.name == AnalyticsEventCatalog.localPushResolutionResult,
      ),
      hasLength(1),
    );
    expect(container.read(notificationTapResultProvider), isNull);
    expectNoFlutterErrors(tester);
  });
}

final _coldStartScenarios = [
  _ColdStartScenario(
    name: 'prayer',
    payload: prayerNotificationPayload(),
    expectedKey: SakinahKeys.prayerContentList,
    expectedContentType: 'prayer',
  ),
  _ColdStartScenario(
    name: 'daily session',
    payload: _localPushPayload(
      type: 'daily_session',
      contentId: 'session_morning_ease',
      fallbackRoute: '/home',
    ),
    expectedKey: SakinahKeys.sessionProgressBar,
    expectedContentType: 'daily_session',
  ),
  _ColdStartScenario(
    name: 'Quran verse',
    payload: _localPushPayload(
      type: 'quran',
      contentId: '94:5',
      fallbackRoute: '/quran',
    ),
    expectedKey: SakinahKeys.quranVerseDetailPage,
    expectedContentType: 'quran',
  ),
  _ColdStartScenario(
    name: 'Dua detail',
    payload: _localPushPayload(
      type: 'dua',
      contentId: 'dua_ease',
      fallbackRoute: '/dua',
    ),
    expectedKey: SakinahKeys.duaSourceCard,
    expectedContentType: 'dua',
  ),
  _ColdStartScenario(
    name: 'Dhikr counter',
    payload: _localPushPayload(
      type: 'dhikr',
      contentId: 'dhikr_subhanallah',
      fallbackRoute: '/dhikr',
    ),
    expectedKey: SakinahKeys.dhikrCounter,
    expectedContentType: 'dhikr',
  ),
];

class _ColdStartScenario {
  const _ColdStartScenario({
    required this.name,
    required this.payload,
    required this.expectedKey,
    required this.expectedContentType,
  });

  final String name;
  final String payload;
  final Key expectedKey;
  final String expectedContentType;
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
