import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/sakinah_app.dart';
import 'core/config/app_environment.dart';
import 'core/providers/app_providers.dart';
import 'core/services/analytics_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = AppEnvironmentConfig.fromDartDefine();
  await FirebaseAnalyticsBootstrap(
    analyticsEnabled: environment.analyticsEnabled,
  ).initialize();

  runApp(
    ProviderScope(
      overrides: [
        appEnvironmentConfigProvider.overrideWithValue(environment),
      ],
      child: const SakinahApp(),
    ),
  );
}
