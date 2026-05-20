import type { AgentCandidate, SourceItem } from "./schemas.js";
import { validateApprovedSource, validateCandidate } from "./validators.js";

export function collectSafetyFlags(
  candidate: AgentCandidate,
  source: SourceItem | undefined
): string[] {
  return [...validateApprovedSource(source), ...validateCandidate(candidate)];
}

export function isSafeForHumanReview(
  candidate: AgentCandidate,
  source: SourceItem | undefined
): boolean {
  return collectSafetyFlags(candidate, source).length === 0;
}
