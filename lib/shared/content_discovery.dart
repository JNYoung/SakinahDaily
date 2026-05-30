import '../core/localization/sakinah_localizations.dart';

const allContentCategory = 'all';

const _preferredCategoryOrder = [
  allContentCategory,
  'quranic',
  'morning',
  'evening',
  'reflection',
  'difficulty',
  'gratitude',
  'forgiveness',
  'general',
];

List<String> discoverCategories(Iterable<String> categories) {
  final unique = <String>{allContentCategory, ...categories};
  final ordered = [
    for (final category in _preferredCategoryOrder)
      if (unique.remove(category)) category,
  ];
  return [...ordered, ...unique.toList()..sort()];
}

bool contentMatchesQuery(String query, Iterable<String> fields) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return true;
  }
  return fields.any((field) => field.toLowerCase().contains(normalizedQuery));
}

String contentCategoryLabel(
  SakinahLocalizations l10n,
  String category,
) {
  return switch (category) {
    allContentCategory => l10n.t('allCategories'),
    'quranic' => l10n.t('categoryQuranic'),
    'morning' => l10n.t('categoryMorning'),
    'evening' => l10n.t('categoryEvening'),
    'reflection' => l10n.t('categoryReflection'),
    'difficulty' => l10n.t('categoryDifficulty'),
    'gratitude' => l10n.t('categoryGratitude'),
    'forgiveness' => l10n.t('categoryForgiveness'),
    'general' => l10n.t('categoryGeneral'),
    _ => _humanizeCategory(category),
  };
}

String _humanizeCategory(String category) {
  final words = category.replaceAll('-', '_').split('_');
  return words
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
