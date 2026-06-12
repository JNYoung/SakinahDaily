import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

class AnalyticsEvent {
  const AnalyticsEvent(this.name, this.properties);

  final String name;
  final Map<String, Object?> properties;
}

class AnalyticsEventCatalog {
  const AnalyticsEventCatalog._();

  static const onboardingStarted = 'onboarding_started';
  static const onboardingCompleted = 'onboarding_completed';
  static const languageSelected = 'language_selected';
  static const locationMethodSelected = 'location_method_selected';
  static const genderModeSelected = 'gender_mode_selected';
  static const audioPreferenceSelected = 'audio_preference_selected';
  static const homeViewed = 'home_viewed';
  static const prayerViewed = 'prayer_viewed';
  static const prayerReminderChanged = 'prayer_reminder_changed';
  static const notificationTapOpened = 'notification_tap_opened';
  static const analyticsConsentChanged = 'analytics_consent_changed';
  static const dailySessionReminderChanged = 'daily_session_reminder_changed';
  static const prayerChecklistUpdated = 'prayer_checklist_updated';
  static const dailySessionStarted = 'daily_session_started';
  static const dailySessionStepViewed = 'daily_session_step_viewed';
  static const dailySessionCompleted = 'daily_session_completed';
  static const duaViewed = 'dua_viewed';
  static const duaSaved = 'dua_saved';
  static const dhikrStarted = 'dhikr_started';
  static const dhikrCompleted = 'dhikr_completed';
  static const womenIbadahModeChanged = 'women_ibadah_mode_changed';
  static const closedTestPromptCopied = 'closed_test_prompt_copied';
  static const closedTestPromptMarkedSent = 'closed_test_prompt_marked_sent';

  static const allowedEventNames = {
    onboardingStarted,
    onboardingCompleted,
    languageSelected,
    locationMethodSelected,
    genderModeSelected,
    audioPreferenceSelected,
    homeViewed,
    prayerViewed,
    prayerReminderChanged,
    notificationTapOpened,
    analyticsConsentChanged,
    dailySessionReminderChanged,
    prayerChecklistUpdated,
    dailySessionStarted,
    dailySessionStepViewed,
    dailySessionCompleted,
    duaViewed,
    duaSaved,
    dhikrStarted,
    dhikrCompleted,
    womenIbadahModeChanged,
    closedTestPromptCopied,
    closedTestPromptMarkedSent,
  };

  static bool isAllowed(String name) =>
      allowedEventNames.contains(name) && _googleAnalyticsName.hasMatch(name);

  static final _googleAnalyticsName = RegExp(r'^[a-z][a-z0-9_]{0,39}$');
}

class AnalyticsParameterPolicy {
  const AnalyticsParameterPolicy._();

  static const allowedKeys = {
    'audio_preference',
    'all_prayers_completed',
    'calculation_method',
    'change_type',
    'completed_count',
    'content_id',
    'content_type',
    'enabled',
    'environment',
    'language_code',
    'location_method',
    'prompt_day',
    'prayer_checkin_days_7d',
    'prayer_checkin_streak_days',
    'prayer_checkins_7d',
    'prayer_name',
    'prayer_reminders_enabled',
    'prayers_completed_today',
    'reminder_offset_minutes',
    'route',
    'screen',
    'session_id',
    'source',
    'step_id',
    'step_index',
    'theme_key',
  };

  static const _blockedKeyFragments = [
    'arabic',
    'body',
    'email',
    'feedback',
    'full_name',
    'health',
    'latitude',
    'longitude',
    'menstru',
    'note',
    'postpartum',
    'pregnan',
    'quran',
    'reflection',
    'text',
    'translation',
    'tester_name',
    'user_name',
    'women_ibadah_status',
    'women_status',
  ];

  static const _homeViewedKeys = {
    'screen',
    'route',
    'prayers_completed_today',
    'prayer_checkins_7d',
    'prayer_checkin_days_7d',
    'prayer_checkin_streak_days',
    'prayer_reminders_enabled',
  };

  static const _prayerChecklistUpdatedKeys = {
    'screen',
    'completed_count',
    'all_prayers_completed',
  };

