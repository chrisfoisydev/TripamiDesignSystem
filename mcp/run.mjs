#!/usr/bin/env node
// Launcher for MCP clients: builds the server on first run (or when the design
// system has changed since the last build), then starts it on stdio.
// All build output goes to stderr so stdout stays clean for the MCP protocol.
import { execSync } from 'node:child_process';
import { existsSync, statSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, '..');
const data = join(here, 'dist', 'data', 'tripami.json');

function newest(dir) {
  let t = 0;
  for (const f of readdirSync(dir, { withFileTypes: true })) {
    if (f.name === 'node_modules' || f.name === 'dist' || f.name.startsWith('.')) continue;
    const p = join(dir, f.name);
    t = Math.max(t, f.isDirectory() ? newest(p) : statSync(p).mtimeMs);
  }
  return t;
}

const sources = ['tokens', 'docs', 'lib/src', 'claude-design/project', 'mcp/src', 'mcp/scripts']
  .map((p) => join(root, p)).filter(existsSync);
const stale = !existsSync(data) || Math.max(...sources.map(newest), statSync(join(root, 'README.md')).mtimeMs) > statSync(data).mtimeMs;

if (stale) {
  const sh = (cmd) => execSync(cmd, { cwd: here, stdio: ['ignore', process.stderr, process.stderr] });
  if (!existsSync(join(here, 'node_modules'))) sh('npm install --no-audit --no-fund --silent');
  sh('npm run build --silent');
}
await import('./dist/src/index.js');
