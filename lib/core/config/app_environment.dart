enum AppEnvironment {
  dev,
  staging,
  prod;

  static AppEnvironment parse(String value) {
    return switch (value.trim().toLowerCase()) {
      'staging' => AppEnvironment.staging,
      'prod' || 'production' => AppEnvironment.prod,
      _ => AppEnvironment.dev,
    };
  }
}

class AppEnvironmentConfig {
  const AppEnvironmentConfig({
    required this.environment,
    required this.appName,
    required this.remoteContentEnabled,
    this.initialRoute = '/splash',
    this.analyticsEnabled = false,
    this.crashReportingEnabled = false,
  });

  factory AppEnvironmentConfig.fromDartDefine() {
    const values = {
      'SAKINAH_APP_ENV': String.fromEnvironment('SAKINAH_APP_ENV'),
      'SAKINAH_CONTENT_API_ENABLED':
          String.fromEnvironment('SAKINAH_CONTENT_API_ENABLED'),
      'SAKINAH_INITIAL_ROUTE': String.fromEnvironment('SAKINAH_INITIAL_ROUTE'),
    };
    return AppEnvironmentConfig.fromMap(values);
  }

  factory AppEnvironmentConfig.fromMap(Map<String, String> values) {
    final environment = AppEnvironment.parse(values['SAKINAH_APP_ENV'] ?? '');
    final remoteContentEnabled =
        _boolFromString(values['SAKINAH_CONTENT_API_ENABLED']);
    final initialRoute = _initialRoute(
      environment,
      values['SAKINAH_INITIAL_ROUTE'],
    );
    return AppEnvironmentConfig(
      environment: environment,
      appName: _appName(environment),
      remoteContentEnabled: remoteContentEnabled,
      initialRoute: initialRoute,
    );
  }

  final AppEnvironment environment;
  final String appName;
  final bool remoteContentEnabled;
  final String initialRoute;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
}

String _appName(AppEnvironment environment) {
  return switch (environment) {
    AppEnvironment.dev => 'Sakinah Daily Dev',
    AppEnvironment.staging => 'Sakinah Daily Staging',
    AppEnvironment.prod => 'Sakinah Daily',
  };
}

bool _boolFromString(String? value) {
  return value?.trim().toLowerCase() == 'true';
}

String _initialRoute(AppEnvironment environment, String? value) {
  final route = value?.trim();
  if (environment == AppEnvironment.prod ||
      route == null ||
      route.isEmpty ||
      !route.startsWith('/')) {
    return '/splash';
  }
  return route;
}
