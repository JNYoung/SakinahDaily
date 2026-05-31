import { createServer } from "node:http";
import path from "node:path";
import { AgentCandidatesRoute } from "./routes/agentCandidates.js";
import { AgentRunsRoute } from "./routes/agentRuns.js";
import { ContentDeliveryRoute } from "./routes/contentDelivery.js";
import { HealthRoute } from "./routes/health.js";
import { ReviewPacketsRoute } from "./routes/reviewPackets.js";
import { AgentRunWorkflow } from "./domain/agentRunWorkflow.js";
import type { AgentRepository } from "./repositories/agentRepository.js";
import { InMemoryAgentRepository } from "./repositories/inMemoryAgentRepository.js";
import { ContentRepository } from "./repositories/contentRepository.js";
import { FileContentPackStore } from "./repositories/fileContentPackStore.js";

export function createContentAgentServer(
  options: {
    agentRepository?: AgentRepository;
    contentRepository?: ContentRepository;
    contentPackStore?: FileContentPackStore;
  } = {},
) {
  const agentRepository =
    options.agentRepository ?? new InMemoryAgentRepository();
  const contentRepository =
    options.contentRepository ?? new ContentRepository();
  const contentPackStore =
    options.contentPackStore ??
    new FileContentPackStore(
      process.env.CONTENT_PACK_OUTPUT_DIR ??
        path.resolve(process.cwd(), ".generated/content-pack"),
    );
  const workflow = new AgentRunWorkflow({ agentRepository, contentRepository });
  const routes = [
    new HealthRoute(),
    new ContentDeliveryRoute(contentPackStore),
    new AgentRunsRoute(agentRepository, workflow),
    new ReviewPacketsRoute(agentRepository),
    new AgentCandidatesRoute(agentRepository, contentRepository),
  ];

  return createServer(async (req, res) => {
    for (const route of routes) {
      const handled = await route.handle(req, res);
      if (handled) {
        return;
      }
    }
    res.writeHead(404, { "content-type": "application/json" });
    res.end(JSON.stringify({ error: "not_found" }));
  });
}

if (process.env.NODE_ENV !== "test") {
  const port = Number(process.env.PORT ?? 8787);
  createContentAgentServer().listen(port, () => {
    console.log(`Sakinah content-agent listening on :${port}`);
  });
}
