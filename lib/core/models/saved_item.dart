import 'dart:convert';

enum SavedItemType {
  dailySession,
  dua,
  dhikr,
  quranVerse;

  static SavedItemType parse(String value) {
    return switch (value) {
      'daily_session' || 'dailySession' => SavedItemType.dailySession,
      'dua' => SavedItemType.dua,
      'dhikr' => SavedItemType.dhikr,
      'quran_verse' || 'quranVerse' => SavedItemType.quranVerse,
      _ => SavedItemType.dailySession,
    };
  }

  String get wireValue {
    return switch (this) {
      SavedItemType.dailySession => 'daily_session',
      SavedItemType.dua => 'dua',
      SavedItemType.dhikr => 'dhikr',
      SavedItemType.quranVerse => 'quran_verse',
    };
  }
}

class SavedItem {
  const SavedItem({
    required this.id,
    required this.itemType,
    required this.itemId,
    required this.titleSnapshot,
    required this.createdAt,
    required this.languageCode,
    this.subtitleSnapshot,
    this.sourceLabel,
  });

  final String id;
  final SavedItemType itemType;
  final String itemId;
  final String titleSnapshot;
  final String? subtitleSnapshot;
  final String? sourceLabel;
  final DateTime createdAt;
  final String languageCode;

  static String stableId(SavedItemType itemType, String itemId) {
    return '${itemType.wireValue}_$itemId';
  }

  SavedItem copyWith({
    String? id,
    SavedItemType? itemType,
    String? itemId,
    String? titleSnapshot,
    String? subtitleSnapshot,
    String? sourceLabel,
    DateTime? createdAt,
    String? languageCode,
  }) {
    return SavedItem(
      id: id ?? this.id,
      itemType: itemType ?? this.itemType,
      itemId: itemId ?? this.itemId,
      titleSnapshot: titleSnapshot ?? this.titleSnapshot,
      subtitleSnapshot: subtitleSnapshot ?? this.subtitleSnapshot,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      createdAt: createdAt ?? this.createdAt,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemType': itemType.wireValue,
        'itemId': itemId,
        'titleSnapshot': titleSnapshot,
        'subtitleSnapshot': subtitleSnapshot,
        'sourceLabel': sourceLabel,
        'createdAt': createdAt.toIso8601String(),
        'languageCode': languageCode,
      };

  factory SavedItem.fromJson(Map<String, dynamic> json) {
    final itemType = SavedItemType.parse(json['itemType'] as String? ?? '');
    final itemId = json['itemId'] as String? ?? '';
    return SavedItem(
      id: json['id'] as String? ?? stableId(itemType, itemId),
      itemType: itemType,
      itemId: itemId,
      titleSnapshot: json['titleSnapshot'] as String? ?? '',
      subtitleSnapshot: json['subtitleSnapshot'] as String?,
      sourceLabel: json['sourceLabel'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      languageCode: json['languageCode'] as String? ?? 'en',
    );
  }
}

List<SavedItem> savedItemsFromJson(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List<dynamic>) {
    return const [];
  }
  return decoded
      .whereType<Map<String, dynamic>>()
      .map(SavedItem.fromJson)
      .where((item) => item.itemId.isNotEmpty && item.titleSnapshot.isNotEmpty)
      .toList();
}

String savedItemsToJson(List<SavedItem> items) {
  return jsonEncode(items.map((item) => item.toJson()).toList());
}
