import type { IncomingMessage, ServerResponse } from "node:http";
import type { AgentRepository } from "../repositories/agentRepository.js";
import { writeJson } from "./http.js";

export class ReviewPacketsRoute {
  constructor(private readonly agentRepository: AgentRepository) {}

  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://localhost");
    const reviewMatch = url.pathname.match(
      /^\/agent-runs\/([^/]+)\/review-packet$/,
    );
    if (req.method === "GET" && reviewMatch) {
      const packet = await this.agentRepository.getReviewPacketByRun(
        reviewMatch[1],
      );
      writeJson(
        res,
        packet ? 200 : 404,
        packet ?? { error: "review_packet_not_found" },
      );
      return true;
    }
    return false;
  }
}
