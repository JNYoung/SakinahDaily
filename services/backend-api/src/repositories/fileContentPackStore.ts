import { readFile } from "node:fs/promises";
import path from "node:path";

export class FileContentPackStore {
  constructor(private readonly outputDir: string) {}

  async loadManifest(): Promise<Record<string, unknown> | undefined> {
    return this.readJson(path.join(this.outputDir, "manifest.json"));
  }

  async loadBundleRaw(bundleId: string): Promise<string | undefined> {
    if (!safeBundleId(bundleId)) {
      return undefined;
    }
    try {
      return await readFile(
        path.join(this.outputDir, "bundles", `${bundleId}.json`),
        "utf-8",
      );
    } catch {
      return undefined;
    }
  }

  async resolveBundleHint(
    bundleHint: string,
  ): Promise<Record<string, unknown> | undefined> {
    const index = await this.readJson(
      path.join(this.outputDir, "detail-bundles.json"),
    );
    const entry = index?.[bundleHint];
    if (isObject(entry) && isObject(entry.bundleRef)) {
      return entry.bundleRef;
    }
    return undefined;
  }

  private async readJson(
    filePath: string,
  ): Promise<Record<string, unknown> | undefined> {
    try {
      return JSON.parse(await readFile(filePath, "utf-8")) as Record<
        string,
        unknown
      >;
    } catch {
      return undefined;
    }
  }
}

function safeBundleId(bundleId: string): boolean {
  return /^[a-zA-Z0-9_.-]+$/.test(bundleId);
}

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
