import { describe, expect, it } from "vitest";
import type { AgentCandidate, SourceItem } from "../src/domain/schemas.js";
import { selectCandidateSources } from "../src/domain/candidateSelector.js";
import { collectSafetyFlags } from "../src/domain/safetyChecks.js";
import { seedSources } from "../src/repositories/contentRepository.js";
import { AgentRunRepository } from "../src/repositories/agentRunRepository.js";
import { ContentRepository } from "../src/repositories/contentRepository.js";
import { AgentRunsRoute } from "../src/routes/agentRuns.js";

describe("guardrails", () => {
  it("selects only approved source items", () => {
    const sources: SourceItem[] = [
      ...seedSources,
      {
        id: "draft",
        clusterId: "draft",
        ritualMoment: "morning",
        status: "draft",
        reviewStatus: "draft",
        language: "en",
        text: "Draft"
      }
    ];

    const selected = selectCandidateSources(sources, {
      language: "en",
      ritualMoment: "morning"
    });

    expect(selected.map((item) => item.id)).not.toContain("draft");
  });

  it("blocks women/cycle-sensitive lock-screen copy", () => {
    const candidate = candidateWith("Private", "Menstruating cycle reminder");
    const flags = collectSafetyFlags(candidate, seedSources[0]);

    expect(flags).toContain("cycle_sensitive_lock_screen");
  });

  it("blocks guaranteed outcome claims", () => {
    const candidate = candidateWith("Guaranteed", "Your dua will definitely be accepted now.");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("guaranteed_outcome_claim");
  });

  it("blocks fatwa-like claims", () => {
    const candidate = candidateWith("Ruling", "The ruling is haram for you.");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("fatwa_like_claim");
  });

  it("creates deterministic dry-run candidates for review", () => {
    const route = new AgentRunsRoute(new AgentRunRepository(), new ContentRepository());
    const run = route.createRun({ language: "en", ritualMoment: "morning" });

    expect(run.status).toBe("completed");
    expect(run.candidates[0].status).toBe("needs_human_review");
    expect(run.candidates[0].safetyFlags).toEqual([]);
  });
});

function candidateWith(title: string, body: string): AgentCandidate {
  return {
    candidateId: "candidate",
    runId: "run",
    clusterId: "ease",
    sourceItemId: seedSources[0].id,
    language: "en",
    lockScreenTitle: title,
    lockScreenBody: body,
    status: "needs_human_review",
    safetyFlags: []
  };
}
