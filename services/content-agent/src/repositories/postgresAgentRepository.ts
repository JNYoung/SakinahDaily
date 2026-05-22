import type {
  AgentContentCandidate,
  AgentFeedbackEvent,
  AgentReviewPacket,
  AgentReviewStatus,
  AgentRun,
  AgentRunStatus,
} from "../domain/schemas.js";
import type { AgentRepository } from "./agentRepository.js";

export class PostgresAgentRepository implements AgentRepository {
  constructor(
    private readonly databaseUrl = process.env.CONTENT_AGENT_DATABASE_URL,
  ) {}

  async createRun(_run: AgentRun): Promise<AgentRun> {
    return this.notConfigured();
  }

  async getRun(_runId: string): Promise<AgentRun | undefined> {
    return this.notConfigured();
  }

  async listRuns(
    _filters: { status?: AgentRunStatus } = {},
  ): Promise<AgentRun[]> {
    return this.notConfigured();
  }

  async updateRunStatus(
    _runId: string,
    _status: AgentRunStatus,
    _patch: Partial<
      Pick<
        AgentRun,
        "summary" | "warnings" | "errorMessage" | "startedAt" | "completedAt"
      >
    > = {},
  ): Promise<AgentRun | undefined> {
    return this.notConfigured();
  }

  async createCandidate(
    _candidate: AgentContentCandidate,
  ): Promise<AgentContentCandidate> {
    return this.notConfigured();
  }

  async getCandidate(
    _candidateId: string,
  ): Promise<AgentContentCandidate | undefined> {
    return this.notConfigured();
  }

  async listCandidatesByRun(_runId: string): Promise<AgentContentCandidate[]> {
    return this.notConfigured();
  }

  async updateCandidateReviewStatus(
    _candidateId: string,
    _status: AgentReviewStatus,
    _patch: Partial<AgentContentCandidate> = {},
  ): Promise<AgentContentCandidate | undefined> {
    return this.notConfigured();
  }

  async updateCandidate(
    _candidate: AgentContentCandidate,
  ): Promise<AgentContentCandidate> {
    return this.notConfigured();
  }

  async createReviewPacket(
    _packet: AgentReviewPacket,
  ): Promise<AgentReviewPacket> {
    return this.notConfigured();
  }

  async getReviewPacketByRun(
    _runId: string,
  ): Promise<AgentReviewPacket | undefined> {
    return this.notConfigured();
  }

  async createFeedbackEvent(
    _event: AgentFeedbackEvent,
  ): Promise<AgentFeedbackEvent> {
    return this.notConfigured();
  }

  async listFeedbackEvents(
    _candidateId: string,
  ): Promise<AgentFeedbackEvent[]> {
    return this.notConfigured();
  }

  private notConfigured<T>(): T {
    if (!this.databaseUrl) {
      throw new Error("PostgresAgentRepository is not configured.");
    }
    throw new Error(
      "PostgresAgentRepository adapter is not implemented for local MVP tests.",
    );
  }
}
