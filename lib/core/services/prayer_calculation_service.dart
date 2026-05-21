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
  List<PrayerTime> calculateForDate(DateTime date, PrayerSettings settings) {
    final localNoonOffset = settings.longitude / 15.0;
    final minuteAdjustment = ((localNoonOffset - localNoonOffset.truncate()) * 8)
        .round()
        .clamp(-12, 12);

    DateTime at(int hour, int minute) {
      return DateTime(date.year, date.month, date.day, hour, minute)
          .add(Duration(minutes: minuteAdjustment));
    }

    return [
      PrayerTime(name: 'Fajr', time: at(5, 5)),
      PrayerTime(name: 'Dhuhr', time: at(12, 20)),
      PrayerTime(name: 'Asr', time: at(15, 45)),
      PrayerTime(name: 'Maghrib', time: at(18, 15)),
      PrayerTime(name: 'Isha', time: at(19, 45)),
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
}
