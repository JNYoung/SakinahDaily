import { createServer } from "node:http";
import { AgentRunsRoute } from "./routes/agentRuns.js";
import { AgentRunRepository } from "./repositories/agentRunRepository.js";
import { ContentRepository } from "./repositories/contentRepository.js";

const route = new AgentRunsRoute(new AgentRunRepository(), new ContentRepository());

export function createContentAgentServer() {
  return createServer(async (req, res) => {
    const handled = await route.handle(req, res);
    if (!handled) {
      res.writeHead(404, { "content-type": "application/json" });
      res.end(JSON.stringify({ error: "not_found" }));
    }
  });
}

if (process.env.NODE_ENV !== "test") {
  const port = Number(process.env.PORT ?? 8787);
  createContentAgentServer().listen(port, () => {
    console.log(`Sakinah content-agent listening on :${port}`);
  });
}
