import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

export type ContentPackProfile = "dev" | "beta";

export interface ContentPackBuildRequest {
  source: Record<string, unknown>;
  profile?: ContentPackProfile;
  language?: string;
  market?: string;
  schemaVersion?: number;
  now?: Date;
}

export interface ContentPackBuildResult {
  ok: boolean;
  errors: string[];
  warnings: string[];
  manifest?: Record<string, unknown>;
  bundle?: Record<string, unknown>;
  detailIndex?: Record<string, unknown>;
  bundleRawJson?: string;
}

export interface ContentPackWriteRequest extends ContentPackBuildRequest {
  outputDir: string;
}

type ContentItem = Record<string, unknown>;

const betaGates = {
  dailySessions: { min: 5, max: 7 },
  duas: { min: 30, max: 50 },
  dhikrs: { min: 20, max: 30 },
  quranAyahs: { min: 10, max: 20 },
};

export function buildContentPack(
  request: ContentPackBuildRequest,
): ContentPackBuildResult {
  const profile = request.profile ?? "dev";
  const language = request.language ?? "en";
  const market = request.market ?? "global";
  const schemaVersion = request.schemaVersion ?? 1;
  const now = request.now ?? new Date();
  const dateStamp = compactDate(now);
  const errors: string[] = [];
  const warnings: string[] = [];
  const payload = extractPayload(request.source);

  validateApproval(payload, errors);
  validateReferences(payload, errors);
  if (profile === "beta") {
    validateBetaInventory(payload, errors, warnings);
  } else {
    validateDevInventory(payload, warnings);
  }

  if (errors.length > 0) {
    return { ok: false, errors, warnings };
  }

  const bundleId = `${profile}_content_${language}_${market}_${dateStamp}`;
  const bundle = {
    bundleId,
    bundleType: "home_bundle",
    schemaVersion,
    language,
    market,
    status: "published",
    reviewStatus: "approved",
    sourceCorpusVersions: sourceCorpusVersions(request.source),
    payload,
  };
  const bundleRawJson = `${JSON.stringify(bundle, null, 2)}\n`;
  const sha256 = createHash("sha256").update(bundleRawJson).digest("hex");
  const bundleRef = {
    bundleId,
    bundleType: "home_bundle",
    url: `/bundles/${bundleId}.json`,
    sha256,
    sizeBytes: Buffer.byteLength(bundleRawJson),
    required: true,
    schemaVersion,
    language,
    market,
  };
  const manifest = {
    manifestId: `content_manifest_${language}_${market}_${dateStamp}`,
    schemaVersion,
    language,
    market,
    generatedAt: now.toISOString(),
    expiresAt: new Date(now.getTime() + 24 * 60 * 60 * 1000).toISOString(),
    sourceCorpusVersions: sourceCorpusVersions(request.source),
    revokedContentIds: [],
    fallback: { allowStale: true, maxStaleSeconds: 604800 },
    bundles: [bundleRef],
  };
  const detailIndex = buildDetailIndex(payload, bundleRef);

  return {
    ok: true,
    errors,
    warnings,
    manifest,
    bundle,
    detailIndex,
    bundleRawJson,
  };
}

export async function writeScheduledContentPack(
  request: ContentPackWriteRequest,
): Promise<ContentPackBuildResult> {
  const result = buildContentPack(request);
  await mkdir(path.join(request.outputDir, "bundles"), { recursive: true });
  await writeFile(
    path.join(request.outputDir, "audit-report.json"),
    `${JSON.stringify(
      {
        ok: result.ok,
        errors: result.errors,
        warnings: result.warnings,
        generatedAt: (request.now ?? new Date()).toISOString(),
      },
      null,
      2,
    )}\n`,
  );
  if (!result.ok || !result.manifest || !result.bundleRawJson) {
    return result;
  }
  const bundleId = result.bundle?.bundleId as string;
  await writeFile(
    path.join(request.outputDir, "manifest.json"),
    `${JSON.stringify(result.manifest, null, 2)}\n`,
  );
  await writeFile(
    path.join(request.outputDir, "bundles", `${bundleId}.json`),
    result.bundleRawJson,
  );
  await writeFile(
    path.join(request.outputDir, "detail-bundles.json"),
    `${JSON.stringify(result.detailIndex ?? {}, null, 2)}\n`,
  );
  return result;
}

export async function readContentPackSource(
  sourcePath: string,
): Promise<Record<string, unknown>> {
  return JSON.parse(await readFile(sourcePath, "utf-8")) as Record<
    string,
    unknown
  >;
}

function extractPayload(source: Record<string, unknown>) {
  return {
    dailySessions: approvedItems(
      listFrom(source, "dailySessions", "sessions"),
    ),
    duas: approvedItems(listFrom(source, "duas")),
    dhikrs: approvedItems(listFrom(source, "dhikrs")),
    sourceItems: approvedItems(listFrom(source, "sourceItems")),
    quranAyahs: approvedItems(listFrom(source, "quranAyahs")),
    reflections: approvedItems(listFrom(source, "reflections")),
    audioAssets: listFrom(source, "audioAssets").filter(
      (item) => item.approved === true,
    ),
  };
}

