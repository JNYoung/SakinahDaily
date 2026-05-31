import 'dart:convert';

enum ContentStatus {
  draft,
  published,
  archived;

  static ContentStatus parse(String value) {
    return ContentStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ContentStatus.draft,
    );
  }
}

enum ReviewStatus {
  draft,
  inReview,
  approved,
  rejected;

  static ReviewStatus parse(String value) {
    return ReviewStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ReviewStatus.draft,
    );
  }
}

enum GenderMode {
  male,
  female,
  preferNotToSay;

  static GenderMode parse(String value) {
    return GenderMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => GenderMode.preferNotToSay,
    );
  }
}

enum AudioPreference {
  recitationOnly,
  quietGuidance,
  textFirst;

  static AudioPreference parse(String value) {
    return AudioPreference.values.firstWhere(
      (preference) => preference.name == value,
      orElse: () => AudioPreference.recitationOnly,
    );
  }
}

enum WomenIbadahStatus {
  normal,
  menstruating,
  postpartum,
  pregnancy,
  preferNotToTrack;

  static WomenIbadahStatus parse(String value) {
    return WomenIbadahStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => WomenIbadahStatus.normal,
    );
  }
}

enum AudioType {
  quranRecitation,
  duaGuidance,
  reflectionGuidance,
  dhikrGuidance,
  ambientNonQuran;

  static AudioType parse(String? value) {
    return switch (value) {
      'dua_guidance' || 'duaGuidance' => AudioType.duaGuidance,
      'reflection_guidance' ||
      'reflectionGuidance' =>
        AudioType.reflectionGuidance,
      'dhikr_guidance' || 'dhikrGuidance' => AudioType.dhikrGuidance,
      'ambient_non_quran' || 'ambientNonQuran' => AudioType.ambientNonQuran,
      _ => AudioType.quranRecitation,
    };
  }

  String get wireValue {
    return switch (this) {
      AudioType.quranRecitation => 'quran_recitation',
      AudioType.duaGuidance => 'dua_guidance',
      AudioType.reflectionGuidance => 'reflection_guidance',
      AudioType.dhikrGuidance => 'dhikr_guidance',
      AudioType.ambientNonQuran => 'ambient_non_quran',
    };
  }
}

class LocalizedText {
  const LocalizedText(this.values);

  final Map<String, String> values;

  String resolve(String languageCode) {
    return values[languageCode] ?? values['en'] ?? values.values.first;
  }

  Map<String, dynamic> toJson() => values;

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(json.map((key, value) => MapEntry(key, '$value')));
  }
}

class AudioAsset {
  const AudioAsset({
    required this.id,
    required this.bgmAllowed,
    required this.approved,
    this.audioType = AudioType.quranRecitation,
    this.reciterName = '',
    this.voiceName,
    this.url,
    this.assetPath,
    this.sha256,
    this.durationSeconds,
  });

  final String id;
  final AudioType audioType;
  final String reciterName;
  final String? voiceName;
  final bool bgmAllowed;
  final bool approved;
  final String? url;
  final String? assetPath;
  final String? sha256;
  final int? durationSeconds;

  bool get isQuranRecitation => audioType == AudioType.quranRecitation;

  bool get textOnlyFallbackRequired =>
      (url == null || url!.isEmpty) &&
      (assetPath == null || assetPath!.isEmpty);

  String get displayVoiceName {
    if (reciterName.isNotEmpty) {
      return reciterName;
    }
    return voiceName ?? '';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'audioType': audioType.wireValue,
        'reciterName': reciterName,
        'voiceName': voiceName,
        'bgmAllowed': bgmAllowed,
        'approved': approved,
        'url': url,
        'assetPath': assetPath,
        'sha256': sha256,
        'durationSeconds': durationSeconds,
      };

