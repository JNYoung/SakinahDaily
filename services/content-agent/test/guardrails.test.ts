import { describe, expect, it } from "vitest";
import type { AgentCandidate, SourceItem } from "../src/domain/schemas.js";
import { isAgentCandidate } from "../src/domain/schemas.js";
import { selectCandidateSources } from "../src/domain/candidateSelector.js";
import { collectSafetyFlags } from "../src/domain/safetyChecks.js";
import { seedSources } from "../src/repositories/contentRepository.js";
import { ContentRepository } from "../src/repositories/contentRepository.js";
import { AgentRunRepository } from "../src/repositories/agentRunRepository.js";
import { AgentRunsRoute } from "../src/routes/agentRuns.js";

describe("Content Agent guardrails", () => {
  it("selects approved source items only", () => {
    const sources: SourceItem[] = [
      ...seedSources,
      {
        id: "draft_source",
        clusterId: "draft",
        ritualMoment: "morning",
        status: "draft",
        reviewStatus: "draft",
        language: "en",
        text: "Draft copy",
        sourceLabel: "Draft"
      }
    ];

    const selected = selectCandidateSources(sources, {
      language: "en",
      ritualMoment: "morning"
    });

    expect(selected.map((source) => source.id)).not.toContain("draft_source");
  });

  it("falls back to English when requested language has no source", () => {
    const selected = selectCandidateSources(seedSources, {
      language: "ar",
      ritualMoment: "after_prayer"
    });

    expect(selected.length).toBeGreaterThanOrEqual(1);
    expect(selected.every((source) => source.language === "en")).toBe(true);
  });

  it("applies cluster cooldown", () => {
    const selected = selectCandidateSources([seedSources[0]], {
      language: "en",
      ritualMoment: "morning",
      recentClusterIds: ["ease"]
    });

    expect(selected).toHaveLength(0);
  });

  it("blocks women/cycle-sensitive lock-screen source items", () => {
    const selected = selectCandidateSources([seedSources.find((source) => source.id === "source_private_rest_en")!], {
      language: "en",
      ritualMoment: "evening",
      womenLockScreenSafe: true
    });

    expect(selected).toHaveLength(0);
  });

  it("flags lock-screen length violations", () => {
    const candidate = candidateWith("A".repeat(60), "Short body");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("lock_screen_length");
  });

  it("flags cycle-sensitive lock-screen terms", () => {
    const candidate = candidateWith("Private", "Menstruating cycle reminder");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("cycle_sensitive_lock_screen");
  });

  it("flags full Quran text on lock screen", () => {
    const candidate = candidateWith(
      "Listen",
      "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ الرَّحْمَٰنِ الرَّحِيمِ مَالِكِ يَوْمِ الدِّينِ"
    );

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("full_quran_text_lock_screen");
  });

  it("flags guaranteed outcome claims", () => {
    const candidate = candidateWith("Guaranteed", "Your dua will definitely be accepted now.");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("guaranteed_outcome_claim");
  });

  it("flags shaming tone", () => {
    const candidate = candidateWith("Reminder", "You are a bad Muslim if you rest.");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("shaming_tone");
  });

  it("flags fatwa-like claims", () => {
    const candidate = candidateWith("Ruling", "The ruling is haram for you.");

    expect(collectSafetyFlags(candidate, seedSources[0])).toContain("fatwa_like_claim");
  });

  it("creates schema-valid deterministic dry-run candidates for human review", () => {
    const route = new AgentRunsRoute(new AgentRunRepository(), new ContentRepository());
    const run = route.createRun({ language: "en", ritualMoment: "morning" });

    expect(run.status).toBe("completed");
    expect(run.candidates.length).toBeGreaterThanOrEqual(3);
    expect(run.candidates[0].status).toBe("needs_human_review");
    expect(run.candidates[0].safetyFlags).toEqual([]);
    expect(isAgentCandidate(run.candidates[0])).toBe(true);
  });

  it("ships source-backed dua seed content for review", () => {
    const duaSources = seedSources.filter((source) => source.contentKind === "dua");

    expect(duaSources).toHaveLength(5);
    for (const source of duaSources) {
      expect(source.status).toBe("published");
      expect(source.reviewStatus).toBe("approved");
      expect(source.sourceLabel).toMatch(/^Quran /);
      expect(source.sourceUrl).toMatch(/^https:\/\/quran\.com\//);
      expect(source.arabicText).toBeTruthy();
      expect(source.transliteration).toBeTruthy();
      expect(source.meaningSummary).toBeTruthy();
    }
  });

  it("adds dua content to candidates without placing Quran text on lock screen", () => {
    const route = new AgentRunsRoute(new AgentRunRepository(), new ContentRepository());
    const run = route.createRun({ language: "en", ritualMoment: "morning" });
    const duaCandidate = run.candidates.find((candidate) => candidate.prayerContent);

    expect(duaCandidate).toBeTruthy();
    expect(duaCandidate!.status).toBe("needs_human_review");
    expect(duaCandidate!.lockScreenBody).not.toMatch(/[\u0600-\u06FF]{10,}/);
    expect(duaCandidate!.prayerContent).toMatchObject({
      sourceLabel: expect.stringMatching(/^Quran /),
      sourceUrl: expect.stringMatching(/^https:\/\/quran\.com\//)
    });
  });
});

function candidateWith(title: string, body: string): AgentCandidate {
  return {
    candidateId: "candidate",
    runId: "run",
    clusterId: "ease",
    sourceItemId: seedSources[0].id,
    sourceLabel: seedSources[0].sourceLabel,
    language: "en",
    lockScreenTitle: title,
    lockScreenBody: body,
    status: "needs_human_review",
    safetyFlags: []
  };
}
