import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/config/app_environment.dart';
import 'package:sakinah_daily/core/providers/app_providers.dart';
import 'package:sakinah_daily/core/repositories/user_preferences_repository.dart';
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
          AnalyticsEventCatalog.prayerChecklistUpdated,
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

    test('daily session start analytics keeps safe source metadata', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.dailySessionStarted,
        const {
          'session_id': 'session_morning_ease',
          'language_code': 'en',
          'source': 'prayer_completion',
          'content_id': '94:5',
          'content_type': 'quran',
          'quran_arabic_text': 'sensitive text should never be sent',
          'reflection_text': 'private note',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'session_id': 'session_morning_ease',
        'language_code': 'en',
        'source': 'prayer_completion',
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

    test('prayer checklist analytics only keeps aggregate usage fields', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.prayerChecklistUpdated,
        const {
          'screen': 'prayer',
          'completed_count': 3,
          'all_prayers_completed': false,
          'prayer_name': 'Fajr',
          'location_label': 'Makkah',
          'completed_at': '2026-06-12T05:10:00Z',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'screen': 'prayer',
        'completed_count': 3,
        'all_prayers_completed': false,
      });
    });

    test('closed test prompt analytics keeps only aggregate prompt metadata',
        () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.closedTestPromptCopied,
        const {
          'prompt_day': 'day3',
          'theme_key': 'prayer_time_trust',
          'source': 'closed_testing_guide',
          'feedback_text': 'private tester note',
          'email': 'tester@example.com',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'prompt_day': 'day3',
        'theme_key': 'prayer_time_trust',
        'source': 'closed_testing_guide',
      });
    });

    test('onboarding analytics keeps only safe funnel metadata', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.onboardingCompleted,
        const {
          'language_code': 'id',
          'location_method': 'preset',
          'audio_preference': 'textFirst',
          'source': 'onboarding',
          'gender_mode': 'female',
          'location_label': 'Jakarta',
          'prayer_name': 'Fajr',
          'latitude': -6.2088,
          'longitude': 106.8456,
        },
      );
      analytics.track(
        AnalyticsEventCatalog.genderModeSelected,
        const {
          'source': 'onboarding',
          'gender_mode': 'female',
          'women_ibadah_status': 'menstruating',
        },
      );

      expect(analytics.events, hasLength(2));
      expect(analytics.events.first.properties, {
        'language_code': 'id',
        'location_method': 'preset',
        'audio_preference': 'textFirst',
        'source': 'onboarding',
      });
      expect(analytics.events.last.properties, {
        'source': 'onboarding',
      });
    });

    test('daily session step analytics keeps only step funnel metadata', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.dailySessionStepViewed,
        const {
          'session_id': 'session_morning_ease',
          'step_id': 'quran',
          'step_index': 2,
          'source': 'daily_session',
          'content_id': '94:5',
          'content_type': 'quran',
          'quran_arabic_text': 'sensitive text should never be sent',
          'reflection_text': 'private note',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'session_id': 'session_morning_ease',
        'step_id': 'quran',
        'step_index': 2,
        'source': 'daily_session',
      });
    });

    test('daily session completion analytics keeps safe source metadata', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.dailySessionCompleted,
        const {
          'session_id': 'session_morning_ease',
          'source': 'prayer_completion',
          'content_id': '94:5',
          'content_type': 'quran',
          'quran_arabic_text': 'sensitive text should never be sent',
          'reflection_text': 'private note',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'session_id': 'session_morning_ease',
        'source': 'prayer_completion',
      });
    });

    test('home analytics only keeps aggregate prayer retention fields', () {
      final analytics = StubAnalyticsService(enabled: true);

      analytics.track(
        AnalyticsEventCatalog.homeViewed,
        const {
          'screen': 'home',
          'route': '/home',
          'prayers_completed_today': 1,
          'prayer_checkins_7d': 4,
          'prayer_checkin_days_7d': 3,
          'prayer_checkin_streak_days': 2,
          'prayer_reminders_enabled': false,
          'prayer_name': 'Fajr',
          'location_label': 'Makkah',
          'last_completed_at': '2026-06-12T05:10:00Z',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(analytics.events.single.properties, {
        'screen': 'home',
        'route': '/home',
        'prayers_completed_today': 1,
        'prayer_checkins_7d': 4,
        'prayer_checkin_days_7d': 3,
        'prayer_checkin_streak_days': 2,
        'prayer_reminders_enabled': false,
      });
    });

    test('disabled stub is a no-op for release builds before consent', () {
      final analytics = StubAnalyticsService(enabled: false);

      analytics.track(AnalyticsEventCatalog.homeViewed, const {
        'route': '/home',
      });

      expect(analytics.events, isEmpty);
    });

    test('firebase adapter sends only sanitized GA4 parameters', () {
      final sink = _FakeAnalyticsEventSink();
      final analytics = FirebaseAnalyticsService(
        enabled: true,
        sinkFactory: () => sink,
      );

      analytics.track(
        AnalyticsEventCatalog.prayerReminderChanged,
        const {
          'prayer_name': 'Fajr',
          'enabled': true,
          'reminder_offset_minutes': 10,
          'latitude': 21.4225,
          'women_status': 'menstruating',
          'reflection_text': 'private note',
        },
      );

      expect(analytics.events, hasLength(1));
      expect(sink.events, hasLength(1));
      expect(
        sink.events.single.name,
        AnalyticsEventCatalog.prayerReminderChanged,
      );
      expect(sink.events.single.parameters, {
        'prayer_name': 'Fajr',
        'enabled': 1,
        'reminder_offset_minutes': 10,
      });
    });

    test('firebase adapter is disabled unless analytics is explicitly enabled',
        () {
      final sink = _FakeAnalyticsEventSink();
      final analytics = FirebaseAnalyticsService(
        enabled: false,
        sinkFactory: () => sink,
      );

      analytics.track(AnalyticsEventCatalog.prayerViewed, const {
        'screen': 'prayer',
      });

      expect(analytics.events, isEmpty);
      expect(sink.events, isEmpty);
    });

    test('firebase bootstrap skips initialization until explicitly enabled',
        () async {
      var initialized = false;
      final collectionController = _FakeAnalyticsCollectionController();
      final bootstrap = FirebaseAnalyticsBootstrap(
        analyticsEnabled: false,
        initializeFirebase: () async {
          initialized = true;
        },
        collectionControllerFactory: () => collectionController,
      );

      final initializedBackend = await bootstrap.initialize();

      expect(initializedBackend, isFalse);
      expect(initialized, isFalse);
      expect(collectionController.values, isEmpty);
    });

    test('firebase bootstrap initializes Firebase with collection disabled',
        () async {
      var initialized = false;
      final collectionController = _FakeAnalyticsCollectionController();
      final bootstrap = FirebaseAnalyticsBootstrap(
        analyticsEnabled: true,
        initializeFirebase: () async {
          initialized = true;
        },
        collectionControllerFactory: () => collectionController,
      );

      final initializedBackend = await bootstrap.initialize();

      expect(initializedBackend, isTrue);
      expect(initialized, isTrue);
      expect(collectionController.values, [false]);
    });

    test('firebase bootstrap fails closed when Firebase is not configured',
        () async {
      final bootstrap = FirebaseAnalyticsBootstrap(
        analyticsEnabled: true,
        initializeFirebase: () async => throw StateError('missing config'),
      );

      final initializedBackend = await bootstrap.initialize();

      expect(initializedBackend, isFalse);
    });

    test('provider requires user opt-in and syncs collection consent',
        () async {
      final preferencesStore = InMemoryUserPreferencesStore();
      final collectionController = _FakeAnalyticsCollectionController();
      final container = ProviderContainer(
        overrides: [
          appEnvironmentConfigProvider.overrideWithValue(
            AppEnvironmentConfig.fromMap(
              const {
                'SAKINAH_APP_ENV': 'prod',
                'SAKINAH_ANALYTICS_ENABLED': 'true',
              },
            ),
          ),
          userPreferencesStoreProvider.overrideWithValue(preferencesStore),
          analyticsCollectionControllerProvider.overrideWithValue(
            collectionController,
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(userPreferencesProvider.notifier).load();

      expect(container.read(analyticsServiceProvider),
          isA<StubAnalyticsService>());
      container.read(analyticsCollectionConsentSyncProvider);
      expect(collectionController.values.last, isFalse);

      await container
          .read(userPreferencesProvider.notifier)
          .setAnalyticsOptIn(true);

      expect(
        container.read(analyticsServiceProvider),
        isA<FirebaseAnalyticsService>(),
      );
      container.read(analyticsCollectionConsentSyncProvider);
      expect(collectionController.values.last, isTrue);

      await container
          .read(userPreferencesProvider.notifier)
          .setAnalyticsOptIn(false);

      expect(container.read(analyticsServiceProvider),
          isA<StubAnalyticsService>());
      container.read(analyticsCollectionConsentSyncProvider);
      expect(collectionController.values.last, isFalse);
    });
  });
}

class _FakeAnalyticsEventSink implements AnalyticsEventSink {
  final events = <_FakeAnalyticsPayload>[];

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) async {
    events.add(_FakeAnalyticsPayload(name, Map.unmodifiable(parameters)));
  }
}

class _FakeAnalyticsPayload {
  const _FakeAnalyticsPayload(this.name, this.parameters);

  final String name;
  final Map<String, Object> parameters;
}

class _FakeAnalyticsCollectionController
    implements AnalyticsCollectionController {
  final values = <bool>[];

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    values.add(enabled);
  }
}