  factory AudioAsset.fromJson(Map<String, dynamic> json) {
    return AudioAsset(
      id: json['id'] as String,
      audioType: AudioType.parse(json['audioType'] as String?),
      reciterName: json['reciterName'] as String? ?? '',
      voiceName: json['voiceName'] as String?,
      bgmAllowed: json['bgmAllowed'] as bool? ?? false,
      approved: json['approved'] as bool? ?? false,
      url: json['url'] as String?,
      assetPath: json['assetPath'] as String?,
      sha256: json['sha256'] as String?,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }
}

class QuranAyah {
  const QuranAyah({
    required this.verseKey,
    required this.surah,
    required this.ayah,
    required this.arabicText,
    required this.translations,
    required this.source,
    required this.status,
    required this.reviewStatus,
    this.audioAssetId,
  });

  final String verseKey;
  final int surah;
  final int ayah;
  final String arabicText;
  final LocalizedText translations;
  final String source;
  final ContentStatus status;
  final ReviewStatus reviewStatus;
  final String? audioAssetId;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'verseKey': verseKey,
        'surah': surah,
        'ayah': ayah,
        'arabicText': arabicText,
        'translations': translations.toJson(),
        'source': source,
        'status': status.name,
        'reviewStatus': reviewStatus.name,
        'audioAssetId': audioAssetId,
      };

  factory QuranAyah.fromJson(Map<String, dynamic> json) {
    return QuranAyah(
      verseKey: json['verseKey'] as String,
      surah: json['surah'] as int,
      ayah: json['ayah'] as int,
      arabicText: json['arabicText'] as String,
      translations: LocalizedText.fromJson(
        json['translations'] as Map<String, dynamic>,
      ),
      source: json['source'] as String,
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
      audioAssetId: json['audioAssetId'] as String?,
    );
  }
}

class DuaItem {
  const DuaItem({
    required this.id,
    required this.category,
    required this.arabicText,
    required this.transliteration,
    required this.translations,
    required this.source,
    required this.status,
    required this.reviewStatus,
    this.isCycleSensitive = false,
  });

  final String id;
  final String category;
  final String arabicText;
  final String transliteration;
  final LocalizedText translations;
  final String source;
  final ContentStatus status;
  final ReviewStatus reviewStatus;
  final bool isCycleSensitive;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'arabicText': arabicText,
        'transliteration': transliteration,
        'translations': translations.toJson(),
        'source': source,
        'status': status.name,
        'reviewStatus': reviewStatus.name,
        'isCycleSensitive': isCycleSensitive,
      };

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] as String,
      category: json['category'] as String,
      arabicText: json['arabicText'] as String,
      transliteration: json['transliteration'] as String,
      translations: LocalizedText.fromJson(
        json['translations'] as Map<String, dynamic>,
      ),
      source: json['source'] as String,
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
      isCycleSensitive: json['isCycleSensitive'] as bool? ?? false,
    );
  }
}

class DhikrItem {
  const DhikrItem({
    required this.id,
    required this.category,
    required this.title,
    required this.arabicText,
    required this.transliteration,
    required this.translations,
    required this.targetCount,
    required this.source,
    required this.status,
    required this.reviewStatus,
  });

  final String id;
  final String category;
  final LocalizedText title;
  final String arabicText;
  final String transliteration;
  final LocalizedText translations;
  final int targetCount;
  final String source;
  final ContentStatus status;
  final ReviewStatus reviewStatus;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title.toJson(),
        'arabicText': arabicText,
        'transliteration': transliteration,
        'translations': translations.toJson(),
        'targetCount': targetCount,
        'source': source,
        'status': status.name,
        'reviewStatus': reviewStatus.name,
      };

  factory DhikrItem.fromJson(Map<String, dynamic> json) {
    return DhikrItem(
      id: json['id'] as String,
      category: json['category'] as String? ?? 'general',
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      arabicText: json['arabicText'] as String,
      transliteration: json['transliteration'] as String,
      translations: LocalizedText.fromJson(
        json['translations'] as Map<String, dynamic>,
      ),
      targetCount: json['targetCount'] as int,
      source: json['source'] as String,
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
    );
  }
}

class ReflectionItem {
  const ReflectionItem({
    required this.id,
    required this.prompt,
    required this.status,
    required this.reviewStatus,
  });

