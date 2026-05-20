import type { AgentCandidate, AgentRun } from "../domain/schemas.js";

export class AgentRunRepository {
  private readonly runs = new Map<string, AgentRun>();

  create(run: AgentRun): AgentRun {
    this.runs.set(run.runId, run);
    return run;
  }

  updateCandidate(candidate: AgentCandidate): AgentCandidate {
    const run = this.runs.get(candidate.runId);
    if (!run) {
      throw new Error(`Run not found for candidate ${candidate.candidateId}`);
    }
    run.candidates = run.candidates.map((existing) =>
      existing.candidateId === candidate.candidateId ? candidate : existing
    );
    this.runs.set(run.runId, run);
    return candidate;
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
