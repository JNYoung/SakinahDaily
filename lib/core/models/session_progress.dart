import 'dart:convert';

enum SessionProgressStatus {
  notStarted,
  inProgress,
  completed,
  abandoned;

  static SessionProgressStatus parse(String value) {
    return SessionProgressStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => SessionProgressStatus.notStarted,
    );
  }
}

class SessionProgress {
  const SessionProgress({
    required this.sessionId,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.status,
    required this.startedAt,
    required this.updatedAt,
    required this.languageCode,
    this.completedAt,
  });

  final String sessionId;
  final int currentStepIndex;
  final int totalSteps;
  final SessionProgressStatus status;
  final DateTime startedAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final String languageCode;

  SessionProgress copyWith({
    String? sessionId,
    int? currentStepIndex,
    int? totalSteps,
    SessionProgressStatus? status,
    DateTime? startedAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    String? languageCode,
  }) {
    return SessionProgress(
      sessionId: sessionId ?? this.sessionId,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'currentStepIndex': currentStepIndex,
        'totalSteps': totalSteps,
        'status': status.name,
        'startedAt': startedAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'languageCode': languageCode,
      };

  factory SessionProgress.fromJson(Map<String, dynamic> json) {
    return SessionProgress(
      sessionId: json['sessionId'] as String? ?? '',
      currentStepIndex: json['currentStepIndex'] as int? ?? 0,
      totalSteps: json['totalSteps'] as int? ?? 0,
      status: SessionProgressStatus.parse(json['status'] as String? ?? ''),
      startedAt: _dateTimeFromJson(json['startedAt']),
      updatedAt: _dateTimeFromJson(json['updatedAt']),
      completedAt: _nullableDateTimeFromJson(json['completedAt']),
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }
}

class SessionCompletionRecord {
  const SessionCompletionRecord({
    required this.id,
    required this.sessionId,
    required this.completedAt,
    required this.durationSeconds,
    required this.languageCode,
    required this.totalSteps,
  });

  final String id;
  final String sessionId;
  final DateTime completedAt;
  final int durationSeconds;
  final String languageCode;
  final int totalSteps;

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'completedAt': completedAt.toIso8601String(),
        'durationSeconds': durationSeconds,
        'languageCode': languageCode,
        'totalSteps': totalSteps,
      };

  factory SessionCompletionRecord.fromJson(Map<String, dynamic> json) {
    return SessionCompletionRecord(
      id: json['id'] as String? ?? '',
      sessionId: json['sessionId'] as String? ?? '',
      completedAt: _dateTimeFromJson(json['completedAt']),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      languageCode: json['languageCode'] as String? ?? 'en',
      totalSteps: json['totalSteps'] as int? ?? 0,
    );
  }
}

Map<String, SessionProgress> sessionProgressMapFromJson(Object? value) {
  if (value is! Map<String, dynamic>) {
    return const {};
  }
  final progress = <String, SessionProgress>{};
  for (final entry in value.entries) {
    final raw = entry.value;
    if (raw is Map<String, dynamic>) {
      final decoded = SessionProgress.fromJson(raw);
      if (decoded.sessionId.isNotEmpty) {
        progress[entry.key] = decoded;
      }
    }
  }
  return progress;
}

List<SessionCompletionRecord> sessionCompletionRecordsFromJson(Object? value) {
  if (value is! List<dynamic>) {
    return const [];
  }
  return value
      .whereType<Map<String, dynamic>>()
      .map(SessionCompletionRecord.fromJson)
      .where((record) => record.id.isNotEmpty && record.sessionId.isNotEmpty)
      .toList();
}

String encodeSessionProgressStore({
  required Map<String, SessionProgress> progress,
  required List<SessionCompletionRecord> records,
}) {
  return jsonEncode({
    'progress': progress.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'records': records.map((record) => record.toJson()).toList(),
  });
}

DateTime _dateTimeFromJson(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

DateTime? _nullableDateTimeFromJson(Object? value) {
  if (value is String) {
    return DateTime.tryParse(value);
  }
  return null;
}
