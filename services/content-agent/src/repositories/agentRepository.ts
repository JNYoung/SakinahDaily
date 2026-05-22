import type {
  AgentContentCandidate,
  AgentFeedbackEvent,
  AgentReviewPacket,
  AgentReviewStatus,
  AgentRun,
  AgentRunStatus,
} from "../domain/schemas.js";

export interface AgentRepository {
  createRun(run: AgentRun): Promise<AgentRun>;
  getRun(runId: string): Promise<AgentRun | undefined>;
  listRuns(filters?: { status?: AgentRunStatus }): Promise<AgentRun[]>;
  updateRunStatus(
    runId: string,
    status: AgentRunStatus,
    patch?: Partial<
      Pick<
        AgentRun,
        "summary" | "warnings" | "errorMessage" | "startedAt" | "completedAt"
      >
    >,
  ): Promise<AgentRun | undefined>;
  createCandidate(
    candidate: AgentContentCandidate,
  ): Promise<AgentContentCandidate>;
  getCandidate(candidateId: string): Promise<AgentContentCandidate | undefined>;
  listCandidatesByRun(runId: string): Promise<AgentContentCandidate[]>;
  updateCandidateReviewStatus(
    candidateId: string,
    status: AgentReviewStatus,
    patch?: Partial<AgentContentCandidate>,
  ): Promise<AgentContentCandidate | undefined>;
  updateCandidate(
    candidate: AgentContentCandidate,
  ): Promise<AgentContentCandidate>;
  createReviewPacket(packet: AgentReviewPacket): Promise<AgentReviewPacket>;
  getReviewPacketByRun(runId: string): Promise<AgentReviewPacket | undefined>;
  createFeedbackEvent(event: AgentFeedbackEvent): Promise<AgentFeedbackEvent>;
  listFeedbackEvents(candidateId: string): Promise<AgentFeedbackEvent[]>;
}
