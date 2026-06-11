import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/services/prayer_calculation_service.dart';

void main() {
  const makkah = PrayerSettings(
    latitude: 21.3891,
    longitude: 39.8579,
    method: 'umm_al_qura',
    locationLabel: 'Makkah',
    timezoneId: 'Asia/Riyadh',
  );

  test('prayer calculation returns five daily prayers for supported methods',
      () {
    final service = PrayerCalculationService();

    for (final method in PrayerCalculationService.supportedMethodIds) {
      final prayers = service.calculateForDate(
        DateTime(2026, 5, 21, 10),
        makkah.copyWith(method: method),
      );

      expect(prayers.map((prayer) => prayer.name), [
        'Fajr',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ]);
      expect(prayers, hasLength(5));
      for (var index = 1; index < prayers.length; index += 1) {
        expect(prayers[index].time.isAfter(prayers[index - 1].time), isTrue);
      }
    }
  });

  test('next prayer rolls over to tomorrow Fajr after Isha', () {
    final service = PrayerCalculationService();
    final today = service.calculateForDate(DateTime(2026, 5, 21), makkah);
    final afterIsha = today.last.time.add(const Duration(minutes: 3));

    final next = service.nextPrayer(afterIsha, makkah);

    expect(next.name, 'Fajr');
    expect(next.time.isAfter(afterIsha), isTrue);
    expect(next.time.day, isNot(today.last.time.day));
  });

  test('day status marks current and next prayers', () {
    final service = PrayerCalculationService();

    final status = service.dayStatus(
      DateTime(2026, 5, 21, 6, 30),
      makkah,
    );

    expect(status.currentPrayer?.name, 'Fajr');
    expect(status.nextPrayer.name, 'Dhuhr');
    expect(status.isCurrent(status.prayers.first), isTrue);
    expect(status.isNext(status.prayers[1]), isTrue);
    expect(status.isNext(status.prayers.first), isFalse);
  });

  test('timezone id overrides longitude fallback when available', () {
    final service = PrayerCalculationService();
    final longitudeFallback = makkah.copyWith(timezoneId: null);
    final jakartaZone = makkah.copyWith(timezoneId: 'Asia/Jakarta');

    final fallbackDhuhr =
        service.calculateForDate(DateTime(2026, 5, 21), longitudeFallback)[1];
    final jakartaDhuhr =
        service.calculateForDate(DateTime(2026, 5, 21), jakartaZone)[1];

    expect(jakartaDhuhr.time.difference(fallbackDhuhr.time).inHours, 4);
  });

  test('invalid timezone id falls back to longitude-derived clock', () {
    final service = PrayerCalculationService();
    final fallback = makkah.copyWith(timezoneId: null);
    final invalidZone = makkah.copyWith(timezoneId: 'Not/AZone');

    final fallbackPrayers =
        service.calculateForDate(DateTime(2026, 5, 21), fallback);
    final invalidPrayers =
        service.calculateForDate(DateTime(2026, 5, 21), invalidZone);

    expect(invalidPrayers[1].time, fallbackPrayers[1].time);
  });
}
