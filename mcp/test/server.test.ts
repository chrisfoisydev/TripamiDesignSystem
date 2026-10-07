// End-to-end: spawn the built server and talk MCP to it over stdio and HTTP.
import { after, before, describe, test } from 'node:test';
import assert from 'node:assert/strict';
import { spawn, type ChildProcess } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { Client } from '@modelcontextprotocol/sdk/client/index.js';
import { StdioClientTransport } from '@modelcontextprotocol/sdk/client/stdio.js';
import { StreamableHTTPClientTransport } from '@modelcontextprotocol/sdk/client/streamableHttp.js';

const entry = fileURLToPath(new URL('../src/index.js', import.meta.url));

type ToolResult = { content: { type: string; text: string }[]; isError?: boolean };
let client: Client;

async function call(name: string, args: Record<string, unknown> = {}): Promise<ToolResult> {
  return (await client.callTool({ name, arguments: args })) as ToolResult;
}
const text = (r: ToolResult) => r.content.map((c) => c.text).join('\n');
const json = (r: ToolResult) => JSON.parse(text(r));

describe('stdio', () => {
  before(async () => {
    client = new Client({ name: 'test', version: '1.0.0' });
    await client.connect(new StdioClientTransport({ command: process.execPath, args: [entry], stderr: 'ignore' }));
  });
  after(async () => client.close());

  test('lists nine read-only tools with the tripami_ prefix', async () => {
    const { tools } = await client.listTools();
    assert.equal(tools.length, 9);
    for (const t of tools) {
      assert.match(t.name, /^tripami_/);
      assert.equal(t.annotations?.readOnlyHint, true, t.name);
    }
  });

  test('semantic colors resolve in both themes with their Flutter names', async () => {
    const rows = json(await call('tripami_get_tokens', { category: 'colors', query: 'text-secondary', format: 'json' }));
    const t = rows.find((r: { name: string }) => r.name === 'text-secondary');
    assert.equal(t.light.toLowerCase(), '#525d6e');
    assert.equal(t.dark.toLowerCase(), '#a7afbd');
    assert.equal(t.dart, 'TPColors.of(context).textSecondary');
  });

  test('every token category answers', async () => {
    for (const category of ['colors', 'ramps', 'type', 'spacing', 'radius', 'size', 'elevation', 'motion', 'haptics', 'braid', 'icons']) {
      const r = await call('tripami_get_tokens', { category });
      assert.ok(!r.isError && text(r).length > 100, category);
    }
    assert.match(text(await call('tripami_get_tokens', { category: 'radius' })), /TPRadius\.md/);
    assert.match(text(await call('tripami_get_tokens', { category: 'motion' })), /TPMotion\.playfulCurve/);
  });

  test('components come with Flutter params and web props', async () => {
    const c = json(await call('tripami_get_component', { name: 'TPPollCard', format: 'json' }));
    assert.equal(c.name, 'PollCard');
    const poll = c.flutterApi.find((d: { name: string }) => d.name === 'TPPollCard');
    const waiting = poll.constructors[0].params.find((p: { name: string }) => p.name === 'waitingOn');
    assert.equal(waiting.type, 'List<TPMember>');
    assert.equal(waiting.required, true);
    assert.ok(c.web.props.some((p: { name: string }) => p.name === 'waitingOn'));
    const md = text(await call('tripami_get_component', { name: 'button' }));
    assert.match(md, /TPButton\.primary/);
    assert.match(md, /join/);
  });

  test('Flutter APIs without a card are reachable too', async () => {
    assert.match(text(await call('tripami_get_component', { name: 'TPMotion' })), /playful/);
    assert.match(text(await call('tripami_get_component', { name: 'TPTone' })), /subtle/);
    const miss = await call('tripami_get_component', { name: 'Carousel' });
    assert.equal(miss.isError, true);
  });

  test('contrast follows WCAG and the grade rule', async () => {
    const r = json(await call('tripami_check_contrast', { foreground: 'text-secondary', background: 'canvas', format: 'json' }));
    assert.ok(r.ratio >= 5.9 && r.aaText);
    const ramp = json(await call('tripami_check_contrast', { foreground: 'navy 700', background: 'orange-100', format: 'json' }));
    assert.ok(ramp.gradeGap >= 590 && ramp.aaText);
    const brand = json(await call('tripami_check_contrast', { foreground: 'brand-orange', background: 'white', format: 'json' }));
    assert.equal(brand.aaText, false);
    assert.equal(brand.aaLargeText, true);
    const dark = json(await call('tripami_check_contrast', { foreground: 'accent', background: 'surface', theme: 'dark', format: 'json' }));
    assert.equal(dark.foreground.hex, '#FF7A3D');
    const bad = await call('tripami_check_contrast', { foreground: 'glass', background: 'canvas' });
    assert.equal(bad.isError, true);
    assert.match(text(bad), /translucent/);
  });

  test('tone roles are safe in both themes', async () => {
    const t = json(await call('tripami_suggest_tone', { ramp: 'green', format: 'json' }));
    const role = (n: string) => t.roles.find((r: { role: string }) => r.role === n);
    assert.equal(role('subtle').light.grade, 50);
    assert.equal(role('text').dark.grade, 200);
    assert.equal(role('onSolid').light.hex, '#FFFFFF');
    assert.equal((await call('tripami_suggest_tone', { ramp: 'teal' })).isError, true);
  });

  test('match_color finds the exact token and flags off-system colors', async () => {
    const exact = json(await call('tripami_match_color', { color: '#B8400F', format: 'json' }));
    assert.equal(exact.matches[0].name, 'accent (light)');
    assert.equal(exact.matches[0].deltaE, 0);
    assert.match(text(await call('tripami_match_color', { color: 'Color(0xFF00FF00)' })), /Off-system/);
  });

  test('guideline search answers rule questions', async () => {
    const accent = json(await call('tripami_search_guidelines', { query: 'accent button fill', format: 'json' }));
    assert.ok(accent.length > 0);
    const braid = text(await call('tripami_search_guidelines', { query: 'braid 50 people groups', limit: 3 }));
    assert.match(braid, /group/i);
  });

  test('review flags off-system Flutter code with concrete fixes', async () => {
    const code = [
      "Container(",
      "  padding: EdgeInsets.all(15),",
      "  decoration: BoxDecoration(color: Color(0xFFB8400F), borderRadius: BorderRadius.circular(16)),",
      "  child: Text('Booked!', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),",
      ")",
      "ElevatedButton(style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(c.accent)), onPressed: go, child: Icon(Icons.add))",
      "HapticFeedback.lightImpact();",
      "AnimatedOpacity(duration: Duration(milliseconds: 300), curve: Curves.easeOut)",
    ].join('\n');
    const r = json(await call('tripami_review_code', { code, format: 'json' }));
    assert.equal(r.language, 'dart');
    const rules = new Set(r.findings.map((f: { rule: string }) => f.rule));
    for (const rule of ['hard-coded-spacing', 'hard-coded-color', 'hard-coded-radius', 'hard-coded-type', 'bold-ui-text', 'material-color', 'raw-button', 'accent-fill', 'material-icon', 'raw-haptic', 'hard-coded-duration', 'material-curve', 'copy-exclamation']) {
      assert.ok(rules.has(rule), `missing ${rule}`);
    }
    const color = r.findings.find((f: { rule: string }) => f.rule === 'hard-coded-color');
    assert.match(color.suggestion, /TPColors\.of\(context\)\.accent/);
    const haptic = r.findings.find((f: { rule: string }) => f.rule === 'raw-haptic');
    assert.match(haptic.suggestion, /TPHaptics\.join\(\)/);
  });

  test('review passes clean Tripami code and handles web', async () => {
    const clean = "TPButton.primary(label: 'Vote', onPressed: vote)\nPadding(padding: TPSpace.screen, child: Text('Waiting on Jonah.', style: TPType.body))";
    assert.match(text(await call('tripami_review_code', { code: clean, language: 'dart' })), /No issues/);
    const web = json(await call('tripami_review_code', { code: '.card { color: #525d6e; padding: 16px; font-size: 15px; border-radius: 16px; }', format: 'json' }));
    assert.equal(web.language, 'web');
    assert.ok(web.findings.some((f: { suggestion: string }) => f.suggestion.includes('var(--text-secondary)')));
  });

  test('overview orients a new session', async () => {
    const t = text(await call('tripami_get_overview'));
    assert.match(t, /TripamiTheme/);
    assert.match(t, /claude\.ai\/artifact/);
  });
});

