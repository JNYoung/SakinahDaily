import type { IncomingMessage, ServerResponse } from "node:http";
import type { CreateAgentRunRequest } from "../domain/schemas.js";
import { selectCandidateSources } from "../domain/candidateSelector.js";
import { collectSafetyFlags } from "../domain/safetyChecks.js";
import { StructuredOutputClient } from "../llm/structuredOutputClient.js";
import { AgentRunRepository } from "../repositories/agentRunRepository.js";
import { ContentRepository } from "../repositories/contentRepository.js";

export class AgentRunsRoute {
  constructor(
    private readonly runRepository: AgentRunRepository,
    private readonly contentRepository: ContentRepository,
    private readonly outputClient = new StructuredOutputClient()
  ) {}

  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://localhost");

    if (req.method === "POST" && url.pathname === "/agent-runs") {
      const body = await readJson<CreateAgentRunRequest>(req);
      const run = this.createRun(body);
      writeJson(res, 201, run);
      return true;
    }

    if (req.method === "GET" && url.pathname === "/agent-runs") {
      writeJson(res, 200, { runs: this.runRepository.list() });
      return true;
    }

    const runMatch = url.pathname.match(/^\/agent-runs\/([^/]+)$/);
    if (req.method === "GET" && runMatch) {
      const run = this.runRepository.get(runMatch[1]);
      writeJson(res, run ? 200 : 404, run ?? { error: "run_not_found" });
      return true;
    }

    const reviewMatch = url.pathname.match(/^\/agent-runs\/([^/]+)\/review-packet$/);
    if (req.method === "GET" && reviewMatch) {
      const run = this.runRepository.get(reviewMatch[1]);
      writeJson(res, run ? 200 : 404, run ? { run, candidates: run.candidates } : { error: "run_not_found" });
      return true;
    }

    const qaMatch = url.pathname.match(/^\/agent-candidates\/([^/]+)\/qa$/);
    if (req.method === "POST" && qaMatch) {
      const candidate = this.runRepository.findCandidate(qaMatch[1]);
      const source = candidate ? this.contentRepository.getSourceItem(candidate.sourceItemId) : undefined;
      const flags = candidate && source ? collectSafetyFlags(candidate, source) : ["candidate_not_found"];
      writeJson(res, candidate ? 200 : 404, {
        candidateId: qaMatch[1],
        accepted: flags.length === 0,
        flags
      });
      return true;
    }

    const promoteMatch = url.pathname.match(/^\/agent-candidates\/([^/]+)\/promote-to-cms-draft$/);
    if (req.method === "POST" && promoteMatch) {
      const candidate = this.runRepository.findCandidate(promoteMatch[1]);
      writeJson(
        res,
        candidate ? 200 : 404,
        candidate
          ? { candidateId: candidate.candidateId, cmsStatus: "draft", autoPublished: false }
          : { error: "candidate_not_found" }
      );
      return true;
    }

    return false;
  }

  createRun(body: CreateAgentRunRequest = {}) {
    const runId = `run_${Date.now()}_${Math.random().toString(16).slice(2)}`;
    const language = body.language ?? "en";
    const ritualMoment = body.ritualMoment ?? "morning";
    const selected = selectCandidateSources(this.contentRepository.listSourceItems(), {
      language,
      ritualMoment,
      womenLockScreenSafe: true
    });
    const candidates = selected.slice(0, 3).map((source, index) => {
      const candidate = this.outputClient.createDraftCandidate({ runId, source, language, index });
      return { ...candidate, safetyFlags: collectSafetyFlags(candidate, source) };
    });
    return this.runRepository.create({
      runId,
      runType: body.runType ?? "weekly_preproduction",
      status: "completed",
      createdAt: new Date().toISOString(),
      candidates
    });
  }
}

async function readJson<T>(req: IncomingMessage): Promise<T> {
  const chunks: Buffer[] = [];
  for await (const chunk of req) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  if (chunks.length === 0) {
    return {} as T;
  }
  return JSON.parse(Buffer.concat(chunks).toString("utf-8")) as T;
}

function writeJson(res: ServerResponse, statusCode: number, payload: unknown): void {
  res.writeHead(statusCode, { "content-type": "application/json" });
  res.end(JSON.stringify(payload));
}