function listFrom(
  source: Record<string, unknown>,
  key: string,
  alias?: string,
): ContentItem[] {
  const raw = source[key] ?? (alias ? source[alias] : undefined);
  return Array.isArray(raw)
    ? raw.filter((item): item is ContentItem => isObject(item))
    : [];
}

function approvedItems(items: ContentItem[]): ContentItem[] {
  return items.filter(
    (item) =>
      item.status === "published" && item.reviewStatus === "approved",
  );
}

function validateApproval(
  payload: ReturnType<typeof extractPayload>,
  errors: string[],
) {
  for (const [collection, items] of Object.entries(payload)) {
    if (collection === "audioAssets") {
      continue;
    }
    for (const item of items) {
      if (item.status !== "published" || item.reviewStatus !== "approved") {
        errors.push(`${collection} includes unapproved item ${itemId(item)}`);
      }
    }
  }
}

function validateBetaInventory(
  payload: ReturnType<typeof extractPayload>,
  errors: string[],
  warnings: string[],
) {
  for (const [collection, gate] of Object.entries(betaGates)) {
    const count = payload[collection as keyof typeof betaGates].length;
    if (count < gate.min) {
      errors.push(
        `${collection} count ${count} is below beta minimum ${gate.min}`,
      );
    }
    if (count > gate.max) {
      warnings.push(
        `${collection} count ${count} is above beta target ${gate.max}`,
      );
    }
  }

  for (const collection of [
    "dailySessions",
    "duas",
    "dhikrs",
    "quranAyahs",
    "reflections",
  ] as const) {
    for (const item of payload[collection]) {
      validateReviewedMetadata(collection, item, errors);
    }
  }
}

function validateDevInventory(
  payload: ReturnType<typeof extractPayload>,
  warnings: string[],
) {
  for (const [collection, gate] of Object.entries(betaGates)) {
    const count = payload[collection as keyof typeof betaGates].length;
    if (count < gate.min) {
      warnings.push(
        `${collection} count ${count} is below beta target ${gate.min}`,
      );
    }
  }
}

function validateReviewedMetadata(
  collection: string,
  item: ContentItem,
  errors: string[],
) {
  const id = itemId(item);
  if (!Number.isInteger(item.version)) {
    errors.push(`${collection} ${id} is missing integer version`);
  }
  if (typeof item.reviewedAt !== "string" || item.reviewedAt.length === 0) {
    errors.push(`${collection} ${id} is missing reviewedAt`);
  }
  const source = item.source;
  if (typeof source !== "string" || source.length === 0) {
    errors.push(`${collection} ${id} is missing source`);
  } else if (/placeholder|replace with approved/i.test(source)) {
    errors.push(`${collection} ${id} has placeholder source metadata`);
  }
}

function validateReferences(
  payload: ReturnType<typeof extractPayload>,
  errors: string[],
) {
  const quranIds = new Set(payload.quranAyahs.map(itemId));
  const duaIds = new Set(payload.duas.map(itemId));
  const dhikrIds = new Set(payload.dhikrs.map(itemId));
  const reflectionIds = new Set(payload.reflections.map(itemId));
  for (const session of payload.dailySessions) {
    const steps = Array.isArray(session.steps) ? session.steps : [];
    for (const rawStep of steps) {
      if (!isObject(rawStep)) {
        continue;
      }
      const contentId = rawStep.contentId;
      if (typeof contentId !== "string" || contentId.length === 0) {
        continue;
      }
      const type = rawStep.type;
      const exists =
        (type === "quran" && quranIds.has(contentId)) ||
        (type === "dua" && duaIds.has(contentId)) ||
        (type === "dhikr" && dhikrIds.has(contentId)) ||
        (type === "reflection" && reflectionIds.has(contentId));
      if (!exists) {
        errors.push(
          `dailySessions ${itemId(session)} references missing ${type} ${contentId}`,
        );
      }
    }
  }
}

function buildDetailIndex(
  payload: ReturnType<typeof extractPayload>,
  bundleRef: Record<string, unknown>,
) {
  const index: Record<string, unknown> = {};
  for (const session of payload.dailySessions) {
    index[itemId(session)] = { bundleRef };
    const steps = Array.isArray(session.steps) ? session.steps : [];
    for (const rawStep of steps) {
      if (!isObject(rawStep) || typeof rawStep.contentId !== "string") {
        continue;
      }
      index[rawStep.contentId] = { bundleRef };
    }
  }
  return index;
}

function sourceCorpusVersions(source: Record<string, unknown>) {
  const raw = source.sourceCorpusVersions;
  return isObject(raw) ? raw : { quran: "local-reviewed-pack" };
}

function itemId(item: ContentItem): string {
  return `${item.id ?? item.verseKey ?? "unknown"}`;
}

function compactDate(date: Date): string {
  return date.toISOString().slice(0, 10).replaceAll("-", "");
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
