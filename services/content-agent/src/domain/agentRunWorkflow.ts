import type { AgentRepository } from "../repositories/agentRepository.js";
import { ContentRepository } from "../repositories/contentRepository.js";
import { StructuredOutputClient } from "../llm/structuredOutputClient.js";
import { selectCandidateSources } from "./candidateSelector.js";
import { runCandidateQa } from "./qaReview.js";
import { buildReviewPacket } from "./reviewPacket.js";
import type {
  AgentContentCandidate,
  AgentRun,
  CreateAgentRunRequest,
  SourceItem,
  WorkflowResult,
} from "./schemas.js";

let runCounter = 0;

export class AgentRunWorkflow {
  constructor(
    private readonly deps: {
      agentRepository: AgentRepository;
      contentRepository: ContentRepository;
      outputClient?: StructuredOutputClient;
      now?: () => Date;
    },
  ) {}

  async execute(request: CreateAgentRunRequest = {}): Promise<WorkflowResult> {
    const runType = request.runType ?? "weekly_preproduction";
    const nowIso = this.nowIso();
    const runId = `run_${runType}_${++runCounter}`;
    const run: AgentRun = {
      id: runId,
      runId,
      runType,
      status: "queued",
      requestPayload: request as Record<string, unknown>,
      summary: "",
      warnings: [],
      dryRun: request.dryRun ?? true,
      createdBy: request.createdBy ?? "local",
      createdAt: nowIso,
    };

    await this.deps.agentRepository.createRun(run);
    await this.deps.agentRepository.updateRunStatus(runId, "running", {
      startedAt: nowIso,
    });

    try {
      const candidates =
        runType === "qa_only"
          ? await this.executeQaOnly(runId, request)
          : await this.executeProductionRun(runId, request, nowIso);
      const selectedSources = candidates.map((candidate) => ({
        sourceItemId: candidate.sourceItemId,
        clusterId: candidate.clusterId,
        language: candidate.language,
      }));
      const completedAt = this.nowIso();
      const updatedRun =
        (await this.deps.agentRepository.updateRunStatus(runId, "completed", {
          completedAt,
          summary: `Created ${candidates.length} candidate(s) for human review.`,
        })) ?? run;
      const reviewPacket = buildReviewPacket({
        run: updatedRun,
        candidates,
        selectedSources,
        nowIso: completedAt,
      });
      await this.deps.agentRepository.createReviewPacket(reviewPacket);
      return { run: updatedRun, candidates, reviewPacket };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Unknown workflow failure.";
      const failedRun =
        (await this.deps.agentRepository.updateRunStatus(runId, "failed", {
          completedAt: this.nowIso(),
          errorMessage: message,
        })) ?? run;
      const reviewPacket = buildReviewPacket({
        run: failedRun,
        candidates: [],
        selectedSources: [],
        nowIso: failedRun.completedAt,
      });
      await this.deps.agentRepository.createReviewPacket(reviewPacket);
      return { run: failedRun, candidates: [], reviewPacket };
    }
  }

  private async executeProductionRun(
    runId: string,
    request: CreateAgentRunRequest,
    nowIso: string,
  ): Promise<AgentContentCandidate[]> {
    const language = request.language ?? "en";
    const targetMarket = request.targetMarket ?? "global";
    const ritualMoment = request.ritualMoment ?? "morning";
    const sources = selectCandidateSources(
      this.deps.contentRepository.listSourceItems(),
      {
        language,
        ritualMoment,
        womenLockScreenSafe: true,
      },
    ).filter((source) =>
      request.clusterId ? source.clusterId === request.clusterId : true,
    );
    const outputClient = this.deps.outputClient ?? new StructuredOutputClient();
    const candidates: AgentContentCandidate[] = [];

    for (const [index, source] of sources.slice(0, 3).entries()) {
      const draft = outputClient.createDraftCandidate({
        runId,
        source,
        language,
        targetMarket,
        index,
        nowIso,
      });
      const checked = applyQa(draft, source);
      await this.deps.agentRepository.createCandidate(checked);
      candidates.push(checked);
    }

    return candidates;
  }

  private async executeQaOnly(
    _runId: string,
    request: CreateAgentRunRequest,
  ): Promise<AgentContentCandidate[]> {
    const candidates: AgentContentCandidate[] = [];
    for (const candidateId of request.candidateIds ?? []) {
      const candidate =
        await this.deps.agentRepository.getCandidate(candidateId);
      if (!candidate) {
        continue;
      }
      const source = this.deps.contentRepository.getSourceItem(
        candidate.sourceItemId,
      );
      const updated = applyQa(candidate, source);
      await this.deps.agentRepository.updateCandidate(updated);
      candidates.push(updated);
    }
    return candidates;
  }

  private nowIso(): string {
    return (this.deps.now?.() ?? new Date()).toISOString();
  }
}

function applyQa(
  candidate: AgentContentCandidate,
  source: SourceItem | undefined,
): AgentContentCandidate {
  const qa = runCandidateQa(candidate, source);
  return {
    ...candidate,
    riskFlags: qa.riskFlags,
    automatedChecks: qa.automatedChecks,
    reviewStatus: "needs_human_review",
    updatedAt: new Date().toISOString(),
  };
}
