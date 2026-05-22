import { describe, expect, it } from "vitest";
import type {
  AgentContentCandidate,
  AgentFeedbackEvent,
  AgentReviewPacket,
  AgentRun,
} from "../src/domain/schemas.js";
import { InMemoryAgentRepository } from "../src/repositories/inMemoryAgentRepository.js";

describe("InMemoryAgentRepository", () => {
  it("creates and retrieves runs", async () => {
    const repository = new InMemoryAgentRepository();
    const run = runFixture();

    await repository.createRun(run);

    await expect(repository.getRun(run.runId)).resolves.toMatchObject({
      runId: "run_fixture",
      status: "queued",
      runType: "weekly_preproduction",
    });
    await expect(repository.listRuns()).resolves.toHaveLength(1);
  });

  it("persists candidates, review packets, and feedback events", async () => {
    const repository = new InMemoryAgentRepository();
    const run = runFixture();
    const candidate = candidateFixture(run.runId);
    const packet = reviewPacketFixture(run.runId);
    const feedback = feedbackFixture(candidate.candidateId);

    await repository.createRun(run);
    await repository.createCandidate(candidate);
    await repository.createReviewPacket(packet);
    await repository.createFeedbackEvent(feedback);

    await expect(
      repository.getCandidate(candidate.candidateId),
    ).resolves.toMatchObject({
      candidateId: "candidate_fixture",
      reviewStatus: "needs_human_review",
    });
    await expect(
      repository.listCandidatesByRun(run.runId),
    ).resolves.toHaveLength(1);
    await expect(
      repository.getReviewPacketByRun(run.runId),
    ).resolves.toMatchObject({
      runId: run.runId,
      status: "needs_human_review",
    });
    await expect(
      repository.listFeedbackEvents(candidate.candidateId),
    ).resolves.toMatchObject([
      { decision: "needs_edit", reason: "Tone needs a human pass." },
    ]);
  });

  it("updates run and candidate review status without approving content", async () => {
    const repository = new InMemoryAgentRepository();
    const run = runFixture();
    const candidate = candidateFixture(run.runId);

    await repository.createRun(run);
    await repository.createCandidate(candidate);
    await repository.updateRunStatus(run.runId, "completed");
    await repository.updateCandidateReviewStatus(
      candidate.candidateId,
      "promoted_to_cms_draft",
    );

    await expect(repository.getRun(run.runId)).resolves.toMatchObject({
      status: "completed",
    });
    await expect(
      repository.getCandidate(candidate.candidateId),
    ).resolves.toMatchObject({
      reviewStatus: "promoted_to_cms_draft",
    });
  });
});

function runFixture(): AgentRun {
  return {
    id: "run_fixture",
    runId: "run_fixture",
    runType: "weekly_preproduction",
    status: "queued",
    requestPayload: { language: "en" },
    summary: "",
    warnings: [],
    dryRun: true,
    createdBy: "test",
    createdAt: "2026-05-22T00:00:00.000Z",
  };
}

function candidateFixture(runId: string): AgentContentCandidate {
  return {
    id: "candidate_fixture",
    candidateId: "candidate_fixture",
    runId,
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
    riskFlags: [],
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

function reviewPacketFixture(runId: string): AgentReviewPacket {
  return {
    id: "packet_fixture",
    runId,
    title: "Weekly review packet",
    summary: "Review one candidate.",
    packetPayload: {
      warning:
        "Agent output is draft only. Human review required before approval or publishing.",
    },
    reviewerChecklist: ["source reference correct"],
    status: "needs_human_review",
    createdAt: "2026-05-22T00:00:00.000Z",
    updatedAt: "2026-05-22T00:00:00.000Z",
  };
}

function feedbackFixture(candidateId: string): AgentFeedbackEvent {
  return {
    id: "feedback_fixture",
    candidateId,
    reviewerRole: "editor",
    decision: "needs_edit",
    reason: "Tone needs a human pass.",
    createdAt: "2026-05-22T00:00:00.000Z",
  };
}
