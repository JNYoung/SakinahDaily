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
    text: "A calm reminder that hardship is held with ease."
  },
  {
    id: "source_ease_id",
    clusterId: "ease",
    ritualMoment: "morning",
    status: "published",
    reviewStatus: "approved",
    language: "id",
    text: "Pengingat lembut bahwa kesulitan bersama kemudahan."
  },
  {
    id: "source_private_en",
    clusterId: "private-rest",
    ritualMoment: "evening",
    status: "published",
    reviewStatus: "approved",
    language: "en",
    text: "Private worship rest copy for sensitive days.",
    cycleSensitiveHidden: true
  }
];
