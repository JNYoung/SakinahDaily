import type { IncomingMessage, ServerResponse } from "node:http";
import { writeJson } from "./http.js";

export class HealthRoute {
  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://localhost");
    if (req.method === "GET" && url.pathname === "/health") {
      writeJson(res, 200, { ok: true, service: "content-agent" });
      return true;
    }
    return false;
  }
}
