import type { RitualMoment, SourceItem } from "./schemas.js";

export interface CandidateSelectionContext {
  language: string;
  ritualMoment: RitualMoment;
  recentClusterIds?: string[];
  womenLockScreenSafe?: boolean;
}

export function selectCandidateSources(
  sources: SourceItem[],
  context: CandidateSelectionContext
): SourceItem[] {
  const recent = new Set(context.recentClusterIds ?? []);
  const preferred = filterSources(sources, context, context.language);
  const fallback = context.language === "en" ? [] : filterSources(sources, context, "en");
  const seen = new Set<string>();

  return [...preferred, ...fallback]
    .filter((source) => {
      const key = `${source.clusterId}:${source.language}`;
      if (seen.has(key)) {
        return false;
      }
      seen.add(key);
      return !recent.has(source.clusterId);
    })
    .sort((a, b) => a.id.localeCompare(b.id));
}

function filterSources(
  sources: SourceItem[],
  context: CandidateSelectionContext,
  language: string
): SourceItem[] {
  return sources
    .filter((source) => source.status === "published")
    .filter((source) => source.reviewStatus === "approved")
    .filter((source) => source.ritualMoment === context.ritualMoment)
    .filter((source) => source.language === language)
    .filter((source) => !(context.womenLockScreenSafe && source.cycleSensitiveHidden));
}
