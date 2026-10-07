#!/usr/bin/env node
// Entry point. stdio by default (Claude Code, Cursor, Claude Desktop);
// `--http` (or TRANSPORT=http) serves stateless Streamable HTTP on PORT (default 3000) at /mcp.
import { createServer as createHttpServer, type IncomingMessage } from 'node:http';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { StreamableHTTPServerTransport } from '@modelcontextprotocol/sdk/server/streamableHttp.js';
import { loadData } from './data.js';
import { createServer } from './server.js';

async function readBody(req: IncomingMessage): Promise<unknown> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of req) {
    size += chunk.length;
    if (size > 1_000_000) throw new Error('Request body too large');
    chunks.push(chunk as Buffer);
  }
  return chunks.length ? JSON.parse(Buffer.concat(chunks).toString('utf8')) : undefined;
}

async function runHttp(): Promise<void> {
  const port = parseInt(process.env.PORT ?? '3000', 10);
  const token = process.env.TRIPAMI_MCP_TOKEN; // optional shared secret for hosted use
  const data = loadData();
  const http = createHttpServer(async (req, res) => {
    const url = new URL(req.url ?? '/', 'http://localhost');
    if (url.pathname === '/health') {
      res.writeHead(200, { 'content-type': 'application/json' }).end(JSON.stringify({ ok: true, built: data.generatedAt, commit: data.commit }));
      return;
    }
    if (url.pathname !== '/mcp') { res.writeHead(404).end(); return; }
    if (token && req.headers.authorization !== `Bearer ${token}`) { res.writeHead(401).end('Unauthorized'); return; }
    if (req.method !== 'POST') {
      res.writeHead(405, { allow: 'POST' }).end(JSON.stringify({ jsonrpc: '2.0', error: { code: -32000, message: 'Method not allowed: this server is stateless, POST only.' }, id: null }));
      return;
    }
    try {
      const body = await readBody(req);
      // Stateless: a fresh server and transport per request.
      const server = createServer(data);
      const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined, enableJsonResponse: true });
      res.on('close', () => { void transport.close(); void server.close(); });
      await server.connect(transport);
      await transport.handleRequest(req, res, body);
    } catch (err) {
      if (!res.headersSent) res.writeHead(400, { 'content-type': 'application/json' });
      res.end(JSON.stringify({ jsonrpc: '2.0', error: { code: -32700, message: err instanceof Error ? err.message : 'Bad request' }, id: null }));
    }
  });
  http.listen(port, () => console.error(`tripami-mcp-server on http://localhost:${port}/mcp${token ? ' (bearer token required)' : ''}`));
}

async function runStdio(): Promise<void> {
  await createServer().connect(new StdioServerTransport());
  console.error('tripami-mcp-server running on stdio');
}

const http = process.argv.includes('--http') || process.env.TRANSPORT === 'http';
(http ? runHttp() : runStdio()).catch((err) => {
  console.error('tripami-mcp-server failed:', err);
  process.exit(1);
});
