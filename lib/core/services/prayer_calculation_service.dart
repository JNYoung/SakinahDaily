import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../models/sakinah_models.dart';

class PrayerTime {
  const PrayerTime({
    required this.name,
    required this.time,
  });

  final String name;
  final DateTime time;
}

class PrayerCalculationService {
  static bool _timeZonesInitialized = false;

  static const supportedMethodIds = [
    'umm_al_qura',
    'muslim_world_league',
    'egyptian',
    'indonesia',
  ];

  static const methodLabels = {
    'umm_al_qura': 'Umm al-Qura',
    'muslim_world_league': 'Muslim World League',
    'egyptian': 'Egyptian',
    'indonesia': 'KEMENAG Indonesia',
  };

  static const locationPresets = [
    PrayerLocationPreset(
      id: 'makkah',
      label: 'Makkah',
      latitude: 21.3891,
      longitude: 39.8579,
      timezoneId: 'Asia/Riyadh',
      method: 'umm_al_qura',
    ),
    PrayerLocationPreset(
      id: 'riyadh',
      label: 'Riyadh',
      latitude: 24.7136,
      longitude: 46.6753,
      timezoneId: 'Asia/Riyadh',
      method: 'umm_al_qura',
    ),
    PrayerLocationPreset(
      id: 'jakarta',
      label: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      timezoneId: 'Asia/Jakarta',
      method: 'indonesia',
    ),
    PrayerLocationPreset(
      id: 'dubai',
      label: 'Dubai',
      latitude: 25.2048,
      longitude: 55.2708,
      timezoneId: 'Asia/Dubai',
      method: 'muslim_world_league',
    ),
    PrayerLocationPreset(
      id: 'cairo',
      label: 'Cairo',
      latitude: 30.0444,
      longitude: 31.2357,
      timezoneId: 'Africa/Cairo',
      method: 'egyptian',
    ),
  ];

  List<PrayerTime> calculateForDate(DateTime date, PrayerSettings settings) {
    _ensureTimeZonesInitialized();
    final coordinates = adhan.Coordinates(
      settings.latitude,
      settings.longitude,
    );
    final prayerTimes = adhan.PrayerTimes(
      coordinates: coordinates,
      date: DateTime(date.year, date.month, date.day),
      calculationParameters: _parametersFor(settings.method),
    );

    return [
      PrayerTime(
        name: 'Fajr',
        time: _toLocationClockTime(prayerTimes.fajr, settings),
      ),
      PrayerTime(
        name: 'Dhuhr',
        time: _toLocationClockTime(prayerTimes.dhuhr, settings),
      ),
      PrayerTime(
        name: 'Asr',
        time: _toLocationClockTime(prayerTimes.asr, settings),
      ),
      PrayerTime(
        name: 'Maghrib',
        time: _toLocationClockTime(prayerTimes.maghrib, settings),
      ),
      PrayerTime(
        name: 'Isha',
        time: _toLocationClockTime(prayerTimes.isha, settings),
      ),
    ];
  }

  PrayerTime nextPrayer(DateTime now, PrayerSettings settings) {
    final today = calculateForDate(now, settings);
    for (final prayer in today) {
      if (prayer.time.isAfter(now)) {
        return prayer;
      }
    }
    return calculateForDate(now.add(const Duration(days: 1)), settings).first;
  }

  String methodLabel(String methodId) {
    return methodLabels[methodId] ?? methodLabels['umm_al_qura']!;
  }

  adhan.CalculationParameters _parametersFor(String methodId) {
    return switch (methodId) {
      'muslim_world_league' =>
        adhan.CalculationMethodParameters.muslimWorldLeague(),
      'egyptian' => adhan.CalculationMethodParameters.egyptian(),
      'indonesia' => adhan.CalculationMethodParameters.indonesian(),
      'kemenag' => adhan.CalculationMethodParameters.indonesian(),
      'umm_al_qura' => adhan.CalculationMethodParameters.ummAlQura(),
      _ => adhan.CalculationMethodParameters.ummAlQura(),
    };
  }

  DateTime _toLocationClockTime(DateTime utcTime, PrayerSettings settings) {
    final location = _locationFor(settings.timezoneId);
    if (location != null) {
      final locationClock = timezone.TZDateTime.from(utcTime.toUtc(), location);
      return DateTime(
        locationClock.year,
        locationClock.month,
        locationClock.day,
        locationClock.hour,
        locationClock.minute,
        locationClock.second,
      );
    }

    final locationClock = utcTime.toUtc().add(_estimatedOffset(settings));
    return DateTime(
      locationClock.year,
      locationClock.month,
      locationClock.day,
      locationClock.hour,
      locationClock.minute,
      locationClock.second,
    );
  }

  Duration _estimatedOffset(PrayerSettings settings) {
    final minutes = (settings.longitude / 15 * 60).round().clamp(-720, 840);
    return Duration(minutes: minutes);
  }

  void _ensureTimeZonesInitialized() {
    if (_timeZonesInitialized) {
      return;
    }
    timezone_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  timezone.Location? _locationFor(String? timezoneId) {
    if (timezoneId == null || timezoneId.isEmpty) {
      return null;
    }
    try {
      return timezone.getLocation(timezoneId);
    } on Object {
      return null;
    }
  }
}
