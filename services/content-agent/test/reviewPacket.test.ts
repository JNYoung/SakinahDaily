import { describe, expect, it } from "vitest";
import type { AgentContentCandidate, AgentRun } from "../src/domain/schemas.js";
import { buildReviewPacket } from "../src/domain/reviewPacket.js";

describe("review packets", () => {
  it("includes safety flags and a human-review-required warning", () => {
    const packet = buildReviewPacket({
      run: runFixture(),
      candidates: [candidateFixture(["fatwa_like_claim"])],
      selectedSources: [
        { sourceItemId: "source_ease_en", clusterId: "ease", language: "en" },
      ],
    });

    expect(packet.title).toContain("weekly_preproduction");
    expect(packet.packetPayload.warning).toBe(
      "Agent output is draft only. Human review required before approval or publishing.",
    );
    expect(packet.packetPayload.candidates?.[0].riskFlags).toContain(
      "fatwa_like_claim",
    );
    expect(packet.reviewerChecklist).toEqual(
      expect.arrayContaining([
        "source reference correct",
        "no invented source",
        "no fatwa-like claim",
        "CMS draft only",
      ]),
    );
  });
});

function runFixture(): AgentRun {
  return {
    id: "run_fixture",
    runId: "run_fixture",
    runType: "weekly_preproduction",
    status: "completed",
    requestPayload: {},
    summary: "Created 1 candidate.",
    warnings: [],
    dryRun: true,
    createdBy: "test",
    createdAt: "2026-05-22T00:00:00.000Z",
    completedAt: "2026-05-22T00:00:00.000Z",
  };
}

function candidateFixture(riskFlags: string[]): AgentContentCandidate {
  return {
    id: "candidate_fixture",
    candidateId: "candidate_fixture",
    runId: "run_fixture",
    candidateType: "push_copy",
    sourceItemId: "source_ease_en",
    clusterId: "ease",
    language: "en",
    targetMarket: "global",
    ritualMoment: "morning",
    payload: {
      lockScreenTitle: "Begin softly",
      lockScreenBody: "A short Sakinah moment is ready for your day.",
      sourceItemId: "source_ease_en",
    },
    riskFlags,
    automatedChecks: [],
    reviewStatus: "needs_human_review",
    cmsTargetTable: "daily_push_candidates",
    agentVersion: "test",
    promptVersion: "test",
    modelName: "deterministic",
    schemaVersion: 1,
    inputHash: "input",
    outputHash: "output",
    createdAt: "2026-05-22T00:00:00.000Z",
    updatedAt: "2026-05-22T00:00:00.000Z",
  };
}