  final String id;
  final LocalizedText prompt;
  final ContentStatus status;
  final ReviewStatus reviewStatus;

  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt.toJson(),
        'status': status.name,
        'reviewStatus': reviewStatus.name,
      };

  factory ReflectionItem.fromJson(Map<String, dynamic> json) {
    return ReflectionItem(
      id: json['id'] as String,
      prompt: LocalizedText.fromJson(json['prompt'] as Map<String, dynamic>),
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
    );
  }
}

class DailySessionStep {
  const DailySessionStep({
    required this.id,
    required this.type,
    required this.title,
    this.contentId,
    this.targetCount,
  });

  final String id;
  final String type;
  final LocalizedText title;
  final String? contentId;
  final int? targetCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title.toJson(),
        'contentId': contentId,
        'targetCount': targetCount,
      };

  factory DailySessionStep.fromJson(Map<String, dynamic> json) {
    return DailySessionStep(
      id: json['id'] as String,
      type: json['type'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      contentId: json['contentId'] as String?,
      targetCount: json['targetCount'] as int?,
    );
  }
}

class DailySession {
  const DailySession({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.steps,
    required this.status,
    required this.reviewStatus,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText subtitle;
  final List<DailySessionStep> steps;
  final ContentStatus status;
  final ReviewStatus reviewStatus;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title.toJson(),
        'subtitle': subtitle.toJson(),
        'steps': steps.map((step) => step.toJson()).toList(),
        'status': status.name,
        'reviewStatus': reviewStatus.name,
      };

  factory DailySession.fromJson(Map<String, dynamic> json) {
    return DailySession(
      id: json['id'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      subtitle: LocalizedText.fromJson(
        json['subtitle'] as Map<String, dynamic>,
      ),
      steps: (json['steps'] as List<dynamic>)
          .map((step) => DailySessionStep.fromJson(step))
          .toList(),
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
    );
  }
}

const _unsetPrayerSetting = Object();

class PrayerSettings {
  const PrayerSettings({
    required this.latitude,
    required this.longitude,
    required this.method,
    this.locationLabel = 'Manual location',
    this.timezoneId,
  });

  final double latitude;
  final double longitude;
  final String method;
  final String locationLabel;
  final String? timezoneId;

  PrayerSettings copyWith({
    double? latitude,
    double? longitude,
    String? method,
    String? locationLabel,
    Object? timezoneId = _unsetPrayerSetting,
  }) {
    return PrayerSettings(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      method: method ?? this.method,
      locationLabel: locationLabel ?? this.locationLabel,
      timezoneId: identical(timezoneId, _unsetPrayerSetting)
          ? this.timezoneId
          : timezoneId as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'method': method,
        'locationLabel': locationLabel,
        'timezoneId': timezoneId,
      };

  factory PrayerSettings.fromJson(Map<String, dynamic> json) {
    final defaults = UserPreferences.defaults().prayerSettings;
    return PrayerSettings(
      latitude: (json['latitude'] as num?)?.toDouble() ?? defaults.latitude,
      longitude: (json['longitude'] as num?)?.toDouble() ?? defaults.longitude,
      method: json['method'] as String? ?? defaults.method,
      locationLabel: json['locationLabel'] as String? ?? defaults.locationLabel,
      timezoneId: json['timezoneId'] as String?,
    );
  }
}

class PrayerLocationPreset {
  const PrayerLocationPreset({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.timezoneId,
    required this.method,
  });

  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final String timezoneId;
  final String method;

  PrayerSettings toPrayerSettings() {
    return PrayerSettings(
      latitude: latitude,
      longitude: longitude,
      method: method,
      locationLabel: label,
      timezoneId: timezoneId,
    );
  }
}

class WomenIbadahMode {
  const WomenIbadahMode({
    required this.enabled,
    this.status = WomenIbadahStatus.normal,
    this.localOnly = true,
    this.hideCycleSensitiveLockScreenCopy = true,
  });

  final bool enabled;
  final WomenIbadahStatus status;
  final bool localOnly;
  final bool hideCycleSensitiveLockScreenCopy;

  WomenIbadahMode copyWith({
    bool? enabled,
    WomenIbadahStatus? status,
    bool? localOnly,
    bool? hideCycleSensitiveLockScreenCopy,
  }) {
    return WomenIbadahMode(
      enabled: enabled ?? this.enabled,
      status: status ?? this.status,
      localOnly: localOnly ?? this.localOnly,
      hideCycleSensitiveLockScreenCopy: hideCycleSensitiveLockScreenCopy ??
          this.hideCycleSensitiveLockScreenCopy,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'status': status.name,
        'localOnly': localOnly,
        'hideCycleSensitiveLockScreenCopy': hideCycleSensitiveLockScreenCopy,
      };

  factory WomenIbadahMode.fromJson(Map<String, dynamic> json) {
    final enabled = json['enabled'] as bool? ?? false;
    final parsedStatus =
        WomenIbadahStatus.parse(json['status'] as String? ?? '');
    return WomenIbadahMode(
      enabled: enabled,
      status: json.containsKey('status')
          ? parsedStatus
          : (enabled
              ? WomenIbadahStatus.menstruating
              : WomenIbadahStatus.normal),
      localOnly: json['localOnly'] as bool? ?? true,
      hideCycleSensitiveLockScreenCopy:
          json['hideCycleSensitiveLockScreenCopy'] as bool? ?? true,
    );
  }
}

const defaultDailySessionReminderMinutesAfterMidnight = 20 * 60;
const _minutesPerDay = 24 * 60;

int sanitizeDailySessionReminderMinutes(int minutesAfterMidnight) {
  if (minutesAfterMidnight < 0) {
    return 0;
  }
  if (minutesAfterMidnight >= _minutesPerDay) {
    return _minutesPerDay - 1;
  }
  return minutesAfterMidnight;
}

String formatDailySessionReminderTime(int minutesAfterMidnight) {
  final minutes = sanitizeDailySessionReminderMinutes(minutesAfterMidnight);
  final hour = minutes ~/ 60;
  final minute = minutes % 60;
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

class UserPreferences {
  const UserPreferences({
    required this.languageCode,
    required this.genderMode,
    required this.audioPreference,
    required this.prayerSettings,
    required this.womenIbadahMode,
    this.notificationsEnabled = false,
    this.dailySessionReminderEnabled = false,
    this.dailySessionReminderMinutesAfterMidnight =
        defaultDailySessionReminderMinutesAfterMidnight,
  }) : assert(
          dailySessionReminderMinutesAfterMidnight >= 0 &&
              dailySessionReminderMinutesAfterMidnight < _minutesPerDay,
        );

  final String languageCode;
  final GenderMode genderMode;
  final AudioPreference audioPreference;
  final PrayerSettings prayerSettings;
  final WomenIbadahMode womenIbadahMode;
  final bool notificationsEnabled;
  final bool dailySessionReminderEnabled;
  final int dailySessionReminderMinutesAfterMidnight;

  factory UserPreferences.defaults() {
    return const UserPreferences(
      languageCode: 'en',
      genderMode: GenderMode.preferNotToSay,
      audioPreference: AudioPreference.recitationOnly,
      prayerSettings: PrayerSettings(
        latitude: 21.3891,
        longitude: 39.8579,
        method: 'umm_al_qura',
        locationLabel: 'Makkah',
      ),
      womenIbadahMode: WomenIbadahMode(enabled: false),
    );
  }

  UserPreferences copyWith({
    String? languageCode,
    GenderMode? genderMode,
    AudioPreference? audioPreference,
    PrayerSettings? prayerSettings,
    WomenIbadahMode? womenIbadahMode,
    bool? notificationsEnabled,
    bool? dailySessionReminderEnabled,
    int? dailySessionReminderMinutesAfterMidnight,
  }) {
    return UserPreferences(
      languageCode: languageCode ?? this.languageCode,
      genderMode: genderMode ?? this.genderMode,
      audioPreference: audioPreference ?? this.audioPreference,
      prayerSettings: prayerSettings ?? this.prayerSettings,
      womenIbadahMode: womenIbadahMode ?? this.womenIbadahMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailySessionReminderEnabled:
          dailySessionReminderEnabled ?? this.dailySessionReminderEnabled,
      dailySessionReminderMinutesAfterMidnight:
          dailySessionReminderMinutesAfterMidnight == null
              ? this.dailySessionReminderMinutesAfterMidnight
              : sanitizeDailySessionReminderMinutes(
                  dailySessionReminderMinutesAfterMidnight,
                ),
    );
  }

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'genderMode': genderMode.name,
        'audioPreference': audioPreference.name,
        'prayerSettings': prayerSettings.toJson(),
        'womenIbadahMode': womenIbadahMode.toJson(),
        'notificationsEnabled': notificationsEnabled,
        'dailySessionReminderEnabled': dailySessionReminderEnabled,
        'dailySessionReminderMinutesAfterMidnight':
            dailySessionReminderMinutesAfterMidnight,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    final defaults = UserPreferences.defaults();
    final prayerSettingsJson = json['prayerSettings'];
    final womenIbadahModeJson = json['womenIbadahMode'];
    return UserPreferences(
      languageCode: json['languageCode'] as String? ?? defaults.languageCode,
      genderMode: GenderMode.parse(json['genderMode'] as String? ?? ''),
      audioPreference:
          AudioPreference.parse(json['audioPreference'] as String? ?? ''),
      prayerSettings: prayerSettingsJson is Map<String, dynamic>
          ? PrayerSettings.fromJson(prayerSettingsJson)
          : defaults.prayerSettings,
      womenIbadahMode: womenIbadahModeJson is Map<String, dynamic>
          ? WomenIbadahMode.fromJson(womenIbadahModeJson)
          : defaults.womenIbadahMode,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? false,
      dailySessionReminderEnabled:
          json['dailySessionReminderEnabled'] as bool? ?? false,
      dailySessionReminderMinutesAfterMidnight:
          sanitizeDailySessionReminderMinutes(
        json['dailySessionReminderMinutesAfterMidnight'] as int? ??
            defaultDailySessionReminderMinutesAfterMidnight,
      ),
    );
  }
}

class SourceItem {
  const SourceItem({
    required this.id,
    required this.clusterId,
    required this.ritualMoment,
    required this.status,
    required this.reviewStatus,
    required this.translations,
    this.cycleSensitiveHidden = false,
  });

  final String id;
  final String clusterId;
  final String ritualMoment;
  final ContentStatus status;
  final ReviewStatus reviewStatus;
  final LocalizedText translations;
  final bool cycleSensitiveHidden;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'clusterId': clusterId,
        'ritualMoment': ritualMoment,
        'status': status.name,
        'reviewStatus': reviewStatus.name,
        'translations': translations.toJson(),
        'cycleSensitiveHidden': cycleSensitiveHidden,
      };

  factory SourceItem.fromJson(Map<String, dynamic> json) {
    return SourceItem(
      id: json['id'] as String,
      clusterId: json['clusterId'] as String,
      ritualMoment: json['ritualMoment'] as String,
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
      translations: LocalizedText.fromJson(
        json['translations'] as Map<String, dynamic>,
      ),
      cycleSensitiveHidden: json['cycleSensitiveHidden'] as bool? ?? false,
    );
  }
}

class PushTemplate {
  const PushTemplate({
    required this.id,
    required this.ritualMoment,
    required this.title,
    required this.body,
    required this.status,
    required this.reviewStatus,
    this.cycleSensitiveHidden = false,
  });

  final String id;
  final String ritualMoment;
  final LocalizedText title;
  final LocalizedText body;
  final ContentStatus status;
  final ReviewStatus reviewStatus;
  final bool cycleSensitiveHidden;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'ritualMoment': ritualMoment,
        'title': title.toJson(),
        'body': body.toJson(),
        'status': status.name,
        'reviewStatus': reviewStatus.name,
        'cycleSensitiveHidden': cycleSensitiveHidden,
      };

  factory PushTemplate.fromJson(Map<String, dynamic> json) {
    return PushTemplate(
      id: json['id'] as String,
      ritualMoment: json['ritualMoment'] as String,
      title: LocalizedText.fromJson(json['title'] as Map<String, dynamic>),
      body: LocalizedText.fromJson(json['body'] as Map<String, dynamic>),
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
      cycleSensitiveHidden: json['cycleSensitiveHidden'] as bool? ?? false,
    );
  }
}

class PushCandidate {
  const PushCandidate({
    required this.sourceItemId,
    required this.templateId,
    required this.clusterId,
    required this.languageCode,
    required this.title,
    required this.body,
  });

  final String sourceItemId;
  final String templateId;
  final String clusterId;
  final String languageCode;
  final String title;
  final String body;
}

class ContentManifest {
  const ContentManifest({
    required this.id,
    required this.schemaVersion,
    required this.bundles,
    this.appMinVersion,
    this.appMaxVersion,
    this.language = 'en',
    this.market = 'global',
    this.generatedAt,
    this.expiresAt,
    this.sourceCorpusVersions = const {},
    this.revokedContentIds = const [],
    this.fallback = const {},
  });

  final String id;
  final int schemaVersion;
  final String? appMinVersion;
  final String? appMaxVersion;
  final String language;
  final String market;
  final DateTime? generatedAt;
  final DateTime? expiresAt;
  final Map<String, String> sourceCorpusVersions;
  final List<String> revokedContentIds;
  final Map<String, dynamic> fallback;
  final List<BundleRef> bundles;

  Map<String, dynamic> toJson() => {
        'id': id,
        'manifestId': id,
        'schemaVersion': schemaVersion,
        'appMinVersion': appMinVersion,
        'appMaxVersion': appMaxVersion,
        'language': language,
        'market': market,
        'generatedAt': generatedAt?.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'sourceCorpusVersions': sourceCorpusVersions,
        'revokedContentIds': revokedContentIds,
        'fallback': fallback,
        'bundles': bundles.map((bundle) => bundle.toJson()).toList(),
      };

  factory ContentManifest.fromJson(Map<String, dynamic> json) {
    return ContentManifest(
      id: _stringFromKeys(json, const ['manifestId', 'id']),
      schemaVersion: _intFromJson(json['schemaVersion'], fallback: 1),
      appMinVersion: json['appMinVersion'] as String?,
      appMaxVersion: json['appMaxVersion'] as String?,
      language: _stringFromKeys(
        json,
        const ['language', 'languageCode'],
        fallback: 'en',
      ),
      market: _stringFromKeys(json, const ['market'], fallback: 'global'),
      generatedAt: _dateTimeFromJson(json['generatedAt']),
      expiresAt: _dateTimeFromJson(json['expiresAt']),
      sourceCorpusVersions: _stringMapFromJson(json['sourceCorpusVersions']),
      revokedContentIds: _stringListFromJson(json['revokedContentIds']),
      fallback: _dynamicMapFromJson(json['fallback']),
      bundles: (json['bundles'] as List<dynamic>? ?? const [])
          .map((bundle) => BundleRef.fromJson(bundle))
          .toList(),
    );
  }

  bool get allowsStaleFallback => fallback['allowStale'] as bool? ?? false;

  int get maxStaleSeconds =>
      _intFromJson(fallback['maxStaleSeconds'], fallback: 0);

  bool isExpired(DateTime now) => expiresAt != null && now.isAfter(expiresAt!);

  bool staleAllowed(DateTime now) {
    if (!isExpired(now)) {
      return true;
    }
    if (!allowsStaleFallback || maxStaleSeconds <= 0 || expiresAt == null) {
      return false;
    }
    return now.difference(expiresAt!).inSeconds <= maxStaleSeconds;
  }
}

class BundleRef {
  const BundleRef({
    required this.id,
    required this.url,
    required this.sha256,
    required this.schemaVersion,
    this.bundleType = 'home_bundle',
    this.sizeBytes,
    this.required = true,
    this.ttlSeconds,
    this.priority = 0,
    this.language = 'en',
    this.market = 'global',
  });

  final String id;
  final String bundleType;
  final String url;
  final String sha256;
  final int? sizeBytes;
  final bool required;
  final int? ttlSeconds;
  final int priority;
  final int schemaVersion;
  final String language;
  final String market;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bundleId': id,
        'bundleType': bundleType,
        'url': url,
        'sha256': sha256,
        'sizeBytes': sizeBytes,
        'required': required,
        'ttlSeconds': ttlSeconds,
        'priority': priority,
        'schemaVersion': schemaVersion,
        'language': language,
        'market': market,
      };

  factory BundleRef.fromJson(Map<String, dynamic> json) {
    return BundleRef(
      id: _stringFromKeys(json, const ['bundleId', 'id']),
      bundleType: _stringFromKeys(
        json,
        const ['bundleType'],
        fallback: 'home_bundle',
      ),
      url: _stringFromKeys(json, const ['url']),
      sha256: _stringFromKeys(json, const ['sha256']),
      sizeBytes: _nullableIntFromJson(json['sizeBytes']),
      required: json['required'] as bool? ?? true,
      ttlSeconds: _nullableIntFromJson(json['ttlSeconds']),
      priority: _intFromJson(json['priority'], fallback: 0),
      schemaVersion: _intFromJson(json['schemaVersion'], fallback: 1),
      language: _stringFromKeys(
        json,
        const ['language', 'languageCode'],
        fallback: 'en',
      ),
      market: _stringFromKeys(json, const ['market'], fallback: 'global'),
    );
  }
}

class ContentBundle {
  const ContentBundle({
    required this.id,
    required this.schemaVersion,
    required this.status,
    required this.reviewStatus,
    required this.payload,
    this.bundleType = 'home_bundle',
    this.language = 'en',
    this.market = 'global',
    this.sourceCorpusVersions = const {},
  });

