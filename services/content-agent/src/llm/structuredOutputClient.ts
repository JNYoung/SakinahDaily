import type { AgentCandidate, SourceItem } from "../domain/schemas.js";

export class StructuredOutputClient {
  createDraftCandidate(params: {
    runId: string;
    source: SourceItem;
    language: string;
    index: number;
  }): AgentCandidate {
    const title =
      params.source.contentKind === "dua"
        ? params.language === "id"
          ? "Doa bersumber siap"
          : "A sourced dua is ready"
        : params.language === "id"
          ? "Mulai dengan lembut"
          : "Begin softly";
    const body = params.source.text;
    const prayerContent =
      params.source.contentKind === "dua" &&
      params.source.arabicText &&
      params.source.transliteration &&
      params.source.meaningSummary &&
      params.source.sourceUrl
        ? {
            arabicText: params.source.arabicText,
            transliteration: params.source.transliteration,
            meaningSummary: params.source.meaningSummary,
            sourceLabel: params.source.sourceLabel,
            sourceUrl: params.source.sourceUrl
          }
        : undefined;

    return {
      candidateId: `${params.runId}_candidate_${params.index + 1}`,
      runId: params.runId,
      clusterId: params.source.clusterId,
      sourceItemId: params.source.id,
      sourceLabel: params.source.sourceLabel,
      language: params.language,
      lockScreenTitle: title,
      lockScreenBody: body,
      prayerContent,
      status: "needs_human_review",
      safetyFlags: []
    };
  }
}
