import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/services/qibla_service.dart';

void main() {
  final service = QiblaService();

  test('computes a valid bearing between 0 and 360 degrees', () {
    final result = service.calculateBearing(const PrayerSettings(
      latitude: 25.2048,
      longitude: 55.2708,
      method: 'muslim_world_league',
      locationLabel: 'Dubai',
    ));

    expect(result.degrees, greaterThanOrEqualTo(0));
    expect(result.degrees, lessThan(360));
    expect(result.locationLabel, 'Dubai');
  });

  test('Jakarta bearing is deterministic within tolerance', () {
    final result = service.calculateBearing(const PrayerSettings(
      latitude: -6.2088,
      longitude: 106.8456,
      method: 'indonesia',
      locationLabel: 'Jakarta',
    ));

    expect(result.degrees, closeTo(295.2, 0.5));
  });

  test('Makkah Jeddah and Dubai fixture bearings are deterministic', () {
    final makkah = service.calculateBearing(const PrayerSettings(
      latitude: 21.3891,
      longitude: 39.8579,
      method: 'umm_al_qura',
      locationLabel: 'Makkah',
    ));
    final jeddah = service.calculateBearing(const PrayerSettings(
      latitude: 21.4858,
      longitude: 39.1925,
      method: 'umm_al_qura',
      locationLabel: 'Jeddah',
    ));
    final dubai = service.calculateBearing(const PrayerSettings(
      latitude: 25.2048,
      longitude: 55.2708,
      method: 'muslim_world_league',
      locationLabel: 'Dubai',
    ));

    expect(makkah.degrees, closeTo(318.5, 0.6));
    expect(jeddah.degrees, closeTo(96.0, 0.6));
    expect(dubai.degrees, closeTo(258.2, 0.6));
  });
}