  final String id;
  final String bundleType;
  final int schemaVersion;
  final String language;
  final String market;
  final ContentStatus status;
  final ReviewStatus reviewStatus;
  final Map<String, String> sourceCorpusVersions;
  final Map<String, dynamic> payload;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'bundleId': id,
        'bundleType': bundleType,
        'schemaVersion': schemaVersion,
        'language': language,
        'market': market,
        'status': status.name,
        'reviewStatus': reviewStatus.name,
        'sourceCorpusVersions': sourceCorpusVersions,
        'payload': payload,
      };

  String toCanonicalJson() => jsonEncode(toJson());

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    return ContentBundle(
      id: _stringFromKeys(json, const ['bundleId', 'id']),
      bundleType: _stringFromKeys(
        json,
        const ['bundleType'],
        fallback: 'home_bundle',
      ),
      schemaVersion: _intFromJson(json['schemaVersion'], fallback: 1),
      language: _stringFromKeys(
        json,
        const ['language', 'languageCode'],
        fallback: 'en',
      ),
      market: _stringFromKeys(json, const ['market'], fallback: 'global'),
      status: ContentStatus.parse(json['status'] as String? ?? ''),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String? ?? ''),
      sourceCorpusVersions: _stringMapFromJson(json['sourceCorpusVersions']),
      payload: _dynamicMapFromJson(json['payload']),
    );
  }
}

