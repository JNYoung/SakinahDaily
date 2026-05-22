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

  test('remote content request metadata is the only leaves-device content item',
      () {
    final category =
        PrivacyDataInventory.categoryById('remote_content_request_metadata');

    expect(category.storageLocation, PrivacyStorageLocation.remoteOptional);
    expect(category.leavesDevice, isTrue);
    expect(category.notesKey, 'remoteContentRequestMetadataNotes');
  });

  test('content request context does not retain women exact status', () {
    const context = ContentRequestContext(
      languageCode: 'en',
      market: 'global',
      appVersion: '0.1.0',
      womenIbadahMode: WomenIbadahMode(
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
      'storePrivacyDraftTitle',
      'privacyPolicyDraftTitle',
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
