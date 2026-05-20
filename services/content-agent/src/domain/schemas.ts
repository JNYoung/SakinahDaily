export type SourceStatus = "draft" | "published" | "archived";
export type SourceReviewStatus = "draft" | "in_review" | "approved" | "rejected";
export type AgentRunStatus = "created" | "completed" | "failed";
export type CandidateStatus = "needs_human_review" | "rejected" | "cms_draft";
export type RitualMoment = "morning" | "evening" | "after_prayer";

export interface SourceItem {
  id: string;
  clusterId: string;
  ritualMoment: RitualMoment;
  status: SourceStatus;
  reviewStatus: SourceReviewStatus;
  language: string;
  text: string;
  sourceLabel: string;
  cycleSensitiveHidden?: boolean;
}

export interface AgentCandidate {
  candidateId: string;
  runId: string;
  clusterId: string;
  sourceItemId: string;
  sourceLabel: string;
  language: string;
  lockScreenTitle: string;
  lockScreenBody: string;
  status: CandidateStatus;
  safetyFlags: string[];
}

export interface AgentRun {
  runId: string;
  runType: "weekly_preproduction";
  status: AgentRunStatus;
  createdAt: string;
  candidates: AgentCandidate[];
}

export interface CreateAgentRunRequest {
  runType?: "weekly_preproduction";
  language?: string;
  ritualMoment?: RitualMoment;
  recentClusterIds?: string[];
  womenLockScreenSafe?: boolean;
}

export interface QaResult {
  candidateId: string;
  accepted: boolean;
  flags: string[];
}

export function isAgentCandidate(value: unknown): value is AgentCandidate {
  const candidate = value as Partial<AgentCandidate>;
  return (
    typeof candidate.candidateId === "string" &&
    typeof candidate.runId === "string" &&
    typeof candidate.clusterId === "string" &&
    typeof candidate.sourceItemId === "string" &&
    typeof candidate.sourceLabel === "string" &&
    typeof candidate.language === "string" &&
    typeof candidate.lockScreenTitle === "string" &&
    typeof candidate.lockScreenBody === "string" &&
    candidate.status === "needs_human_review" &&
    Array.isArray(candidate.safetyFlags)
  );
}
