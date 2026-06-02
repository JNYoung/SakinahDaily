import { mkdtemp, rm, writeFile, mkdir } from "node:fs/promises";
import { tmpdir } from "node:os";
import path from "node:path";
import { AddressInfo } from "node:net";
import { afterEach, describe, expect, it } from "vitest";
import { createBackendApiServer } from "../src/index.js";
import { FileContentPackStore } from "../src/repositories/fileContentPackStore.js";

const servers: Array<ReturnType<typeof createBackendApiServer>> = [];
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

describe("backend api server", () => {
  it("reports integrated backend capabilities", async () => {
    const client = await startServer();

    const health = await client.get("/health");

    expect(health).toMatchObject({
      ok: true,
      service: "sakinah-backend-api",
      capabilities: ["locations", "content_delivery", "push_preview"],
    });
  });

  it("serves city search and location resolution over HTTP", async () => {
    const client = await startServer();

    const search = await client.get("/locations/cities?query=dubai");
    expect(search.results[0]).toMatchObject({
      id: "ae-dubai",
      timezone: "Asia/Dubai",
      prayerCalculationMethod: "muslim_world_league",
    });

    const resolved = await client.post("/locations/resolve", {
      cityId: "id-jakarta",
    });
    expect(resolved).toMatchObject({
      id: "id-jakarta",
      timezone: "Asia/Jakarta",
      prayerCalculationMethod: "indonesia",
      resolution: "city_id",
    });
  });

  it("serves generic content manifest, bundles, and detail-bundle refs", async () => {
    const outputDir = await tempOutputDir();
    await writeContentPackFixture(outputDir);
    const client = await startServer(outputDir);

    const manifest = await client.get("/content/manifest");
    expect(manifest.manifestId).toBe("fixture_manifest");
    expect(manifest.bundles[0].bundleId).toBe("fixture_bundle");

    const bundle = await client.get("/content/bundles/fixture_bundle.json");
    expect(bundle).toMatchObject({
      bundleId: "fixture_bundle",
      status: "published",
      reviewStatus: "approved",
    });

    const detail = await client.get(
      "/content/detail-bundle?bundle_hint=session_morning",
    );
    expect(detail.bundleRef.bundleId).toBe("fixture_bundle");

    const defaultManifest = await client.get("/manifest");
    expect(defaultManifest.manifestId).toBe("fixture_manifest");

    const defaultDetail = await client.get(
      "/detail-bundle?bundle_hint=session_morning",
    );
    expect(defaultDetail.bundleRef.url).toBe(
      "/content/bundles/fixture_bundle.json",
    );
  });

  it("previews safe local push payloads and blocks sensitive lock-screen copy", async () => {
    const client = await startServer();

    const accepted = await client.post("/push/preview", {
      language: "id",
      type: "daily_session",
      contentId: "session_morning_ease",
      womenIbadahSafeRequired: true,
      permissionState: "granted",
    });
    expect(accepted).toMatchObject({
      accepted: true,
      provider: "local_preview",
      sent: false,
      payload: {
        type: "daily_session",
        contentId: "session_morning_ease",
        languageCode: "id",
        lockScreenSafe: true,
      },
    });

    const rejected = await client.post("/push/preview", {
      language: "en",
      type: "daily_session",
      contentId: "session_morning_ease",
      bodyOverride: "Support for your period today.",
      womenIbadahSafeRequired: true,
    });
    expect(rejected).toEqual({
      accepted: false,
      provider: "local_preview",
      sent: false,
      flags: ["cycle_sensitive_lock_screen_copy"],
    });
  });
});

async function startServer(outputDir?: string) {
  const server = createBackendApiServer({
    contentPackStore: new FileContentPackStore(
      outputDir ?? path.join(process.cwd(), ".generated/content-pack"),
    ),
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
    post: async (targetPath: string, body: object) => {
      const response = await fetch(`${baseUrl}${targetPath}`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify(body),
      });
      const payload = await response.json();
      return response.ok ? payload : { statusCode: response.status, payload };
    },
  };
}

async function tempOutputDir() {
  const dir = await mkdtemp(path.join(tmpdir(), "sakinah-backend-api-"));
  tempDirs.push(dir);
  return dir;
}

async function writeContentPackFixture(outputDir: string) {
  await mkdir(path.join(outputDir, "bundles"), { recursive: true });
  await writeFile(
    path.join(outputDir, "manifest.json"),
    JSON.stringify({
      manifestId: "fixture_manifest",
      schemaVersion: 1,
      language: "en",
      market: "global",
      bundles: [{ bundleId: "fixture_bundle" }],
    }),
  );
  await writeFile(
    path.join(outputDir, "bundles", "fixture_bundle.json"),
    JSON.stringify({
      bundleId: "fixture_bundle",
      status: "published",
      reviewStatus: "approved",
      payload: { dailySessions: [], duas: [], dhikrs: [] },
    }),
  );
  await writeFile(
    path.join(outputDir, "detail-bundles.json"),
    JSON.stringify({
      session_morning: {
        bundleRef: { bundleId: "fixture_bundle", url: "/content/bundles/fixture_bundle.json" },
      },
    }),
  );
}
