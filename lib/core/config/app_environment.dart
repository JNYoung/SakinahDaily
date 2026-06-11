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
    this.notificationQaEnabled = false,
    this.storeScreenshotModeEnabled = false,
    this.storeScreenshotLanguageCode,
    this.storeScreenshotInitialRoute,
    this.analyticsEnabled = false,
    this.crashReportingEnabled = false,
    this.privacyPolicyUri,
    this.testingFeedbackChannel,
  });

  factory AppEnvironmentConfig.fromDartDefine() {
    const values = {
      'SAKINAH_APP_ENV': String.fromEnvironment('SAKINAH_APP_ENV'),
      'SAKINAH_CONTENT_API_ENABLED':
          String.fromEnvironment('SAKINAH_CONTENT_API_ENABLED'),
      'SAKINAH_NOTIFICATION_QA_ENABLED':
          String.fromEnvironment('SAKINAH_NOTIFICATION_QA_ENABLED'),
      'SAKINAH_STORE_SCREENSHOT_ENABLED':
          String.fromEnvironment('SAKINAH_STORE_SCREENSHOT_ENABLED'),
      'SAKINAH_STORE_SCREENSHOT_LOCALE':
          String.fromEnvironment('SAKINAH_STORE_SCREENSHOT_LOCALE'),
      'SAKINAH_STORE_SCREENSHOT_ROUTE':
          String.fromEnvironment('SAKINAH_STORE_SCREENSHOT_ROUTE'),
      'SAKINAH_PRIVACY_POLICY_URL':
          String.fromEnvironment('SAKINAH_PRIVACY_POLICY_URL'),
      'SAKINAH_PLAY_TESTING_FEEDBACK':
          String.fromEnvironment('SAKINAH_PLAY_TESTING_FEEDBACK'),
      'SAKINAH_ANALYTICS_ENABLED':
          String.fromEnvironment('SAKINAH_ANALYTICS_ENABLED'),
    };
    return AppEnvironmentConfig.fromMap(values);
  }

  factory AppEnvironmentConfig.fromMap(Map<String, String> values) {
    final environment = AppEnvironment.parse(values['SAKINAH_APP_ENV'] ?? '');
    final storeScreenshotModeEnabled = environment == AppEnvironment.dev &&
        _boolFromString(values['SAKINAH_STORE_SCREENSHOT_ENABLED']);
    final remoteContentEnabled =
        _boolFromString(values['SAKINAH_CONTENT_API_ENABLED']) &&
            !storeScreenshotModeEnabled;
    final notificationQaEnabled = environment == AppEnvironment.dev &&
        _boolFromString(values['SAKINAH_NOTIFICATION_QA_ENABLED']);
    return AppEnvironmentConfig(
      environment: environment,
      appName: _appName(environment),
      remoteContentEnabled: remoteContentEnabled,
      notificationQaEnabled: notificationQaEnabled,
      storeScreenshotModeEnabled: storeScreenshotModeEnabled,
      storeScreenshotLanguageCode: storeScreenshotModeEnabled
          ? _storeScreenshotLanguageCode(
              values['SAKINAH_STORE_SCREENSHOT_LOCALE'],
            )
          : null,
      storeScreenshotInitialRoute: storeScreenshotModeEnabled
          ? _storeScreenshotInitialRoute(
              values['SAKINAH_STORE_SCREENSHOT_ROUTE'],
            )
          : null,
      privacyPolicyUri: _publicHttpsUri(values['SAKINAH_PRIVACY_POLICY_URL']),
      testingFeedbackChannel:
          _testingFeedbackChannel(values['SAKINAH_PLAY_TESTING_FEEDBACK']),
      analyticsEnabled: _boolFromString(values['SAKINAH_ANALYTICS_ENABLED']) &&
          !storeScreenshotModeEnabled,
    );
  }

  final AppEnvironment environment;
  final String appName;
  final bool remoteContentEnabled;
  final bool notificationQaEnabled;
  final bool storeScreenshotModeEnabled;
  final String? storeScreenshotLanguageCode;
  final String? storeScreenshotInitialRoute;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final Uri? privacyPolicyUri;
  final String? testingFeedbackChannel;
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

String _storeScreenshotLanguageCode(String? value) {
  return switch (value?.trim().toLowerCase()) {
    'ar' => 'ar',
    'id' => 'id',
    _ => 'en',
  };
}

const _allowedStoreScreenshotRoutes = {
  '/splash',
  '/onboarding',
  '/home',
  '/prayer',
  '/settings',
  '/settings/notifications',
  '/settings/content-sources',
  '/settings/testing-guide',
  '/settings/prayer-location',
  '/settings/privacy',
  '/session/session_morning_ease',
  '/quran/94:5',
};

String _storeScreenshotInitialRoute(String? value) {
  final route = value?.trim();
  if (route != null && _allowedStoreScreenshotRoutes.contains(route)) {
    return route;
  }
  return '/home';
}

Uri? _publicHttpsUri(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null || uri.scheme != 'https' || !uri.hasAuthority) {
    return null;
  }
  final host = uri.host.trim().toLowerCase();
  if (_isPlaceholderHost(host)) {
    return null;
  }
  return uri;
}

String? _testingFeedbackChannel(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final uri = _publicHttpsUri(trimmed);
  if (uri != null) {
    return uri.toString();
  }
  if (_isPublicEmail(trimmed)) {
    return trimmed;
  }
  return null;
}

bool _isPublicEmail(String value) {
  final match =
      RegExp(r'^[^@\s]+@([^@\s]+\.[^@\s]+)$').firstMatch(value.trim());
  if (match == null) {
    return false;
  }
  return !_isPlaceholderHost(match.group(1)!.toLowerCase());
}

bool _isPlaceholderHost(String host) {
  return host.isEmpty ||
      !host.contains('.') ||
      host == 'localhost' ||
      host == '127.0.0.1' ||
      host == '0.0.0.0' ||
      host == 'example.com' ||
      host.endsWith('.example.com') ||
      host.endsWith('.example') ||
      host.endsWith('.test') ||
      host.endsWith('.invalid');
}
