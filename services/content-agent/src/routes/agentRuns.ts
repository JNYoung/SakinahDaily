import type { IncomingMessage, ServerResponse } from "node:http";
import type { AgentRepository } from "../repositories/agentRepository.js";
import { AgentRunWorkflow } from "../domain/agentRunWorkflow.js";
import type { CreateAgentRunRequest } from "../domain/schemas.js";
import { readJson, writeJson } from "./http.js";

export class AgentRunsRoute {
  constructor(
    private readonly agentRepository: AgentRepository,
    private readonly workflow: AgentRunWorkflow,
  ) {}

  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://localhost");

    if (req.method === "POST" && url.pathname === "/agent-runs") {
      const body = await readJson<CreateAgentRunRequest>(req);
      const result = await this.workflow.execute(body);
      writeJson(res, 201, result);
      return true;
    }

    if (req.method === "GET" && url.pathname === "/agent-runs") {
      writeJson(res, 200, { runs: await this.agentRepository.listRuns() });
      return true;
    }

    const cancelMatch = url.pathname.match(/^\/agent-runs\/([^/]+)\/cancel$/);
    if (req.method === "POST" && cancelMatch) {
      const run = await this.agentRepository.updateRunStatus(
        cancelMatch[1],
        "cancelled",
        {
          completedAt: new Date().toISOString(),
        },
      );
      writeJson(
        res,
        run ? 200 : 404,
        run ? { run } : { error: "run_not_found" },
      );
      return true;
    }

    const runMatch = url.pathname.match(/^\/agent-runs\/([^/]+)$/);
    if (req.method === "GET" && runMatch) {
      const run = await this.agentRepository.getRun(runMatch[1]);
      const candidates = run
        ? await this.agentRepository.listCandidatesByRun(run.runId)
        : [];
      writeJson(
        res,
        run ? 200 : 404,
        run ? { run, candidates } : { error: "run_not_found" },
      );
      return true;
    }

    return false;
  }
}