describe('http', () => {
  let proc: ChildProcess;
  const port = 3900 + Math.floor(Math.random() * 90);
  before(async () => {
    proc = spawn(process.execPath, [entry, '--http'], { env: { ...process.env, PORT: String(port), TRIPAMI_MCP_TOKEN: 'secret' }, stdio: ['ignore', 'ignore', 'pipe'] });
    await new Promise<void>((resolve) => proc.stderr!.on('data', (d) => String(d).includes('localhost') && resolve()));
  });
  after(() => proc.kill());

  test('health, auth and a tool call over Streamable HTTP', async () => {
    const health = (await (await fetch(`http://localhost:${port}/health`)).json()) as { ok: boolean };
    assert.equal(health.ok, true);
    assert.equal((await fetch(`http://localhost:${port}/mcp`, { method: 'POST', body: '{}' })).status, 401);

    const http = new Client({ name: 'test-http', version: '1.0.0' });
    await http.connect(new StreamableHTTPClientTransport(new URL(`http://localhost:${port}/mcp`), { requestInit: { headers: { authorization: 'Bearer secret' } } }));
    const r = (await http.callTool({ name: 'tripami_check_contrast', arguments: { foreground: 'white', background: 'navy-500', format: 'json' } })) as ToolResult;
    assert.ok(JSON.parse(r.content[0].text).aaText);
    await http.close();
  });
});
