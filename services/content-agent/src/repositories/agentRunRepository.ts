import type { AgentCandidate, AgentRun } from "../domain/schemas.js";

export class AgentRunRepository {
  private readonly runs = new Map<string, AgentRun>();

  create(run: AgentRun): AgentRun {
    this.runs.set(run.runId, run);
    return run;
  }

  list(): AgentRun[] {
    return [...this.runs.values()].sort((a, b) => a.createdAt.localeCompare(b.createdAt));
  }

  get(runId: string): AgentRun | undefined {
    return this.runs.get(runId);
  }

  findCandidate(candidateId: string): AgentCandidate | undefined {
    for (const run of this.runs.values()) {
      const candidate = run.candidates.find((item) => item.candidateId === candidateId);
      if (candidate) {
        return candidate;
      }
    }
    return undefined;
  }
}
