import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/sakinah_app.dart';
import 'core/config/app_environment.dart';
import 'core/models/sakinah_models.dart';
import 'core/providers/app_providers.dart';
import 'core/repositories/user_preferences_repository.dart';
import 'core/services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = AppEnvironmentConfig.fromDartDefine();
  await FirebaseAnalyticsBootstrap(
    analyticsEnabled: environment.analyticsEnabled,
  ).initialize();
  final startupPreferencesStore = environment.storeScreenshotModeEnabled
      ? null
      : SharedPreferencesUserPreferencesStore();
  final startupPreferences = environment.storeScreenshotModeEnabled
      ? UserPreferences.defaults().copyWith(
          languageCode: environment.storeScreenshotLanguageCode ?? 'en',
          notificationsEnabled: false,
          dailySessionReminderEnabled: false,
        )
      : await UserPreferencesRepository(startupPreferencesStore!).load();

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentConfigProvider.overrideWithValue(environment),
        initialUserPreferencesProvider.overrideWithValue(startupPreferences),
        if (startupPreferencesStore != null)
          userPreferencesStoreProvider
              .overrideWithValue(startupPreferencesStore),
      ],
      child: const SakinahApp(),
    ),
  );
}
