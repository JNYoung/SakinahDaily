import type {
  AgentContentCandidate,
  AgentReviewPacket,
  AgentRun,
} from "./schemas.js";

export const HUMAN_REVIEW_WARNING =
  "Agent output is draft only. Human review required before approval or publishing.";

export const reviewerChecklist = [
  "source reference correct",
  "no invented source",
  "no fatwa-like claim",
  "lock-screen safe",
  "women privacy safe",
  "localization natural",
  "no guaranteed outcome",
  "no shaming",
  "content cluster appropriate",
  "CMS draft only",
];

export function buildReviewPacket(params: {
  run: AgentRun;
  candidates: AgentContentCandidate[];
  selectedSources: Array<Record<string, unknown>>;
  nowIso?: string;
}): AgentReviewPacket {
  const nowIso = params.nowIso ?? new Date().toISOString();
  return {
    id: `review_packet_${params.run.runId}`,
    runId: params.run.runId,
    title: `${params.run.runType} review packet`,
    summary: `Review ${params.candidates.length} draft candidate(s).`,
    packetPayload: {
      warning: HUMAN_REVIEW_WARNING,
      runId: params.run.runId,
      runType: params.run.runType,
      generatedAt: nowIso,
      selectedSources: params.selectedSources,
      candidates: params.candidates.map((candidate) => ({
        candidateId: candidate.candidateId,
        candidateType: candidate.candidateType,
        sourceItemId: candidate.sourceItemId,
        clusterId: candidate.clusterId,
        language: candidate.language,
        targetMarket: candidate.targetMarket,
        ritualMoment: candidate.ritualMoment,
        payload: candidate.payload,
        riskFlags: candidate.riskFlags,
        automatedChecks: candidate.automatedChecks,
        reviewStatus: candidate.reviewStatus,
      })),
    },
    reviewerChecklist,
    status: "needs_human_review",
    createdAt: nowIso,
    updatedAt: nowIso,
  };
}
