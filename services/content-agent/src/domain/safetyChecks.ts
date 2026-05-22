import type { AgentContentCandidate, SourceItem } from "./schemas.js";
import { runCandidateQa } from "./qaReview.js";

export function collectSafetyFlags(
  candidate: AgentContentCandidate,
  source?: SourceItem,
) {
  return runCandidateQa(candidate, source);
}

export function isSafeForReview(
  candidate: AgentContentCandidate,
  source?: SourceItem,
): boolean {
  return collectSafetyFlags(candidate, source).riskFlags.length === 0;
}
