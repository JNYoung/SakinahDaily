export type ReviewStatus = "draft" | "in_review" | "approved" | "needs_human_review";
export type AgentRunStatus = "created" | "completed" | "failed";

export interface SourceItem {
  id: string;
  clusterId: string;
  ritualMoment: "morning" | "evening" | "after_prayer";
  status: "draft" | "published" | "archived";
  reviewStatus: "draft" | "in_review" | "approved" | "rejected";
  language: string;
  text: string;
  cycleSensitiveHidden?: boolean;
}

export interface AgentCandidate {
  candidateId: string;
  runId: string;
  clusterId: string;
  sourceItemId: string;
  language: string;
  lockScreenTitle: string;
  lockScreenBody: string;
  status: ReviewStatus;
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
  ritualMoment?: SourceItem["ritualMoment"];
}

export interface QaResult {
  candidateId: string;
  accepted: boolean;
  flags: string[];
}
