import type { IncomingMessage, ServerResponse } from "node:http";
import type { FileContentPackStore } from "../repositories/fileContentPackStore.js";
import { writeJson } from "./http.js";

export class ContentDeliveryRoute {
  constructor(private readonly contentPackStore: FileContentPackStore) {}

  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://local");

    if (req.method === "GET" && url.pathname === "/manifest") {
      const manifest = await this.contentPackStore.loadManifest();
      writeJson(
        res,
        manifest ? 200 : 404,
        manifest ?? { error: "manifest_not_found" },
      );
      return true;
    }

    const bundleMatch = url.pathname.match(/^\/bundles\/([^/]+)\.json$/);
    if (req.method === "GET" && bundleMatch) {
      const raw = await this.contentPackStore.loadBundleRaw(bundleMatch[1]);
      if (!raw) {
        writeJson(res, 404, { error: "bundle_not_found" });
        return true;
      }
      res.writeHead(200, { "content-type": "application/json" });
      res.end(raw);
      return true;
    }

    if (req.method === "GET" && url.pathname === "/detail-bundle") {
      const bundleHint = url.searchParams.get("bundle_hint") ?? "";
      const bundleRef =
        bundleHint.length > 0
          ? await this.contentPackStore.resolveBundleHint(bundleHint)
          : undefined;
      writeJson(
        res,
        bundleRef ? 200 : 404,
        bundleRef ? { bundleRef } : { error: "bundle_hint_not_found" },
      );
      return true;
    }

    return false;
  }
}
