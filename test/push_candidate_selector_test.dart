import 'package:flutter_test/flutter_test.dart';
import 'package:sakinah_daily/core/models/sakinah_models.dart';
import 'package:sakinah_daily/core/repositories/content_repository.dart';
import 'package:sakinah_daily/core/services/push_candidate_selector.dart';

void main() {
  final content = SeedContent.demo();
  final selector = PushCandidateSelector();

  test('candidate selector returns deterministic approved content', () {
    final candidate = selector.select(
      sourceItems: content.sourceItems,
      templates: content.pushTemplates,
      context: const PushSelectionContext(
        languageCode: 'id',
        ritualMoment: 'morning',
        recentClusterIds: {},
        womenIbadahMode: WomenIbadahMode(enabled: false),
      ),
    );

    expect(candidate, isNotNull);
    expect(candidate!.languageCode, 'id');
    expect(candidate.title, 'Mulai dengan lembut');
  });

  test('cooldown blocks recently used cluster', () {
    final candidate = selector.select(
      sourceItems: content.sourceItems,
      templates: content.pushTemplates,
      context: const PushSelectionContext(
        languageCode: 'en',
        ritualMoment: 'morning',
        recentClusterIds: {'ease'},
        womenIbadahMode: WomenIbadahMode(enabled: false),
      ),
    );

    expect(candidate, isNull);
  });

  test('women mode hides cycle-sensitive lock-screen copy', () {
    final candidate = selector.select(
      sourceItems: content.sourceItems,
      templates: content.pushTemplates,
      context: const PushSelectionContext(
        languageCode: 'en',
        ritualMoment: 'evening',
        recentClusterIds: {},
        womenIbadahMode: WomenIbadahMode(enabled: true),
      ),
    );

    expect(candidate, isNull);
  });
}
