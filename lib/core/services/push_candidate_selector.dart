import '../models/sakinah_models.dart';

class PushSelectionContext {
  const PushSelectionContext({
    required this.languageCode,
    required this.ritualMoment,
    required this.recentClusterIds,
    required this.womenIbadahMode,
  });

  final String languageCode;
  final String ritualMoment;
  final Set<String> recentClusterIds;
  final WomenIbadahMode womenIbadahMode;
}

class PushCandidateSelector {
  PushCandidate? select({
    required List<SourceItem> sourceItems,
    required List<PushTemplate> templates,
    required PushSelectionContext context,
  }) {
    final filteredSources = sourceItems.where((item) {
      if (!item.isApproved) {
        return false;
      }
      if (item.ritualMoment != context.ritualMoment) {
        return false;
      }
      if (context.recentClusterIds.contains(item.clusterId)) {
        return false;
      }
      if (context.womenIbadahMode.enabled &&
          context.womenIbadahMode.hideCycleSensitiveLockScreenCopy &&
          item.cycleSensitiveHidden) {
        return false;
      }
      return true;
    }).toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    final source = filteredSources.firstOrNull;
    if (source == null) {
      return null;
    }

    final template = templates
        .where(
          (template) =>
              template.isApproved &&
              template.ritualMoment == context.ritualMoment &&
              !(context.womenIbadahMode.enabled &&
                  context.womenIbadahMode.hideCycleSensitiveLockScreenCopy &&
                  template.cycleSensitiveHidden),
        )
        .firstOrNull;

    if (template == null) {
      return null;
    }

    return PushCandidate(
      sourceItemId: source.id,
      templateId: template.id,
      clusterId: source.clusterId,
      languageCode: context.languageCode,
      title: template.title.resolve(context.languageCode),
      body: template.body.resolve(context.languageCode),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
