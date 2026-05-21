import 'dart:convert';

enum LocalPushType {
  dailySession,
  dua,
  dhikr,
  quran,
  unknown;

  static LocalPushType parse(String? value) {
    return switch (value) {
      'daily_session' || 'dailySession' => LocalPushType.dailySession,
      'dua' => LocalPushType.dua,
      'dhikr' => LocalPushType.dhikr,
      'quran' => LocalPushType.quran,
      _ => LocalPushType.unknown,
    };
  }

  String get wireValue {
    return switch (this) {
      LocalPushType.dailySession => 'daily_session',
      LocalPushType.dua => 'dua',
      LocalPushType.dhikr => 'dhikr',
      LocalPushType.quran => 'quran',
      LocalPushType.unknown => 'unknown',
    };
  }
}

class LocalPushPayload {
  const LocalPushPayload({
    required this.id,
    required this.type,
    required this.contentId,
    required this.languageCode,
    required this.title,
    required this.body,
    required this.data,
    required this.lockScreenSafe,
    this.clusterId,
    this.bundleHint,
  });

  final String id;
  final LocalPushType type;
  final String contentId;
  final String? clusterId;
  final String? bundleHint;
  final String languageCode;
  final String title;
  final String body;
  final Map<String, String> data;
  final bool lockScreenSafe;

  static LocalPushPayload? tryParseJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      if (!_hasExpectedTypes(decoded)) {
        return null;
      }
      return LocalPushPayload.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  factory LocalPushPayload.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'];
    return LocalPushPayload(
      id: _stringValue(json['id']),
      type: LocalPushType.parse(_stringValue(json['type'])),
      contentId: _stringValue(json['contentId']),
      clusterId: _nullableStringValue(json['clusterId']),
      bundleHint: _nullableStringValue(json['bundleHint']),
      languageCode: _stringValue(json['languageCode'], fallback: 'en'),
      title: _stringValue(json['title']),
      body: _stringValue(json['body']),
      data: dataJson is Map<String, dynamic>
          ? dataJson.map((key, value) => MapEntry(key, '$value'))
          : const {},
      lockScreenSafe: json['lockScreenSafe'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.wireValue,
        'contentId': contentId,
        'clusterId': clusterId,
        'bundleHint': bundleHint,
        'languageCode': languageCode,
        'title': title,
        'body': body,
        'data': data,
        'lockScreenSafe': lockScreenSafe,
      };

  bool get hasRequiredFields =>
      id.isNotEmpty &&
      contentId.isNotEmpty &&
      languageCode.isNotEmpty &&
      title.isNotEmpty &&
      body.isNotEmpty;
}

String _stringValue(Object? value, {String fallback = ''}) {
  return value is String ? value : fallback;
}

String? _nullableStringValue(Object? value) {
  return value is String && value.isNotEmpty ? value : null;
}

bool _hasExpectedTypes(Map<String, dynamic> json) {
  for (final key in [
    'id',
    'type',
    'contentId',
    'clusterId',
    'bundleHint',
    'languageCode',
    'title',
    'body',
  ]) {
    if (json.containsKey(key) && json[key] is! String) {
      return false;
    }
  }
  if (json.containsKey('lockScreenSafe') && json['lockScreenSafe'] is! bool) {
    return false;
  }
  if (json.containsKey('data') && json['data'] is! Map<String, dynamic>) {
    return false;
  }
  return true;
}
