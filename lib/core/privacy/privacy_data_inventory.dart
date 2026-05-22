enum PrivacyStorageLocation {
  localDevice,
  remoteOptional,
  notCollected,
}

enum PrivacySensitivity {
  low,
  medium,
  high,
}

class PrivacyDataCategory {
  const PrivacyDataCategory({
    required this.id,
    required this.displayNameKey,
    required this.storageLocation,
    required this.sensitivity,
    required this.leavesDevice,
    required this.userCanDelete,
    required this.notesKey,
  });

  final String id;
  final String displayNameKey;
  final PrivacyStorageLocation storageLocation;
  final PrivacySensitivity sensitivity;
  final bool leavesDevice;
  final bool userCanDelete;
  final String notesKey;
}

abstract final class PrivacyDataInventory {
  static const categories = [
    PrivacyDataCategory(
      id: 'language_preference',
      displayNameKey: 'privacyDataLanguagePreference',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataLanguagePreferenceNotes',
    ),
    PrivacyDataCategory(
      id: 'gender_mode_preference',
      displayNameKey: 'privacyDataGenderModePreference',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataGenderModePreferenceNotes',
    ),
    PrivacyDataCategory(
      id: 'audio_preference',
      displayNameKey: 'privacyDataAudioPreference',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataAudioPreferenceNotes',
    ),
    PrivacyDataCategory(
      id: 'prayer_settings',
      displayNameKey: 'privacyDataPrayerSettings',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataPrayerSettingsNotes',
    ),
    PrivacyDataCategory(
      id: 'prayer_location_preset',
      displayNameKey: 'privacyDataPrayerLocationPreset',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataPrayerLocationPresetNotes',
    ),
    PrivacyDataCategory(
      id: 'notification_enabled_state',
      displayNameKey: 'privacyDataNotificationEnabledState',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataNotificationEnabledStateNotes',
    ),
    PrivacyDataCategory(
      id: 'women_ibadah_mode_state',
      displayNameKey: 'privacyDataWomenModeState',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.high,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataWomenModeStateNotes',
    ),
    PrivacyDataCategory(
      id: 'local_content_manifest',
      displayNameKey: 'privacyDataLocalContentManifest',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataLocalContentManifestNotes',
    ),
    PrivacyDataCategory(
      id: 'local_content_bundles',
      displayNameKey: 'privacyDataLocalContentBundles',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataLocalContentBundlesNotes',
    ),
    PrivacyDataCategory(
      id: 'local_revoked_content_ids',
      displayNameKey: 'privacyDataLocalRevokedContentIds',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataLocalRevokedContentIdsNotes',
    ),
    PrivacyDataCategory(
      id: 'saved_items',
      displayNameKey: 'privacyDataSavedItems',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataSavedItemsNotes',
    ),
    PrivacyDataCategory(
      id: 'session_progress_history',
      displayNameKey: 'privacyDataSessionProgressHistory',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataSessionProgressHistoryNotes',
    ),
    PrivacyDataCategory(
      id: 'local_push_payload_debug_data',
      displayNameKey: 'privacyDataLocalPushDebug',
      storageLocation: PrivacyStorageLocation.notCollected,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: false,
      notesKey: 'privacyDataLocalPushDebugNotes',
    ),
    PrivacyDataCategory(
      id: 'audio_playback_state',
      displayNameKey: 'privacyDataAudioPlaybackState',
      storageLocation: PrivacyStorageLocation.notCollected,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: false,
      userCanDelete: false,
      notesKey: 'privacyDataAudioPlaybackStateNotes',
    ),
    PrivacyDataCategory(
      id: 'remote_content_api_config_state',
      displayNameKey: 'privacyDataRemoteContentApiConfig',
      storageLocation: PrivacyStorageLocation.localDevice,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: true,
      notesKey: 'privacyDataRemoteContentApiConfigNotes',
    ),
    PrivacyDataCategory(
      id: 'remote_content_request_metadata',
      displayNameKey: 'privacyDataRemoteContentRequestMetadata',
      storageLocation: PrivacyStorageLocation.remoteOptional,
      sensitivity: PrivacySensitivity.low,
      leavesDevice: true,
      userCanDelete: false,
      notesKey: 'remoteContentRequestMetadataNotes',
    ),
    PrivacyDataCategory(
      id: 'future_analytics_crash_reporting',
      displayNameKey: 'privacyDataFutureAnalyticsCrash',
      storageLocation: PrivacyStorageLocation.notCollected,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: false,
      notesKey: 'privacyDataFutureAnalyticsCrashNotes',
    ),
    PrivacyDataCategory(
      id: 'account_data',
      displayNameKey: 'privacyDataAccountData',
      storageLocation: PrivacyStorageLocation.notCollected,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: false,
      notesKey: 'privacyDataAccountDataNotes',
    ),
    PrivacyDataCategory(
      id: 'payments_subscriptions',
      displayNameKey: 'privacyDataPaymentsSubscriptions',
      storageLocation: PrivacyStorageLocation.notCollected,
      sensitivity: PrivacySensitivity.medium,
      leavesDevice: false,
      userCanDelete: false,
      notesKey: 'privacyDataPaymentsSubscriptionsNotes',
    ),
    PrivacyDataCategory(
      id: 'ads_tracking',
      displayNameKey: 'privacyDataAdsTracking',
      storageLocation: PrivacyStorageLocation.notCollected,
      sensitivity: PrivacySensitivity.high,
      leavesDevice: false,
      userCanDelete: false,
      notesKey: 'privacyDataAdsTrackingNotes',
    ),
  ];

  static PrivacyDataCategory categoryById(String id) {
    return categories.firstWhere((category) => category.id == id);
  }
}
