import type { AgentCandidate, SourceItem } from "../domain/schemas.js";

export class StructuredOutputClient {
  createDraftCandidate(params: {
    runId: string;
    source: SourceItem;
    language: string;
    index: number;
  }): AgentCandidate {
    const title = params.language === "id" ? "Mulai dengan lembut" : "Begin softly";
    const body =
      params.language === "id"
        ? "Sesi Sakinah singkat siap untuk menemani ibadahmu."
        : "A short Sakinah moment is ready for your day.";

    return {
      candidateId: `${params.runId}-candidate-${params.index + 1}`,
      runId: params.runId,
      clusterId: params.source.clusterId,
      sourceItemId: params.source.id,
      language: params.language,
      lockScreenTitle: title,
      lockScreenBody: body,
      status: "needs_human_review",
      safetyFlags: []
    };
  }
}
