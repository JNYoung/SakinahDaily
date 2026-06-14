import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/app/sakinah_app.dart';
import 'package:sakinah_daily/app/sakinah_router.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/config/content_api_config.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/repositories/content_cache_repository.dart';
import 'package:sakinah_daily/core/repositories/prayer_completion_repository.dart';
import 'package:sakinah_daily/core/repositories/saved_items_repository.dart';
import 'package:sakinah_daily/core/repositories/session_progress_repository.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';
import 'package:sakinah_daily/core/services/audio_player_service.dart';
import 'package:sakinah_daily/core/services/notification_service.dart';
import 'package:sakinah_daily/shared/sakinah_keys.dart';

const mobileViewport = Size(390, 844);
const tabletViewport = Size(768, 1024);
const desktopViewport = Size(1280, 720);

Future<void> pumpSakinahApp(
  WidgetTester tester, {
  Size viewport = desktopViewport,
  String languageCode = 'en',
  String? initialLocation,
  Brightness? platformBrightness,
  bool settleSplash = true,
  UserPreferencesStore? preferencesStore,
  ContentCacheStore? contentCacheStore,
  SavedItemsStore? savedItemsStore,
  PrayerCompletionStore? prayerCompletionStore,
  SessionProgressStore? sessionProgressStore,
  ContentApiConfig? contentApiConfig,
  AppEnvironmentConfig? appEnvironmentConfig,
  AnalyticsService? analyticsService,
  NotificationService? notificationService,
  SakinahAudioPlayer? audioPlayer,
  DateTime? currentDateTime,
}) async {
  final effectivePreferencesStore =
      preferencesStore ?? InMemoryUserPreferencesStore();
  if (preferencesStore == null &&
      appEnvironmentConfig?.storeScreenshotModeEnabled == true) {
    await UserPreferencesRepository(effectivePreferencesStore).save(
      UserPreferences.defaults().copyWith(
        languageCode: appEnvironmentConfig?.storeScreenshotLanguageCode ?? 'en',
        notificationsEnabled: false,
        dailySessionReminderEnabled: false,
      ),
    );
  }
  final initialPreferences =
      await UserPreferencesRepository(effectivePreferencesStore).load();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = viewport;
  if (platformBrightness != null) {
    tester.platformDispatcher.platformBrightnessTestValue = platformBrightness;
  }
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
    tester.platformDispatcher.clearPlatformBrightnessTestValue();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialUserPreferencesProvider.overrideWithValue(initialPreferences),
        userPreferencesStoreProvider
            .overrideWithValue(effectivePreferencesStore),
        contentCacheStoreProvider.overrideWithValue(
          contentCacheStore ?? InMemoryContentCacheStore(),
        ),
        savedItemsStoreProvider.overrideWithValue(
          savedItemsStore ?? InMemorySavedItemsStore(),
        ),
        prayerCompletionStoreProvider.overrideWithValue(
          prayerCompletionStore ?? InMemoryPrayerCompletionStore(),
        ),
        sessionProgressStoreProvider.overrideWithValue(
          sessionProgressStore ?? InMemorySessionProgressStore(),
        ),
        contentApiConfigProvider.overrideWithValue(
          contentApiConfig ?? const ContentApiConfig.disabled(),
        ),
        if (appEnvironmentConfig != null)
          appEnvironmentConfigProvider.overrideWithValue(appEnvironmentConfig),
        if (analyticsService != null)
          analyticsServiceProvider.overrideWithValue(analyticsService),
        notificationServiceProvider.overrideWithValue(
          notificationService ?? LocalNotificationServiceStub(),
        ),
        audioPlayerProvider.overrideWithValue(
          audioPlayer ?? FakeSakinahAudioPlayer(),
        ),
        if (currentDateTime != null)
          currentDateTimeProvider.overrideWithValue(currentDateTime),
        routerProvider.overrideWithValue(
          createSakinahRouter(
            initialLocation: initialLocation ??
                appEnvironmentConfig?.storeScreenshotInitialRoute ??
                startupRouteForPreferences(initialPreferences),
          ),
        ),
      ],
      child: const SakinahApp(),
    ),
  );
  if (settleSplash && initialLocation == null) {
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
  if (finder.evaluate().isEmpty) {
    await scrollUntilFound(tester, finder);
  }
  expect(finder, findsOneWidget);
  await Scrollable.ensureVisible(
    tester.element(finder),
    alignment: 0.35,
    duration: Duration.zero,
  );
  await tester.pump();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> scrollUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxAttempts = 10,
  double delta = 240,
}) async {
  final scrollable = find.byType(Scrollable);
  for (var attempt = 0;
      attempt < maxAttempts &&
          finder.evaluate().isEmpty &&
          scrollable.evaluate().isNotEmpty;
      attempt += 1) {
    await tester.drag(scrollable.first, Offset(0, -delta));
    await tester.pumpAndSettle();
  }
}

void expectNoFlutterErrors(WidgetTester tester) {
  expect(tester.takeException(), isNull);
}
