import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { AddressInfo } from "node:net";
import { afterEach, describe, expect, it } from "vitest";
import { createContentAgentServer } from "../src/index.js";
import {
  buildContentPack,
  writeScheduledContentPack,
} from "../src/domain/contentPackBuilder.js";
import { FileContentPackStore } from "../src/repositories/fileContentPackStore.js";

const servers: Array<ReturnType<typeof createContentAgentServer>> = [];
const tempDirs: string[] = [];

afterEach(async () => {
  await Promise.all(
    servers.splice(0).map(
      (server) =>
        new Promise<void>((resolve, reject) => {
          server.close((error) => (error ? reject(error) : resolve()));
        }),
    ),
  );
  await Promise.all(
    tempDirs.splice(0).map((dir) => rm(dir, { recursive: true, force: true })),
  );
});

describe("scheduled content pack delivery", () => {
  it("blocks beta packs that do not meet reviewed inventory gates", () => {
    const result = buildContentPack({
      source: reviewedSourceFixture({ sessionCount: 1, duaCount: 5 }),
      profile: "beta",
      now: new Date("2026-05-31T00:00:00.000Z"),
    });

    expect(result.ok).toBe(false);
    expect(result.errors).toContain("dailySessions count 1 is below beta minimum 5");
    expect(result.errors).toContain("duas count 5 is below beta minimum 30");
  });

  it("creates a beta manifest, bundle, and detail index from approved sources", async () => {
    const outputDir = await tempOutputDir();
    const result = await writeScheduledContentPack({
      source: reviewedSourceFixture(),
      outputDir,
      profile: "beta",
      now: new Date("2026-05-31T00:00:00.000Z"),
    });

    expect(result.ok).toBe(true);
    const manifest = result.manifest as {
      bundles: Array<{ sha256: string; bundleId: string }>;
    };
    expect(manifest.bundles).toHaveLength(1);
    expect(manifest.bundles[0]).toMatchObject({
      bundleId: "beta_content_en_global_20260531",
      url: "/bundles/beta_content_en_global_20260531.json",
      required: true,
      schemaVersion: 1,
      language: "en",
      market: "global",
    });

    const bundlePath = path.join(
      outputDir,
      "bundles",
      "beta_content_en_global_20260531.json",
    );
    const bundle = JSON.parse(await readFile(bundlePath, "utf-8"));
    expect(bundle.status).toBe("published");
    expect(bundle.reviewStatus).toBe("approved");
    expect(bundle.payload.dailySessions).toHaveLength(5);
    expect(bundle.payload.duas).toHaveLength(30);
    expect(bundle.payload.dhikrs).toHaveLength(20);
    expect(bundle.payload.quranAyahs).toHaveLength(10);
    expect(
      [
        ...bundle.payload.dailySessions,
        ...bundle.payload.duas,
        ...bundle.payload.dhikrs,
        ...bundle.payload.quranAyahs,
      ].every(
        (item: Record<string, unknown>) =>
          item.status === "published" &&
          item.reviewStatus === "approved" &&
          item.version === 1 &&
          item.reviewedAt === "2026-05-30T00:00:00.000Z",
      ),
    ).toBe(true);

    const detailIndex = JSON.parse(
      await readFile(path.join(outputDir, "detail-bundles.json"), "utf-8"),
    );
    expect(detailIndex.session_beta_1.bundleRef.sha256).toBe(
      manifest.bundles[0].sha256,
    );
  });

  it("serves generated manifest, bundles, and detail-bundle refs", async () => {
    const outputDir = await tempOutputDir();
    await writeScheduledContentPack({
      source: reviewedSourceFixture(),
      outputDir,
      profile: "beta",
      now: new Date("2026-05-31T00:00:00.000Z"),
    });
    const client = await startServer(outputDir);

    const manifest = await client.get("/manifest?language=en&market=global");
    expect(manifest.manifestId).toBe("content_manifest_en_global_20260531");
    expect(manifest.bundles[0].sha256).toMatch(/^[a-f0-9]{64}$/);

    const bundle = await client.get(
      "/bundles/beta_content_en_global_20260531.json",
    );
    expect(bundle.bundleId).toBe("beta_content_en_global_20260531");
    expect(bundle.payload.dailySessions[0].id).toBe("session_beta_1");

    const detail = await client.get(
      "/detail-bundle?bundle_hint=session_beta_1",
    );
    expect(detail.bundleRef.bundleId).toBe("beta_content_en_global_20260531");
  });
});

