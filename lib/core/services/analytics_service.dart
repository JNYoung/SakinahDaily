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
    'calculation_method',
    'content_id',
    'content_type',
    'enabled',
    'environment',
    'language_code',
    'location_method',
    'prompt_day',
    'prayer_name',
    'reminder_offset_minutes',
    'route',
    'screen',
    'session_id',
    'source',
    'step_id',
    'step_index',
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

  static Map<String, Object> sanitize(Map<String, Object?> properties) {
    final sanitized = <String, Object>{};
    for (final entry in properties.entries) {
      final key = entry.key.trim();
      final lowerKey = key.toLowerCase();
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
}

abstract class AnalyticsService {
  void track(String name, [Map<String, Object?> properties = const {}]);
  List<AnalyticsEvent> get events;
}

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
      AnalyticsEvent(name, AnalyticsParameterPolicy.sanitize(properties)),
    );
  }
}
