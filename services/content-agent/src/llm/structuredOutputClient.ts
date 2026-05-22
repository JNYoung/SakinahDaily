import { createHash } from "node:crypto";
import type { AgentContentCandidate, SourceItem } from "../domain/schemas.js";

export class StructuredOutputClient {
  createDraftCandidate(params: {
    runId: string;
    source: SourceItem;
    language: string;
    targetMarket: string;
    index: number;
    nowIso: string;
  }): AgentContentCandidate {
    const title =
      params.language === "id" ? "Mulai dengan lembut" : "Begin softly";
    const body =
      params.language === "id"
        ? "Sesi Sakinah singkat siap untuk menemani ibadahmu."
        : "A short Sakinah moment is ready for your day.";
    const payload = {
      lockScreenTitle: title,
      lockScreenBody: body,
      sourceItemId: params.source.id,
    };
    const candidateId = `${params.runId}-candidate-${params.index + 1}`;

    return {
      id: candidateId,
      candidateId,
      runId: params.runId,
      candidateType: "push_copy",
      sourceItemId: params.source.id,
      clusterId: params.source.clusterId,
      language: params.language,
      targetMarket: params.targetMarket,
      ritualMoment: params.source.ritualMoment,
      payload,
      riskFlags: [],
      automatedChecks: [],
      reviewStatus: "needs_human_review",
      cmsTargetTable: "daily_push_candidates",
      agentVersion: "content-agent-local-v1",
      promptVersion: "weekly-preproduction-v1",
      modelName: "deterministic-local",
      schemaVersion: 1,
      inputHash: sha256(
        JSON.stringify({ source: params.source, language: params.language }),
      ),
      outputHash: sha256(JSON.stringify(payload)),
      createdAt: params.nowIso,
      updatedAt: params.nowIso,
    };
  }
}

function sha256(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}
