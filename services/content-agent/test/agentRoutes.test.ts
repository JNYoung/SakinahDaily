import { AddressInfo } from "node:net";
import { afterEach, describe, expect, it } from "vitest";
import { createContentAgentServer } from "../src/index.js";
import type {
  AgentContentCandidate,
  AgentRun,
  SourceItem,
} from "../src/domain/schemas.js";
import { InMemoryAgentRepository } from "../src/repositories/inMemoryAgentRepository.js";
import {
  ContentRepository,
  seedSources,
} from "../src/repositories/contentRepository.js";

const servers: Array<ReturnType<typeof createContentAgentServer>> = [];

afterEach(async () => {
  await Promise.all(
    servers.splice(0).map(
      (server) =>
        new Promise<void>((resolve, reject) => {
          server.close((error) => (error ? reject(error) : resolve()));
        }),
    ),
  );
});

describe("agent routes", () => {
  it("serves health, creates runs, lists runs, and returns review packets", async () => {
    const client = await startServer();

    await expect(client.get("/health")).resolves.toMatchObject({ ok: true });

    const created = await client.post("/agent-runs", {
      runType: "weekly_preproduction",
      language: "en",
      ritualMoment: "morning",
    });

    expect(created.run.status).toBe("completed");
    expect(created.candidates[0].reviewStatus).toBe("needs_human_review");
    expect(
      created.candidates.map(
        (candidate: AgentContentCandidate) => candidate.reviewStatus,
      ),
    ).not.toContain("approved");
    expect(
      created.candidates.map(
        (candidate: AgentContentCandidate) => candidate.reviewStatus,
      ),
    ).not.toContain("published");

    const listed = await client.get("/agent-runs");
    expect(listed.runs).toHaveLength(1);

    const fetched = await client.get(`/agent-runs/${created.run.runId}`);
    expect(fetched.candidates).toHaveLength(created.candidates.length);

    const packet = await client.get(
      `/agent-runs/${created.run.runId}/review-packet`,
    );
    expect(packet.packetPayload.warning).toContain("Human review required");
  });

  it("re-runs QA and updates candidate flags", async () => {
    const repository = new InMemoryAgentRepository();
    const source = seedSources[0];
    const run = runFixture();
    const candidate = candidateFixture(run.runId, source.id, {
      lockScreenBody: "The ruling is haram for you.",
    });
    await repository.createRun(run);
    await repository.createCandidate(candidate);
    const client = await startServer({ repository });

    const qa = await client.post(
      `/agent-candidates/${candidate.candidateId}/qa`,
      {},
    );

    expect(qa.accepted).toBe(false);
    expect(qa.flags).toContain("fatwa_like_claim");
    await expect(
      repository.getCandidate(candidate.candidateId),
    ).resolves.toMatchObject({
      riskFlags: expect.arrayContaining(["fatwa_like_claim"]),
    });
  });

  it("promotes safe candidates to CMS draft only", async () => {
    const repository = new InMemoryAgentRepository();
    const source = seedSources[0];
    const run = runFixture();
    const candidate = candidateFixture(run.runId, source.id);
    await repository.createRun(run);
    await repository.createCandidate(candidate);
    const client = await startServer({ repository });

    const promotion = await client.post(
      `/agent-candidates/${candidate.candidateId}/promote-to-cms-draft`,
      {},
    );

    expect(promotion).toMatchObject({
      candidateId: candidate.candidateId,
      cmsStatus: "draft",
      autoPublished: false,
      reviewStatus: "promoted_to_cms_draft",
    });
    expect(JSON.stringify(promotion)).not.toContain("published");
    expect(JSON.stringify(promotion)).not.toContain("sent");
  });

  it("blocks unsafe candidate promotion unless forceDraft is true", async () => {
    const repository = new InMemoryAgentRepository();
    const source = seedSources[0];
    const run = runFixture();
    const candidate = candidateFixture(run.runId, source.id, {
      lockScreenBody: "Your dua will definitely be accepted now.",
    });
    await repository.createRun(run);
    await repository.createCandidate(candidate);
    const client = await startServer({ repository });

    const blocked = await client.post(
      `/agent-candidates/${candidate.candidateId}/promote-to-cms-draft`,
      {},
    );
    expect(blocked.statusCode).toBe(409);
    expect(blocked.body.error).toBe("blocking_safety_flags");
    expect(blocked.body.flags).toContain("guaranteed_outcome_claim");

    const forced = await client.post(
      `/agent-candidates/${candidate.candidateId}/promote-to-cms-draft`,
      {
        forceDraft: true,
      },
    );
    expect(forced).toMatchObject({
      cmsStatus: "draft",
      autoPublished: false,
      reviewStatus: "promoted_to_cms_draft",
    });
  });

  it("records feedback events and never sends FCM/APNs", async () => {
    const repository = new InMemoryAgentRepository();
    const source = seedSources[0];
    const run = runFixture();
    const candidate = candidateFixture(run.runId, source.id);
    await repository.createRun(run);
    await repository.createCandidate(candidate);
    const client = await startServer({ repository });

    const feedback = await client.post(
      `/agent-candidates/${candidate.candidateId}/feedback`,
      {
        reviewerRole: "editor",
        decision: "needs_edit",
        reason: "Needs localization polish.",
      },
    );

    expect(feedback.event).toMatchObject({ decision: "needs_edit" });
    await expect(
      repository.listFeedbackEvents(candidate.candidateId),
    ).resolves.toHaveLength(1);
    expect(JSON.stringify(feedback)).not.toMatch(/FCM|APNs|sent|published/i);
  });
});

async function startServer(
  options: {
    repository?: InMemoryAgentRepository;
    sources?: SourceItem[];
  } = {},
) {
  const server = createContentAgentServer({
    agentRepository: options.repository ?? new InMemoryAgentRepository(),
    contentRepository: new ContentRepository(options.sources ?? seedSources),
  });
  servers.push(server);
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const { port } = server.address() as AddressInfo;
  const baseUrl = `http://127.0.0.1:${port}`;
  return {
    get: (path: string) => request(baseUrl, path),
    post: (path: string, body: unknown) =>
      request(baseUrl, path, { method: "POST", body }),
  };
}

async function request(
  baseUrl: string,
  path: string,
  init: { method?: string; body?: unknown } = {},
) {
  const response = await fetch(`${baseUrl}${path}`, {
    method: init.method ?? "GET",
    headers:
      init.body === undefined
        ? undefined
        : { "content-type": "application/json" },
    body: init.body === undefined ? undefined : JSON.stringify(init.body),
  });
  const body = await response.json();
  return response.ok ? body : { statusCode: response.status, body };
}

function runFixture(): AgentRun {
  return {
    id: "run_routes",
    runId: "run_routes",
    runType: "weekly_preproduction",
    status: "completed",
    requestPayload: {},
    summary: "Fixture run.",
    warnings: [],
    dryRun: true,
    createdBy: "test",
    createdAt: "2026-05-22T00:00:00.000Z",
    completedAt: "2026-05-22T00:00:00.000Z",
  };
}

function candidateFixture(
  runId: string,
  sourceItemId: string,
  payloadOverrides: Record<string, unknown> = {},
): AgentContentCandidate {
  return {
    id: "candidate_routes",
    candidateId: "candidate_routes",
    runId,
    candidateType: "push_copy",
    sourceItemId,
    clusterId: "ease",
    language: "en",
    targetMarket: "global",
    ritualMoment: "morning",
    payload: {
      lockScreenTitle: "Begin softly",
      lockScreenBody: "A short Sakinah moment is ready for your day.",
      sourceItemId,
      ...payloadOverrides,
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
