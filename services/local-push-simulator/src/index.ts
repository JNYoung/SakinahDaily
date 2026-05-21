import { createServer, IncomingMessage, ServerResponse } from 'node:http';
import {
  clearQueuedMessages,
  getQueuedMessages,
  previewPush,
  sendPush,
} from './payloadFactory';

const port = Number(process.env.PORT ?? 8790);

const server = createServer(async (request, response) => {
  try {
    if (request.method === 'GET' && request.url === '/health') {
      return sendJson(response, 200, { ok: true });
    }

    if (request.method === 'POST' && request.url === '/push/preview') {
      return sendJson(response, 200, previewPush(await readJson(request)));
    }

    if (request.method === 'POST' && request.url === '/push/send') {
      return sendJson(response, 200, sendPush(await readJson(request)));
    }

    if (request.method === 'GET' && request.url === '/push/messages') {
      return sendJson(response, 200, { messages: getQueuedMessages() });
    }

    if (request.method === 'DELETE' && request.url === '/push/messages') {
      return sendJson(response, 200, clearQueuedMessages());
    }

    return sendJson(response, 404, { error: 'not_found' });
  } catch (error) {
    return sendJson(response, 400, {
      accepted: false,
      flags: ['malformed_request'],
    });
  }
});

server.listen(port, () => {
  process.stdout.write(`Local push simulator listening on ${port}\n`);
});

async function readJson(request: IncomingMessage): Promise<object> {
  const chunks: Buffer[] = [];
  for await (const chunk of request) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  const raw = Buffer.concat(chunks).toString('utf8');
  if (raw.trim().length === 0) {
    return {};
  }
  const parsed = JSON.parse(raw);
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('Expected JSON object');
  }
  return parsed;
}

function sendJson(response: ServerResponse, status: number, body: object) {
  response.writeHead(status, {
    'content-type': 'application/json; charset=utf-8',
  });
  response.end(JSON.stringify(body, null, 2));
}
