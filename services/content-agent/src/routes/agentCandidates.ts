import type { IncomingMessage, ServerResponse } from "node:http";
import type { AgentFeedbackEvent } from "../domain/schemas.js";
import { runCandidateQa } from "../domain/qaReview.js";
import type { AgentRepository } from "../repositories/agentRepository.js";
import { ContentRepository } from "../repositories/contentRepository.js";
import { readJson, writeJson } from "./http.js";

export class AgentCandidatesRoute {
  constructor(
    private readonly agentRepository: AgentRepository,
    private readonly contentRepository: ContentRepository,
  ) {}

  async handle(req: IncomingMessage, res: ServerResponse): Promise<boolean> {
    const url = new URL(req.url ?? "/", "http://localhost");

    const candidateMatch = url.pathname.match(/^\/agent-candidates\/([^/]+)$/);
    if (req.method === "GET" && candidateMatch) {
      const candidate = await this.agentRepository.getCandidate(
        candidateMatch[1],
      );
      writeJson(
        res,
        candidate ? 200 : 404,
        candidate ?? { error: "candidate_not_found" },
      );
      return true;
    }

    const qaMatch = url.pathname.match(/^\/agent-candidates\/([^/]+)\/qa$/);
    if (req.method === "POST" && qaMatch) {
      const candidate = await this.agentRepository.getCandidate(qaMatch[1]);
      if (!candidate) {
        writeJson(res, 404, { error: "candidate_not_found" });
        return true;
      }
      const source = this.contentRepository.getSourceItem(
        candidate.sourceItemId,
      );
      const qa = runCandidateQa(candidate, source);
      const updated = {
        ...candidate,
        riskFlags: qa.riskFlags,
        automatedChecks: qa.automatedChecks,
        updatedAt: new Date().toISOString(),
      };
      await this.agentRepository.updateCandidate(updated);
      writeJson(res, 200, {
        candidateId: candidate.candidateId,
        accepted: qa.riskFlags.length === 0,
        flags: qa.riskFlags,
        riskFlags: qa.riskFlags,
        automatedChecks: qa.automatedChecks,
        candidate: updated,
      });
      return true;
    }

    const promoteMatch = url.pathname.match(
      /^\/agent-candidates\/([^/]+)\/promote-to-cms-draft$/,
    );
    if (req.method === "POST" && promoteMatch) {
      const body = await readJson<{ forceDraft?: boolean }>(req);
      const candidate = await this.agentRepository.getCandidate(
        promoteMatch[1],
      );
      if (!candidate) {
        writeJson(res, 404, { error: "candidate_not_found" });
        return true;
      }
      const source = this.contentRepository.getSourceItem(
        candidate.sourceItemId,
      );
      const qa = runCandidateQa(candidate, source);
      if (qa.riskFlags.length > 0 && !body.forceDraft) {
        writeJson(res, 409, {
          error: "blocking_safety_flags",
          flags: qa.riskFlags,
          autoPublished: false,
        });
        return true;
      }
      await this.agentRepository.updateCandidateReviewStatus(
        candidate.candidateId,
        "promoted_to_cms_draft",
        {
          riskFlags: qa.riskFlags,
          automatedChecks: qa.automatedChecks,
          cmsTargetId: `cms_draft_${candidate.candidateId}`,
        },
      );
      writeJson(res, 200, {
        candidateId: candidate.candidateId,
        cmsStatus: "draft",
        autoPublished: false,
        reviewStatus: "promoted_to_cms_draft",
      });
      return true;
    }

    const feedbackMatch = url.pathname.match(
      /^\/agent-candidates\/([^/]+)\/feedback$/,
    );
    if (req.method === "POST" && feedbackMatch) {
      const candidate = await this.agentRepository.getCandidate(
        feedbackMatch[1],
      );
      if (!candidate) {
        writeJson(res, 404, { error: "candidate_not_found" });
        return true;
      }
      const body = await readJson<Partial<AgentFeedbackEvent>>(req);
      const event: AgentFeedbackEvent = {
        id: `feedback_${Date.now()}`,
        candidateId: candidate.candidateId,
        reviewerRole: body.reviewerRole ?? "reviewer",
        decision: body.decision ?? "needs_edit",
        reason: body.reason ?? "",
        editedPayload: body.editedPayload,
        createdAt: new Date().toISOString(),
      };
      await this.agentRepository.createFeedbackEvent(event);
      writeJson(res, 201, { event });
      return true;
    }

    return false;
  }
}