class CacheEntry {
  CacheEntry({
    required this.bundleId,
    required this.sha256,
    required this.cachedAt,
    required this.bundle,
    String? cacheKey,
    this.contentType = 'bundle',
    String? contentId,
    this.language = 'en',
    this.market = 'global',
    this.sourceCorpusVersionId,
    this.localPath,
    this.sizeBytes,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
    this.expiresAt,
    this.pinned = false,
  })  : cacheKey = cacheKey ?? bundleId,
        contentId = contentId ?? bundleId,
        createdAt = createdAt ?? cachedAt,
        lastAccessedAt = lastAccessedAt ?? cachedAt;

  final String cacheKey;
  final String contentType;
  final String contentId;
  final String bundleId;
  final String language;
  final String market;
  final String? sourceCorpusVersionId;
  final String? localPath;
  final String sha256;
  final int? sizeBytes;
  final DateTime createdAt;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  final DateTime? expiresAt;
  final bool pinned;
  final ContentBundle bundle;

  factory CacheEntry.fromBundle(
    ContentBundle bundle, {
    required String sha256,
    DateTime? cachedAt,
    int? sizeBytes,
  }) {
    final now = cachedAt ?? DateTime.now();
    return CacheEntry(
      bundleId: bundle.id,
      sha256: sha256,
      cachedAt: now,
      bundle: bundle,
      contentType: bundle.bundleType,
      language: bundle.language,
      market: bundle.market,
      sourceCorpusVersionId: bundle.sourceCorpusVersions.values.firstOrNull,
      sizeBytes: sizeBytes,
      createdAt: now,
      lastAccessedAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
        'cacheKey': cacheKey,
        'contentType': contentType,
        'contentId': contentId,
        'bundleId': bundleId,
        'language': language,
        'market': market,
        'sourceCorpusVersionId': sourceCorpusVersionId,
        'localPath': localPath,
        'sha256': sha256,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
        'cachedAt': cachedAt.toIso8601String(),
        'lastAccessedAt': lastAccessedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'pinned': pinned,
        'bundle': bundle.toJson(),
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    final cachedAt = _dateTimeFromJson(json['cachedAt']) ?? DateTime.now();
    return CacheEntry(
      cacheKey: json['cacheKey'] as String?,
      contentType: json['contentType'] as String? ?? 'bundle',
      contentId: json['contentId'] as String?,
      bundleId: _stringFromKeys(json, const ['bundleId', 'id']),
      language: json['language'] as String? ?? 'en',
      market: json['market'] as String? ?? 'global',
      sourceCorpusVersionId: json['sourceCorpusVersionId'] as String?,
      localPath: json['localPath'] as String?,
      sha256: json['sha256'] as String? ?? '',
      sizeBytes: _nullableIntFromJson(json['sizeBytes']),
      createdAt: _dateTimeFromJson(json['createdAt']) ?? cachedAt,
      cachedAt: cachedAt,
      lastAccessedAt: _dateTimeFromJson(json['lastAccessedAt']) ?? cachedAt,
      expiresAt: _dateTimeFromJson(json['expiresAt']),
      pinned: json['pinned'] as bool? ?? false,
      bundle: ContentBundle.fromJson(json['bundle'] as Map<String, dynamic>),
    );
  }
}

class ContentRequestContext {
  ContentRequestContext({
    required this.languageCode,
    this.market = 'global',
    this.appVersion,
    this.lockScreenSafe = false,
    WomenIbadahMode womenIbadahMode = const WomenIbadahMode(enabled: false),
    bool? womenModeEnabled,
    bool? hideCycleSensitiveLockScreenCopy,
  })  : womenModeEnabled = womenModeEnabled ?? womenIbadahMode.enabled,
        hideCycleSensitiveLockScreenCopy = hideCycleSensitiveLockScreenCopy ??
            womenIbadahMode.hideCycleSensitiveLockScreenCopy;

  final String languageCode;
  final String market;
  final String? appVersion;
  final bool lockScreenSafe;
  final bool womenModeEnabled;
  final bool hideCycleSensitiveLockScreenCopy;

  WomenIbadahMode get womenIbadahMode {
    return WomenIbadahMode(
      enabled: womenModeEnabled,
      status: WomenIbadahStatus.normal,
      hideCycleSensitiveLockScreenCopy: hideCycleSensitiveLockScreenCopy,
    );
  }
}

String _stringFromKeys(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) {
      return value;
    }
  }
  return fallback;
}

int _intFromJson(Object? value, {required int fallback}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

int? _nullableIntFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  return _intFromJson(value, fallback: 0);
}

DateTime? _dateTimeFromJson(Object? value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

Map<String, String> _stringMapFromJson(Object? value) {
  if (value is Map<String, dynamic>) {
    return value.map((key, entry) => MapEntry(key, '$entry'));
  }
  return const {};
}

Map<String, dynamic> _dynamicMapFromJson(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  return const {};
}

List<String> _stringListFromJson(Object? value) {
  if (value is List<dynamic>) {
    return value.map((entry) => '$entry').toList();
  }
  return const [];
}

extension _IterableFirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
