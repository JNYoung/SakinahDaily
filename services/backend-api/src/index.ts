import { createServer } from "node:http";
import path from "node:path";
import { ContentDeliveryRoute } from "./routes/contentDelivery.js";
import { HealthRoute } from "./routes/health.js";
import { LocationRoute } from "./routes/locationRoutes.js";
import { PushRoute } from "./routes/pushRoutes.js";
import { writeJson } from "./routes/http.js";
import { FileContentPackStore } from "./repositories/fileContentPackStore.js";

export function createBackendApiServer(
  options: {
    contentPackStore?: FileContentPackStore;
  } = {},
) {
  const contentPackStore =
    options.contentPackStore ??
    new FileContentPackStore(
      process.env.CONTENT_PACK_OUTPUT_DIR ??
        path.resolve(process.cwd(), ".generated/content-pack"),
    );

  const routes = [
    new HealthRoute(),
    new LocationRoute(),
    new ContentDeliveryRoute(contentPackStore),
    new PushRoute(),
  ];

  return createServer(async (req, res) => {
    try {
      for (const route of routes) {
        const handled = await route.handle(req, res);
        if (handled) {
          return;
        }
      }
      writeJson(res, 404, { error: "not_found" });
    } catch {
      writeJson(res, 400, { error: "malformed_request" });
    }
  });
}

if (process.env.NODE_ENV !== "test") {
  const port = Number(process.env.PORT ?? 8800);
  createBackendApiServer().listen(port, () => {
    console.log(`Sakinah backend-api listening on :${port}`);
  });
}
