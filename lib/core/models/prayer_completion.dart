import 'dart:convert';

import 'sakinah_models.dart';

class PrayerCompletionRecord {
  PrayerCompletionRecord({
    required this.id,
    required this.prayerName,
    required this.completedAt,
    String? localDayKey,
  }) : localDayKey = localDayKey ?? prayerCompletionDayKey(completedAt);

  final String id;
  final String prayerName;
  final DateTime completedAt;
  final String localDayKey;

  Map<String, dynamic> toJson() => {
        'id': id,
        'prayerName': prayerName,
        'localDayKey': localDayKey,
        'completedAt': completedAt.toUtc().toIso8601String(),
      };

  factory PrayerCompletionRecord.fromJson(Map<String, dynamic> json) {
    final prayerName = json['prayerName'] as String? ?? '';
    if (!defaultPrayerReminderNames.contains(prayerName)) {
      throw FormatException('Unknown prayer name: $prayerName');
    }
    final id = json['id'] as String;
    return PrayerCompletionRecord(
      id: id,
      prayerName: prayerName,
      completedAt: DateTime.parse(json['completedAt'] as String),
      localDayKey: json['localDayKey'] as String? ?? id.split('_').first,
    );
  }
}

String prayerCompletionDayKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String prayerCompletionRecordId(String prayerName, DateTime date) {
  return '${prayerCompletionDayKey(date)}_$prayerName';
}

List<PrayerCompletionRecord> prayerCompletionRecordsFromJson(dynamic value) {
  if (value is! List) {
    return const [];
  }
  final records = <PrayerCompletionRecord>[];
  for (final item in value) {
    if (item is! Map<String, dynamic>) {
      continue;
    }
    try {
      records.add(PrayerCompletionRecord.fromJson(item));
    } on Object {
      continue;
    }
  }
  return records;
}

String encodePrayerCompletionStore({
  required List<PrayerCompletionRecord> records,
}) {
  return jsonEncode({
    'records': records.map((record) => record.toJson()).toList(),
  });
}
