import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/privacy/privacy_data_inventory.dart';

void main() {
  test('women mode is marked high sensitivity and local only', () {
    final category =
        PrivacyDataInventory.categoryById('women_ibadah_mode_state');

    expect(category.storageLocation, PrivacyStorageLocation.localDevice);
    expect(category.sensitivity, PrivacySensitivity.high);
    expect(category.leavesDevice, isFalse);
    expect(category.userCanDelete, isTrue);
  });

  test('remote content and opted-in analytics are leaves-device categories',
      () {
    final leavesDeviceIds = PrivacyDataInventory.categories
        .where((category) => category.leavesDevice)
        .map((category) => category.id);

    expect(
        leavesDeviceIds,
        unorderedEquals([
          'remote_content_request_metadata',
          'default_off_analytics_events',
        ]));
    expect(
      PrivacyDataInventory.categoryById('remote_content_request_metadata')
          .notesKey,
      'remoteContentRequestMetadataNotes',
    );
    expect(
      PrivacyDataInventory.categoryById('default_off_analytics_events')
          .notesKey,
      'privacyDataAnalyticsEventsNotes',
    );
  });

  test('analytics consent preference is local and deletable', () {
    final category =
        PrivacyDataInventory.categoryById('analytics_consent_preference');

    expect(category.storageLocation, PrivacyStorageLocation.localDevice);
    expect(category.sensitivity, PrivacySensitivity.low);
    expect(category.leavesDevice, isFalse);
    expect(category.userCanDelete, isTrue);
  });

  test('saved items are marked medium sensitivity and local only', () {
    final category = PrivacyDataInventory.categoryById('saved_items');

    expect(category.storageLocation, PrivacyStorageLocation.localDevice);
    expect(category.sensitivity, PrivacySensitivity.medium);
    expect(category.leavesDevice, isFalse);
    expect(category.userCanDelete, isTrue);
  });

  test('session progress history is marked medium sensitivity and local only',
      () {
    final category =
        PrivacyDataInventory.categoryById('session_progress_history');

    expect(category.storageLocation, PrivacyStorageLocation.localDevice);
    expect(category.sensitivity, PrivacySensitivity.medium);
    expect(category.leavesDevice, isFalse);
    expect(category.userCanDelete, isTrue);
  });

  test('content request context does not retain women exact status', () {
    final context = ContentRequestContext(
      languageCode: 'en',
      market: 'global',
      appVersion: '0.1.0',
      womenIbadahMode: const WomenIbadahMode(
        enabled: true,
        status: WomenIbadahStatus.menstruating,
      ),
    );

    expect(context.womenModeEnabled, isTrue);
    expect(context.womenIbadahMode.status, WomenIbadahStatus.normal);
  });

  test('English Indonesian and Arabic privacy strings exist', () {
    const requiredKeys = [
      'privacyCenterTitle',
      'dataInventoryTitle',
      'deleteLocalDataTitle',
      'deleteLocalDataBody',
      'deleteLocalDataConfirm',
      'deleteLocalDataSuccess',
      'localOnlyData',
      'leavesDeviceData',
      'womenModePrivacyTitle',
      'womenModePrivacyBody',
      'prayerLocationPrivacyTitle',
      'prayerLocationPrivacyBody',
      'notificationPrivacyTitle',
      'notificationPrivacyBody',
      'remoteContentPrivacyTitle',
      'remoteContentPrivacyBody',
      'privacyDataSavedItems',
      'privacyDataSavedItemsNotes',
      'privacyDataSessionProgressHistory',
      'privacyDataSessionProgressHistoryNotes',
      'privacyDataAnalyticsConsent',
      'privacyDataAnalyticsConsentNotes',
      'privacyDataAnalyticsEvents',
      'privacyDataAnalyticsEventsNotes',
      'storePrivacyDraftTitle',
      'privacyPolicyDraftTitle',
      'quranPageTitle',
      'featuredAyah',
      'openAyah',
      'quranVerseUnavailable',
      'saveAyah',
      'savedAyah',
      'quranVoiceOnlyTitle',
      'quranVoiceOnlyBody',
      'noQuranTts',
      'noQuranBgm',
      'manualPrayerLocationTitle',
      'manualPrayerLocationBody',
      'locationLabel',
      'latitude',
      'longitude',
      'timezoneId',
      'saveLocation',
      'invalidLatitude',
      'invalidLongitude',
      'locationSaved',
      'locationLocalOnlyNoGps',
      'sessionCompletedTitle',
      'sessionCompletedBody',
      'completedToday',
      'resumeSession',
      'reviewSession',
      'localProgress',
      'currentStreak',
      'completedThisWeek',
      'progressLocalOnly',
      'saveSession',
      'sessionSaved',
      'openSavedItems',
      'backHome',
      'sessionProgressHistory',
      'sessionProgressHistoryNotes',
      'noGuaranteedOutcome',
      'localOnlyMode',
      'womenModePrivatePath',
      'womenModeHomeSupportBody',
      'womenModeSessionNoteTitle',
      'womenModeSessionNoteBody',
      'womenModeWhatChangesTitle',
      'womenModeWhatChangesBody',
      'womenModeWhatStaysPrivateTitle',
      'womenModeWhatStaysPrivateBody',
      'womenModeReminderPrivacyBody',
      'womenModeTurnOffBody',
      'openPrivacyCenter',
    ];

    for (final locale in ['en', 'id', 'ar']) {
      final raw = File('lib/l10n/app_$locale.arb').readAsStringSync();
      final values = jsonDecode(raw) as Map<String, dynamic>;
      for (final key in requiredKeys) {
        expect(values[key], isA<String>());
        expect((values[key] as String).trim(), isNotEmpty);
      }
    }
  });
}
