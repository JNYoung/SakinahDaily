import { createServer } from "node:http";
import { pathToFileURL } from "node:url";
import { AgentRunsRoute } from "./routes/agentRuns.js";
import { AgentRunRepository } from "./repositories/agentRunRepository.js";
import { ContentRepository } from "./repositories/contentRepository.js";

export function createContentAgentServer() {
  const route = new AgentRunsRoute(new AgentRunRepository(), new ContentRepository());

  return createServer(async (req, res) => {
    const handled = await route.handle(req, res);
    if (!handled) {
      res.writeHead(404, { "content-type": "application/json" });
      res.end(JSON.stringify({ error: "not_found" }));
    }
  });
}

function isMainModule(): boolean {
  return process.argv[1] ? import.meta.url === pathToFileURL(process.argv[1]).href : false;
}

if (isMainModule()) {
  const port = Number(process.env.PORT ?? 8787);
  createContentAgentServer().listen(port, () => {
    console.log(`Sakinah content-agent listening on :${port}`);
  });
}
