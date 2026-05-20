import type { SourceItem } from "../domain/schemas.js";

export class ContentRepository {
  private readonly sources: SourceItem[];

  constructor(sources = seedSources) {
    this.sources = sources;
  }

  listSourceItems(): SourceItem[] {
    return [...this.sources];
  }

  getSourceItem(id: string): SourceItem | undefined {
    return this.sources.find((source) => source.id === id);
  }
}

export const seedSources: SourceItem[] = [
  {
    id: "source_ease_en",
    clusterId: "ease",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A calm reminder that hardship is held with ease.",
    sourceLabel: "Quran 94:5"
  },
  {
    id: "source_ease_id",
    clusterId: "ease",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "id",
    text: "Pengingat lembut bahwa kesulitan bersama kemudahan.",
    sourceLabel: "Quran 94:5"
  },
  {
    id: "source_gratitude_en",
    clusterId: "gratitude",
    ritualMoment: "after_prayer",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "A short gratitude moment after prayer.",
    sourceLabel: "Reviewed editorial source"
  },
  {
    id: "source_private_rest_en",
    clusterId: "private-rest",
    ritualMoment: "evening",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "Private worship rest copy for sensitive days.",
    sourceLabel: "Reviewed women ibadah source",
    cycleSensitiveHidden: true
  }
];