  static const _dailySessionReminderChangedKeys = {
    'session_id',
    'enabled',
    'source',
    'change_type',
  };

  static const _analyticsConsentChangedKeys = {
    'enabled',
    'source',
  };

  static const _notificationTapOpenedKeys = {
    'content_type',
    'source',
  };

  static const _closedTestPromptKeys = {
    'prompt_day',
    'theme_key',
    'source',
  };

  static const _onboardingStartedKeys = {
    'screen',
    'source',
  };

  static const _languageSelectedKeys = {
    'language_code',
    'source',
  };

  static const _locationMethodSelectedKeys = {
    'location_method',
    'source',
  };

  static const _genderModeSelectedKeys = {
    'source',
  };

  static const _audioPreferenceSelectedKeys = {
    'audio_preference',
    'source',
  };

  static const _onboardingCompletedKeys = {
    'language_code',
    'location_method',
    'audio_preference',
    'source',
  };

  static const _dailySessionStartedKeys = {
    'session_id',
    'language_code',
    'source',
  };

  static const _dailySessionStepViewedKeys = {
    'session_id',
    'step_id',
    'step_index',
    'source',
  };

  static const _dailySessionCompletedKeys = {
    'session_id',
    'source',
  };

  static Map<String, Object> sanitize(
    Map<String, Object?> properties, {
    String? eventName,
  }) {
    final sanitized = <String, Object>{};
    for (final entry in properties.entries) {
      final key = entry.key.trim();
      final lowerKey = key.toLowerCase();
      if (!_isAllowedForEvent(key, eventName)) {
        continue;
      }
      if (!allowedKeys.contains(key) ||
          _blockedKeyFragments.any(lowerKey.contains)) {
        continue;
      }
      final value = entry.value;
      if (value is String && value.trim().isNotEmpty) {
        sanitized[key] = value.trim();
      } else if (value is num) {
        sanitized[key] = value;
      } else if (value is bool) {
        sanitized[key] = value;
      }
    }
    return Map.unmodifiable(sanitized);
  }

  static bool _isAllowedForEvent(String key, String? eventName) {
    return switch (eventName) {
      AnalyticsEventCatalog.homeViewed => _homeViewedKeys.contains(key),
      AnalyticsEventCatalog.prayerChecklistUpdated =>
        _prayerChecklistUpdatedKeys.contains(key),
      AnalyticsEventCatalog.dailySessionReminderChanged =>
        _dailySessionReminderChangedKeys.contains(key),
      AnalyticsEventCatalog.analyticsConsentChanged =>
        _analyticsConsentChangedKeys.contains(key),
      AnalyticsEventCatalog.notificationTapOpened =>
        _notificationTapOpenedKeys.contains(key),
      AnalyticsEventCatalog.closedTestPromptCopied ||
      AnalyticsEventCatalog.closedTestPromptMarkedSent =>
        _closedTestPromptKeys.contains(key),
      AnalyticsEventCatalog.onboardingStarted =>
        _onboardingStartedKeys.contains(key),
      AnalyticsEventCatalog.languageSelected =>
        _languageSelectedKeys.contains(key),
      AnalyticsEventCatalog.locationMethodSelected =>
        _locationMethodSelectedKeys.contains(key),
      AnalyticsEventCatalog.genderModeSelected =>
        _genderModeSelectedKeys.contains(key),
      AnalyticsEventCatalog.audioPreferenceSelected =>
        _audioPreferenceSelectedKeys.contains(key),
      AnalyticsEventCatalog.onboardingCompleted =>
        _onboardingCompletedKeys.contains(key),
      AnalyticsEventCatalog.dailySessionStarted =>
        _dailySessionStartedKeys.contains(key),
      AnalyticsEventCatalog.dailySessionStepViewed =>
        _dailySessionStepViewedKeys.contains(key),
      AnalyticsEventCatalog.dailySessionCompleted =>
        _dailySessionCompletedKeys.contains(key),
      _ => true,
    };
  }
}

abstract class AnalyticsService {
  void track(String name, [Map<String, Object?> properties = const {}]);
  List<AnalyticsEvent> get events;
}

abstract class AnalyticsEventSink {
  Future<void> logEvent(String name, Map<String, Object> parameters);
}

