import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/privacy/privacy_data_inventory.dart';

void main() {
  group('Android release identity', () {
    test('build.gradle uses the Sakinah package id', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(gradle, isNot(contains('com.example.sakinah_daily')));
      expect(gradle, contains('namespace = "com.sakinahdaily.app"'));
      expect(gradle, contains('applicationId = "com.sakinahdaily.app"'));
      expect(
        gradle,
        isNot(contains('TODO: Specify your own unique Application ID')),
      );
    });

    test('Android label resolves to Sakinah Daily', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final strings = File('android/app/src/main/res/values/strings.xml');

      expect(manifest, contains('android:label="@string/app_name"'));
      expect(strings.existsSync(), isTrue);
      expect(
        strings.readAsStringSync(),
        contains('<string name="app_name">Sakinah Daily</string>'),
      );
    });

    test('MainActivity package follows the Sakinah namespace', () {
      final oldActivity = File(
        'android/app/src/main/kotlin/com/example/sakinah_daily/MainActivity.kt',
      );
      final activity = File(
        'android/app/src/main/kotlin/com/sakinahdaily/app/MainActivity.kt',
      );

      expect(oldActivity.existsSync(), isFalse);
      expect(activity.existsSync(), isTrue);
      expect(
        activity.readAsStringSync(),
        contains('package com.sakinahdaily.app'),
      );
    });

    test('Android build toolchain meets Flutter compatibility floor', () {
      final wrapper = File('android/gradle/wrapper/gradle-wrapper.properties')
          .readAsStringSync();
      final settings = File('android/settings.gradle.kts').readAsStringSync();

      final gradleVersion = _versionFromMatch(
        RegExp(r'gradle-([0-9.]+)-all\.zip').firstMatch(wrapper),
      );
      final agpVersion = _versionFromMatch(
        RegExp(r'id\("com\.android\.application"\) version "([0-9.]+)"')
            .firstMatch(settings),
      );
      final kotlinVersion = _versionFromMatch(
        RegExp(r'id\("org\.jetbrains\.kotlin\.android"\) version "([0-9.]+)"')
            .firstMatch(settings),
      );

      expect(gradleVersion.compareTo(const _Version(8, 14, 0)), isNonNegative);
      expect(agpVersion.compareTo(const _Version(8, 11, 1)), isNonNegative);
      expect(kotlinVersion.compareTo(const _Version(2, 2, 20)), isNonNegative);
    });

    test('Android app module is migrated away from explicit KGP', () {
      final gradleProperties =
          File('android/gradle.properties').readAsStringSync();
      final appGradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(gradleProperties, contains('android.newDsl=false'));
      expect(gradleProperties, contains('android.builtInKotlin=false'));
      expect(appGradle, isNot(contains('id("kotlin-android")')));
      expect(
        appGradle,
        isNot(contains('id("org.jetbrains.kotlin.android")')),
      );
      expect(appGradle, contains('kotlin {'));
      expect(
        appGradle,
        contains(
            'jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17'),
      );
    });

    test('Android plugin dependency patches reduce KGP warning surface', () {
      final lockfile = File('pubspec.lock').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();
      final sharedPreferencesAndroidVersion =
          _versionFromLockfile(lockfile, 'shared_preferences_android');
      final audioSessionVersion =
          _versionFromLockfile(lockfile, 'audio_session');
      final firebaseAnalyticsVersion =
          _versionFromLockfile(lockfile, 'firebase_analytics');

      expect(
        sharedPreferencesAndroidVersion.compareTo(const _Version(2, 4, 26)),
        isNonNegative,
      );
      expect(
        audioSessionVersion.compareTo(const _Version(0, 2, 3)),
        isNonNegative,
      );
      expect(
        firebaseAnalyticsVersion.compareTo(const _Version(12, 4, 2)),
        isNonNegative,
      );
      expect(readiness, contains('Flutter Built-in Kotlin warning remains'));
      expect(readiness, contains('audio_session'));
      expect(readiness, contains('firebase_analytics'));
      expect(androidChecklist, contains('flutter pub outdated --show-all'));
      expect(androidChecklist, contains('audio_session` `0.2.3`'));
      expect(androidChecklist, contains('firebase_analytics` `12.4.2`'));
      expect(versionNotes, contains('Kotlin Gradle Plugin warning'));
    });

    test('Android release signing can be supplied without tracked secrets', () {
      final appGradle = File('android/app/build.gradle.kts').readAsStringSync();
      final example = File('android/key.properties.example');

      expect(appGradle, contains('SAKINAH_UPLOAD_STORE_FILE'));
      expect(appGradle, contains('SAKINAH_UPLOAD_STORE_PASSWORD'));
      expect(appGradle, contains('SAKINAH_UPLOAD_KEY_ALIAS'));
      expect(appGradle, contains('SAKINAH_UPLOAD_KEY_PASSWORD'));
      expect(appGradle, contains('SAKINAH_REQUIRE_RELEASE_SIGNING'));
      expect(appGradle, contains('rootProject.file("key.properties")'));
      expect(appGradle, contains('signingConfigs {'));
      expect(appGradle, contains('create("release")'));
      expect(appGradle, contains('signingConfigs.getByName("debug")'));

      expect(example.existsSync(), isTrue);
      final exampleContent = example.readAsStringSync();
      expect(exampleContent, contains('storeFile='));
      expect(exampleContent, contains('storePassword='));
      expect(exampleContent, contains('keyAlias='));
      expect(exampleContent, contains('keyPassword='));
      expect(exampleContent.toLowerCase(), isNot(contains('sakinah-secret')));
    });

    test('release version train is documented and sourced from Flutter', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      final appGradle = File('android/app/build.gradle.kts').readAsStringSync();
      final versionDoc = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();

      expect(pubspec, contains('version: 0.1.0+1'));
      expect(appGradle, contains('versionCode = flutter.versionCode'));
      expect(appGradle, contains('versionName = flutter.versionName'));
      expect(versionDoc, contains('Release train: v0.1 daily-prayer MVP'));
      expect(versionDoc, contains('Flutter version: `0.1.0+1`'));
      expect(versionDoc, contains('Android `versionName`: `0.1.0`'));
      expect(versionDoc, contains('Android `versionCode`: `1`'));
      expect(readiness, contains('[x] App version and build number'));
    });
  });

  group('build flavor config', () {
    test('defaults to dev and keeps telemetry disabled', () {
      final config = AppEnvironmentConfig.fromMap(const {});

      expect(config.environment, AppEnvironment.dev);
      expect(config.appName, 'Sakinah Daily Dev');
      expect(config.remoteContentEnabled, isFalse);
      expect(config.analyticsEnabled, isFalse);
      expect(config.crashReportingEnabled, isFalse);
      expect(config.privacyPolicyUri, isNull);
      expect(config.testingFeedbackChannel, isNull);
    });

    test('prod does not imply remote content without an explicit define', () {
      final config = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
      });

      expect(config.environment, AppEnvironment.prod);
      expect(config.appName, 'Sakinah Daily');
      expect(config.remoteContentEnabled, isFalse);
      expect(config.analyticsEnabled, isFalse);
      expect(config.crashReportingEnabled, isFalse);
    });

    test(
        'analytics can be explicitly enabled while screenshot mode disables it',
        () {
      final analyticsConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_ANALYTICS_ENABLED': 'true',
      });
      final screenshotConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'dev',
        'SAKINAH_ANALYTICS_ENABLED': 'true',
        'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
      });

      expect(analyticsConfig.analyticsEnabled, isTrue);
      expect(screenshotConfig.storeScreenshotModeEnabled, isTrue);
      expect(screenshotConfig.analyticsEnabled, isFalse);
    });

    test('privacy-safe Google Analytics event contract is documented', () {
      final analyticsService =
          File('lib/core/services/analytics_service.dart').readAsStringSync();
      final analyticsTest =
          File('test/analytics_service_test.dart').readAsStringSync();
      final privacyNavigationTest =
          File('test/privacy_navigation_test.dart').readAsStringSync();
      final mainDart = File('lib/main.dart').readAsStringSync();
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final privacyCenter =
          File('lib/features/settings/privacy_center_page.dart')
              .readAsStringSync();
      final analyticsPlan =
          File('docs/privacy/07_GOOGLE_ANALYTICS_EVENT_PLAN.md')
              .readAsStringSync();
      final sdkInventory =
          File('docs/privacy/06_SDK_AND_API_INVENTORY.md').readAsStringSync();
      final buildFlavorDoc =
          File('docs/release/07_BUILD_FLAVORS_AND_DART_DEFINE.md')
              .readAsStringSync();

      expect(analyticsService, contains('AnalyticsEventCatalog'));
      expect(analyticsService, contains('AnalyticsParameterPolicy'));
      expect(analyticsService, contains('onboarding_started'));
      expect(analyticsService, contains('onboarding_completed'));
      expect(analyticsService, contains('daily_session_started'));
      expect(analyticsService, contains('daily_session_step_viewed'));
      expect(analyticsService, contains('daily_session_reminder_changed'));
      expect(analyticsService, contains('home_viewed'));
      expect(analyticsService, contains('qibla_viewed'));
      expect(analyticsService, contains('prayer_location_changed'));
      expect(analyticsService, contains('prayer_reminder_changed'));
      expect(analyticsService, contains('notification_settings_viewed'));
      expect(analyticsService, contains('prayer_reminder_permission_result'));
      expect(analyticsService, contains('notification_tap_opened'));
      expect(analyticsService, contains('analytics_consent_changed'));
      expect(analyticsService,
          contains('daily_session_reminder_permission_result'));
      expect(analyticsService, contains('prayer_checkin_days_7d'));
      expect(analyticsService, contains('prayers_completed_today'));
      expect(analyticsService, contains('closed_test_prompt_copied'));
      expect(analyticsService, contains('dua_viewed'));
      expect(analyticsService, contains('dua_saved'));
      expect(analyticsService, contains('dhikr_started'));
      expect(analyticsService, contains('dhikr_completed'));
      expect(analyticsService, contains('women_ibadah_mode_changed'));
      expect(analyticsService, contains('theme_key'));
      expect(analyticsService, contains('women_ibadah_status'));
      expect(analyticsService, contains('latitude'));
      expect(analyticsService, contains('feedback'));
      expect(analyticsService, contains('FirebaseAnalyticsBootstrap'));
      expect(analyticsService, contains('FirebaseAnalyticsEventSink'));
      expect(analyticsService, contains('setAnalyticsCollectionEnabled'));
      expect(
          analyticsTest, contains('Google Analytics compatible event names'));
      expect(analyticsTest, contains('drops sensitive or free-text'));
      expect(
        analyticsTest,
        contains('qibla view analytics keeps coarse prayer-location metadata'),
      );
      expect(
        analyticsTest,
        contains('prayer location analytics keeps safe settings metadata'),
      );
      expect(
        analyticsTest,
        contains('home analytics only keeps aggregate prayer retention fields'),
      );
      expect(
        analyticsTest,
        contains('onboarding analytics keeps only safe funnel metadata'),
      );
      expect(
        analyticsTest,
        contains(
            'daily session step analytics keeps only step funnel metadata'),
      );
      expect(
        analyticsTest,
        contains(
            'notification settings view analytics keeps safe reminder state metadata'),
      );
      expect(
        analyticsTest,
        contains('secondary feature analytics keeps only safe usage metadata'),
      );
      expect(
        analyticsTest,
        contains(
            'prayer reminder permission analytics keeps safe outcome metadata'),
      );
      expect(
        analyticsTest,
        contains('daily session reminder analytics keeps safe reminder'),
      );
      expect(
        analyticsTest,
        contains(
            'daily session reminder permission analytics keeps safe outcome metadata'),
      );
      expect(analyticsTest, contains('home_prayer_card'));
      expect(analyticsTest, contains('prayer_completion_card'));
      expect(
        analyticsTest,
        contains(
            'daily session completion analytics keeps safe source metadata'),
      );
      expect(analyticsTest, contains('firebase bootstrap fails closed'));
      expect(analyticsTest, contains('collection disabled'));
      expect(analyticsTest, contains('provider requires user opt-in'));
      expect(privacyNavigationTest,
          contains('Privacy Center stores analytics opt-in'));
      expect(mainDart, contains('FirebaseAnalyticsBootstrap'));
      expect(privacyCenter, contains('privacyAnalyticsSwitch'));
      expect(privacyCenter, contains('setAnalyticsOptIn'));
      expect(analyticsPlan, contains('Google Analytics 4 compatible'));
      expect(analyticsPlan, contains('SAKINAH_ANALYTICS_ENABLED=true'));
      expect(analyticsPlan, contains('analyticsOptIn'));
      expect(analyticsPlan, contains('collection disabled'));
      expect(analyticsPlan, contains('Onboarding flow records local funnel'));
      expect(analyticsPlan, contains('daily_session_step_viewed'));
      expect(analyticsPlan, contains('daily_session_reminder_changed'));
      expect(analyticsPlan, contains('notification_settings_viewed'));
      expect(analyticsPlan, contains('prayer_reminder_permission_result'));
      expect(analyticsPlan, contains('notification_tap_opened'));
      expect(analyticsPlan, contains('analytics_consent_changed'));
      expect(
          analyticsPlan, contains('daily_session_reminder_permission_result'));
      expect(analyticsPlan, contains('home_session_completion'));
      expect(analyticsPlan, contains('home_prayer_badge'));
      expect(analyticsPlan, contains('qibla_viewed'));
      expect(analyticsPlan, contains('prayer_location_changed'));
      expect(analyticsPlan, contains('Qibla page records a local'));
      expect(analyticsPlan, contains('settings_prayer_location'));
      expect(analyticsPlan, contains('manual_location_page'));
      expect(analyticsPlan, contains('home_prayer_card'));
      expect(analyticsPlan, contains('home_progress_card'));
      expect(analyticsPlan, contains('prayer_page_card'));
      expect(analyticsPlan, contains('prayer_completion_card'));
      expect(analyticsPlan, contains('prayer_page_checklist'));
      expect(analyticsPlan, contains('exact daily session reminder time'));
      expect(analyticsPlan, contains('Completion analytics keeps only'));
      expect(analyticsPlan, contains('aggregate prayer retention counts'));
      expect(analyticsPlan, contains('prayer_checkin_days_7d'));
      expect(analyticsPlan, contains('closed_test_prompt_marked_sent'));
      expect(analyticsPlan, contains('theme_key'));
      expect(analyticsPlan,
          contains('Firebase Analytics SDK dependency is present'));
      expect(analyticsPlan, contains("Women's Ibadah Mode exact status"));
      expect(sdkInventory, contains('Firebase Analytics SDK'));
      expect(sdkInventory, contains('default-off'));
      expect(
          sdkInventory, contains('Google Analytics / Firebase Analytics SDK'));
      expect(buildFlavorDoc,
          contains('Store screenshot mode forces analytics off'));
      expect(
        manifest,
        contains('firebase_analytics_collection_enabled'),
      );
      expect(
        manifest,
        contains('google_analytics_automatic_screen_reporting_enabled'),
      );
    });

    test('privacy policy URL accepts public HTTPS and rejects placeholders',
        () {
      final publicConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PRIVACY_POLICY_URL': 'https://sakinahdaily.app/privacy',
      });
      final exampleConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PRIVACY_POLICY_URL': 'https://example.com/privacy',
      });
      final localhostConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PRIVACY_POLICY_URL': 'https://localhost/privacy',
      });
      final httpConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PRIVACY_POLICY_URL': 'http://sakinahdaily.app/privacy',
      });

      expect(
        publicConfig.privacyPolicyUri,
        Uri.parse('https://sakinahdaily.app/privacy'),
      );
      expect(exampleConfig.privacyPolicyUri, isNull);
      expect(localhostConfig.privacyPolicyUri, isNull);
      expect(httpConfig.privacyPolicyUri, isNull);
    });

    test('testing feedback accepts public channels and rejects placeholders',
        () {
      final emailConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
      });
      final urlConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PLAY_TESTING_FEEDBACK':
            'https://feedback.sakinahdaily.app/testing',
      });
      final exampleEmailConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@example.com',
      });
      final exampleUrlConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_PLAY_TESTING_FEEDBACK': 'https://example.com/feedback',
      });

      expect(emailConfig.testingFeedbackChannel, 'support@sakinahdaily.app');
      expect(
        urlConfig.testingFeedbackChannel,
        'https://feedback.sakinahdaily.app/testing',
      );
      expect(exampleEmailConfig.testingFeedbackChannel, isNull);
      expect(exampleUrlConfig.testingFeedbackChannel, isNull);
    });

    test('staging can enable remote content explicitly', () {
      final config = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'staging',
        'SAKINAH_CONTENT_API_ENABLED': 'true',
      });

      expect(config.environment, AppEnvironment.staging);
      expect(config.appName, 'Sakinah Daily Staging');
      expect(config.remoteContentEnabled, isTrue);
      expect(config.analyticsEnabled, isFalse);
      expect(config.crashReportingEnabled, isFalse);
    });

    test('notification QA is dev-only and disabled by default', () {
      final defaultConfig = AppEnvironmentConfig.fromMap(const {});
      final devConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'dev',
        'SAKINAH_NOTIFICATION_QA_ENABLED': 'true',
      });
      final stagingConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'staging',
        'SAKINAH_NOTIFICATION_QA_ENABLED': 'true',
      });
      final prodConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_NOTIFICATION_QA_ENABLED': 'true',
      });

      expect(defaultConfig.notificationQaEnabled, isFalse);
      expect(devConfig.notificationQaEnabled, isTrue);
      expect(stagingConfig.notificationQaEnabled, isFalse);
      expect(prodConfig.notificationQaEnabled, isFalse);
    });

    test('store screenshot mode is dev-only deterministic and offline', () {
      final defaultConfig = AppEnvironmentConfig.fromMap(const {});
      final devConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'dev',
        'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
        'SAKINAH_STORE_SCREENSHOT_LOCALE': 'ar',
        'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings/privacy',
        'SAKINAH_CONTENT_API_ENABLED': 'true',
      });
      final invalidRouteConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'dev',
        'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
        'SAKINAH_STORE_SCREENSHOT_LOCALE': 'xx',
        'SAKINAH_STORE_SCREENSHOT_ROUTE': '/unknown',
      });
      final splashRouteConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'dev',
        'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
        'SAKINAH_STORE_SCREENSHOT_ROUTE': '/splash',
      });
      final contentSourcesRouteConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'dev',
        'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
        'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings/content-sources',
      });
      final prodConfig = AppEnvironmentConfig.fromMap(const {
        'SAKINAH_APP_ENV': 'prod',
        'SAKINAH_STORE_SCREENSHOT_ENABLED': 'true',
        'SAKINAH_STORE_SCREENSHOT_LOCALE': 'ar',
        'SAKINAH_STORE_SCREENSHOT_ROUTE': '/settings/privacy',
      });

      expect(defaultConfig.storeScreenshotModeEnabled, isFalse);
      expect(devConfig.storeScreenshotModeEnabled, isTrue);
      expect(devConfig.storeScreenshotLanguageCode, 'ar');
      expect(devConfig.storeScreenshotInitialRoute, '/settings/privacy');
      expect(devConfig.remoteContentEnabled, isFalse);
      expect(invalidRouteConfig.storeScreenshotLanguageCode, 'en');
      expect(invalidRouteConfig.storeScreenshotInitialRoute, '/home');
      expect(splashRouteConfig.storeScreenshotInitialRoute, '/splash');
      expect(
        contentSourcesRouteConfig.storeScreenshotInitialRoute,
        '/settings/content-sources',
      );
      expect(prodConfig.storeScreenshotModeEnabled, isFalse);
      expect(prodConfig.storeScreenshotLanguageCode, isNull);
      expect(prodConfig.storeScreenshotInitialRoute, isNull);
    });
  });

  group('store readiness docs and guardrails', () {
    test('privacy docs exist', () {
      for (final path in _privacyDocs) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    });

    test('release docs exist', () {
      for (final path in _releaseDocs) {
        expect(File(path).existsSync(), isTrue, reason: path);
      }
      expect(
        File('docs/client/07_NOTIFICATION_ROUTER_QURAN_MANUAL_LOCATION.md')
            .existsSync(),
        isTrue,
      );
      expect(
        File('scripts/capture_android_store_screenshot.sh').existsSync(),
        isTrue,
      );
      expect(
        File('scripts/capture_android_store_screenshots.sh').existsSync(),
        isTrue,
      );
      expect(
        File('scripts/verify_google_play_internal_release.sh').existsSync(),
        isTrue,
      );
      expect(
        File('scripts/verify_android_launch_smoke.sh').existsSync(),
        isTrue,
      );
    });

    test('Google Play internal release gate is scripted and documented', () {
      final script = File('scripts/verify_google_play_internal_release.sh');
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_REQUIRE_RELEASE_SIGNING=true'));
      expect(content, contains('SAKINAH_ALLOW_UNSIGNED_RELEASE_QA'));
      expect(content, contains('SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA'));
      expect(content, contains('apkanalyzer'));
      expect(content, contains('sdkmanager'));
      expect(content, contains('--licenses'));
      expect(content, contains('All SDK package licenses accepted'));
      expect(
        content,
        contains(
            'flutter --no-version-check test test/release_readiness_test.dart'),
      );
      expect(content, contains('dart analyze'));
      expect(content, contains('build appbundle --release'));
      expect(content, contains('--dart-define=SAKINAH_APP_ENV=prod'));
      expect(content,
          contains('build/app/outputs/bundle/release/app-release.aab'));
      expect(content, contains('shasum -a 256'));
      expect(content, contains('build_status='));
      expect(content, contains('failed after producing a bundle'));
      expect(content, isNot(contains('SAKINAH_APP_ENV=dev')));

      expect(readiness, contains('Google Play internal release gate script'));
      expect(readiness, contains('native debug-symbol stripping'));
      expect(readiness, contains('Unsigned Google Play release QA passes'));
      expect(
          androidChecklist, contains('verify_google_play_internal_release.sh'));
      expect(androidChecklist, contains('SAKINAH_ALLOW_UNSIGNED_RELEASE_QA'));
      expect(
          androidChecklist, contains('SAKINAH_ALLOW_MISSING_CMDLINE_TOOLS_QA'));
      expect(androidChecklist, contains('apkanalyzer'));
      expect(androidChecklist, contains('sdkmanager --licenses'));
      expect(androidChecklist, contains('unsigned release QA now passes'));
      expect(androidChecklist, contains('All Android licenses accepted'));
      expect(versionNotes, contains('Google Play internal testing gate'));
    });

    test('Android launch smoke gate is scripted and documented', () {
      final script = File('scripts/verify_android_launch_smoke.sh');
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_ANDROID_SERIAL'));
      expect(content, contains('SAKINAH_ANDROID_EMULATOR_ID'));
      expect(content, contains('ANDROID_HOME'));
      expect(content, contains('ANDROID_SDK_ROOT'));
      expect(content, contains('platform-tools/adb'));
      expect(content, contains('--no-version-check build apk --debug'));
      expect(content, contains(r'flutter "${flutter_args[@]}"'));
      expect(content, contains('--dart-define=SAKINAH_APP_ENV=dev'));
      expect(content, contains('build/app/outputs/flutter-apk/app-debug.apk'));
      expect(content, contains('install -r'));
      expect(content, contains('package_name="com.sakinahdaily.app"'));
      expect(content, contains(r'am force-stop "$package_name"'));
      expect(content, contains(r'monkey -p "$package_name"'));
      expect(content, contains(r'pidof -s "$package_name"'));
      expect(content, contains('screencap -p'));
      expect(content, contains('build/android-launch-smoke'));

      expect(readiness, contains('verify_android_launch_smoke.sh'));
      expect(readiness, contains('Android launch smoke gate'));
      expect(androidChecklist, contains('verify_android_launch_smoke.sh'));
      expect(androidChecklist, contains('SAKINAH_ANDROID_SERIAL'));
      expect(androidChecklist, contains('SAKINAH_ANDROID_EMULATOR_ID'));
      expect(productProgress, contains('verify_android_launch_smoke.sh'));
      expect(productProgress, contains('Android launch smoke'));
    });

    test('Android OEM reminder observation packet is scripted', () {
      final script =
          File('scripts/export_android_oem_reminder_observation_packet.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('build/android-oem-reminder-observation'));
      expect(content, contains('long_window_observation_log.csv'));
      expect(content, contains('reboot_delivery_checklist.csv'));
      expect(content, contains('battery_policy_review.csv'));
      expect(content, contains('device_environment_snapshot.txt'));
      expect(content, contains('oem_observation_checklist.md'));
      expect(content, contains('adb shell getprop'));
      expect(content, contains('cmd deviceidle whitelist'));
      expect(content,
          contains('SAKINAH_REQUIRE_ANDROID_OEM_REMINDER_OBSERVATION_READY'));
      expect(content, contains('SAKINAH_ANDROID_OEM_TEST_DEVICE_CONFIRMED'));
      expect(content, contains('SAKINAH_8H_PRAYER_REMINDER_OBSERVED'));
      expect(content, contains('SAKINAH_24H_PRAYER_REMINDER_OBSERVED'));
      expect(content, contains('SAKINAH_REBOOT_REMINDER_RESTORE_OBSERVED'));
      expect(content, contains('SAKINAH_BATTERY_POLICY_REVIEWED'));
      expect(content, contains('SAKINAH_OEM_OBSERVATION_OWNER_ASSIGNED'));
      expect(content, contains('RECEIVE_BOOT_COMPLETED'));
      expect(content, contains('No tester personal data'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_android_oem_reminder_observation_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Android OEM reminder observation packet exported'),
      );

      final manifest =
          File('build/android-oem-reminder-observation/manifest.txt')
              .readAsStringSync();
      final observation = File(
              'build/android-oem-reminder-observation/long_window_observation_log.csv')
          .readAsStringSync();
      final reboot = File(
              'build/android-oem-reminder-observation/reboot_delivery_checklist.csv')
          .readAsStringSync();
      final battery = File(
              'build/android-oem-reminder-observation/battery_policy_review.csv')
          .readAsStringSync();
      final deviceSnapshot = File(
              'build/android-oem-reminder-observation/device_environment_snapshot.txt')
          .readAsStringSync();
      final checklist = File(
              'build/android-oem-reminder-observation/oem_observation_checklist.md')
          .readAsStringSync();

      expect(manifest, contains('Android OEM reminder observation packet'));
      expect(manifest, contains('com.sakinahdaily.app'));
      expect(manifest, contains('No tester personal data'));
      expect(
        observation,
        contains(
          'observation_window,device_serial,oem_or_model,scheduled_reminder_type,scheduled_local_time,expected_delivery_window,actual_delivery_result,tap_result,notes_without_personal_data',
        ),
      );
      expect(observation, contains('8h'));
      expect(observation, contains('24h'));
      expect(reboot, contains('reboot_restore'));
      expect(reboot, contains('RECEIVE_BOOT_COMPLETED'));
      expect(battery, contains('battery_policy_state'));
      expect(battery, contains('aggressive battery-management'));
      expect(
          deviceSnapshot, contains('Android OEM device environment snapshot'));
      expect(deviceSnapshot, contains('Privacy rule: No tester personal data'));
      expect(checklist, contains('8-hour prayer reminder'));
      expect(checklist, contains('24-hour prayer reminder'));
      expect(checklist, contains('device_environment_snapshot.txt'));
      expect(checklist, contains('after device reboot'));
      expect(checklist, contains('do not record tester personal data'));
      expect(checklist, contains('lock-screen copy'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_android_oem_reminder_observation_packet.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_ANDROID_OEM_REMINDER_OBSERVATION_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Android OEM reminder observation packet failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_ANDROID_OEM_TEST_DEVICE_CONFIRMED=true'),
      );

      expect(docsIndex,
          contains('export_android_oem_reminder_observation_packet.sh'));
      expect(readiness, contains('Android OEM reminder observation packet'));
      expect(androidChecklist,
          contains('Android OEM reminder observation packet'));
      expect(androidChecklist, contains('device_environment_snapshot.txt'));
      expect(
          productProgress, contains('Android OEM reminder observation packet'));
      expect(productProgress, contains('device environment snapshot'));
      expect(acceptance, contains('Android OEM reminder observation packet'));
      expect(versionNotes, contains('Android OEM reminder observation packet'));
    });

    test('local e2e gate is scripted and documented', () {
      final script = File('scripts/verify_local_e2e.sh');
      final workflow = File('.github/workflows/local-e2e.yml');
      final pullRequestTemplate = File('.github/PULL_REQUEST_TEMPLATE.md');
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('flutter --no-version-check test'));
      expect(content, contains('--concurrency=1'));
      expect(content, contains('SAKINAH_E2E_FLUTTER_TEST_ARGS'));
      expect(content, contains('dart analyze'));
      expect(content, contains('verify_google_play_submission_pack.sh'));
      expect(content, contains('verify_google_play_public_links_packet.sh'));
      expect(content, contains('export_google_analytics_debugview_packet.sh'));
      expect(content, contains('SAKINAH_E2E_SKIP_ANALYTICS_DEBUGVIEW_PACKET'));
      expect(content, contains('export_reviewed_content_pack_readiness.sh'));
      expect(content, contains('SAKINAH_E2E_SKIP_REVIEWED_CONTENT_PACK'));
      expect(content,
          contains('export_android_oem_reminder_observation_packet.sh'));
      expect(
          content, contains('SAKINAH_E2E_SKIP_ANDROID_OEM_OBSERVATION_PACKET'));
      expect(content, contains('verify_android_launch_smoke.sh'));
      expect(content, contains('SAKINAH_E2E_RUN_RELEASE_GATE'));
      expect(content, contains('SAKINAH_E2E_SKIP_ANDROID_LAUNCH'));
      expect(content, contains('android-arm64'));
      expect(readiness, contains('Local e2e gate'));
      expect(readiness, contains('Google Analytics DebugView QA packet'));
      expect(readiness, contains('actions/checkout@v6'));
      expect(readiness, contains('Node 24-compatible checkout'));
      expect(acceptance, contains('scripts/verify_local_e2e.sh'));
      expect(acceptance, contains('Google Analytics DebugView QA packet'));

      expect(workflow.existsSync(), isTrue);
      final workflowContent = workflow.readAsStringSync();
      expect(workflowContent, contains('name: Local E2E'));
      expect(workflowContent, contains('pull_request'));
      expect(workflowContent, contains('push'));
      expect(workflowContent, contains('actions/checkout@v6'));
      expect(workflowContent, isNot(contains('actions/checkout@v4')));
      expect(workflowContent, contains('subosito/flutter-action'));
      expect(workflowContent, contains('python3 -m pip install --user pillow'));
      expect(workflowContent, contains('scripts/verify_local_e2e.sh'));
      expect(workflowContent, contains('SAKINAH_E2E_SKIP_ANDROID_LAUNCH'));
      expect(workflowContent, contains('SAKINAH_E2E_SKIP_FLUTTER_TEST'));
      expect(workflowContent,
          isNot(contains('SAKINAH_E2E_RUN_RELEASE_GATE: true')));

      expect(pullRequestTemplate.existsSync(), isTrue);
      final template = pullRequestTemplate.readAsStringSync();
      expect(template, contains('Commands Run'));
      expect(template, contains('scripts/verify_local_e2e.sh'));
      expect(template, contains('Product Constraints'));
      expect(template, contains("Women's Ibadah Mode remains local-first"));
      expect(template, contains('No secrets'));
    });

    test('Google Play closed testing launch pack is documented', () {
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();
      final settingsPage =
          File('lib/features/settings/settings_page.dart').readAsStringSync();
      final testingGuidePage =
          File('lib/features/settings/closed_testing_guide_page.dart')
              .readAsStringSync();
      final testingGuideTest =
          File('test/closed_testing_guide_test.dart').readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final models =
          File('lib/core/models/sakinah_models.dart').readAsStringSync();
      final providers =
          File('lib/core/providers/app_providers.dart').readAsStringSync();

      expect(launchPack, contains('Sakinah Daily'));
      expect(launchPack, contains('com.sakinahdaily.app'));
      expect(launchPack, contains('Sakinah Daily Alpha Testers'));
      expect(launchPack, contains('sakinah-daily-testers'));
      expect(
        launchPack,
        contains('sakinah-daily-testers@googlegroups.com'),
      );
      expect(
        launchPack,
        contains('https://groups.google.com/g/sakinah-daily-testers'),
      );
      expect(
        launchPack,
        contains(
          'https://play.google.com/apps/testing/com.sakinahdaily.app',
        ),
      );
      expect(
        launchPack,
        contains(
          'https://play.google.com/store/apps/details?id=com.sakinahdaily.app',
        ),
      );
      expect(launchPack, contains('at least 12 opted-in testers'));
      expect(launchPack, contains('14 days continuously'));
      expect(launchPack, contains('feedback email or URL'));
      expect(launchPack, contains('Testing feedback'));
      expect(launchPack, contains('Closed testing guide'));
      expect(launchPack, contains('Daily tester checklist'));
      expect(launchPack, contains('copyable feedback templates'));
      expect(launchPack, contains('feedback-sent checklist'));
      expect(
        launchPack,
        contains('Please avoid personal or sensitive health details'),
      );
      expect(launchPack, contains('Production access'));
      expect(launchPack, contains('邀请加入 Sakinah Daily 封闭测试'));
      expect(launchPack, contains('不要把 leave testing 链接当作邀请链接'));
      expect(
        launchPack,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/14151465',
        ),
      );
      expect(
        launchPack,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/9845334',
        ),
      );

      expect(docsIndex, contains('09_GOOGLE_PLAY_CLOSED_TESTING.md'));
      expect(readiness, contains('Google Play closed-testing launch pack'));
      expect(readiness, contains('Closed testing guide'));
      expect(androidChecklist, contains('sakinah-daily-testers'));
      expect(versionNotes, contains('closed-testing launch pack'));
      expect(settingsPage, contains('settingsClosedTestingGuideTile'));
      expect(settingsPage, contains('/settings/testing-guide'));
      expect(testingGuidePage, contains('closedTestingGuideNextPrompt'));
      expect(testingGuidePage, contains('closedTestingNextFeedback'));
      expect(testingGuidePage, contains('closedTestingAllFeedbackSent'));
      expect(testingGuidePage, contains('closedTestingChecklistDailyOpen'));
      expect(testingGuidePage, contains('closedTestingChecklistPrayer'));
      expect(testingGuidePage, contains('closedTestingChecklistSession'));
      expect(testingGuidePage, contains('closedTestingChecklistPrivacy'));
      expect(testingGuidePage, contains('closedTestingPromptTitle'));
      expect(testingGuidePage, contains('closedTestingPromptDay1'));
      expect(testingGuidePage, contains('closedTestingPromptDay3'));
      expect(testingGuidePage, contains('closedTestingPromptDay7'));
      expect(testingGuidePage, contains('closedTestingPromptDay14'));
      expect(testingGuidePage, contains('closedTestingPromptDay1CopyButton'));
      expect(testingGuidePage, contains('closedTestingPromptDay3CopyButton'));
      expect(testingGuidePage, contains('closedTestingPromptDay7CopyButton'));
      expect(testingGuidePage, contains('closedTestingPromptDay14CopyButton'));
      expect(
        testingGuidePage,
        contains('closedTestingPromptDay1CompletedCheckbox'),
      );
      expect(
        testingGuidePage,
        contains('closedTestingPromptDay3CompletedCheckbox'),
      );
      expect(
        testingGuidePage,
        contains('closedTestingPromptDay7CompletedCheckbox'),
      );
      expect(
        testingGuidePage,
        contains('closedTestingPromptDay14CompletedCheckbox'),
      );
      expect(testingGuidePage, contains('setClosedTestingPromptCompleted'));
      expect(testingGuidePage, contains('closedTestingPromptCopyHeader'));
      expect(testingGuidePage, contains('closedTestingPromptCopyThemeLabel'));
      expect(testingGuidePage, contains('onboarding_location_clarity'));
      expect(testingGuidePage, contains('prayer_time_trust'));
      expect(testingGuidePage, contains('retention_reason_to_return'));
      expect(testingGuidePage, contains('closedTestingPromptCopyPrivacyLine'));
      expect(testingGuidePage, contains('closedTestingPromptFeedbackSent'));
      expect(testingGuidePage, contains('closedTestingPromptLocalOnlyStatus'));
      expect(testingGuidePage, contains('closedTestingFeedbackCopyButton'));
      expect(
        testingGuideTest,
        contains('Settings opens closed testing guide when feedback'),
      );
      expect(testingGuideTest, contains('Feedback prompts'));
      expect(testingGuideTest, contains('Did onboarding explain location'));
      expect(
        testingGuideTest,
        contains('Suggested theme: onboarding_location_clarity'),
      );
      expect(
        testingGuideTest,
        contains('Were prayer times, location, and reminder controls'),
      );
      expect(
        testingGuideTest,
        contains('Suggested theme: prayer_time_trust'),
      );
      expect(testingGuideTest, contains('What made you want to reopen'));
      expect(
        testingGuideTest,
        contains('What one change would most improve daily use'),
      );
      expect(
        testingGuideTest,
        contains('Feedback prompt copied.'),
      );
      expect(
        testingGuideTest,
        contains('Please avoid personal or sensitive health details.'),
      );
      expect(
        testingGuideTest,
        contains('Closed testing prompt completion is local and persistent'),
      );
      expect(
        testingGuideTest,
        contains('Closed testing guide surfaces next unsent feedback prompt'),
      );
      expect(
        testingGuideTest,
        contains('Closed testing guide summarizes all feedback sent'),
      );
      expect(testingGuideTest, contains('Stored only on this device.'));
      expect(models, contains('completedClosedTestingPromptDays'));
      expect(models, contains('closedTestingPromptDayIds'));
      expect(providers, contains('setClosedTestingPromptCompleted'));
      expect(
        testingGuideTest,
        contains('Settings hides closed testing guide without feedback'),
      );
      expect(keys, contains('settingsClosedTestingGuideTile'));
      expect(keys, contains('closedTestingGuidePage'));
      expect(keys, contains('closedTestingGuideNextPrompt'));
      expect(keys, contains('closedTestingPromptDay1'));
      expect(keys, contains('closedTestingPromptDay3'));
      expect(keys, contains('closedTestingPromptDay7'));
      expect(keys, contains('closedTestingPromptDay14'));
      expect(keys, contains('closedTestingPromptDay1CopyButton'));
      expect(keys, contains('closedTestingPromptDay3CopyButton'));
      expect(keys, contains('closedTestingPromptDay7CopyButton'));
      expect(keys, contains('closedTestingPromptDay14CopyButton'));
      expect(keys, contains('closedTestingPromptDay1CompletedCheckbox'));
      expect(keys, contains('closedTestingPromptDay3CompletedCheckbox'));
      expect(keys, contains('closedTestingPromptDay7CompletedCheckbox'));
      expect(keys, contains('closedTestingPromptDay14CompletedCheckbox'));
    });

    test('Google Play closed testing evidence log is scripted and documented',
        () {
      final evidenceLogFile =
          File('docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md');
      final evidenceScript =
          File('scripts/verify_google_play_closed_testing_evidence.sh');
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(evidenceLogFile.existsSync(), isTrue);
      expect(evidenceScript.existsSync(), isTrue);
      final mode = evidenceScript.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final evidenceLog = evidenceLogFile.readAsStringSync();
      expect(evidenceLog, contains('12 opted-in testers'));
      expect(evidenceLog, contains('14 continuous days'));
      expect(evidenceLog, contains('No tester personal data'));
      expect(evidenceLog, contains('Feedback themes'));
      expect(evidenceLog, contains('Changes made'));
      expect(evidenceLog, contains('Production access answers'));
      expect(evidenceLog, contains('Opted-in testers'));
      expect(evidenceLog, contains('Day 0'));
      expect(evidenceLog, contains('Day 14'));
      expect(
        evidenceLog,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/14151465',
        ),
      );

      final scriptContent = evidenceScript.readAsStringSync();
      expect(
          scriptContent, contains('SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE'));
      expect(scriptContent, contains('12'));
      expect(scriptContent, contains('14'));
      expect(scriptContent, contains('Day 14'));
      expect(scriptContent, contains('Opted-in testers'));
      expect(scriptContent, contains('Feedback reviewed'));
      expect(scriptContent, contains('Production access'));
      expect(
        scriptContent,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/14151465',
        ),
      );

      final templateRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_closed_testing_evidence.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Google Play closed-testing evidence passed'),
      );

      final strictRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_closed_testing_evidence.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_CLOSED_TESTING_COMPLETE': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('closed testing evidence is not complete'),
      );

      expect(docsIndex, contains('12_CLOSED_TESTING_EVIDENCE_LOG.md'));
      expect(readiness, contains('closed-testing evidence log'));
      expect(
        androidChecklist,
        contains('verify_google_play_closed_testing_evidence.sh'),
      );
      expect(launchPack, contains('12_CLOSED_TESTING_EVIDENCE_LOG.md'));
      expect(
        launchPack,
        contains('verify_google_play_closed_testing_evidence.sh'),
      );
      expect(versionNotes, contains('closed-testing evidence log'));
    });

    test('Google Play upload preflight is scripted and documented', () {
      final script = File('scripts/verify_google_play_upload_preflight.sh');
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('com.sakinahdaily.app'));
      expect(content, contains('sakinah-daily-testers@googlegroups.com'));
      expect(content, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(content, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(content, contains('SAKINAH_PLAY_TESTER_GROUP_EMAIL'));
      expect(content, contains('SAKINAH_PLAY_TESTER_GROUP_CREATED'));
      expect(content, contains('SAKINAH_PLAY_CLOSED_TRACK_READY'));
      expect(content, contains('SAKINAH_PLAY_APP_CONTENT_READY'));
      expect(content, contains('SAKINAH_PLAY_STORE_LISTING_READY'));
      expect(content, contains('SAKINAH_PREFLIGHT_SKIP_RELEASE_GATE'));
      expect(content, contains('verify_google_play_public_links.sh'));
      expect(content, contains('has_env_signing'));
      expect(content, contains('has_local_signing'));
      expect(content, contains('verify_google_play_internal_release.sh'));
      expect(content,
          contains('build/app/outputs/bundle/release/app-release.aab'));
      expect(content, contains('build/play-internal/app-release.aab.sha256'));
      expect(content, contains('android/key.properties'));
      expect(content, contains('key.properties'));
      expect(content, contains('service-account.json'));
      expect(
          content, isNot(contains('SAKINAH_ALLOW_UNSIGNED_RELEASE_QA=true')));

      final dryRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_upload_preflight.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(dryRun.exitCode, isNot(0));
      expect(
        dryRun.stderr.toString(),
        contains('Play upload preflight failed'),
      );

      expect(readiness, contains('Google Play upload preflight script'));
      expect(
        readiness,
        contains('does not accept unsigned release QA as upload evidence'),
      );
      expect(
        androidChecklist,
        contains('verify_google_play_upload_preflight.sh'),
      );
      expect(androidChecklist, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(androidChecklist, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(androidChecklist, contains('SAKINAH_PLAY_TESTER_GROUP_CREATED'));
      expect(androidChecklist, contains('SAKINAH_PLAY_CLOSED_TRACK_READY'));
      expect(launchPack, contains('verify_google_play_upload_preflight.sh'));
      expect(versionNotes, contains('Google Play upload preflight'));
    });

    test('Google Play upload evidence packet can be exported', () {
      final script = File('scripts/export_google_play_upload_packet.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_REQUIRE_PLAY_UPLOAD_PACKET_READY'));
      expect(content, contains('build/play-upload'));
      expect(content, contains('manifest.txt'));
      expect(content, contains('verify_google_play_upload_preflight.sh'));
      expect(content, contains('verify_google_play_store_assets.sh'));
      expect(content,
          contains('build/app/outputs/bundle/release/app-release.aab'));
      expect(content, contains('build/play-internal/app-release.aab.sha256'));
      expect(content, contains('google-play-feature-graphic.png'));
      expect(content, contains('android-contact-sheet.png'));
      expect(content, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(content, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_upload_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Google Play upload evidence packet exported'),
      );

      final manifest =
          File('build/play-upload/manifest.txt').readAsStringSync();
      expect(manifest, contains('Google Play upload evidence packet'));
      expect(manifest, contains('com.sakinahdaily.app'));
      expect(manifest, contains('No tester personal data'));
      expect(manifest, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(manifest, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(
        manifest,
        contains('scripts/verify_google_play_upload_preflight.sh'),
      );
      expect(manifest,
          contains('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_upload_packet.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_PLAY_UPLOAD_PACKET_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Play upload preflight failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PRIVACY_POLICY_URL is required'),
      );

      expect(docsIndex, contains('export_google_play_upload_packet.sh'));
      expect(readiness, contains('Google Play upload evidence packet'));
      expect(androidChecklist, contains('export_google_play_upload_packet.sh'));
      expect(
        submissionRunbook,
        contains('export_google_play_upload_packet.sh'),
      );
      expect(versionNotes, contains('Google Play upload evidence packet'));
    });

    test('Google Play Console submission pack is scripted and documented', () {
      final runbookFile =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md');
      final script = File('scripts/verify_google_play_submission_pack.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(runbookFile.existsSync(), isTrue);
      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final runbook = runbookFile.readAsStringSync();
      expect(runbook, contains('Play Console submission pack'));
      expect(runbook, contains('Sakinah Daily'));
      expect(runbook, contains('com.sakinahdaily.app'));
      expect(runbook, contains('Main store listing'));
      expect(runbook, contains('App content'));
      expect(runbook, contains('App access'));
      expect(runbook, contains('Ads'));
      expect(runbook, contains('Content rating'));
      expect(runbook, contains('Target audience and content'));
      expect(runbook, contains('Data safety'));
      expect(runbook, contains('Privacy policy'));
      expect(runbook, contains('Store settings'));
      expect(runbook, contains('Feature graphic'));
      expect(runbook, contains('Phone screenshots'));
      expect(runbook, contains('Closed testing release'));
      expect(runbook, contains('Production access'));
      expect(runbook, contains('docs/release/04_STORE_METADATA_DRAFT.md'));
      expect(runbook,
          contains('docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md'));
      expect(runbook, contains('docs/release/05_SCREENSHOT_PLAN.md'));
      expect(
          runbook, contains('scripts/verify_google_play_upload_preflight.sh'));
      expect(
        runbook,
        contains('scripts/export_google_analytics_debugview_packet.sh'),
      );
      expect(
        runbook,
        contains('scripts/verify_google_play_closed_testing_evidence.sh'),
      );
      expect(
        runbook,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/9859455',
        ),
      );

      final scriptContent = script.readAsStringSync();
      expect(scriptContent, contains('SAKINAH_REQUIRE_PLAY_SUBMISSION_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_CONSOLE_APP_CREATED'));
      expect(scriptContent, contains('SAKINAH_PLAY_MAIN_STORE_LISTING_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_APP_ACCESS_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_ADS_DECLARATION_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_CONTENT_RATING_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_TARGET_AUDIENCE_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_DATA_SAFETY_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_PRIVACY_POLICY_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_STORE_SETTINGS_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_RELEASE_NOTES_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_SCREENSHOTS_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_FEATURE_GRAPHIC_READY'));
      expect(
        scriptContent,
        contains('SAKINAH_PLAY_CLOSED_TEST_RELEASE_DRAFTED'),
      );
      expect(scriptContent, contains('verify_google_play_upload_preflight.sh'));
      expect(
        scriptContent,
        contains('export_google_analytics_debugview_packet.sh'),
      );
      expect(
        scriptContent,
        contains('verify_google_play_closed_testing_evidence.sh'),
      );

      final templateRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_submission_pack.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Google Play submission pack passed'),
      );
      final analyticsManifest =
          File('build/google-analytics-debugview/manifest.txt')
              .readAsStringSync();
      expect(
        analyticsManifest,
        contains('Google Analytics DebugView QA packet'),
      );

      final strictRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_submission_pack.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_PLAY_SUBMISSION_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Play Console submission pack failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PLAY_CONSOLE_APP_CREATED=true'),
      );

      expect(docsIndex, contains('13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md'));
      expect(readiness, contains('Play Console submission pack'));
      expect(
        androidChecklist,
        contains('verify_google_play_submission_pack.sh'),
      );
      expect(launchPack, contains('13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md'));
      expect(versionNotes, contains('Play Console submission pack'));
    });

    test('Google Play Production access answer pack is scripted and documented',
        () {
      final answerDraftFile =
          File('docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md');
      final script =
          File('scripts/verify_google_play_production_access_pack.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final evidenceLog = File('docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md')
          .readAsStringSync();
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(answerDraftFile.existsSync(), isTrue);
      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final answerDraft = answerDraftFile.readAsStringSync();
      expect(answerDraft, contains('Production access answer draft'));
      expect(answerDraft, contains('Closed test summary'));
      expect(answerDraft, contains('How many testers joined'));
      expect(answerDraft, contains('14 continuous days'));
      expect(answerDraft, contains('What feedback did you receive'));
      expect(answerDraft, contains('What changes did you make'));
      expect(answerDraft, contains('Why is the app ready for Production'));
      expect(answerDraft, contains('Intended users and value'));
      expect(answerDraft, contains('Sakinah Daily Alpha Testers'));
      expect(answerDraft, contains('sakinah-daily-testers@googlegroups.com'));
      expect(answerDraft, contains('com.sakinahdaily.app'));
      expect(answerDraft, contains('No tester personal data'));
      expect(answerDraft,
          contains('docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md'));
      expect(answerDraft,
          contains('docs/release/01_RELEASE_READINESS_CHECKLIST.md'));
      expect(
          answerDraft, contains('build/play-internal/app-release.aab.sha256'));
      expect(
        answerDraft,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/14151465',
        ),
      );

      final scriptContent = script.readAsStringSync();
      expect(
          scriptContent, contains('SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY'));
      expect(scriptContent,
          contains('verify_google_play_closed_testing_evidence.sh'));
      expect(scriptContent, contains('14_PRODUCTION_ACCESS_ANSWER_DRAFT.md'));
      expect(scriptContent, contains('Production access answer pack passed'));
      expect(scriptContent,
          contains('SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED'));
      expect(scriptContent, contains('SAKINAH_PLAY_FEEDBACK_SUMMARY_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_CHANGES_SUMMARY_READY'));
      expect(scriptContent, contains('SAKINAH_PLAY_READINESS_EVIDENCE_READY'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_production_access_pack.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Production access answer pack passed'),
      );

      final strictRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_production_access_pack.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_PRODUCTION_ACCESS_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Production access answer pack failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED=true'),
      );

      expect(docsIndex, contains('14_PRODUCTION_ACCESS_ANSWER_DRAFT.md'));
      expect(readiness, contains('Production access answer pack'));
      expect(
        submissionRunbook,
        contains('verify_google_play_production_access_pack.sh'),
      );
      expect(evidenceLog, contains('14_PRODUCTION_ACCESS_ANSWER_DRAFT.md'));
      expect(launchPack, contains('Production access answer draft'));
      expect(versionNotes, contains('Production access answer pack'));
    });

    test('Google Play Production access evidence packet can be exported', () {
      final script =
          File('scripts/export_google_play_production_access_packet.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final answerDraft =
          File('docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final scriptContent = script.readAsStringSync();
      expect(scriptContent,
          contains('SAKINAH_REQUIRE_PRODUCTION_ACCESS_PACKET_READY'));
      expect(scriptContent, contains('build/play-production-access'));
      expect(scriptContent, contains('manifest.txt'));
      expect(scriptContent, contains('14_PRODUCTION_ACCESS_ANSWER_DRAFT.md'));
      expect(scriptContent, contains('12_CLOSED_TESTING_EVIDENCE_LOG.md'));
      expect(scriptContent,
          contains('verify_google_play_production_access_pack.sh'));
      expect(scriptContent, contains('app-release.aab.sha256'));
      expect(scriptContent, contains('google-play-feature-graphic.png'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_production_access_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Production access evidence packet exported'),
      );

      final manifest =
          File('build/play-production-access/manifest.txt').readAsStringSync();
      expect(manifest, contains('Production access evidence packet'));
      expect(manifest, contains('com.sakinahdaily.app'));
      expect(manifest, contains('No tester personal data'));
      expect(manifest,
          contains('docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md'));
      expect(
          manifest, contains('docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md'));
      expect(manifest,
          contains('scripts/verify_google_play_production_access_pack.sh'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_production_access_packet.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_PRODUCTION_ACCESS_PACKET_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Production access answer pack failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PLAY_PRODUCTION_ACCESS_DRAFT_REVIEWED=true'),
      );

      expect(docsIndex,
          contains('export_google_play_production_access_packet.sh'));
      expect(readiness, contains('Production access evidence packet'));
      expect(
        submissionRunbook,
        contains('export_google_play_production_access_packet.sh'),
      );
      expect(answerDraft,
          contains('export_google_play_production_access_packet.sh'));
      expect(versionNotes, contains('Production access evidence packet'));
    });

    test('Google Play closed-test retention observation packet can be exported',
        () {
      final observationPlanFile =
          File('docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md');
      final script =
          File('scripts/export_google_play_closed_test_retention_packet.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final evidenceLog = File('docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md')
          .readAsStringSync();
      final runbook = File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
          .readAsStringSync();
      final answerDraft =
          File('docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md')
              .readAsStringSync();
      final launchDayChecklist =
          File('docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();
      final productionExporter =
          File('scripts/export_google_play_production_access_packet.sh')
              .readAsStringSync();
      final productionVerifier =
          File('scripts/verify_google_play_production_access_pack.sh')
              .readAsStringSync();

      expect(observationPlanFile.existsSync(), isTrue);
      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final observationPlan = observationPlanFile.readAsStringSync();
      expect(
          observationPlan, contains('Closed-test retention observation plan'));
      expect(observationPlan, contains('Weekly Active Prayer Reminder Users'));
      expect(observationPlan, contains('Prayer Reminder Opt-in Rate'));
      expect(observationPlan, contains('Day 1'));
      expect(observationPlan, contains('Day 3'));
      expect(observationPlan, contains('Day 7'));
      expect(observationPlan, contains('Day 14'));
      expect(observationPlan, contains('No tester personal data'));
      expect(observationPlan,
          contains('Please avoid personal or sensitive health details'));
      expect(
        observationPlan,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/14151465',
        ),
      );

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY'));
      expect(content, contains('build/play-retention-observation'));
      expect(content, contains('daily_observation_template.csv'));
      expect(content, contains('feedback_theme_template.csv'));
      expect(content, contains('production_access_decisions_template.csv'));
      expect(content, contains('SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE'));
      expect(content, contains('SAKINAH_PLAY_TESTING_FEEDBACK_READY'));
      expect(content, contains('SAKINAH_PLAY_RETENTION_OWNER_ASSIGNED'));
      expect(content, contains('SAKINAH_PLAY_RETENTION_REVIEW_SCHEDULED'));
      expect(content, contains('SAKINAH_PLAY_EVIDENCE_LOG_READY'));
      expect(content, contains('No tester personal data'));
      expect(content, contains('Day 1'));
      expect(content, contains('Day 3'));
      expect(content, contains('Day 7'));
      expect(content, contains('Day 14'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_closed_test_retention_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains(
            'Google Play closed-test retention observation packet exported'),
      );

      final manifest = File('build/play-retention-observation/manifest.txt')
          .readAsStringSync();
      final dailyCsv = File(
              'build/play-retention-observation/daily_observation_template.csv')
          .readAsStringSync();
      final feedbackCsv =
          File('build/play-retention-observation/feedback_theme_template.csv')
              .readAsStringSync();
      final decisionsCsv = File(
        'build/play-retention-observation/production_access_decisions_template.csv',
      ).readAsStringSync();

      expect(manifest,
          contains('Google Play closed-test retention observation packet'));
      expect(manifest, contains('No tester personal data'));
      expect(manifest, contains('daily_observation_template.csv'));
      expect(manifest, contains('feedback_theme_template.csv'));
      expect(manifest, contains('production_access_decisions_template.csv'));
      expect(dailyCsv, contains('test_day,calendar_date,version_code'));
      expect(dailyCsv, contains('Day 1'));
      expect(dailyCsv, contains('Day 3'));
      expect(dailyCsv, contains('Day 7'));
      expect(dailyCsv, contains('Day 14'));
      expect(dailyCsv, contains('prayer_view_signal'));
      expect(dailyCsv, contains('reminder_opt_in_signal'));
      expect(dailyCsv, contains('suggested_theme_key'));
      expect(dailyCsv, contains('prayer_time_trust'));
      expect(dailyCsv, contains('retention_reason_to_return'));
      expect(feedbackCsv, contains('theme,severity,source,decision'));
      expect(feedbackCsv, contains('onboarding_location_clarity'));
      expect(feedbackCsv, contains('reminder_usefulness_or_annoyance'));
      expect(feedbackCsv, contains('localization_rtl_or_bahasa'));
      expect(decisionsCsv,
          contains('decision_date,feedback_theme,change_or_decision'));
      expect(decisionsCsv, contains('production_access_answer_note'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_closed_test_retention_packet.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_RETENTION_OBSERVATION_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('closed-test retention observation packet failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE=true'),
      );

      expect(
          docsIndex, contains('17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md'));
      expect(readiness, contains('closed-test retention observation packet'));
      expect(launchPack,
          contains('export_google_play_closed_test_retention_packet.sh'));
      expect(evidenceLog, contains('retention observation packet'));
      expect(runbook,
          contains('export_google_play_closed_test_retention_packet.sh'));
      expect(answerDraft,
          contains('17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md'));
      expect(launchDayChecklist, contains('retention observation packet'));
      expect(
          versionNotes, contains('closed-test retention observation packet'));
      expect(productionExporter,
          contains('export_google_play_closed_test_retention_packet.sh'));
      expect(productionVerifier,
          contains('17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md'));
    });

    test('Google Analytics DebugView QA packet can be exported', () {
      final script =
          File('scripts/export_google_analytics_debugview_packet.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final analyticsPlan =
          File('docs/privacy/07_GOOGLE_ANALYTICS_EVENT_PLAN.md')
              .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final retentionPlan =
          File('docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('build/google-analytics-debugview'));
      expect(content, contains('debugview_checklist.md'));
      expect(content, contains('analytics_events_catalog.csv'));
      expect(content, contains('retention_funnel_debugview.csv'));
      expect(content, contains('blocked_parameter_review.csv'));
      expect(content, contains('SAKINAH_REQUIRE_ANALYTICS_DEBUGVIEW_READY'));
      expect(content, contains('SAKINAH_ANALYTICS_ENABLED=true'));
      expect(content, contains('debug.firebase.analytics.app'));
      expect(content, contains('com.sakinahdaily.app'));
      expect(content, contains('home_session_completion'));
      expect(content, contains('daily_session_reminder_changed'));
      expect(content, contains('daily_session_reminder_permission_result'));
      expect(content, contains('analytics_consent_changed'));
      expect(content, contains('notification_settings_viewed'));
      expect(content, contains('prayer_reminder_permission_result'));
      expect(content, contains('prayer_location_changed'));
      expect(content, contains('qibla_viewed'));
      expect(content, contains('notification_tap_opened'));
      expect(content, contains('home_prayer_badge'));
      expect(content, contains('prayer_page_card'));
      expect(content, contains('settings_prayer_location'));
      expect(content, contains('manual_location_page'));
      expect(content, contains('home_progress_card'));
      expect(content, contains('prayer_completion_card'));
      expect(content, contains('prayer_page_checklist'));
      expect(readiness, contains('prayer_page_card'));
      expect(readiness, contains('prayer_location_changed'));
      expect(readiness, contains('prayer_completion_card'));
      expect(retentionPlan, contains('notification_settings_viewed'));
      expect(retentionPlan, contains('prayer_reminder_permission_result'));
      expect(retentionPlan, contains('prayer_location_changed'));
      expect(
          retentionPlan, contains('daily_session_reminder_permission_result'));
      expect(retentionPlan, contains('prayer_page_card'));
      expect(retentionPlan, contains('prayer_completion_card'));
      expect(retentionPlan, contains('prayer_page_checklist'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_google_analytics_debugview_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Google Analytics DebugView QA packet exported'),
      );

      final manifest = File('build/google-analytics-debugview/manifest.txt')
          .readAsStringSync();
      final checklist =
          File('build/google-analytics-debugview/debugview_checklist.md')
              .readAsStringSync();
      final events =
          File('build/google-analytics-debugview/analytics_events_catalog.csv')
              .readAsStringSync();
      final funnel = File(
              'build/google-analytics-debugview/retention_funnel_debugview.csv')
          .readAsStringSync();
      final blocked =
          File('build/google-analytics-debugview/blocked_parameter_review.csv')
              .readAsStringSync();

      expect(manifest, contains('Google Analytics DebugView QA packet'));
      expect(manifest, contains('No tester personal data'));
      expect(manifest, contains('SAKINAH_ANALYTICS_ENABLED=true'));
      expect(manifest, contains('Firebase DebugView'));
      expect(
        manifest,
        contains('https://firebase.google.com/docs/analytics/debugview'),
      );

      expect(
        checklist,
        contains(
          'adb shell setprop debug.firebase.analytics.app com.sakinahdaily.app',
        ),
      );
      expect(
        checklist,
        contains('adb shell setprop debug.firebase.analytics.app .none.'),
      );
      expect(checklist, contains('Privacy Center usage analytics opt-in'));
      expect(checklist, contains('Store screenshot mode forces analytics off'));

      expect(
        events,
        contains(
          'event_name,qa_flow,expected_parameters,forbidden_parameters,retention_signal',
        ),
      );
      expect(events, contains('home_viewed'));
      expect(events, contains('qibla_viewed'));
      expect(events, contains('prayer_location_changed'));
      expect(events, contains('prayer_reminder_changed'));
      expect(events, contains('notification_settings_viewed'));
      expect(events, contains('prayer_reminder_permission_result'));
      expect(events, contains('home_prayer_card'));
      expect(events, contains('home_prayer_badge'));
      expect(events, contains('home_progress_card'));
      expect(events, contains('prayer_page_card'));
      expect(events, contains('settings_prayer_location'));
      expect(events, contains('manual_location_page'));
      expect(events, contains('prayer_completion_card'));
      expect(events, contains('prayer_page_checklist'));
      expect(events, contains('notification_tap_opened'));
      expect(events, contains('analytics_consent_changed'));
      expect(events, contains('daily_session_started'));
      expect(events, contains('daily_session_step_viewed'));
      expect(events, contains('daily_session_completed'));
      expect(events, contains('daily_session_reminder_permission_result'));
      expect(events, contains('daily_session_reminder_changed'));
      expect(events, contains('home_session_completion'));
      expect(events, contains('dua_viewed'));
      expect(events, contains('dua_saved'));
      expect(events, contains('dhikr_started'));
      expect(events, contains('dhikr_completed'));
      expect(events, contains('women_ibadah_mode_changed'));
      expect(events, contains('closed_test_prompt_copied'));

      expect(funnel, contains('Prayer Reminder Opt-in Rate'));
      expect(funnel, contains('Qibla View Rate'));
      expect(funnel, contains('Prayer Settings Completion Rate'));
      expect(funnel, contains('prayer_location_changed'));
      expect(funnel, contains('Reminder Setup View Rate'));
      expect(funnel, contains('notification_settings_viewed'));
      expect(funnel, contains('Prayer Reminder Permission Outcome Rate'));
      expect(funnel, contains('prayer_reminder_permission_result'));
      expect(funnel, contains('home_prayer_card'));
      expect(funnel, contains('prayer_page_card'));
      expect(funnel, contains('prayer_completion_card'));
      expect(funnel, contains('Push Open Rate'));
      expect(funnel, contains('Analytics Consent Rate'));
      expect(funnel, contains('Daily Session Start Rate'));
      expect(
        funnel,
        contains('Daily Session Reminder Permission Outcome Rate'),
      );
      expect(funnel, contains('daily_session_reminder_permission_result'));
      expect(funnel, contains('session_to_reminder'));
      expect(funnel, contains('daily_session_reminder_changed'));
      expect(funnel, contains('home_session_completion'));
      expect(funnel, contains('Dua Detail View Rate'));
      expect(funnel, contains('Dhikr Completion Rate'));
      expect(funnel, contains('Women Mode Trust Signal'));

      expect(blocked, contains('latitude'));
      expect(blocked, contains('longitude'));
      expect(blocked, contains('location_label'));
      expect(blocked, contains('timezone_id'));
      expect(blocked, contains('qibla_bearing'));
      expect(blocked, contains('women_ibadah_status'));
      expect(blocked, contains('feedback_text'));
      expect(blocked, contains('quran_arabic_text'));
      expect(blocked, contains('reminder_time'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_google_analytics_debugview_packet.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_ANALYTICS_DEBUGVIEW_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Google Analytics DebugView QA packet failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_ANALYTICS_ENABLED_CONFIRMED=true'),
      );

      expect(
          docsIndex, contains('export_google_analytics_debugview_packet.sh'));
      expect(analyticsPlan, contains('DebugView QA packet'));
      expect(readiness, contains('Google Analytics DebugView QA packet'));
      expect(readiness, contains('notification_settings_viewed'));
      expect(readiness, contains('prayer_reminder_permission_result'));
      expect(readiness, contains('prayer_location_changed'));
      expect(readiness, contains('qibla_viewed'));
      expect(readiness, contains('daily_session_reminder_permission_result'));
      expect(retentionPlan, contains('DebugView QA packet'));
      expect(versionNotes, contains('Google Analytics DebugView QA packet'));
    });

    test('reviewed content pack readiness packet can be exported', () {
      final script = File('scripts/export_reviewed_content_pack_readiness.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final research =
          File('docs/research/01_COMPETITOR_FEATURE_GAP_PRIORITY.md')
              .readAsStringSync();
      final contentGuidelines =
          File('docs/content/01_CONTENT_GUIDELINES.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('build/reviewed-content-pack-readiness'));
      expect(content, contains('content_inventory.csv'));
      expect(content, contains('source_placeholder_review.csv'));
      expect(content, contains('audio_asset_rights_review.csv'));
      expect(content, contains('beta_pack_gap_checklist.md'));
      expect(content, contains('SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY'));
      expect(content, contains('SAKINAH_QURAN_SOURCE_PLACEHOLDERS_REPLACED'));
      expect(content, contains('SAKINAH_BETA_SESSION_PACK_REVIEWED'));
      expect(content, contains('SAKINAH_DUA_DHIKR_PACK_REVIEWED'));
      expect(content, contains('SAKINAH_QURAN_AUDIO_RIGHTS_CONFIRMED'));
      expect(content, contains('SAKINAH_REVIEWED_CONTENT_PACK_OWNER_ASSIGNED'));
      expect(
        content,
        contains(
          'Seed metadata; replace with approved Quran source before production',
        ),
      );
      expect(content, contains('session_target_min,5'));
      expect(content, contains('dua_target_min,30'));
      expect(content, contains('dhikr_target_min,20'));
      expect(content, contains('quran_ayah_target_min,10'));
      expect(content, contains('No generated religious content'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_reviewed_content_pack_readiness.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Reviewed content pack readiness packet exported'),
      );

      final manifest =
          File('build/reviewed-content-pack-readiness/manifest.txt')
              .readAsStringSync();
      final inventory =
          File('build/reviewed-content-pack-readiness/content_inventory.csv')
              .readAsStringSync();
      final sourceReview = File(
              'build/reviewed-content-pack-readiness/source_placeholder_review.csv')
          .readAsStringSync();
      final audioReview = File(
              'build/reviewed-content-pack-readiness/audio_asset_rights_review.csv')
          .readAsStringSync();
      final checklist = File(
              'build/reviewed-content-pack-readiness/beta_pack_gap_checklist.md')
          .readAsStringSync();

      expect(manifest, contains('Reviewed content pack readiness packet'));
      expect(manifest, contains('No generated religious content'));
      expect(manifest, contains('Seed-only v0.1 baseline'));
      expect(manifest, contains('com.sakinahdaily.app'));

      expect(inventory, contains('content_type,metric,value'));
      expect(inventory, contains('daily_session,current_count,1'));
      expect(inventory, contains('daily_session,reviewed_beta_target_min,5'));
      expect(inventory, contains('quran_ayah,current_count,3'));
      expect(inventory, contains('quran_ayah,reviewed_beta_target_min,10'));
      expect(inventory, contains('quran_ayah,source_placeholder_count,3'));
      expect(inventory, contains('dua,current_count,5'));
      expect(inventory, contains('dua,reviewed_beta_target_min,30'));
      expect(inventory, contains('dhikr,current_count,5'));
      expect(inventory, contains('dhikr,reviewed_beta_target_min,20'));
      expect(inventory, contains('audio_asset,missing_sha256_count,1'));

      expect(
        sourceReview,
        contains('content_type,content_id,current_source,required_action'),
      );
      expect(sourceReview, contains('quran_ayah,1:1'));
      expect(sourceReview, contains('quran_ayah,94:5'));
      expect(sourceReview, contains('quran_ayah,13:28'));
      expect(sourceReview, contains('replace with approved Quran source'));

      expect(
        audioReview,
        contains(
          'audio_asset_id,asset_type,approved,url_present,sha256_present,rights_status,required_action',
        ),
      );
      expect(audioReview, contains('audio_fatiha_minshawi'));
      expect(audioReview, contains('true,false,false'));
      expect(audioReview, contains('licensed reciter'));

      expect(checklist, contains('5-7 reviewed sessions'));
      expect(checklist, contains('30-50 reviewed duas'));
      expect(checklist, contains('20-30 reviewed dhikrs'));
      expect(checklist, contains('10-20 reviewed Quran ayah references'));
      expect(checklist, contains('No Quran source placeholder'));
      expect(checklist, contains('No generated religious content'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_reviewed_content_pack_readiness.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('reviewed content pack readiness failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_QURAN_SOURCE_PLACEHOLDERS_REPLACED=true'),
      );

      expect(docsIndex, contains('export_reviewed_content_pack_readiness.sh'));
      expect(
          productProgress, contains('reviewed content pack readiness packet'));
      expect(research, contains('SAKINAH_REQUIRE_REVIEWED_CONTENT_PACK_READY'));
      expect(contentGuidelines,
          contains('reviewed content pack readiness packet'));
      expect(readiness, contains('Reviewed content pack readiness packet'));
      expect(versionNotes, contains('Reviewed content pack readiness packet'));
    });

    test('Google Play public links are scripted and documented', () {
      final script = File('scripts/verify_google_play_public_links.sh');
      final hostingDoc =
          File('docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md')
              .readAsStringSync();
      final privacyPolicy =
          File('docs/privacy/02_PRIVACY_POLICY_DRAFT.md').readAsStringSync();
      final dataSafety =
          File('docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md')
              .readAsStringSync();
      final appEnvironment =
          File('lib/core/config/app_environment.dart').readAsStringSync();
      final privacyCenter =
          File('lib/features/settings/privacy_center_page.dart')
              .readAsStringSync();
      final settingsPage =
          File('lib/features/settings/settings_page.dart').readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final flavorDoc = File('docs/release/07_BUILD_FLAVORS_AND_DART_DEFINE.md')
          .readAsStringSync();
      final permissionReview =
          File('docs/release/06_PERMISSION_AND_DATA_SAFETY_REVIEW.md')
              .readAsStringSync();
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(content, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(content, contains('SAKINAH_SKIP_PUBLIC_LINK_NETWORK'));
      expect(content, contains('https://'));
      expect(content, contains('example.com'));
      expect(content, contains('reject_placeholder_email'));
      expect(content, contains('localhost'));
      expect(content, contains('127.0.0.1'));
      expect(content, contains('curl'));
      expect(content, contains('Google Play public links passed'));

      expect(appEnvironment, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(appEnvironment, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(appEnvironment, contains('privacyPolicyUri'));
      expect(appEnvironment, contains('testingFeedbackChannel'));
      expect(appEnvironment, contains('example.com'));
      expect(privacyCenter, contains('privacyPolicyUri'));
      expect(privacyCenter, contains('privacyPolicyPublishedTitle'));
      expect(privacyCenter, contains('SakinahKeys.privacyPolicyLinkTile'));
      expect(privacyCenter, contains('Clipboard.setData'));
      expect(settingsPage, contains('testingFeedbackChannel'));
      expect(settingsPage, contains('testingFeedbackTitle'));
      expect(settingsPage, contains('SakinahKeys.settingsTestingFeedbackTile'));
      expect(
        settingsPage,
        contains('SakinahKeys.settingsClosedTestingGuideTile'),
      );
      expect(settingsPage, contains('Clipboard.setData'));
      expect(keys, contains('privacyPolicyLinkTile'));
      expect(keys, contains('settingsTestingFeedbackTile'));
      expect(keys, contains('settingsClosedTestingGuideTile'));

      final dryRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_public_links.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(dryRun.exitCode, isNot(0));
      expect(
        dryRun.stderr.toString(),
        contains('SAKINAH_PRIVACY_POLICY_URL is required'),
      );

      final placeholderFeedbackRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_public_links.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_SKIP_PUBLIC_LINK_NETWORK': 'true',
          'SAKINAH_PRIVACY_POLICY_URL':
              'https://privacy.sakinahdaily.app/privacy',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@example.com',
        },
        includeParentEnvironment: false,
      );
      expect(placeholderFeedbackRun.exitCode, isNot(0));
      expect(
        placeholderFeedbackRun.stderr.toString(),
        contains('SAKINAH_PLAY_TESTING_FEEDBACK must be a real feedback email'),
      );

      final localQaRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_public_links.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_SKIP_PUBLIC_LINK_NETWORK': 'true',
          'SAKINAH_PRIVACY_POLICY_URL':
              'https://privacy.sakinahdaily.app/privacy',
          'SAKINAH_PLAY_TESTING_FEEDBACK': 'support@sakinahdaily.app',
        },
        includeParentEnvironment: false,
      );
      expect(localQaRun.exitCode, 0);
      expect(
        localQaRun.stdout.toString(),
        contains('Google Play public links passed'),
      );

      expect(hostingDoc, contains('verify_google_play_public_links.sh'));
      expect(hostingDoc, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(hostingDoc, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(hostingDoc, contains('Data safety'));
      expect(hostingDoc, contains('Closed testing'));
      expect(hostingDoc, contains('Settings > Privacy'));
      expect(hostingDoc, contains('Settings shows the configured feedback'));
      expect(hostingDoc, contains('Privacy Center copies'));
      expect(hostingDoc, contains('do not use example.com'));
      expect(flavorDoc, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(flavorDoc, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(flavorDoc, contains('Testing feedback'));
      expect(flavorDoc, contains('Privacy Center'));
      expect(privacyPolicy, contains('Effective date'));
      expect(privacyPolicy, contains('Contact'));
      expect(privacyPolicy, contains('Sakinah Daily'));
      expect(dataSafety, contains('privacy policy URL'));
      expect(permissionReview, contains('verify_google_play_public_links.sh'));
      expect(docsIndex, contains('11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md'));
      expect(readiness, contains('Google Play public links preflight'));
      expect(androidChecklist, contains('verify_google_play_public_links.sh'));
      expect(versionNotes, contains('public privacy/feedback links'));
    });

    test('Google Play public links hosting packet can be exported', () {
      final hostingPacketFile =
          File('docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md');
      final script = File('scripts/export_google_play_public_links_packet.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final publicLinksDoc =
          File('docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md')
              .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(hostingPacketFile.existsSync(), isTrue);
      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY'));
      expect(content, contains('build/play-public-links'));
      expect(content, contains('privacy/index.html'));
      expect(content, contains('feedback/index.html'));
      expect(content, contains('manifest.txt'));
      expect(content, contains('verify_google_play_public_links.sh'));
      expect(content, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(content, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(
        content,
        contains(
          'No ads, tracking SDK, crash SDK, or default-on analytics collection',
        ),
      );

      final templateRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_public_links_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Google Play public links hosting packet exported'),
      );

      final manifest =
          File('build/play-public-links/manifest.txt').readAsStringSync();
      final privacyHtml =
          File('build/play-public-links/privacy/index.html').readAsStringSync();
      final feedbackHtml = File('build/play-public-links/feedback/index.html')
          .readAsStringSync();

      expect(manifest, contains('Google Play public links hosting packet'));
      expect(manifest, contains('com.sakinahdaily.app'));
      expect(manifest, contains('No tester personal data'));
      expect(manifest, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(manifest, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(manifest, contains('scripts/verify_google_play_public_links.sh'));
      expect(privacyHtml, contains('Sakinah Daily Privacy Policy'));
      expect(privacyHtml,
          contains('Settings &gt; Privacy &gt; Delete local data'));
      expect(
        privacyHtml,
        contains(
          'No ads, tracking SDK, crash SDK, or default-on analytics collection',
        ),
      );
      expect(feedbackHtml, contains('Sakinah Daily Closed Testing Feedback'));
      expect(feedbackHtml, contains('Day 1'));
      expect(feedbackHtml, contains('Day 3'));
      expect(feedbackHtml, contains('Day 7'));
      expect(feedbackHtml, contains('Day 14'));
      expect(feedbackHtml, contains('Suggested theme:'));
      expect(feedbackHtml, contains('onboarding_location_clarity'));
      expect(feedbackHtml, contains('prayer_time_trust'));
      expect(feedbackHtml, contains('retention_reason_to_return'));
      expect(feedbackHtml,
          contains('Please avoid personal or sensitive health details'));

      final strictRun = Process.runSync(
        'bash',
        ['scripts/export_google_play_public_links_packet.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_PUBLIC_LINKS_HOSTING_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Google Play public links failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PRIVACY_POLICY_URL is required'),
      );

      final hostingPacket = hostingPacketFile.readAsStringSync();
      expect(hostingPacket, contains('Public links hosting packet'));
      expect(hostingPacket, contains('build/play-public-links'));
      expect(
          hostingPacket, contains('export_google_play_public_links_packet.sh'));
      expect(hostingPacket, contains('SAKINAH_PRIVACY_POLICY_URL'));
      expect(hostingPacket, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(docsIndex, contains('15_PUBLIC_LINKS_HOSTING_PACKET.md'));
      expect(readiness, contains('Google Play public links hosting packet'));
      expect(publicLinksDoc,
          contains('export_google_play_public_links_packet.sh'));
      expect(androidChecklist,
          contains('export_google_play_public_links_packet.sh'));
      expect(submissionRunbook,
          contains('export_google_play_public_links_packet.sh'));
      expect(versionNotes, contains('public links hosting packet'));
    });

    test('Google Play public links hosting packet QA is scripted', () {
      final verifier =
          File('scripts/verify_google_play_public_links_packet.sh');
      final hostingPacket =
          File('docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md')
              .readAsStringSync();
      final publicLinksDoc =
          File('docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md')
              .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();

      expect(verifier.existsSync(), isTrue);
      final mode = verifier.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = verifier.readAsStringSync();
      expect(content, contains('export_google_play_public_links_packet.sh'));
      expect(content, contains('build/play-public-links/privacy/index.html'));
      expect(content, contains('build/play-public-links/feedback/index.html'));
      expect(content, contains('reject_text'));
      expect(content, contains('To be finalized'));
      expect(content, contains('example.com'));
      expect(content, contains('<form'));
      expect(content,
          contains('Google Play public links hosting packet QA passed'));

      final qaRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_public_links_packet.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(qaRun.exitCode, 0);
      expect(
        qaRun.stdout.toString(),
        contains('Google Play public links hosting packet QA passed'),
      );

      final privacyHtml =
          File('build/play-public-links/privacy/index.html').readAsStringSync();
      final feedbackHtml = File('build/play-public-links/feedback/index.html')
          .readAsStringSync();
      final manifest =
          File('build/play-public-links/manifest.txt').readAsStringSync();

      expect(privacyHtml, isNot(contains('To be finalized')));
      expect(privacyHtml, isNot(contains('TBD')));
      expect(privacyHtml, isNot(contains('example.com')));
      expect(privacyHtml, contains('Effective date:'));
      expect(privacyHtml, contains('Contact:'));
      expect(privacyHtml, contains('Data Stored On Device'));
      expect(privacyHtml, contains('Data That May Leave The Device'));
      expect(privacyHtml, contains('How To Delete Local Data'));
      expect(feedbackHtml, isNot(contains('<form')));
      expect(feedbackHtml, isNot(contains('<input')));
      expect(feedbackHtml, isNot(contains('<textarea')));
      expect(
        feedbackHtml,
        contains('Please avoid personal or sensitive health details'),
      );
      expect(manifest, contains('verify_google_play_public_links_packet.sh'));

      expect(
          hostingPacket, contains('verify_google_play_public_links_packet.sh'));
      expect(publicLinksDoc,
          contains('verify_google_play_public_links_packet.sh'));
      expect(readiness, contains('public links hosting packet QA'));
      expect(submissionRunbook,
          contains('verify_google_play_public_links_packet.sh'));
      expect(versionNotes, contains('public links hosting packet QA'));
    });

    test('Google Play closed-test launch day gate is scripted and documented',
        () {
      final checklistFile =
          File('docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md');
      final script =
          File('scripts/verify_google_play_closed_test_launch_day.sh');
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final launchPack = File('docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md')
          .readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();
      final uploadExporter = File('scripts/export_google_play_upload_packet.sh')
          .readAsStringSync();
      final submissionVerifier =
          File('scripts/verify_google_play_submission_pack.sh')
              .readAsStringSync();

      expect(checklistFile.existsSync(), isTrue);
      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final checklist = checklistFile.readAsStringSync();
      expect(checklist, contains('Closed-test launch day checklist'));
      expect(checklist, contains('Google Group link first'));
      expect(checklist, contains('Play opt-in link second'));
      expect(checklist, contains('Leave testing link is not an invite'));
      expect(checklist, contains('build/play-upload'));
      expect(checklist, contains('No tester personal data'));
      expect(checklist,
          contains('https://groups.google.com/g/sakinah-daily-testers'));
      expect(
        checklist,
        contains('https://play.google.com/apps/testing/com.sakinahdaily.app'),
      );

      final content = script.readAsStringSync();
      expect(content, contains('SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY'));
      expect(content, contains('SAKINAH_PLAY_CONSOLE_APP_CREATED'));
      expect(content, contains('SAKINAH_PLAY_TESTER_GROUP_CREATED'));
      expect(content, contains('SAKINAH_PLAY_CLOSED_TRACK_READY'));
      expect(content, contains('SAKINAH_PLAY_CLOSED_TEST_RELEASE_LIVE'));
      expect(content, contains('SAKINAH_PLAY_TESTER_LINKS_REVIEWED'));
      expect(content, contains('verify_google_play_submission_pack.sh'));
      expect(content, contains('verify_google_play_public_links_packet.sh'));
      expect(content, contains('verify_google_play_store_assets.sh'));
      expect(content, contains('export_google_play_upload_packet.sh'));
      expect(content, contains('build/play-upload'));
      expect(content, contains('sakinah-daily-testers@googlegroups.com'));
      expect(
        content,
        contains('https://groups.google.com/g/sakinah-daily-testers'),
      );
      expect(
        content,
        contains('https://play.google.com/apps/testing/com.sakinahdaily.app'),
      );
      expect(
        content,
        contains(
          'https://play.google.com/store/apps/details?id=com.sakinahdaily.app',
        ),
      );
      expect(
        content,
        contains(
            'https://play.google.com/apps/testing/com.sakinahdaily.app/leave'),
      );
      expect(content, contains('邀请加入 Sakinah Daily 封闭测试'));
      expect(content, contains('不要把 leave testing 链接当作邀请链接'));

      final templateRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_closed_test_launch_day.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(templateRun.exitCode, 0);
      expect(
        templateRun.stdout.toString(),
        contains('Google Play closed-test launch day gate passed'),
      );

      final manifest =
          File('build/play-upload/manifest.txt').readAsStringSync();
      expect(manifest, contains('Closed-test launch day gate'));
      expect(
        manifest,
        contains('scripts/verify_google_play_closed_test_launch_day.sh'),
      );

      final strictRun = Process.runSync(
        'bash',
        ['scripts/verify_google_play_closed_test_launch_day.sh'],
        environment: {
          'PATH': Platform.environment['PATH'] ?? '',
          'SAKINAH_REQUIRE_CLOSED_TEST_LAUNCH_READY': 'true',
        },
        includeParentEnvironment: false,
      );
      expect(strictRun.exitCode, isNot(0));
      expect(
        strictRun.stderr.toString(),
        contains('Google Play closed-test launch day gate failed'),
      );
      expect(
        strictRun.stderr.toString(),
        contains('SAKINAH_PLAY_CONSOLE_APP_CREATED=true'),
      );

      expect(docsIndex, contains('16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md'));
      expect(readiness, contains('closed-test launch day gate'));
      expect(androidChecklist,
          contains('verify_google_play_closed_test_launch_day.sh'));
      expect(
          launchPack, contains('verify_google_play_closed_test_launch_day.sh'));
      expect(launchPack, contains('Share the Google Group link first'));
      expect(submissionRunbook,
          contains('verify_google_play_closed_test_launch_day.sh'));
      expect(versionNotes, contains('closed-test launch day gate'));
      expect(uploadExporter,
          contains('verify_google_play_closed_test_launch_day.sh'));
      expect(
          uploadExporter, contains('16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md'));
      expect(submissionVerifier,
          contains('verify_google_play_closed_test_launch_day.sh'));
    });

    test('Google Play store visual assets are generated and verified', () {
      final generator = File('scripts/generate_google_play_feature_graphic.py');
      final verifier = File('scripts/verify_google_play_store_assets.sh');
      final featureGraphic =
          File('build/store-assets/google-play-feature-graphic.png');
      final screenshotPlan =
          File('docs/release/05_SCREENSHOT_PLAN.md').readAsStringSync();
      final submissionRunbook =
          File('docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md')
              .readAsStringSync();
      final submissionVerifier =
          File('scripts/verify_google_play_submission_pack.sh')
              .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final metadata =
          File('docs/release/04_STORE_METADATA_DRAFT.md').readAsStringSync();

      expect(generator.existsSync(), isTrue);
      expect(verifier.existsSync(), isTrue);
      final mode = verifier.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final generatorContent = generator.readAsStringSync();
      expect(generatorContent, contains('1024'));
      expect(generatorContent, contains('500'));
      expect(generatorContent, contains('RGB'));
      expect(generatorContent, contains('Sakinah Daily'));
      expect(generatorContent, contains('assets/branding/app_icon.png'));
      expect(
        generatorContent,
        contains('build/store-assets/google-play-feature-graphic.png'),
      );

      final verifierContent = verifier.readAsStringSync();
      expect(verifierContent, contains('1024'));
      expect(verifierContent, contains('500'));
      expect(verifierContent, contains('24-bit PNG'));
      expect(verifierContent, contains('no alpha'));
      expect(verifierContent, contains('build/store-screenshots/android'));
      expect(verifierContent, contains('android-contact-sheet.png'));

      final run = Process.runSync(
        'bash',
        ['scripts/verify_google_play_store_assets.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(run.exitCode, 0);
      expect(
        run.stdout.toString(),
        contains('Google Play store visual assets passed'),
      );
      expect(featureGraphic.existsSync(), isTrue);

      final featureGraphicInfo = _readPngInfo(featureGraphic);
      expect(featureGraphicInfo.width, 1024);
      expect(featureGraphicInfo.height, 500);
      expect(featureGraphicInfo.colorType, 2);

      expect(screenshotPlan, contains('google-play-feature-graphic.png'));
      expect(screenshotPlan, contains('1024 x 500'));
      expect(screenshotPlan, contains('24-bit PNG'));
      expect(screenshotPlan, contains('no alpha'));
      expect(
        screenshotPlan,
        contains(
          'https://support.google.com/googleplay/android-developer/answer/9866151',
        ),
      );
      expect(submissionRunbook, contains('google-play-feature-graphic.png'));
      expect(
        submissionRunbook,
        contains('verify_google_play_store_assets.sh'),
      );
      expect(
        submissionVerifier,
        contains('verify_google_play_store_assets.sh'),
      );
      expect(readiness, contains('Google Play store visual assets'));
      expect(androidChecklist, contains('verify_google_play_store_assets.sh'));
      expect(metadata, contains('Feature graphic'));
      expect(metadata, contains('Prayer times and local reminders'));
    });

    test('Android upload keystore setup is scripted and documented safely', () {
      final script = File('scripts/create_android_upload_keystore.sh');
      final setupDoc = File('docs/release/10_ANDROID_UPLOAD_SIGNING_SETUP.md')
          .readAsStringSync();
      final docsIndex = File('docs/00_DOCS_INDEX.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final versionNotes = File('docs/release/08_VERSION_AND_RELEASE_NOTES.md')
          .readAsStringSync();
      final gitignore = File('.gitignore').readAsStringSync();

      expect(script.existsSync(), isTrue);
      final mode = script.statSync().mode;
      expect(mode & 0x49, isNonZero);

      final content = script.readAsStringSync();
      expect(content, contains('keytool -genkeypair'));
      expect(content, contains('SAKINAH_UPLOAD_KEYSTORE_PATH'));
      expect(content, contains('SAKINAH_UPLOAD_STORE_PASSWORD'));
      expect(content, contains('SAKINAH_UPLOAD_KEY_ALIAS'));
      expect(content, contains('SAKINAH_UPLOAD_KEY_PASSWORD'));
      expect(content, contains('SAKINAH_WRITE_KEY_PROPERTIES'));
      expect(content, contains('SAKINAH_OVERWRITE_KEY_PROPERTIES'));
      expect(content, contains('android/key.properties'));
      expect(content, contains('umask 077'));
      expect(
          content, contains('refusing to create a keystore inside the repo'));
      expect(content, contains('-keyalg RSA'));
      expect(content, contains('-keysize 2048'));
      expect(content, contains('-validity 10000'));
      expect(content, isNot(contains('replace-with-local-store-password')));
      expect(content, isNot(contains('replace-with-local-key-password')));

      final dryRun = Process.runSync(
        'bash',
        ['scripts/create_android_upload_keystore.sh'],
        environment: {'PATH': Platform.environment['PATH'] ?? ''},
        includeParentEnvironment: false,
      );
      expect(dryRun.exitCode, isNot(0));
      expect(
        dryRun.stderr.toString(),
        contains('SAKINAH_UPLOAD_KEYSTORE_PATH is required'),
      );

      expect(setupDoc, contains('create_android_upload_keystore.sh'));
      expect(setupDoc, contains('SAKINAH_UPLOAD_KEYSTORE_PATH'));
      expect(setupDoc, contains('SAKINAH_WRITE_KEY_PROPERTIES=true'));
      expect(setupDoc, contains('outside the repository'));
      expect(setupDoc, contains('Do not commit'));
      expect(setupDoc, contains('verify_google_play_upload_preflight.sh'));
      expect(setupDoc, contains('flutter build appbundle'));
      expect(setupDoc, contains('Google Play App Signing'));
      expect(docsIndex, contains('10_ANDROID_UPLOAD_SIGNING_SETUP.md'));
      expect(readiness, contains('Android upload keystore setup helper'));
      expect(androidChecklist, contains('create_android_upload_keystore.sh'));
      expect(versionNotes, contains('Android upload signing setup'));
      expect(gitignore, contains('key.properties'));
      expect(gitignore, contains('*.jks'));
      expect(gitignore, contains('*.keystore'));
    });

    test('Android store screenshot helper uses deterministic dev defines', () {
      final script = File('scripts/capture_android_store_screenshot.sh')
          .readAsStringSync();

      expect(script, contains('SAKINAH_APP_ENV=dev'));
      expect(script, contains('SAKINAH_STORE_SCREENSHOT_ENABLED=true'));
      expect(script, contains('SAKINAH_STORE_SCREENSHOT_LOCALE'));
      expect(script, contains('SAKINAH_STORE_SCREENSHOT_ROUTE'));
      expect(script, contains('/splash'));
      expect(script, contains('/quran/94:5'));
      expect(script, contains('/settings/content-sources'));
      expect(script, contains('/settings/testing-guide'));
      expect(script, contains('/settings/privacy'));
      expect(script, contains('SAKINAH_PLAY_TESTING_FEEDBACK'));
      expect(script, contains('/session/session_morning_ease'));
      expect(script, contains('SAKINAH_SCREENSHOT_SETTLE_SECONDS'));
      expect(
        script,
        contains(r'settle_seconds="${SAKINAH_SCREENSHOT_SETTLE_SECONDS:-3}"'),
      );
      expect(script, contains('screencap -p'));
    });

    test('Android store screenshot set helper covers launch matrix', () {
      final script = File('scripts/capture_android_store_screenshots.sh')
          .readAsStringSync();

      expect(script, contains('SAKINAH_SCREENSHOT_LOCALES'));
      expect(script, contains('SAKINAH_SCREENSHOT_ROUTES'));
      expect(script, contains('en id ar'));
      expect(script, contains('/splash'));
      expect(script, contains('/home'));
      expect(script, contains('/prayer'));
      expect(script, contains('/settings/notifications'));
      expect(script, contains('/settings/prayer-location'));
      expect(script, contains('/settings/privacy'));
      expect(script, contains('SAKINAH_SCREENSHOT_ROUTES'));
      expect(script, contains('/session/session_morning_ease'));
      expect(script, contains('capture_android_store_screenshot.sh'));
      expect(script, contains('build/store-screenshots/android'));
    });

    test('Android icon and splash review evidence is documented', () {
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final androidChecklist =
          File('docs/release/02_ANDROID_RELEASE_CHECKLIST.md')
              .readAsStringSync();
      final screenshotPlan =
          File('docs/release/05_SCREENSHOT_PLAN.md').readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();

      expect(readiness, contains('[x] App icon and splash assets reviewed'));
      expect(
        readiness,
        contains('build/store-screenshots/android-assets/en-splash.png'),
      );
      expect(readiness, contains('27-screen Android phone matrix'));
      expect(androidChecklist, contains('## Android Asset Review'));
      expect(androidChecklist, contains('assets/branding/app_icon.png'));
      expect(androidChecklist, contains('sakinah_native_splash.png'));
      expect(
        androidChecklist,
        contains('build/store-screenshots/android-assets/en-splash.png'),
      );
      expect(screenshotPlan, contains('/splash'));
      expect(screenshotPlan, contains('SAKINAH_SCREENSHOT_SETTLE_SECONDS'));
      expect(screenshotPlan, contains('27 screenshots'));
      expect(screenshotPlan, contains('en-splash.png'));
      expect(screenshotPlan, contains('id-splash.png'));
      expect(screenshotPlan, contains('ar-splash.png'));
      expect(
        screenshotPlan,
        contains('build/store-screenshots/android-safety/en-quran-94-5.png'),
      );
      expect(
        screenshotPlan,
        contains('[x] Quran recitation screen shows no background music'),
      );
      expect(productProgress, contains('full 27-screen Android phone matrix'));
      expect(productProgress, contains('Splash / brand'));
      expect(productProgress, contains('Quran safety screenshot evidence'));
    });

    test('prayer reminder controls are per-prayer and documented', () {
      final model =
          File('lib/core/models/sakinah_models.dart').readAsStringSync();
      final settingsPage =
          File('lib/features/settings/notification_settings_page.dart')
              .readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final notificationSettingsTest =
          File('test/notification_settings_page_test.dart').readAsStringSync();
      final notificationService =
          File('lib/core/services/notification_service.dart')
              .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final research =
          File('docs/research/01_COMPETITOR_FEATURE_GAP_PRIORITY.md')
              .readAsStringSync();

      expect(model, contains('enabledPrayerReminderNames'));
      expect(model, contains('prayerReminderOffsetMinutes'));
      expect(settingsPage, contains('prayerReminderChoicesTitle'));
      expect(settingsPage, contains('settingsPrayerReminderPrayerSwitch'));
      expect(settingsPage, contains('settingsPrayerReminderLeadTimeDropdown'));
      expect(settingsPage, contains('nextPrayerReminderPreview'));
      expect(keys, contains('settingsPrayerNextReminderPreview'));
      expect(settingsPage, contains('enabledPrayerReminderNames'));
      expect(
        notificationSettingsTest,
        contains('Notification settings summarizes enabled prayer reminders'),
      );
      expect(
        notificationSettingsTest,
        contains(
            'Notification settings previews the next local prayer reminder'),
      );
      expect(notificationService, contains('enabledPrayerNames'));
      expect(notificationService, contains('reminderOffsetMinutes'));
      expect(readiness, contains('per-prayer local reminder controls'));
      expect(readiness, contains('prayer reminder lead-time choices'));
      expect(readiness, contains('selected prayer names and lead time'));
      expect(readiness, contains('next local prayer reminder'));
      expect(productProgress, contains('per-prayer reminder controls'));
      expect(productProgress, contains('lead-time offset controls'));
      expect(productProgress, contains('selected prayer names and lead time'));
      expect(productProgress, contains('next local prayer reminder'));
      expect(research, contains('per-prayer reminder control implemented'));
      expect(research, contains('lead-time offset control implemented'));
    });

    test('daily session reminder status is visible on Home', () {
      final home = File('lib/features/home/home_page.dart').readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final navigationTest =
          File('test/navigation_flow_test.dart').readAsStringSync();
      final sessionProgressTest =
          File('test/session_progress_flow_test.dart').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(home, contains('formatDailySessionReminderTime'));
      expect(home, contains('homeSessionReminderStatusChip'));
      expect(home, contains('homeSessionReminderCtaButton'));
      expect(keys, contains('homeSessionReminderStatusChip'));
      expect(keys, contains('homeSessionReminderCtaButton'));
      expect(
        navigationTest,
        contains('home session card shows enabled daily reminder time'),
      );
      expect(
        sessionProgressTest,
        contains('homeSessionReminderCtaButton'),
      );
      expect(
        readiness,
        contains('Home offers a Set daily reminder CTA'),
      );
      expect(
        readiness,
        contains('Home session card surfaces enabled daily session reminder'),
      );
      expect(
        productProgress,
        contains('Set daily reminder CTA'),
      );
      expect(productProgress, contains('home_session_completion'));
      expect(
        productProgress,
        contains('Home session card now surfaces the enabled daily session'),
      );
      expect(acceptance, contains('[x] 用户可以管理每日 session reminder。'));
      expect(acceptance, contains('[x] Daily reminder 可开启/关闭。'));
    });

    test(
        'daily session completion and reflection no-fatwa guardrail are covered',
        () {
      final sessionPage =
          File('lib/features/daily_session/daily_session_page.dart')
              .readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final featureTest =
          File('test/feature_behavior_test.dart').readAsStringSync();
      final navigationTest =
          File('test/navigation_flow_test.dart').readAsStringSync();
      final contentGuidelines =
          File('docs/content/01_CONTENT_GUIDELINES.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(sessionPage, contains('reflectionSafetyDescription'));
      expect(keys, contains('sessionReflectionSafetyCard'));
      expect(keys, contains('prayerCompletionStartSessionButton'));
      expect(keys, contains('prayerCompletionReminderSettingsButton'));
      expect(
        featureTest,
        contains('Daily Session reflection step shows no-fatwa safety note'),
      );
      expect(
        featureTest,
        contains('Prayer complete state starts Daily Session'),
      );
      expect(
        featureTest,
        contains('Prayer complete state can open reminder settings'),
      );
      expect(
        featureTest,
        contains('Prayer complete state reviews completed Daily Session'),
      );
      expect(
        navigationTest,
        contains('daily session start advances and finishes to completion'),
      );
      expect(contentGuidelines, contains('no-fatwa 安全提示'));
      expect(
        readiness,
        contains('Daily Session Reflection step displays a localized no-fatwa'),
      );
      expect(
        productProgress,
        contains('Reflection step now shows a localized no-fatwa note'),
      );
      expect(
        productProgress,
        contains('five-prayer complete state now offers a Start session CTA'),
      );
      expect(productProgress, contains('opens the local completion page'));
      expect(acceptance, contains('[x] 用户可以可选完成 Daily Session。'));
      expect(acceptance, contains('[x] Reflection 不提供 fatwa 风格结论。'));
    });

    test('Quran audio safety and text fallback acceptance are covered', () {
      final audioPolicyTest =
          File('test/audio_policy_service_test.dart').readAsStringSync();
      final audioPlayerTest =
          File('test/audio_player_service_test.dart').readAsStringSync();
      final featureTest =
          File('test/feature_behavior_test.dart').readAsStringSync();
      final quranDetail =
          File('lib/features/quran/quran_verse_detail_page.dart')
              .readAsStringSync();
      final quranDetailTest =
          File('test/quran_verse_detail_page_test.dart').readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final contentGuidelines =
          File('docs/content/01_CONTENT_GUIDELINES.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(
        audioPolicyTest,
        contains(
            'approved Quran recitation without BGM is voice-only playable'),
      );
      expect(
        audioPolicyTest,
        contains('Quran recitation with BGM allowed is blocked'),
      );
      expect(
        audioPlayerTest,
        contains('fake player enters text-only fallback for missing audio'),
      );
      expect(
        featureTest,
        contains('Daily Session Quran step hides playback for text fallback'),
      );
      expect(quranDetail, contains('quranVerseSafetyCard'));
      expect(keys, contains('quranVerseSafetyCard'));
      expect(
        quranDetailTest,
        contains('Quran verse detail shows voice-only no-BGM no-TTS'),
      );
      expect(contentGuidelines, contains('Quran recitation 下不播放 BGM'));
      expect(contentGuidelines, contains('Arabic Quran recitation 不使用普通 TTS'));
      expect(
        readiness,
        contains('Quran recitation copy remains voice-only with no BGM'),
      );
      expect(
        productProgress,
        contains('Quran step enforces no BGM and no Quran TTS'),
      );
      expect(acceptance, contains('[x] Quran recitation 不使用 TTS。'));
      expect(acceptance, contains('[x] Quran recitation 无 BGM。'));
      expect(acceptance, contains('[x] 上架主路径没有 no-op audio CTA。'));
      expect(acceptance, contains('[x] Quran step 禁止 BGM。'));
      expect(acceptance, contains('[x] Audio failure 有 fallback 文本。'));
    });

    test('Dua detail source and review status acceptance are covered', () {
      final duaDetail =
          File('lib/features/dua/dua_detail_page.dart').readAsStringSync();
      final sourceChip =
          File('lib/shared/widgets/source_chip.dart').readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final featureTest =
          File('test/feature_behavior_test.dart').readAsStringSync();
      final contentGuidelines =
          File('docs/content/01_CONTENT_GUIDELINES.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(duaDetail, contains('SakinahKeys.duaSourceCard'));
      expect(duaDetail, contains('SourceChip('));
      expect(duaDetail, contains('source: dua.source'));
      expect(duaDetail, contains('reviewStatus: dua.reviewStatus.name'));
      expect(sourceChip, contains('reviewContentLabel(reviewStatus)'));
      expect(keys, contains('duaSourceCard'));
      expect(
          featureTest, contains('Dua detail shows source and review status'));
      expect(featureTest, contains("find.textContaining('Ibn Hibban')"));
      expect(featureTest, contains("find.textContaining('approved content')"));
      expect(contentGuidelines, contains('Source label'));
      expect(contentGuidelines, contains('Review status'));
      expect(
        readiness,
        contains('Dua detail displays source and review status'),
      );
      expect(
        productProgress,
        contains('Dua detail shows Arabic, transliteration'),
      );
      expect(acceptance, contains('[x] Dua detail 显示 source。'));
      expect(acceptance, contains('[x] Dua detail 显示 review status。'));
    });

    test('Remote CMS default and published-approved acceptance are covered',
        () {
      final appEnvironment =
          File('lib/core/config/app_environment.dart').readAsStringSync();
      final contentApiConfig =
          File('lib/core/config/content_api_config.dart').readAsStringSync();
      final appProviders =
          File('lib/core/providers/app_providers.dart').readAsStringSync();
      final contentService =
          File('lib/core/services/content_service.dart').readAsStringSync();
      final remoteContentApiTest =
          File('test/remote_content_api_client_test.dart').readAsStringSync();
      final cacheTest =
          File('test/client_content_cache_test.dart').readAsStringSync();
      final remoteIntegration =
          File('docs/client/05_REMOTE_CONTENT_API_INTEGRATION.md')
              .readAsStringSync();
      final contentGuidelines =
          File('docs/content/01_CONTENT_GUIDELINES.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(appEnvironment, contains('remoteContentEnabled'));
      expect(
        appEnvironment,
        contains("values['SAKINAH_CONTENT_API_ENABLED']"),
      );
      expect(contentApiConfig, contains('ContentApiConfig.disabled'));
      expect(contentApiConfig, contains('bool.fromEnvironment'));
      expect(contentApiConfig, contains('bool get isUsable'));
      expect(appProviders, contains('if (remoteClient != null)'));
      expect(contentService, contains('if (!bundle.isApproved)'));
      expect(contentService, contains('entry.bundle.isApproved'));
      expect(contentService, contains('approved(item)'));
      expect(
        remoteContentApiTest,
        contains('disabled config produces no remote client and seed fallback'),
      );
      expect(
        remoteContentApiTest,
        contains('unpublished remote bundle is rejected'),
      );
      expect(
        remoteContentApiTest,
        contains('unapproved remote bundle is rejected'),
      );
      expect(
        cacheTest,
        contains('draft and in-review content inside approved bundle'),
      );
      expect(cacheTest, contains("'unpublished_session'"));
      expect(cacheTest, contains("'unpublished_dua'"));
      expect(
          remoteIntegration, contains('Remote content is disabled by default'));
      expect(
        remoteIntegration,
        contains('client still rejects any bundle that is not `published`'),
      );
      expect(
        contentGuidelines,
        contains('Remote CMS content must stay hidden unless it is published'),
      );
      expect(
        readiness,
        contains('Remote CMS defaults to seed/cache behavior'),
      );
      expect(
        readiness,
        contains('Only published + approved'),
      );
      expect(
        readiness,
        contains('remote content can be cached'),
      );
      expect(
        acceptance,
        contains(
          '[x] Remote CMS 默认关闭；如开启则仅显示 published + approved。',
        ),
      );
    });

    test('Localization and Arabic RTL acceptance are covered', () {
      final app = File('lib/app/sakinah_app.dart').readAsStringSync();
      final localizations =
          File('lib/core/localization/sakinah_localizations.dart')
              .readAsStringSync();
      final localizationTest =
          File('test/localization_consistency_test.dart').readAsStringSync();
      final screenshotPlan =
          File('docs/release/05_SCREENSHOT_PLAN.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(app, contains('GlobalWidgetsLocalizations.delegate'));
      expect(localizations, contains("Locale('en')"));
      expect(localizations, contains("Locale('id')"));
      expect(localizations, contains("Locale('ar')"));
      expect(localizations, contains("'dua': 'Doa'"));
      expect(localizations, contains("'dhikr': 'Dzikir'"));
      expect(localizations, contains("'prayer': 'Shalat'"));
      expect(localizations, contains("'qibla': 'Kiblat'"));
      expect(
        localizationTest,
        contains(
          'release-critical prayer path is localized across English Indonesian and Arabic',
        ),
      );
      expect(localizationTest, contains('TextDirection.rtl'));
      expect(localizationTest, contains('forbiddenButtonLabels'));
      expect(localizationTest, contains("expect(idL10n.t('dua'), 'Doa')"));
      expect(localizationTest, contains("expect(idL10n.t('dhikr'), 'Dzikir')"));
      expect(
          localizationTest, contains("expect(idL10n.t('prayer'), 'Shalat')"));
      expect(localizationTest, contains("expect(idL10n.t('qibla'), 'Kiblat')"));
      expect(screenshotPlan, contains('English, Indonesian, and Arabic RTL'));
      expect(
        readiness,
        contains(
          'Release path is localized across English, Bahasa Indonesia, and Arabic RTL',
        ),
      );
      expect(
        readiness,
        contains('Indonesian release copy uses Doa / Dzikir / Shalat / Kiblat'),
      );
      expect(acceptance, contains('[x] English 可用。'));
      expect(acceptance, contains('[x] Bahasa Indonesia 可用。'));
      expect(acceptance, contains('[x] Arabic 可用。'));
      expect(acceptance, contains('[x] Arabic RTL 生效。'));
      expect(acceptance, contains('[x] 关键按钮没有硬编码英文。'));
      expect(
        acceptance,
        contains('[x] 印尼语使用 Doa / Dzikir / Shalat / Kiblat。'),
      );
    });

    test('prayer page all-day times and reminder toggle acceptance are covered',
        () {
      final prayerPage =
          File('lib/features/prayer/prayer_page.dart').readAsStringSync();
      final keys = File('lib/shared/sakinah_keys.dart').readAsStringSync();
      final navigationTest =
          File('test/navigation_flow_test.dart').readAsStringSync();
      final featureBehaviorTest =
          File('test/feature_behavior_test.dart').readAsStringSync();
      final privacyInventory =
          File('docs/privacy/01_PRIVACY_DATA_INVENTORY.md').readAsStringSync();
      final localDeletionTest =
          File('test/local_data_deletion_service_test.dart').readAsStringSync();
      final notificationSettingsTest =
          File('test/notification_settings_page_test.dart').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final productProgress =
          File('docs/client/10_PRODUCT_REQUIREMENTS_PROGRESS.md')
              .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(prayerPage, contains('todaysPrayerTimes'));
      expect(prayerPage, contains('todaysPrayerCheckIn'));
      expect(prayerPage, contains('prayerChecklistUpdated'));
      expect(prayerPage, contains('prayerTopQiblaButton'));
      expect(prayerPage, contains('/qibla?source=prayer_page_card'));
      expect(keys, contains('prayerTimesSectionHeader'));
      expect(keys, contains('prayerTopReminderSettingsButton'));
      expect(keys, contains('prayerTopQiblaButton'));
      expect(keys, contains('prayerCompletionCheckbox'));
      expect(keys, contains('homePrayerCompletionMetric'));
      expect(keys, contains('homePrayerCheckInButton'));
      expect(keys, contains('homePrayerWeekProgress'));
      expect(
        navigationTest,
        contains('prayer page shows all five daily prayer times'),
      );
      expect(
        navigationTest,
        contains('prayer page opens Qibla direction from prayer context'),
      );
      expect(
        navigationTest,
        contains("['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']"),
      );
      expect(
          navigationTest, contains('SakinahKeys.prayerListItem(prayerName)'));
      expect(
        navigationTest,
        contains('home progress card opens prayer check-in'),
      );
      expect(
        featureBehaviorTest,
        contains(
          'Prayer page stores local prayer check-in and Home summarizes it',
        ),
      );
      expect(
        featureBehaviorTest,
        contains('Prayer page shows complete state for five local check-ins'),
      );
      expect(featureBehaviorTest, contains("Today's prayers are checked in"));
      expect(featureBehaviorTest, contains('Prayers today'));
      expect(featureBehaviorTest, contains('1/5'));
      expect(
        featureBehaviorTest,
        contains(
            'Home shows prayer weekly progress and aggregate view analytics'),
      );
      expect(featureBehaviorTest, contains('Prayer week'));
      expect(featureBehaviorTest, contains('3/7'));
      expect(featureBehaviorTest, contains('prayer_checkin_days_7d'));
      expect(
        privacyInventory,
        contains('Prayer completion history'),
      );
      expect(
        privacyInventory,
        contains('Home/prayer checklist retention fields are aggregate counts'),
      );
      expect(
        localDeletionTest,
        contains('prayerCompletionRepository.listCompletionRecords()'),
      );
      expect(
        notificationSettingsTest,
        contains('Notification settings manage prayer reminders'),
      );
      expect(
        notificationSettingsTest,
        contains('Prayer page reminder CTA records prayer page source'),
      );
      expect(
        readiness,
        contains(
            'Prayer page exposes a localized all-day prayer-times section'),
      );
      expect(
        readiness,
        contains('Prayer completion check-ins are local-only'),
      );
      expect(readiness, contains('complete state after all five'));
      expect(readiness, contains('Prayer week summary'));
      expect(readiness, contains('prayer_page_card'));
      expect(readiness, contains('Qibla view analytics'));
      expect(
        productProgress,
        contains('Prayer page now gives the full-day list'),
      );
      expect(
        productProgress,
        contains('Prayer page now includes a local-only'),
      );
      expect(productProgress, contains('complete-state summary'));
      expect(productProgress, contains('Home now shows a local-only'));
      expect(productProgress, contains('Home view analytics includes only'));
      expect(productProgress, contains('prayer_page_card'));
      expect(productProgress, contains('Qibla context action'));
      expect(
        productProgress,
        contains('prayer times" heading'),
      );
      expect(
        acceptance,
        contains(
          '[x] 用户可以查看 Fajr / Dhuhr / Asr / Maghrib / Isha 全天时间。',
        ),
      );
      expect(acceptance, contains('[x] 用户可以开启/关闭本地 prayer reminders。'));
      expect(
        acceptance,
        contains('用户可以在 Prayer 页本地标记今日五次礼拜完成状态'),
      );
      expect(acceptance, contains('本地完成态'));
      expect(acceptance, contains('本地周进度'));
      expect(acceptance, contains('[x] Prayer reminders 可开启/关闭。'));
      expect(acceptance, contains('Prayer 页上下文动作进入 Qibla'));
    });

    test('Home daily prayer companion acceptance is covered', () {
      final prd = File('docs/prd/02_CLIENT_PRD.md').readAsStringSync();
      final homePage =
          File('lib/features/home/home_page.dart').readAsStringSync();
      final navigationTest =
          File('test/navigation_flow_test.dart').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(prd, contains('Home 是核心入口，不能做成工具列表。'));
      expect(
        prd,
        contains('不在 Home 放 Quran / Dua / Dhikr / Qibla 工具宫格。'),
      );
      expect(homePage, contains('homePrayerPrimaryCard'));
      expect(homePage, contains('calculateNextPrayerReminderPreview'));
      expect(homePage, contains('homePrayerNextReminderPreview'));
      expect(homePage, contains('homeSessionCard'));
      expect(homePage, contains('homeProgressCard'));
      expect(homePage, contains('homeNightCard'));
      expect(homePage, contains('homeSavedRail'));
      expect(homePage, contains('homeClosedTestingGuideCard'));
      expect(homePage, contains('homeClosedTestingNextPrompt'));
      expect(homePage, contains('closedTestingNextFeedback'));
      expect(homePage, contains('homeClosedTestingGuideButton'));
      expect(homePage, contains('testingFeedbackChannel'));
      expect(homePage, contains('/settings/testing-guide'));
      expect(homePage, isNot(contains('homeQuickActionsCard')));
      expect(
        navigationTest,
        contains('home is daily prayer companion rather than a tool stack'),
      );
      expect(
        navigationTest,
        contains(
            'home surfaces closed testing guide when feedback is configured'),
      );
      expect(navigationTest, contains('Next feedback'));
      expect(
        navigationTest,
        contains(
            'home hides closed testing guide without feedback configuration'),
      );
      expect(navigationTest, contains('Daily prayer at the center'));
      expect(navigationTest, contains('Next prayer reminder'));
      expect(navigationTest, contains("Today's Sakinah Session"));
      expect(navigationTest, contains('Local progress'));
      expect(navigationTest, contains('Sleep with Ayat al-Kursi'));
      expect(navigationTest, contains('Quick Actions'));
      expect(
        readiness,
        contains(
          'Home daily prayer companion acceptance is covered by prayer-first',
        ),
      );
      expect(
        acceptance,
        contains('[x] App 不像工具堆叠，而像 daily prayer companion。'),
      );
    });

    test('Notification denial and gentle copy acceptance are covered', () {
      final notificationService =
          File('lib/core/services/notification_service.dart')
              .readAsStringSync();
      final prayerReminderToggleFlow =
          File('lib/features/settings/prayer_reminder_toggle_flow.dart')
              .readAsStringSync();
      final notificationServiceTest =
          File('test/notification_service_test.dart').readAsStringSync();
      final notificationSettingsTest =
          File('test/notification_settings_page_test.dart').readAsStringSync();
      final permissionCopy =
          File('docs/privacy/05_PERMISSION_COPY.md').readAsStringSync();
      final pushContent = File('docs/content/02_DAILY_PUSH_CONTENT_SYSTEM.md')
          .readAsStringSync();
      final permissionReview =
          File('docs/release/06_PERMISSION_AND_DATA_SAFETY_REVIEW.md')
              .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(
          notificationService, contains('requestPermissionAfterExplanation'));
      expect(prayerReminderToggleFlow,
          contains('NotificationPermissionFeedback.denied'));
      expect(
          prayerReminderToggleFlow, contains('setNotificationsEnabled(false)'));
      expect(
          notificationService, contains('A gentle Sakinah reminder is ready.'));
      expect(notificationService, contains('Sesi Sakinah singkat sudah siap.'));
      expect(notificationService, contains('جلسة سكينة قصيرة جاهزة.'));
      expect(
        notificationServiceTest,
        contains('notification denied state returns no scheduled reminders'),
      );
      expect(
        notificationServiceTest,
        contains(
            'daily session reminder is not scheduled when permission is denied'),
      );
      expect(
        notificationServiceTest,
        contains('notification copy stays gentle brief and policy safe'),
      );
      expect(
        notificationServiceTest,
        contains('_expectGentleNotificationCopy'),
      );
      expect(
        notificationSettingsTest,
        contains('Prayer reminder permission denial keeps app usable'),
      );
      expect(
        notificationSettingsTest,
        contains('Daily session reminder permission denial keeps app usable'),
      );
      expect(
        notificationSettingsTest,
        contains(
            'Notifications are off. You can enable them from system settings.'),
      );
      expect(
        permissionCopy,
        contains('reminders stay privacy-safe on the lock screen'),
      );
      expect(
        permissionCopy,
        contains('reminder text should stay generic and avoid menstruation'),
      );
      expect(pushContent, contains('human-reviewed content'));
      expect(pushContent, contains('hide cycle-sensitive content'));
      expect(
        permissionReview,
        contains(
            'The app shows explanatory copy before requesting notification permission'),
      );
      expect(
        readiness,
        contains(
          'Notification permission denial keeps Prayer and Daily Session reminders off',
        ),
      );
      expect(
        readiness,
        contains('Notification copy remains gentle, brief, and privacy-safe'),
      );
      expect(acceptance, contains('[x] 权限拒绝不影响 App 使用。'));
      expect(acceptance, contains('[x] 推送文案温柔克制。'));
    });

    test('store metadata and Google Play drafts are present', () {
      expect(
        File('docs/release/04_STORE_METADATA_DRAFT.md').existsSync(),
        isTrue,
      );
      expect(
        File('docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md').existsSync(),
        isTrue,
      );
    });

    test('Google Play metadata draft is prayer-first and policy-safe', () {
      final metadata =
          File('docs/release/04_STORE_METADATA_DRAFT.md').readAsStringSync();
      final lower = metadata.toLowerCase();

      expect(metadata, contains('## Google Play Listing Candidate'));
      expect(metadata, contains('Short description'));
      expect(metadata, contains('Full description'));
      expect(metadata, contains('English'));
      expect(metadata, contains('Bahasa Indonesia'));
      expect(metadata, contains('Arabic'));
      expect(lower, contains('prayer'));
      expect(lower, contains('local prayer reminders'));
      expect(lower, contains('manual or preset'));
      expect(lower, contains('privacy center'));
      expect(lower, contains('no ads'));
      expect(lower, contains('no tracking'));
      expect(lower, contains('no gps permission'));
      expect(lower, contains('no ai fatwa'));

      for (final forbidden in [
        'scholar-approved app',
        'medical guidance',
        'cycle-health',
        'guaranteed',
        'official religious authority',
        'personalized fatwa',
      ]) {
        expect(lower, isNot(contains(forbidden)), reason: forbidden);
      }

      final englishShort = _metadataValue(metadata, 'English short');
      final indonesianShort = _metadataValue(metadata, 'Indonesian short');
      final arabicShort = _metadataValue(metadata, 'Arabic short');
      expect(englishShort.length, lessThanOrEqualTo(80));
      expect(indonesianShort.length, lessThanOrEqualTo(80));
      expect(arabicShort.length, lessThanOrEqualTo(80));
    });

    test('Project structure and seed fallback acceptance are covered', () {
      final prd = File('docs/prd/02_CLIENT_PRD.md').readAsStringSync();
      final appProvider =
          File('lib/core/providers/app_providers.dart').readAsStringSync();
      final contentService =
          File('lib/core/services/content_service.dart').readAsStringSync();
      final contentServiceTest =
          File('test/content_service_test.dart').readAsStringSync();
      final cacheTest =
          File('test/client_content_cache_test.dart').readAsStringSync();
      final remoteTest =
          File('test/remote_content_api_client_test.dart').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      expect(prd, contains('## 3. 目录结构'));
      expect(_childDirectoryNames('lib/features'), containsAll(_featureDirs));
      expect(_childDirectoryNames('lib/core'), containsAll(_coreDirs));
      expect(Directory('lib/features').listSync().whereType<File>(), isEmpty);

      for (final feature in _featureDirs) {
        expect(
          _dartFilesUnder('lib/features/$feature'),
          isNotEmpty,
          reason: feature,
        );
      }
      for (final file in _dartFilesUnder('lib/features')) {
        final contents = file.readAsStringSync();
        expect(
          _crossFeatureImportPattern.hasMatch(contents),
          isFalse,
          reason: file.path,
        );
      }

      expect(appProvider, contains('seedContentRepositoryProvider'));
      expect(appProvider, contains('ContentApiConfig.fromEnvironment'));
      expect(appProvider, contains('if (remoteClient != null)'));
      expect(contentService, contains('return seedRepository'));
      expect(
        contentServiceTest,
        contains('seed fallback covers release-critical offline content types'),
      );
      expect(contentServiceTest, contains('seed home loads offline'));
      expect(
        contentServiceTest,
        contains('seed push deep link loads offline'),
      );
      expect(cacheTest, contains('seed fallback works when no cache exists'));
      expect(
        remoteTest,
        contains('disabled config produces no remote client and seed fallback'),
      );
      expect(remoteTest, contains('remote fetch failure keeps seed fallback'));
      expect(
        readiness,
        contains('Client feature folders match PRD boundaries'),
      );
      expect(
        readiness,
        contains('Seed fallback covers release-critical offline content types'),
      );
      expect(acceptance, contains('[x] 目录结构符合 PRD。'));
      expect(acceptance, contains('[x] 每个 feature 模块边界清楚。'));
      expect(acceptance, contains('[x] Seed fallback 可用。'));
    });

    test('Firebase Analytics is gated while crash ads tracking SDKs stay out',
        () {
      final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
      final appProvider =
          File('lib/core/providers/app_providers.dart').readAsStringSync();
      final analyticsService =
          File('lib/core/services/analytics_service.dart').readAsStringSync();
      final userPreferences =
          File('lib/core/models/sakinah_models.dart').readAsStringSync();
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

      expect(pubspec, contains('firebase_core'));
      expect(pubspec, contains('firebase_analytics'));
      for (final forbidden in [
        'firebase_crashlytics',
        'sentry',
        'appsflyer',
        'adjust',
        'google_mobile_ads',
      ]) {
        expect(pubspec, isNot(contains(forbidden)), reason: forbidden);
      }
      expect(appProvider, contains('environment.analyticsEnabled'));
      expect(appProvider, contains('preferences.analyticsOptIn'));
      expect(appProvider, contains('analyticsCollectionConsentSyncProvider'));
      expect(appProvider, contains('setCollectionEnabled'));
      expect(appProvider, contains('FirebaseAnalyticsService'));
      expect(userPreferences, contains('analyticsOptIn'));
      expect(analyticsService, contains('AnalyticsParameterPolicy.sanitize'));
      expect(analyticsService, contains('FirebaseAnalyticsBootstrap'));
      expect(
        manifest,
        contains('firebase_analytics_collection_enabled'),
      );
      expect(
        manifest,
        contains('google_analytics_automatic_screen_reporting_enabled'),
      );
      expect(manifest, contains('android:value="false"'));
    });

    test('Android manifest does not request location or sensor permission', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

      expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
      expect(manifest, isNot(contains('ACCESS_COARSE_LOCATION')));
      expect(manifest, isNot(contains('BODY_SENSORS')));
    });

    test('Android manifest enables predictive back callback', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

      expect(manifest, contains('android:enableOnBackInvokedCallback="true"'));
    });

    test('Android manifest supports scheduled local notifications', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

      expect(
        manifest,
        contains('android.permission.RECEIVE_BOOT_COMPLETED'),
      );
      expect(
        manifest,
        contains(
          'android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"',
        ),
      );
      expect(
        manifest,
        contains(
          'android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver"',
        ),
      );
      expect(manifest, contains('android.intent.action.BOOT_COMPLETED'));
      expect(manifest, contains('android.intent.action.MY_PACKAGE_REPLACED'));
    });

    test('no obvious secret files are committed', () {
      final forbiddenPatterns = [
        RegExp(r'(^|/)\.env(\..*)?$'),
        RegExp(r'(^|/)key\.properties$'),
        RegExp(r'\.(jks|keystore)$'),
        RegExp(r'(^|/)service-account\.json$'),
      ];

      final files = Process.runSync('git', ['ls-files']);
      expect(files.exitCode, 0);
      final tracked = (files.stdout as String)
          .split('\n')
          .where((path) => path.trim().isNotEmpty);
      for (final path in tracked) {
        for (final pattern in forbiddenPatterns) {
          expect(pattern.hasMatch(path), isFalse, reason: path);
        }
      }
    });

    test('no service role key or production token is committed', () {
      final serverPrd = File('docs/prd/03_SERVER_PRD.md').readAsStringSync();
      final architecture =
          File('docs/architecture/01_TECH_ARCHITECTURE.md').readAsStringSync();
      final buildFlavorDoc =
          File('docs/release/07_BUILD_FLAVORS_AND_DART_DEFINE.md')
              .readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();
      final scannedFiles = _trackedProjectFiles().where(
        (path) =>
            !path.startsWith('docs/') &&
            path != 'test/release_readiness_test.dart' &&
            _isScannableTextPath(path),
      );

      expect(serverPrd, contains('客户端只允许使用 anon key'));
      expect(architecture, contains('不在客户端存 service role key。'));
      expect(buildFlavorDoc, contains('Do not commit tokens'));
      expect(buildFlavorDoc, contains('service'));
      expect(buildFlavorDoc, contains('account files'));

      for (final path in scannedFiles) {
        final lower = File(path).readAsStringSync().toLowerCase();
        for (final forbidden in const [
          'supabase_service_role_key',
          'service_role_key',
          'service-role-key',
          'service role key',
          '"service_role"',
          "'service_role'",
        ]) {
          expect(lower, isNot(contains(forbidden)), reason: path);
        }
        expect(_jwtLikeSecretPattern.hasMatch(lower), isFalse, reason: path);
      }

      expect(
        readiness,
        contains('No Supabase service role key or production content token'),
      );
      expect(acceptance, contains('[x] 不存在 service role key 泄漏。'));
    });

    test('privacy inventory still marks women mode local-only high sensitivity',
        () {
      final womenMode =
          PrivacyDataInventory.categoryById('women_ibadah_mode_state');
      final closedTestingFeedback =
          PrivacyDataInventory.categoryById('closed_testing_feedback_status');

      expect(womenMode.storageLocation, PrivacyStorageLocation.localDevice);
      expect(womenMode.sensitivity, PrivacySensitivity.high);
      expect(womenMode.leavesDevice, isFalse);
      expect(
        closedTestingFeedback.storageLocation,
        PrivacyStorageLocation.localDevice,
      );
      expect(closedTestingFeedback.sensitivity, PrivacySensitivity.low);
      expect(closedTestingFeedback.leavesDevice, isFalse);
      expect(closedTestingFeedback.userCanDelete, isTrue);
    });

    test('Privacy acceptance is covered for location and women mode data', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      final privacyCenter =
          File('lib/features/settings/privacy_center_page.dart')
              .readAsStringSync();
      final privacyNavigationTest =
          File('test/privacy_navigation_test.dart').readAsStringSync();
      final manualLocationTest =
          File('test/manual_prayer_location_page_test.dart').readAsStringSync();
      final remoteContentTest =
          File('test/remote_content_api_client_test.dart').readAsStringSync();
      final womenModeSessionTest =
          File('test/women_mode_session_behavior_test.dart').readAsStringSync();
      final womenModePolicyDoc =
          File('docs/client/09_WOMEN_MODE_CONTENT_POLICY.md')
              .readAsStringSync();
      final permissionCopy =
          File('docs/privacy/05_PERMISSION_COPY.md').readAsStringSync();
      final dataSafety =
          File('docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md')
              .readAsStringSync();
      final privacyInventory =
          File('docs/privacy/01_PRIVACY_DATA_INVENTORY.md').readAsStringSync();
      final readiness = File('docs/release/01_RELEASE_READINESS_CHECKLIST.md')
          .readAsStringSync();
      final acceptance =
          File('docs/testing/01_ACCEPTANCE_CHECKLIST.md').readAsStringSync();

      for (final forbiddenPermission in [
        'ACCESS_FINE_LOCATION',
        'ACCESS_COARSE_LOCATION',
        'ACCESS_BACKGROUND_LOCATION',
        'BODY_SENSORS',
        'ACTIVITY_RECOGNITION',
      ]) {
        expect(
          manifest,
          isNot(contains(forbiddenPermission)),
          reason: forbiddenPermission,
        );
      }

      final prayerLocation =
          PrivacyDataInventory.categoryById('prayer_location_preset');
      final womenMode =
          PrivacyDataInventory.categoryById('women_ibadah_mode_state');
      expect(
          prayerLocation.storageLocation, PrivacyStorageLocation.localDevice);
      expect(prayerLocation.leavesDevice, isFalse);
      expect(womenMode.storageLocation, PrivacyStorageLocation.localDevice);
      expect(womenMode.sensitivity, PrivacySensitivity.high);
      expect(womenMode.leavesDevice, isFalse);
      expect(womenMode.userCanDelete, isTrue);

      expect(privacyCenter, contains('womenModePrivacyBody'));
      expect(privacyCenter, contains('prayerLocationPrivacyBody'));
      expect(
        privacyNavigationTest,
        contains('Privacy Center never renders the content API token'),
      );
      expect(
        privacyNavigationTest,
        contains('Women’s Ibadah Mode is designed local-first'),
      );
      expect(
        privacyNavigationTest,
        contains('Prayer location uses manual or preset choices'),
      );
      expect(
        privacyNavigationTest,
        contains('Delete local data page requires confirmation and resets'),
      );
      expect(
        manualLocationTest,
        contains('manual prayer location page saves valid coordinates'),
      );
      expect(
        manualLocationTest,
        contains('Stored locally. No GPS permission is required.'),
      );
      expect(
        remoteContentTest,
        contains('manifest request omits women mode status and gender fields'),
      );
      expect(remoteContentTest, contains('women mode status values do not'));
      expect(womenModeSessionTest, contains('avoids sensitive status terms'));
      expect(womenModeSessionTest, contains('menstruat'));
      expect(womenModeSessionTest, contains('postpartum'));
      expect(womenModeSessionTest, contains('pregnan'));
      expect(
        womenModePolicyDoc,
        contains('Exact Women\'s Ibadah Mode status'),
      );
      expect(
        womenModePolicyDoc,
        contains('Remote manifest requests continue to include only'),
      );
      expect(
        permissionCopy,
        contains('exact GPS permission is not implemented in MVP'),
      );
      expect(
        permissionCopy,
        contains('Exact status is not sent with'),
      );
      expect(
        permissionCopy,
        contains('remote content requests'),
      );
      expect(
        dataSafety,
        contains('exact GPS permission is not implemented in MVP'),
      );
      expect(
        dataSafety,
        contains('No Women\'s Ibadah Mode exact status'),
      );
      expect(
        dataSafety,
        contains('local closed-testing feedback-sent day markers'),
      );
      expect(
        dataSafety,
        contains('does not store feedback text, tester'),
      );
      expect(
        dataSafety,
        contains('identity, health details'),
      );
      expect(
        privacyInventory,
        contains('Closed testing feedback status'),
      );
      expect(
        privacyInventory,
        contains('Stores day IDs only; no feedback text or personal details'),
      );
      expect(
        readiness,
        contains('Privacy acceptance covers no GPS/location permission'),
      );
      expect(
        readiness,
        contains(
            'Privacy Center includes local closed-testing feedback status'),
      );
      expect(readiness, contains('manual or preset'));
      expect(readiness, contains('local-first Women'));
      expect(
        readiness,
        contains('exclude menstruating, postpartum, pregnancy, gender'),
      );
      expect(acceptance, contains('[x] v0.1 不请求 GPS/location permission。'));
      expect(acceptance, contains('[x] 支持 preset/manual location。'));
      expect(acceptance, contains('[x] Women’s Ibadah Mode 默认本地存储。'));
      expect(
        acceptance,
        contains('[x] 不上传 menstruating/postpartum/pregnancy 状态。'),
      );
      expect(
        acceptance,
        contains('[x] 隐私页面说明 location 和 women mode 数据用途。'),
      );
    });

    test('privacy docs remain explicit about no ads or tracking', () {
      final dataSafety =
          File('docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md')
              .readAsStringSync()
              .toLowerCase();
      final sdkInventory = File('docs/privacy/06_SDK_AND_API_INVENTORY.md')
          .readAsStringSync()
          .toLowerCase();

      expect(dataSafety, contains('no ads sdk'));
      expect(dataSafety, contains('no tracking sdk'));
      expect(sdkInventory, contains('shared_preferences'));
      expect(sdkInventory, contains('flutter_local_notifications'));
    });
  });
}

const _privacyDocs = [
  'docs/privacy/01_PRIVACY_DATA_INVENTORY.md',
  'docs/privacy/02_PRIVACY_POLICY_DRAFT.md',
  'docs/privacy/03_APP_STORE_PRIVACY_LABEL_DRAFT.md',
  'docs/privacy/04_GOOGLE_PLAY_DATA_SAFETY_DRAFT.md',
  'docs/privacy/05_PERMISSION_COPY.md',
  'docs/privacy/06_SDK_AND_API_INVENTORY.md',
];

const _releaseDocs = [
  'docs/release/01_RELEASE_READINESS_CHECKLIST.md',
  'docs/release/02_ANDROID_RELEASE_CHECKLIST.md',
  'docs/release/03_IOS_RELEASE_CHECKLIST.md',
  'docs/release/04_STORE_METADATA_DRAFT.md',
  'docs/release/05_SCREENSHOT_PLAN.md',
  'docs/release/06_PERMISSION_AND_DATA_SAFETY_REVIEW.md',
  'docs/release/07_BUILD_FLAVORS_AND_DART_DEFINE.md',
  'docs/release/08_VERSION_AND_RELEASE_NOTES.md',
  'docs/release/09_GOOGLE_PLAY_CLOSED_TESTING.md',
  'docs/release/10_ANDROID_UPLOAD_SIGNING_SETUP.md',
  'docs/release/11_PLAY_PUBLIC_LINKS_AND_FEEDBACK.md',
  'docs/release/12_CLOSED_TESTING_EVIDENCE_LOG.md',
  'docs/release/13_PLAY_CONSOLE_SUBMISSION_RUNBOOK.md',
  'docs/release/14_PRODUCTION_ACCESS_ANSWER_DRAFT.md',
  'docs/release/15_PUBLIC_LINKS_HOSTING_PACKET.md',
  'docs/release/16_CLOSED_TEST_LAUNCH_DAY_CHECKLIST.md',
  'docs/release/17_CLOSED_TEST_RETENTION_OBSERVATION_PLAN.md',
];

const _featureDirs = {
  'daily_session',
  'dhikr',
  'dua',
  'home',
  'onboarding',
  'prayer',
  'qibla',
  'quran',
  'saved',
  'settings',
  'splash',
};

const _coreDirs = {
  'config',
  'localization',
  'models',
  'privacy',
  'providers',
  'repositories',
  'services',
};

final _crossFeatureImportPattern = RegExp(
  r"import\s+'(\.\./\.\./features/|\.\./("
  r'daily_session|dhikr|dua|home|onboarding|prayer|qibla|quran|saved|settings|splash'
  r")/)",
);

final _jwtLikeSecretPattern = RegExp(
  r'eyj[a-z0-9_-]{20,}\.[a-z0-9_-]{20,}\.[a-z0-9_-]{20,}',
);

List<String> _trackedProjectFiles() {
  final result = Process.runSync('git', ['ls-files']);
  expect(result.exitCode, 0);
  return (result.stdout as String)
      .split('\n')
      .where((path) => path.trim().isNotEmpty)
      .toList();
}

_PngInfo _readPngInfo(File file) {
  final bytes = file.readAsBytesSync();
  expect(bytes.length, greaterThanOrEqualTo(26), reason: file.path);
  expect(bytes.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
  expect(String.fromCharCodes(bytes.sublist(12, 16)), 'IHDR');
  return _PngInfo(
    _uint32BigEndian(bytes, 16),
    _uint32BigEndian(bytes, 20),
    bytes[25],
  );
}

int _uint32BigEndian(List<int> bytes, int offset) {
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

class _PngInfo {
  const _PngInfo(this.width, this.height, this.colorType);

  final int width;
  final int height;
  final int colorType;
}

bool _isScannableTextPath(String path) {
  return const [
    '.arb',
    '.dart',
    '.gradle',
    '.json',
    '.kts',
    '.kt',
    '.lock',
    '.md',
    '.properties',
    '.sh',
    '.swift',
    '.toml',
    '.ts',
    '.tsx',
    '.txt',
    '.xml',
    '.yaml',
    '.yml',
  ].any(path.endsWith);
}

Set<String> _childDirectoryNames(String path) {
  return Directory(path)
      .listSync()
      .whereType<Directory>()
      .map((directory) => directory.uri.pathSegments
          .where((segment) => segment.isNotEmpty)
          .last)
      .toSet();
}

List<File> _dartFilesUnder(String path) {
  return Directory(path)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}

_Version _versionFromMatch(RegExpMatch? match) {
  expect(match, isNotNull);
  final parts = match!.group(1)!.split('.').map(int.parse).toList();
  return _Version(
    parts.isNotEmpty ? parts[0] : 0,
    parts.length > 1 ? parts[1] : 0,
    parts.length > 2 ? parts[2] : 0,
  );
}

_Version _versionFromLockfile(String lockfile, String packageName) {
  final lines = lockfile.split('\n');
  for (var index = 0; index < lines.length; index += 1) {
    if (lines[index] != '  $packageName:') {
      continue;
    }
    for (var versionIndex = index + 1;
        versionIndex < lines.length;
        versionIndex += 1) {
      final line = lines[versionIndex];
      if (line.startsWith('  ') && !line.startsWith('    ')) {
        break;
      }
      final match = RegExp(r'^\s+version: "([0-9.]+)"$').firstMatch(line);
      if (match != null) {
        return _versionFromMatch(match);
      }
    }
  }

  fail('Could not find $packageName in pubspec.lock');
}

String _metadataValue(String metadata, String label) {
  final match =
      RegExp('^- $label: (.+)\$', multiLine: true).firstMatch(metadata);
  expect(match, isNotNull, reason: label);
  return match!.group(1)!.trim();
}

class _Version implements Comparable<_Version> {
  const _Version(this.major, this.minor, this.patch);

  final int major;
  final int minor;
  final int patch;

  @override
  int compareTo(_Version other) {
    final majorCompare = major.compareTo(other.major);
    if (majorCompare != 0) {
      return majorCompare;
    }
    final minorCompare = minor.compareTo(other.minor);
    if (minorCompare != 0) {
      return minorCompare;
    }
    return patch.compareTo(other.patch);
  }
}
