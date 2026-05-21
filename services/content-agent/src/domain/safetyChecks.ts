import type { AgentCandidate, SourceItem } from "./schemas.js";
import { validateApprovedSource, validateCandidate } from "./validators.js";

export function collectSafetyFlags(candidate: AgentCandidate, source: SourceItem): string[] {
  return [...validateApprovedSource(source), ...validateCandidate(candidate)];
}

export function isSafeForReview(candidate: AgentCandidate, source: SourceItem): boolean {
  return collectSafetyFlags(candidate, source).length === 0;
}
