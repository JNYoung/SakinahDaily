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
    required this.reciterName,
    required this.bgmAllowed,
    required this.approved,
    this.url,
    this.sha256,
  });

  final String id;
  final String reciterName;
  final bool bgmAllowed;
  final bool approved;
  final String? url;
  final String? sha256;

  bool get textOnlyFallbackRequired => url == null || url!.isEmpty;

  Map<String, dynamic> toJson() => {
        'id': id,
        'reciterName': reciterName,
        'bgmAllowed': bgmAllowed,
        'approved': approved,
        'url': url,
        'sha256': sha256,
      };

  factory AudioAsset.fromJson(Map<String, dynamic> json) {
    return AudioAsset(
      id: json['id'] as String,
      reciterName: json['reciterName'] as String,
      bgmAllowed: json['bgmAllowed'] as bool? ?? false,
      approved: json['approved'] as bool? ?? false,
      url: json['url'] as String?,
      sha256: json['sha256'] as String?,
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
    this.localOnly = true,
    this.hideCycleSensitiveLockScreenCopy = true,
  });

  final bool enabled;
  final bool localOnly;
  final bool hideCycleSensitiveLockScreenCopy;

  WomenIbadahMode copyWith({
    bool? enabled,
    bool? localOnly,
    bool? hideCycleSensitiveLockScreenCopy,
  }) {
    return WomenIbadahMode(
      enabled: enabled ?? this.enabled,
      localOnly: localOnly ?? this.localOnly,
      hideCycleSensitiveLockScreenCopy: hideCycleSensitiveLockScreenCopy ??
          this.hideCycleSensitiveLockScreenCopy,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'localOnly': localOnly,
        'hideCycleSensitiveLockScreenCopy': hideCycleSensitiveLockScreenCopy,
      };

  factory WomenIbadahMode.fromJson(Map<String, dynamic> json) {
    return WomenIbadahMode(
      enabled: json['enabled'] as bool? ?? false,
      localOnly: json['localOnly'] as bool? ?? true,
      hideCycleSensitiveLockScreenCopy:
          json['hideCycleSensitiveLockScreenCopy'] as bool? ?? true,
    );
  }
}

class UserPreferences {
  const UserPreferences({
    required this.languageCode,
    required this.genderMode,
    required this.audioPreference,
    required this.prayerSettings,
    required this.womenIbadahMode,
    this.notificationsEnabled = false,
  });

  final String languageCode;
  final GenderMode genderMode;
  final AudioPreference audioPreference;
  final PrayerSettings prayerSettings;
  final WomenIbadahMode womenIbadahMode;
  final bool notificationsEnabled;

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
  }) {
    return UserPreferences(
      languageCode: languageCode ?? this.languageCode,
      genderMode: genderMode ?? this.genderMode,
      audioPreference: audioPreference ?? this.audioPreference,
      prayerSettings: prayerSettings ?? this.prayerSettings,
      womenIbadahMode: womenIbadahMode ?? this.womenIbadahMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'languageCode': languageCode,
        'genderMode': genderMode.name,
        'audioPreference': audioPreference.name,
        'prayerSettings': prayerSettings.toJson(),
        'womenIbadahMode': womenIbadahMode.toJson(),
        'notificationsEnabled': notificationsEnabled,
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
  });

  final String id;
  final int schemaVersion;
  final List<BundleRef> bundles;

  Map<String, dynamic> toJson() => {
        'id': id,
        'schemaVersion': schemaVersion,
        'bundles': bundles.map((bundle) => bundle.toJson()).toList(),
      };

  factory ContentManifest.fromJson(Map<String, dynamic> json) {
    return ContentManifest(
      id: json['id'] as String,
      schemaVersion: json['schemaVersion'] as int,
      bundles: (json['bundles'] as List<dynamic>)
          .map((bundle) => BundleRef.fromJson(bundle))
          .toList(),
    );
  }
}

class BundleRef {
  const BundleRef({
    required this.id,
    required this.url,
    required this.sha256,
    required this.schemaVersion,
  });

  final String id;
  final String url;
  final String sha256;
  final int schemaVersion;

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'sha256': sha256,
        'schemaVersion': schemaVersion,
      };

  factory BundleRef.fromJson(Map<String, dynamic> json) {
    return BundleRef(
      id: json['id'] as String,
      url: json['url'] as String,
      sha256: json['sha256'] as String,
      schemaVersion: json['schemaVersion'] as int,
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
  });

  final String id;
  final int schemaVersion;
  final ContentStatus status;
  final ReviewStatus reviewStatus;
  final Map<String, dynamic> payload;

  bool get isApproved =>
      status == ContentStatus.published &&
      reviewStatus == ReviewStatus.approved;

  Map<String, dynamic> toJson() => {
        'id': id,
        'schemaVersion': schemaVersion,
        'status': status.name,
        'reviewStatus': reviewStatus.name,
        'payload': payload,
      };

  String toCanonicalJson() => jsonEncode(toJson());

  factory ContentBundle.fromJson(Map<String, dynamic> json) {
    return ContentBundle(
      id: json['id'] as String,
      schemaVersion: json['schemaVersion'] as int,
      status: ContentStatus.parse(json['status'] as String),
      reviewStatus: ReviewStatus.parse(json['reviewStatus'] as String),
      payload: json['payload'] as Map<String, dynamic>,
    );
  }
}

class CacheEntry {
  const CacheEntry({
    required this.bundleId,
    required this.sha256,
    required this.cachedAt,
    required this.bundle,
  });

  final String bundleId;
  final String sha256;
  final DateTime cachedAt;
  final ContentBundle bundle;
}

class ContentRequestContext {
  const ContentRequestContext({
    required this.languageCode,
    required this.womenIbadahMode,
    this.lockScreenSafe = false,
  });

  final String languageCode;
  final WomenIbadahMode womenIbadahMode;
  final bool lockScreenSafe;
}
