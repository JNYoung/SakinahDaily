import 'package:adhan_dart/adhan_dart.dart' as adhan;

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

  List<PrayerTime> calculateForDate(DateTime date, PrayerSettings settings) {
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
}
