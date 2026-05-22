export type AgentRunType =
  | "weekly_preproduction"
  | "cluster_production"
  | "qa_only";

export type AgentRunStatus =
  | "queued"
  | "running"
  | "completed"
  | "completed_with_warnings"
  | "failed"
  | "cancelled";

export type AgentReviewStatus =
  | "agent_draft"
  | "agent_rejected"
  | "needs_human_review"
  | "promoted_to_cms_draft"
  | "discarded";

export type RitualMoment = "morning" | "evening" | "after_prayer";

export interface SourceItem {
  id: string;
  clusterId: string;
  ritualMoment: RitualMoment;
  status: "draft" | "published" | "archived";
  reviewStatus: "draft" | "in_review" | "approved" | "rejected";
  language: string;
  text: string;
  cycleSensitiveHidden?: boolean;
}

export interface AutomatedCheck {
  check: string;
  passed: boolean;
  flag?: string;
  message?: string;
}

export interface AgentCandidatePayload {
  lockScreenTitle?: string;
  lockScreenBody?: string;
  sourceItemId?: string;
  cmsStatus?: string;
  status?: string;
  reviewStatus?: string;
  sendFcm?: boolean;
  sendFCM?: boolean;
  sendApns?: boolean;
  sendAPNs?: boolean;
  fcmPayload?: unknown;
  apnsPayload?: unknown;
  generatedQuranText?: unknown;
  generatedHadithText?: unknown;
  [key: string]: unknown;
}

export interface AgentContentCandidate {
  id: string;
  candidateId: string;
  runId: string;
  candidateType: string;
  sourceItemId: string;
  clusterId: string;
  language: string;
  targetMarket: string;
  ritualMoment: RitualMoment;
  payload: AgentCandidatePayload;
  riskFlags: string[];
  automatedChecks: AutomatedCheck[];
  reviewStatus: AgentReviewStatus;
  cmsTargetTable: string;
  cmsTargetId?: string;
  agentVersion: string;
  promptVersion: string;
  modelName: string;
  schemaVersion: number;
  inputHash: string;
  outputHash: string;
  createdAt: string;
  updatedAt: string;
}

export type AgentCandidate = AgentContentCandidate;

export interface AgentRun {
  id: string;
  runId: string;
  runType: AgentRunType;
  status: AgentRunStatus;
  requestPayload: Record<string, unknown>;
  summary: string;
  warnings: string[];
  errorMessage?: string;
  dryRun: boolean;
  createdBy: string;
  createdAt: string;
  startedAt?: string;
  completedAt?: string;
}

export interface AgentReviewPacket {
  id: string;
  runId: string;
  title: string;
  summary: string;
  packetPayload: {
    warning: string;
    runId?: string;
    runType?: AgentRunType;
    generatedAt?: string;
    selectedSources?: Array<Record<string, unknown>>;
    candidates?: Array<Record<string, unknown>>;
    [key: string]: unknown;
  };
  reviewerChecklist: string[];
  status: "needs_human_review" | "completed" | "discarded";
  createdAt: string;
  updatedAt: string;
}

export interface AgentFeedbackEvent {
  id: string;
  candidateId: string;
  reviewerRole: string;
  decision: "needs_edit" | "accepted_for_draft" | "discarded" | string;
  reason: string;
  editedPayload?: AgentCandidatePayload;
  createdAt: string;
}

export interface CreateAgentRunRequest {
  runType?: AgentRunType;
  language?: string;
  targetMarket?: string;
  ritualMoment?: RitualMoment;
  clusterId?: string;
  candidateIds?: string[];
  dryRun?: boolean;
  createdBy?: string;
}

export interface QaResult {
  candidateId: string;
  accepted: boolean;
  flags: string[];
  riskFlags: string[];
  automatedChecks: AutomatedCheck[];
}

export interface WorkflowResult {
  run: AgentRun;
  candidates: AgentContentCandidate[];
  reviewPacket: AgentReviewPacket;
}
