import type { AddressInfo } from "node:net";
import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { createContentAgentServer } from "../src/index.js";

describe("Content Agent HTTP routes", () => {
  let server: ReturnType<typeof createContentAgentServer>;
  let baseUrl: string;

  beforeEach(async () => {
    server = createContentAgentServer();
    await new Promise<void>((resolve) => server.listen(0, resolve));
    const address = server.address() as AddressInfo;
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  afterEach(async () => {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => (error ? reject(error) : resolve()));
    });
  });

  it("creates, reads, reviews, QAs, and promotes a candidate to CMS draft only", async () => {
    const createResponse = await fetch(`${baseUrl}/agent-runs`, {
      method: "POST",
      body: JSON.stringify({ language: "en", ritualMoment: "morning" })
    });
    expect(createResponse.status).toBe(201);
    const run = (await createResponse.json()) as {
      runId: string;
      candidates: Array<{ candidateId: string; status: string }>;
    };
    expect(run.candidates[0].status).toBe("needs_human_review");

    const listResponse = await fetch(`${baseUrl}/agent-runs`);
    expect(listResponse.status).toBe(200);
    expect((await listResponse.json()) as unknown).toMatchObject({ runs: [expect.objectContaining({ runId: run.runId })] });

    const getResponse = await fetch(`${baseUrl}/agent-runs/${run.runId}`);
    expect(getResponse.status).toBe(200);

    const reviewResponse = await fetch(`${baseUrl}/agent-runs/${run.runId}/review-packet`);
    expect(reviewResponse.status).toBe(200);
    expect((await reviewResponse.json()) as unknown).toMatchObject({
      candidates: expect.arrayContaining([
        expect.objectContaining({ candidateId: run.candidates[0].candidateId })
      ])
    });

    const qaResponse = await fetch(`${baseUrl}/agent-candidates/${run.candidates[0].candidateId}/qa`, {
      method: "POST"
    });
    expect(qaResponse.status).toBe(200);
    expect(await qaResponse.json()).toMatchObject({ accepted: true, flags: [] });

    const promoteResponse = await fetch(
      `${baseUrl}/agent-candidates/${run.candidates[0].candidateId}/promote-to-cms-draft`,
      { method: "POST" }
    );
    expect(promoteResponse.status).toBe(200);
    expect(await promoteResponse.json()).toMatchObject({
      promoted: true,
      cmsStatus: "draft",
      autoPublished: false,
      fcmSent: false
    });
  });
});
