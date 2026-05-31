import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/sakinah_localizations.dart';
import '../../core/models/sakinah_models.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/device_location_service.dart';

Future<bool> requestAndSaveDevicePrayerLocation({
  required BuildContext context,
  required WidgetRef ref,
  required SakinahLocalizations l10n,
}) async {
  final result = await ref
      .read(deviceLocationServiceProvider)
      .requestCurrentPrayerLocation();

  if (!context.mounted) {
    return false;
  }

  final messenger = ScaffoldMessenger.of(context);
  if (result.status == DeviceLocationRequestStatus.granted &&
      result.location != null) {
    final currentSettings = ref.read(userPreferencesProvider).prayerSettings;
    await ref.read(userPreferencesProvider.notifier).setPrayerSettings(
          currentSettings.copyWith(
            latitude: result.location!.latitude,
            longitude: result.location!.longitude,
            locationLabel: l10n.t('deviceLocationLabel'),
            timezoneId: null,
            locationMode: PrayerLocationMode.device,
          ),
        );
    if (!context.mounted) {
      return true;
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.t('deviceLocationSaved'))),
    );
    return true;
  }

  messenger.showSnackBar(
    SnackBar(content: Text(_fallbackMessage(l10n, result.status))),
  );
  return false;
}

String _fallbackMessage(
  SakinahLocalizations l10n,
  DeviceLocationRequestStatus status,
) {
  return switch (status) {
    DeviceLocationRequestStatus.serviceDisabled =>
      l10n.t('deviceLocationServiceDisabledFallback'),
    DeviceLocationRequestStatus.permissionDeniedForever =>
      l10n.t('deviceLocationDeniedForeverFallback'),
    DeviceLocationRequestStatus.permissionDenied =>
      l10n.t('deviceLocationDeniedFallback'),
    DeviceLocationRequestStatus.unavailable =>
      l10n.t('deviceLocationUnavailableFallback'),
    DeviceLocationRequestStatus.granted => l10n.t('deviceLocationSaved'),
  };
}
