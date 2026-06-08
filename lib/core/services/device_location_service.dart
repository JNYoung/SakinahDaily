import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum DeviceLocationRequestStatus {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class DevicePrayerLocation {
  const DevicePrayerLocation({
    required this.latitude,
    required this.longitude,
    required this.approximate,
  });

  final double latitude;
  final double longitude;
  final bool approximate;
}

class DeviceLocationRequestResult {
  const DeviceLocationRequestResult._({
    required this.status,
    this.location,
  });

  final DeviceLocationRequestStatus status;
  final DevicePrayerLocation? location;

  const DeviceLocationRequestResult.granted(DevicePrayerLocation location)
      : this._(
          status: DeviceLocationRequestStatus.granted,
          location: location,
        );

  const DeviceLocationRequestResult.serviceDisabled()
      : this._(status: DeviceLocationRequestStatus.serviceDisabled);

  const DeviceLocationRequestResult.permissionDenied()
      : this._(status: DeviceLocationRequestStatus.permissionDenied);

  const DeviceLocationRequestResult.permissionDeniedForever()
      : this._(status: DeviceLocationRequestStatus.permissionDeniedForever);

  const DeviceLocationRequestResult.unavailable()
      : this._(status: DeviceLocationRequestStatus.unavailable);
}

abstract class DeviceLocationService {
  Future<DeviceLocationRequestResult> requestCurrentPrayerLocation();
}

class GeolocatorDeviceLocationService implements DeviceLocationService {
  const GeolocatorDeviceLocationService();

  static const _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    timeLimit: Duration(seconds: 15),
  );

  @override
  Future<DeviceLocationRequestResult> requestCurrentPrayerLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const DeviceLocationRequestResult.serviceDisabled();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const DeviceLocationRequestResult.permissionDenied();
      }
      if (permission == LocationPermission.deniedForever) {
        return const DeviceLocationRequestResult.permissionDeniedForever();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings,
      );
      return DeviceLocationRequestResult.granted(
        DevicePrayerLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          approximate: await _isApproximateLocation(),
        ),
      );
    } on TimeoutException {
      return const DeviceLocationRequestResult.unavailable();
    } on Object {
      return const DeviceLocationRequestResult.unavailable();
    }
  }

  Future<bool> _isApproximateLocation() async {
    try {
      final accuracy = await Geolocator.getLocationAccuracy();
      return accuracy == LocationAccuracyStatus.reduced;
    } on Object {
      return true;
    }
  }
}
