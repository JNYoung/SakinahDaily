import type { IncomingMessage, ServerResponse } from "node:http";
import { writeJson } from "./http.js";

export class HealthRoute {
  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://local");
    if (req.method !== "GET" || url.pathname !== "/health") {
      return false;
    }

    writeJson(res, 200, {
      ok: true,
      service: "sakinah-backend-api",
      capabilities: ["locations", "content_delivery", "push_preview"],
    });
    return true;
  }
}
