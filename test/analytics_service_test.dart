import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/services/analytics_service.dart';

void main() {
  group('analytics event contract', () {
    test('catalog uses Google Analytics compatible event names', () {
      for (final eventName in AnalyticsEventCatalog.allowedEventNames) {
        expect(eventName.length, lessThanOrEqualTo(40), reason: eventName);
        expect(
          RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(eventName),
          isTrue,
          reason: eventName,
        );
      }

      expect(
        AnalyticsEventCatalog.allowedEventNames,
        containsAll(<String>[
          AnalyticsEventCatalog.onboardingCompleted,
          AnalyticsEventCatalog.homeViewed,
          AnalyticsEventCatalog.prayerViewed,
          AnalyticsEventCatalog.prayerReminderChanged,
          AnalyticsEventCatalog.dailySessionStarted,
          AnalyticsEventCatalog.dailySessionCompleted,
          AnalyticsEventCatalog.closedTestPromptCopied,
        ]),
      );
    });

    test('stub records only whitelisted events when enabled', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.dailySessionStarted,
        const {
          'session_id': 'session_morning_ease',
          'language_code': 'en',
        },
      );
      analytics.track('unknown_event', const {'session_id': 'ignored'});

      expect(analytics.events, hasLength(1));
      expect(
        analytics.events.single.name,
        AnalyticsEventCatalog.dailySessionStarted,
      );
      expect(analytics.events.single.properties, {
        'session_id': 'session_morning_ease',
        'language_code': 'en',
      });
    });

    test('stub drops sensitive or free-text parameters', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.prayerReminderChanged,
        const {
          'prayer_name': 'Fajr',
          'enabled': true,
          'reminder_offset_minutes': 10,
          'latitude': 21.4225,
          'longitude': 39.8262,
          'women_ibadah_status': 'menstruating',
          'feedback_text': 'private tester note',
          'quran_arabic_text': 'sensitive text should never be sent',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'prayer_name': 'Fajr',
        'enabled': true,
        'reminder_offset_minutes': 10,
      });
    });

    test('disabled stub is a no-op for release builds before consent', () {
      final analytics = StubAnalyticsService(enabled: false);

      analytics.track(AnalyticsEventCatalog.homeViewed, const {
        'route': '/home',
      });

      expect(analytics.events, isEmpty);
    });
  });
}
