import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

import 'support/sakinah_test_harness.dart';

void main() {
  testWidgets('store screenshot mode can target the splash brand screen',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'en',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/splash',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.splashPage), findsOneWidget);
    expect(find.byKey(SakinahKeys.splashBrand), findsOneWidget);
    expect(find.text('Sakinah\nDaily'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('store screenshot splash is localized in Indonesian',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'id',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/splash',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.splashPage), findsOneWidget);
    expect(find.text('Tenang untuk hati,\nzikir untuk hari ini'), findsOne);
    expect(
      find.text('QURAN   ·   DOA   ·   DZIKIR   ·   SHALAT'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('store screenshot splash is localized and RTL in Arabic',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'ar',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/splash',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    final page = find.byKey(SakinahKeys.splashPage);
    expect(page, findsOneWidget);
    expect(Directionality.of(tester.element(page)), TextDirection.rtl);
    expect(find.text('طمأنينة للقلب،\nوذكر لليوم'), findsOneWidget);
    expect(
      find.text('القرآن   ·   الدعاء   ·   الذكر   ·   الصلاة'),
      findsOneWidget,
    );
    expectNoFlutterErrors(tester);
  });

  testWidgets('store screenshot mode opens target route in Arabic RTL',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'ar',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings/privacy',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    final page = find.byKey(SakinahKeys.privacyCenterPage);
    expect(page, findsOneWidget);
    expect(Directionality.of(tester.element(page)), TextDirection.rtl);
    expectNoFlutterErrors(tester);
  });

  testWidgets('store screenshot mode can target Quran no-BGM safety evidence',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'en',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/quran/94:5',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.quranVerseDetailPage), findsOneWidget);
    expect(find.textContaining('No background music'), findsOneWidget);
    expect(find.textContaining('No Quran TTS'), findsOneWidget);
    expect(find.textContaining('Background sound allowed'), findsNothing);
    expectNoFlutterErrors(tester);
  });

  testWidgets('store screenshot mode can target closed testing guide',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'en',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings/testing-guide',
      'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(SakinahKeys.closedTestingGuidePage), findsOneWidget);
    expect(find.text('Daily tester checklist'), findsOneWidget);
    expectNoFlutterErrors(tester);
  });

  testWidgets('store screenshot mode seeds matching preferences locale',
      (tester) async {
    final config = AppEnvironmentConfig.fromMap(const {
      'SAKINAH_APP_ENV': 'dev',
      'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      'SAKINAH_STORE_SCREENSHOT_LOCALE': 'id',
      'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings',
    });

    await pumpSakinahApp(
      tester,
      viewport: mobileViewport,
      appEnvironmentConfig: config,
      settleSplash: false,
    );
    await tester.pumpAndSettle();

    final languageDropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>).first,
    );
    expect(languageDropdown.value, 'id');

    await scrollUntilFound(
      tester,
      find.byKey(SakinahKeys.settingsNotificationSettingsTile),
    );
    expect(find.byKey(SakinahKeys.settingsNotificationSettingsTile), findsOne);
    expectNoFlutterErrors(tester);
  });
}
