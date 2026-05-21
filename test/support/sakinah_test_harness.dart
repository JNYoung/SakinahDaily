import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/app/sakinah_app.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

const mobileViewport = Size(390, 844);
const tabletViewport = Size(768, 1024);
const desktopViewport = Size(1280, 720);

Future<void> pumpSakinahApp(
  WidgetTester tester, {
  Size viewport = desktopViewport,
  String languageCode = 'en',
  bool settleSplash = true,
  UserPreferencesStore? preferencesStore,
  NotificationService? notificationService,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = viewport;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userPreferencesStoreProvider.overrideWithValue(
          preferencesStore ?? InMemoryUserPreferencesStore(),
        ),
        notificationServiceProvider.overrideWithValue(
          notificationService ?? LocalNotificationServiceStub(),
        ),
      ],
      child: const SakinahApp(),
    ),
  );
  if (settleSplash) {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }

  if (settleSplash && languageCode != 'en') {
    await chooseOnboardingLanguage(tester, languageCode);
  }
}

Future<void> chooseOnboardingLanguage(
  WidgetTester tester,
  String languageCode,
) async {
  final label = switch (languageCode) {
    'id' => 'Indonesia',
    'ar' => 'العربية',
    _ => 'English',
  };
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

Future<void> continueToHome(WidgetTester tester) async {
  await tapByKey(tester, SakinahKeys.onboardingContinueButton);
}

Future<void> tapByKey(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget);
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void expectNoFlutterErrors(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
