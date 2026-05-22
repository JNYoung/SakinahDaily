import type { AgentContentCandidate, SourceItem } from "./schemas.js";
import { runCandidateQa } from "./qaReview.js";

export function validateApprovedSource(source: SourceItem): string[] {
  if (source.status !== "published" || source.reviewStatus !== "approved") {
    return ["source_not_approved"];
  }
  return [];
}

export function validateCandidate(candidate: AgentContentCandidate): string[] {
  return runCandidateQa(candidate, undefined).riskFlags.filter(
    (flag) => flag !== "invented_source_id",
  );
}
