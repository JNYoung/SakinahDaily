import { describe, expect, it } from "vitest";
import type {
  AgentContentCandidate,
  SourceItem,
} from "../src/domain/schemas.js";
import { selectCandidateSources } from "../src/domain/candidateSelector.js";
import { collectSafetyFlags } from "../src/domain/safetyChecks.js";
import { runCandidateQa } from "../src/domain/qaReview.js";
import { seedSources } from "../src/repositories/contentRepository.js";
import { InMemoryAgentRepository } from "../src/repositories/inMemoryAgentRepository.js";
import { ContentRepository } from "../src/repositories/contentRepository.js";
import { AgentRunWorkflow } from "../src/domain/agentRunWorkflow.js";

describe("guardrails", () => {
  it("selects only approved source items", () => {
    const sources: SourceItem[] = [
      ...seedSources,
      {
        id: "draft",
        clusterId: "draft",
        ritualMoment: "morning",
        status: "draft",
        reviewStatus: "draft",
        language: "en",
        text: "Draft",
      },
    ];

    const selected = selectCandidateSources(sources, {
      language: "en",
      ritualMoment: "morning",
    });

    expect(selected.map((item) => item.id)).not.toContain("draft");
  });

  it("blocks women/cycle-sensitive lock-screen copy", () => {
    const candidate = candidateWith("Private", "Menstruating cycle reminder");
    const flags = collectSafetyFlags(candidate, seedSources[0]).riskFlags;

    expect(flags).toContain("cycle_sensitive_lock_screen");
  });

  it("blocks guaranteed outcome claims", () => {
    const candidate = candidateWith(
      "Guaranteed",
      "Your dua will definitely be accepted now.",
    );

    expect(collectSafetyFlags(candidate, seedSources[0]).riskFlags).toContain(
      "guaranteed_outcome_claim",
    );
  });

  it("blocks missing source references and long lock-screen copy", () => {
    const candidate = {
      ...candidateWith(
        "A very long title that is intentionally too long for a lock screen",
        "b".repeat(121),
      ),
      sourceItemId: "",
      payload: {
        lockScreenTitle:
          "A very long title that is intentionally too long for a lock screen",
        lockScreenBody: "b".repeat(121),
      },
    };

    const flags = collectSafetyFlags(candidate, seedSources[0]).riskFlags;

    expect(flags).toContain("missing_source_reference");
    expect(flags).toContain("lock_screen_length");
  });

  it("blocks shaming tone", () => {
    const candidate = candidateWith(
      "Reminder",
      "Do not be lazy with remembrance.",
    );

    expect(collectSafetyFlags(candidate, seedSources[0]).riskFlags).toContain(
      "shaming_tone",
    );
  });

  it("blocks fatwa-like claims", () => {
    const candidate = candidateWith("Ruling", "The ruling is haram for you.");

    expect(collectSafetyFlags(candidate, seedSources[0]).riskFlags).toContain(
      "fatwa_like_claim",
    );
  });

  it("blocks full Quran-like Arabic on lock screen", () => {
    const candidate = candidateWith("Reminder", "ا".repeat(121));

    expect(collectSafetyFlags(candidate, seedSources[0]).riskFlags).toContain(
      "full_quran_text_lock_screen",
    );
  });

  it("blocks unapproved and invented sources", () => {
    const unapproved: SourceItem = {
      id: "source_draft",
      clusterId: "draft",
      ritualMoment: "morning",
      status: "draft",
      reviewStatus: "draft",
      language: "en",
      text: "Draft",
    };

    expect(
      collectSafetyFlags(
        candidateWith("Draft", "Body", unapproved.id),
        unapproved,
      ).riskFlags,
    ).toContain("source_not_approved");
    expect(
      runCandidateQa(
        candidateWith("Missing", "Body", "invented_source"),
        undefined,
      ).riskFlags,
    ).toContain("invented_source_id");
  });

  it("blocks unsupported language, auto-publish, FCM/APNs, and generated source markers", () => {
    const candidate = {
      ...candidateWith("Ready", "A calm moment."),
      language: "fr",
      payload: {
        lockScreenTitle: "Ready",
        lockScreenBody: "A calm moment.",
        sourceItemId: seedSources[0].id,
        cmsStatus: "published",
        sendFcm: true,
        generatedQuranText: "[GENERATED_QURAN]",
        generatedHadithText: "[GENERATED_HADITH]",
      },
    };

    const flags = collectSafetyFlags(candidate, seedSources[0]).riskFlags;

    expect(flags).toEqual(
      expect.arrayContaining([
        "unsupported_language",
        "auto_publish_attempt",
        "fcm_apns_send_attempt",
        "generated_quran_marker",
        "generated_hadith_marker",
      ]),
    );
  });

  it("creates deterministic dry-run candidates for review", async () => {
    const workflow = new AgentRunWorkflow({
      agentRepository: new InMemoryAgentRepository(),
      contentRepository: new ContentRepository(),
    });
    const run = await workflow.execute({
      language: "en",
      ritualMoment: "morning",
    });

    expect(run.run.status).toBe("completed");
    expect(run.candidates[0].reviewStatus).toBe("needs_human_review");
    expect(run.candidates[0].riskFlags).toEqual([]);
  });
});

function candidateWith(
  title: string,
  body: string,
  sourceItemId = seedSources[0].id,
): AgentContentCandidate {
  return {
    id: "candidate",
    candidateId: "candidate",
    runId: "run",
    candidateType: "push_copy",
    clusterId: "ease",
    sourceItemId,
    language: "en",
    targetMarket: "global",
    ritualMoment: "morning",
    payload: {
      lockScreenTitle: title,
      lockScreenBody: body,
      sourceItemId,
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
