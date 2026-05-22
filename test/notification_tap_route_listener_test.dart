import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/app/sakinah_app.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/services/notification_tap_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
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

ProviderContainer _container(WidgetTester tester) {
  return ProviderScope.containerOf(
    tester.element(find.byType(SakinahApp)),
    listen: false,
  );
}
