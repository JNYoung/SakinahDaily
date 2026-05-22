import type {
  AgentContentCandidate,
  AgentFeedbackEvent,
  AgentReviewPacket,
  AgentReviewStatus,
  AgentRun,
  AgentRunStatus,
} from "../domain/schemas.js";
import type { AgentRepository } from "./agentRepository.js";

export class InMemoryAgentRepository implements AgentRepository {
  private readonly runs = new Map<string, AgentRun>();
  private readonly candidates = new Map<string, AgentContentCandidate>();
  private readonly reviewPacketsByRun = new Map<string, AgentReviewPacket>();
  private readonly feedbackEvents = new Map<string, AgentFeedbackEvent[]>();

  async createRun(run: AgentRun): Promise<AgentRun> {
    this.runs.set(run.runId, run);
    return run;
  }

  async getRun(runId: string): Promise<AgentRun | undefined> {
    return this.runs.get(runId);
  }

  async listRuns(
    filters: { status?: AgentRunStatus } = {},
  ): Promise<AgentRun[]> {
    return [...this.runs.values()]
      .filter((run) => (filters.status ? run.status === filters.status : true))
      .sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  }

  async updateRunStatus(
    runId: string,
    status: AgentRunStatus,
    patch: Partial<
      Pick<
        AgentRun,
        "summary" | "warnings" | "errorMessage" | "startedAt" | "completedAt"
      >
    > = {},
  ): Promise<AgentRun | undefined> {
    const run = this.runs.get(runId);
    if (!run) {
      return undefined;
    }
    const updated = { ...run, ...patch, status };
    this.runs.set(runId, updated);
    return updated;
  }

  async createCandidate(
    candidate: AgentContentCandidate,
  ): Promise<AgentContentCandidate> {
    this.candidates.set(candidate.candidateId, candidate);
    return candidate;
  }

  async getCandidate(
    candidateId: string,
  ): Promise<AgentContentCandidate | undefined> {
    return this.candidates.get(candidateId);
  }

  async listCandidatesByRun(runId: string): Promise<AgentContentCandidate[]> {
    return [...this.candidates.values()]
      .filter((candidate) => candidate.runId === runId)
      .sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  }

  async updateCandidateReviewStatus(
    candidateId: string,
    status: AgentReviewStatus,
    patch: Partial<AgentContentCandidate> = {},
  ): Promise<AgentContentCandidate | undefined> {
    const candidate = this.candidates.get(candidateId);
    if (!candidate) {
      return undefined;
    }
    const updated = {
      ...candidate,
      ...patch,
      reviewStatus: status,
      updatedAt: patch.updatedAt ?? new Date().toISOString(),
    };
    this.candidates.set(candidateId, updated);
    return updated;
  }

  async updateCandidate(
    candidate: AgentContentCandidate,
  ): Promise<AgentContentCandidate> {
    const updated = {
      ...candidate,
      updatedAt: candidate.updatedAt ?? new Date().toISOString(),
    };
    this.candidates.set(candidate.candidateId, updated);
    return updated;
  }

  async createReviewPacket(
    packet: AgentReviewPacket,
  ): Promise<AgentReviewPacket> {
    this.reviewPacketsByRun.set(packet.runId, packet);
    return packet;
  }

  async getReviewPacketByRun(
    runId: string,
  ): Promise<AgentReviewPacket | undefined> {
    return this.reviewPacketsByRun.get(runId);
  }

  async createFeedbackEvent(
    event: AgentFeedbackEvent,
  ): Promise<AgentFeedbackEvent> {
    const current = this.feedbackEvents.get(event.candidateId) ?? [];
    this.feedbackEvents.set(event.candidateId, [...current, event]);
    return event;
  }

  async listFeedbackEvents(candidateId: string): Promise<AgentFeedbackEvent[]> {
    return [...(this.feedbackEvents.get(candidateId) ?? [])].sort((a, b) =>
      a.createdAt.localeCompare(b.createdAt),
    );
  }
}
