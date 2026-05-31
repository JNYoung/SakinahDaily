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
  });

  group('build flavor config', () {
    test('defaults to dev and keeps telemetry disabled', () {
      final config = AppEnvironmentConfig.fromMap(const {});

      expect(config.environment, AppEnvironment.dev);
      expect(config.appName, 'Sakinah Daily Dev');
      expect(config.remoteContentEnabled, isFalse);
      expect(config.analyticsEnabled, isFalse);
      expect(config.crashReportingEnabled, isFalse);
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

    test('no analytics crash ads or tracking SDK dependency exists', () {
      final pubspec = File('pubspec.yaml').readAsStringSync().toLowerCase();
      for (final forbidden in [
        'firebase_analytics',
        'firebase_crashlytics',
        'sentry',
        'appsflyer',
        'adjust',
        'google_mobile_ads',
      ]) {
        expect(pubspec, isNot(contains(forbidden)), reason: forbidden);
      }
    });

    test('Android manifest requests only foreground coarse location', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();

      expect(manifest, contains('ACCESS_COARSE_LOCATION'));
      expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
      expect(manifest, isNot(contains('ACCESS_BACKGROUND_LOCATION')));
      expect(manifest, isNot(contains('FOREGROUND_SERVICE_LOCATION')));
      expect(manifest, isNot(contains('BODY_SENSORS')));
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

    test('privacy inventory still marks women mode local-only high sensitivity',
        () {
      final womenMode =
          PrivacyDataInventory.categoryById('women_ibadah_mode_state');

      expect(womenMode.storageLocation, PrivacyStorageLocation.localDevice);
      expect(womenMode.sensitivity, PrivacySensitivity.high);
      expect(womenMode.leavesDevice, isFalse);
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
  'docs/release/08_PRAYER_DEVICE_LOCATION_QA.md',
];