typedef AnalyticsEventSinkFactory = AnalyticsEventSink Function();

abstract class AnalyticsCollectionController {
  Future<void> setCollectionEnabled(bool enabled);
}

typedef AnalyticsCollectionControllerFactory = AnalyticsCollectionController
    Function();

typedef FirebaseCoreInitializer = Future<void> Function();

class StubAnalyticsService implements AnalyticsService {
  StubAnalyticsService({this.enabled = true});

  final bool enabled;
  final List<AnalyticsEvent> _events = [];

  @override
  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  @override
  void track(String name, [Map<String, Object?> properties = const {}]) {
    if (!enabled || !AnalyticsEventCatalog.isAllowed(name)) {
      return;
    }
    _events.add(
      AnalyticsEvent(
        name,
        AnalyticsParameterPolicy.sanitize(properties, eventName: name),
      ),
    );
  }
}

class FirebaseAnalyticsEventSink
    implements AnalyticsEventSink, AnalyticsCollectionController {
  FirebaseAnalyticsEventSink({FirebaseAnalytics? analytics})
      : _analytics = analytics;

  FirebaseAnalytics? _analytics;

  FirebaseAnalytics get _instance => _analytics ??= FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, Map<String, Object> parameters) {
    return _instance.logEvent(
      name: name,
      parameters: parameters.isEmpty ? null : parameters,
    );
  }

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _instance.setAnalyticsCollectionEnabled(enabled);
  }
}

class FirebaseAnalyticsBootstrap {
  const FirebaseAnalyticsBootstrap({
    required this.analyticsEnabled,
    FirebaseCoreInitializer? initializeFirebase,
    AnalyticsCollectionControllerFactory? collectionControllerFactory,
  })  : _initializeFirebase = initializeFirebase ?? Firebase.initializeApp,
        _collectionControllerFactory =
            collectionControllerFactory ?? FirebaseAnalyticsEventSink.new;

  final bool analyticsEnabled;
  final FirebaseCoreInitializer _initializeFirebase;
  final AnalyticsCollectionControllerFactory _collectionControllerFactory;

  Future<bool> initialize() async {
    if (!analyticsEnabled) {
      return false;
    }
    try {
      await _initializeFirebase();
      await _collectionControllerFactory().setCollectionEnabled(false);
      return true;
    } catch (_) {
      return false;
    }
  }
}

class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({
    required this.enabled,
    AnalyticsEventSinkFactory? sinkFactory,
  }) : _sinkFactory = sinkFactory ?? (() => FirebaseAnalyticsEventSink());

  final bool enabled;
  final AnalyticsEventSinkFactory _sinkFactory;
  final List<AnalyticsEvent> _events = [];
  AnalyticsEventSink? _sink;
  bool _sinkUnavailable = false;

  @override
  List<AnalyticsEvent> get events => List.unmodifiable(_events);

  @override
  void track(String name, [Map<String, Object?> properties = const {}]) {
    if (!enabled || !AnalyticsEventCatalog.isAllowed(name)) {
      return;
    }
    final sanitized = AnalyticsParameterPolicy.sanitize(
      properties,
      eventName: name,
    );
    _events.add(AnalyticsEvent(name, sanitized));

    final sink = _resolveSink();
    if (sink == null) {
      return;
    }
    try {
      unawaited(
        sink.logEvent(name, _firebaseParameters(sanitized)).catchError((
          Object _,
        ) {
          _sinkUnavailable = true;
        }),
      );
    } catch (_) {
      _sinkUnavailable = true;
    }
  }

  AnalyticsEventSink? _resolveSink() {
    if (_sinkUnavailable) {
      return null;
    }
    try {
      return _sink ??= _sinkFactory();
    } catch (_) {
      _sinkUnavailable = true;
      return null;
    }
  }

  Map<String, Object> _firebaseParameters(Map<String, Object> properties) {
    return Map.unmodifiable(
      properties.map((key, value) {
        final normalized = switch (value) {
          bool() => value ? 1 : 0,
          int() => value,
          double() => value,
          String() => value,
          _ => '$value',
        };
        return MapEntry(key, normalized);
      }),
    );
  }
}
