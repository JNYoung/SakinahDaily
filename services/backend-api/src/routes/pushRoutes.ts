import type { IncomingMessage, ServerResponse } from "node:http";
import {
  previewPush,
  type LocalPushPayload,
  type PushPreviewRequest,
} from "../domain/pushPreview.js";
import { readJson, writeJson } from "./http.js";

export class PushRoute {
  private readonly queuedMessages: LocalPushPayload[] = [];

  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://local");

    if (req.method === "POST" && url.pathname === "/push/preview") {
      writeJson(res, 200, previewPush(await readJson<PushPreviewRequest>(req)));
      return true;
    }

    if (req.method === "POST" && url.pathname === "/push/send") {
      const result = previewPush(await readJson<PushPreviewRequest>(req));
      if (result.accepted && result.payload) {
        this.queuedMessages.push(result.payload);
      }
      writeJson(res, 200, {
        ...result,
        queued: result.accepted,
        queueSize: this.queuedMessages.length,
      });
      return true;
    }

    if (req.method === "GET" && url.pathname === "/push/messages") {
      writeJson(res, 200, { messages: [...this.queuedMessages] });
      return true;
    }

    if (req.method === "DELETE" && url.pathname === "/push/messages") {
      this.queuedMessages.splice(0, this.queuedMessages.length);
      writeJson(res, 200, { cleared: true });
      return true;
    }

    return false;
  }
}