async function startServer(outputDir: string) {
  const server = createContentAgentServer({
    contentPackStore: new FileContentPackStore(outputDir),
  });
  servers.push(server);
  await new Promise<void>((resolve) => server.listen(0, resolve));
  const { port } = server.address() as AddressInfo;
  const baseUrl = `http://127.0.0.1:${port}`;
  return {
    get: async (targetPath: string) => {
      const response = await fetch(`${baseUrl}${targetPath}`);
      const body = await response.json();
      return response.ok ? body : { statusCode: response.status, body };
    },
  };
}

async function tempOutputDir() {
  const dir = await mkdtemp(path.join(tmpdir(), "sakinah-content-pack-"));
  tempDirs.push(dir);
  return dir;
}

function reviewedSourceFixture(
  counts: {
    sessionCount?: number;
    duaCount?: number;
    dhikrCount?: number;
    quranCount?: number;
  } = {},
) {
  const sessionCount = counts.sessionCount ?? 5;
  const duaCount = counts.duaCount ?? 30;
  const dhikrCount = counts.dhikrCount ?? 20;
  const quranCount = counts.quranCount ?? 10;
  const reviewedAt = "2026-05-30T00:00:00.000Z";
  return {
    quranAyahs: Array.from({ length: quranCount }, (_, index) => {
      const ayah = index + 1;
      return reviewedItem({
        verseKey: `2:${ayah}`,
        surah: 2,
        ayah,
        arabicText: `Approved Quran fixture ${ayah}`,
        translations: { en: `Approved translation fixture ${ayah}` },
        source: `Approved Quran source fixture ${ayah}`,
        audioAssetId: "",
        reviewedAt,
      });
    }),
    duas: Array.from({ length: duaCount }, (_, index) => {
      const id = index + 1;
      return reviewedItem({
        id: `dua_beta_${id}`,
        category: id % 2 === 0 ? "morning" : "evening",
        arabicText: `Approved dua fixture ${id}`,
        transliteration: `Approved dua transliteration ${id}`,
        translations: { en: `Approved dua meaning ${id}` },
        source: `Approved dua source fixture ${id}`,
        isCycleSensitive: false,
        reviewedAt,
      });
    }),
    dhikrs: Array.from({ length: dhikrCount }, (_, index) => {
      const id = index + 1;
      return reviewedItem({
        id: `dhikr_beta_${id}`,
        category: id % 2 === 0 ? "morning" : "gratitude",
        title: { en: `Dhikr ${id}` },
        arabicText: `Approved dhikr fixture ${id}`,
        transliteration: `Approved dhikr transliteration ${id}`,
        translations: { en: `Approved dhikr meaning ${id}` },
        targetCount: 33,
        source: `Approved dhikr source fixture ${id}`,
        reviewedAt,
      });
    }),
    reflections: Array.from({ length: sessionCount }, (_, index) => {
      const id = index + 1;
      return reviewedItem({
        id: `reflection_beta_${id}`,
        prompt: { en: `Approved reflection ${id}` },
        source: `Approved reflection source fixture ${id}`,
        reviewedAt,
      });
    }),
    dailySessions: Array.from({ length: sessionCount }, (_, index) => {
      const id = index + 1;
      return reviewedItem({
        id: `session_beta_${id}`,
        title: { en: `Session ${id}` },
        subtitle: { en: `Approved beta session ${id}` },
        source: `Approved session review packet ${id}`,
        reviewedAt,
        steps: [
          step("intention", "intention"),
          step("quran", "quran", `2:${id}`),
          step("reflection", "reflection", `reflection_beta_${id}`),
          step("dua", "dua", `dua_beta_${id}`),
          step("dhikr", "dhikr", `dhikr_beta_${id}`, 33),
          step("complete", "completion"),
        ],
      });
    }),
    sourceItems: [],
    audioAssets: [],
  };
}

function reviewedItem(fields: Record<string, unknown>) {
  return {
    ...fields,
    status: "published",
    reviewStatus: "approved",
    version: 1,
  };
}

function step(
  id: string,
  type: string,
  contentId?: string,
  targetCount?: number,
) {
  return {
    id,
    type,
    contentId,
    targetCount,
    title: { en: id },
  };
}
