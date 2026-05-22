import 'dart:math' as math;

import '../models/sakinah_models.dart';

class QiblaBearing {
  const QiblaBearing({
    required this.degrees,
    required this.locationLabel,
    required this.cardinalLabel,
  });

  final double degrees;
  final String locationLabel;
  final String cardinalLabel;
}

class QiblaService {
  static const kaabaLatitude = 21.4225;
  static const kaabaLongitude = 39.8262;

  QiblaBearing calculateBearing(PrayerSettings settings) {
    final lat1 = _radians(settings.latitude);
    final lat2 = _radians(kaabaLatitude);
    final deltaLongitude = _radians(kaabaLongitude - settings.longitude);
    final y = math.sin(deltaLongitude) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLongitude);
    final bearing = (_degrees(math.atan2(y, x)) + 360) % 360;
    return QiblaBearing(
      degrees: bearing,
      locationLabel: settings.locationLabel,
      cardinalLabel: _cardinalLabel(bearing),
    );
  }

  double _radians(double degrees) => degrees * math.pi / 180;

  double _degrees(double radians) => radians * 180 / math.pi;

  String _cardinalLabel(double degrees) {
    const labels = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) ~/ 45) % labels.length;
    return labels[index];
  }
}
