import { describe, expect, it } from "vitest";
import { AgentRunWorkflow } from "../src/domain/agentRunWorkflow.js";
import { InMemoryAgentRepository } from "../src/repositories/inMemoryAgentRepository.js";
import {
  ContentRepository,
  seedSources,
} from "../src/repositories/contentRepository.js";

describe("AgentRunWorkflow", () => {
  it("weekly_preproduction creates draft candidates and a review packet", async () => {
    const repository = new InMemoryAgentRepository();
    const workflow = new AgentRunWorkflow({
      agentRepository: repository,
      contentRepository: new ContentRepository(seedSources),
    });

    const result = await workflow.execute({
      runType: "weekly_preproduction",
      language: "en",
      ritualMoment: "morning",
      createdBy: "codex-test",
    });

    expect(result.run.status).toBe("completed");
    expect(result.candidates.length).toBeGreaterThan(0);
    expect(
      result.candidates.every(
        (candidate) => candidate.reviewStatus === "needs_human_review",
      ),
    ).toBe(true);
    expect(
      result.candidates.map((candidate) => candidate.reviewStatus),
    ).not.toContain("approved");
    expect(
      result.candidates.map((candidate) => candidate.reviewStatus),
    ).not.toContain("published");
    expect(result.reviewPacket.packetPayload.warning).toContain(
      "Human review required",
    );
    await expect(
      repository.getReviewPacketByRun(result.run.runId),
    ).resolves.toBeDefined();
  });

  it("cluster_production only drafts candidates for the requested cluster", async () => {
    const repository = new InMemoryAgentRepository();
    const workflow = new AgentRunWorkflow({
      agentRepository: repository,
      contentRepository: new ContentRepository(seedSources),
    });

    const result = await workflow.execute({
      runType: "cluster_production",
      clusterId: "ease",
      language: "en",
      ritualMoment: "morning",
    });

    expect(result.candidates.length).toBeGreaterThan(0);
    expect(
      result.candidates.every((candidate) => candidate.clusterId === "ease"),
    ).toBe(true);
  });

  it("qa_only re-runs QA for stored candidates", async () => {
    const repository = new InMemoryAgentRepository();
    const workflow = new AgentRunWorkflow({
      agentRepository: repository,
      contentRepository: new ContentRepository(seedSources),
    });
    const first = await workflow.execute({
      runType: "weekly_preproduction",
      language: "en",
      ritualMoment: "morning",
    });
    const candidateId = first.candidates[0].candidateId;

    const qaRun = await workflow.execute({
      runType: "qa_only",
      candidateIds: [candidateId],
      language: "en",
    });

    expect(qaRun.run.status).toBe("completed");
    expect(qaRun.candidates).toHaveLength(1);
    expect(qaRun.candidates[0].candidateId).toBe(candidateId);
    expect(qaRun.candidates[0].automatedChecks.length).toBeGreaterThan(0);
  });
});
