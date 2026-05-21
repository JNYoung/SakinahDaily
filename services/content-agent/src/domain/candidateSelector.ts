import type { SourceItem } from "./schemas.js";

export interface CandidateSelectionContext {
  language: string;
  ritualMoment: SourceItem["ritualMoment"];
  recentClusterIds?: string[];
  womenLockScreenSafe?: boolean;
}

export function selectCandidateSources(
  sources: SourceItem[],
  context: CandidateSelectionContext
): SourceItem[] {
  const recent = new Set(context.recentClusterIds ?? []);
  return sources
    .filter((source) => source.status === "published")
    .filter((source) => source.reviewStatus === "approved")
    .filter((source) => source.ritualMoment === context.ritualMoment)
    .filter((source) => source.language === context.language || source.language === "en")
    .filter((source) => !recent.has(source.clusterId))
    .filter((source) => !(context.womenLockScreenSafe && source.cycleSensitiveHidden))
    .sort((a, b) => a.id.localeCompare(b.id));
}
