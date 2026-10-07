// The Tripami MCP server: tools over the compiled design system.
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { z } from 'zod';
import { contrast, gradeOf, wcag } from './color.js';
import { loadData, resolveColor, type Component, type DartType, type Theme, type TripamiData } from './data.js';
import { nearestColors, reviewCode } from './review.js';
import { searchGuidelines } from './search.js';

const CHARACTER_LIMIT = 25_000;
const READ_ONLY = { readOnlyHint: true, destructiveHint: false, idempotentHint: true, openWorldHint: false } as const;

const format = z.enum(['markdown', 'json']).default('markdown').describe("'markdown' for reading, 'json' for structured data");
const themeArg = z.enum(['light', 'dark']).default('light').describe('Which theme to resolve semantic colors in');

type Result = { content: { type: 'text'; text: string }[]; isError?: boolean };

function reply(text: string): Result {
  if (text.length > CHARACTER_LIMIT) {
    text = text.slice(0, CHARACTER_LIMIT) + '\n\n…truncated. Narrow the request (a category, a query or a smaller limit).';
  }
  return { content: [{ type: 'text', text }] };
}
const fail = (text: string): Result => ({ content: [{ type: 'text', text: `Error: ${text}` }], isError: true });
const asJson = (v: unknown) => reply(JSON.stringify(v, null, 2));

const table = (head: string[], rows: (string | number | null | undefined)[][]) =>
  [`| ${head.join(' | ')} |`, `|${head.map(() => '---').join('|')}|`, ...rows.map((r) => `| ${r.map((c) => String(c ?? '—').replace(/\|/g, '\\|').replace(/\n/g, ' ')).join(' | ')} |`)].join('\n');

function findComponent(data: TripamiData, name: string): Component | undefined {
  const key = name.toLowerCase().replace(/^(tripami\.|tp)/, '').replace(/[^a-z]/g, '');
  return data.components.find((c) => c.name.toLowerCase() === key) ??
    data.components.find((c) => c.flutter.some((f) => f.toLowerCase().replace(/^tp/, '') === key));
}

function dartMarkdown(t: DartType): string {
  const parts = [`### \`${t.name}\` (${t.kind})`, t.doc || ''];
  for (const c of t.constructors ?? []) {
    parts.push(`**${c.name}(…)**`);
    if (c.params.length) {
      parts.push(table(['Param', 'Type', 'Required', 'Default', 'Notes'], c.params.map((p) => [`\`${p.name}\`${p.positional ? ' (positional)' : ''}`, p.type ? `\`${p.type}\`` : null, p.required ? 'yes' : '', p.default ? `\`${p.default}\`` : '', p.doc])));
    }
  }
  if (t.values) parts.push(`Values: ${t.values.map((v) => `\`${v}\``).join(', ')}`);
  if (t.members?.length) parts.push(table(['Member', 'Value', 'Notes'], t.members.map((m) => [`\`${t.name}.${m.name}\``, m.value ? `\`${m.value.slice(0, 80)}\`` : '', m.doc])));
  return parts.filter(Boolean).join('\n\n');
}

export function createServer(data: TripamiData = loadData()): McpServer {
  const server = new McpServer(
    { name: 'tripami-mcp-server', version: '1.0.0' },
    {
      instructions:
        'Tripami design system for a collaborative group-travel app (Flutter package `tripami_design_system`, plus a web/Claude Design mirror). ' +
        'Before writing UI code: look up components with tripami_get_component and values with tripami_get_tokens instead of inventing colors, sizes or durations. ' +
        'Use semantic colors first; tints and shades only where semantics do not cover it. Check pairings with tripami_check_contrast. ' +
        'After writing UI code, run tripami_review_code. For "can I…" or "how should…" questions, use tripami_search_guidelines.',
    },
  );

  server.registerTool(
    'tripami_get_tokens',
    {
      title: 'Get Tripami design tokens',
      description: `Returns Tripami design tokens for one category, with their value, usage rule and how to reference them in Flutter (Dart) and on the web (CSS).

Categories: colors (semantic, light + dark), ramps (tints and shades 50–950), type, spacing, radius, size, elevation, motion (durations, curves, springs), haptics, braid (Plan-view metrics), icons.

Args:
  - category: one of the categories above
  - query: optional filter on name or usage text (e.g. "text", "orange", "sheet")
  - format: 'markdown' (default) or 'json'

Use it instead of guessing values: e.g. "what's the card radius?" → category=radius; "which color for secondary text?" → category=colors, query=text.`,
      inputSchema: {
        category: z.enum(['colors', 'ramps', 'type', 'spacing', 'radius', 'size', 'elevation', 'motion', 'haptics', 'braid', 'icons']).describe('Token category'),
        query: z.string().max(100).optional().describe('Filter by name or usage, case-insensitive'),
        format,
      },
      annotations: { title: 'Get Tripami design tokens', ...READ_ONLY },
    },
    async ({ category, query, format: fmt }) => {
      const q = query?.toLowerCase();
      const hit = (...s: (string | null | undefined)[]) => !q || s.some((x) => x?.toLowerCase().includes(q));

      if (category === 'colors') {
        const rows = data.colors.filter((c) => hit(c.name, c.usage));
        if (fmt === 'json') return asJson(rows);
        return reply(`## Semantic colors (${rows.length})\nUse these for UI. Read in Flutter with \`final c = TPColors.of(context);\`.\n\n` +
          table(['Token', 'Light', 'Dark', 'Flutter', 'Usage'], rows.map((c) => [`\`${c.name}\``, c.light, c.dark, `\`${c.dart}\``, c.usage])));
      }
      if (category === 'ramps') {
        const names = Object.keys(data.ramps.ramps).filter((n) => hit(n, data.ramps.ramps[n].description));
        if (fmt === 'json') return asJson({ ...data.ramps, ramps: Object.fromEntries(names.map((n) => [n, data.ramps.ramps[n]])) });
        return reply(`## Tints and shades\nGrade fixes luminance, so contrast follows from the grade gap in any pair of hues: **≥400 → 3:1**, **≥500 → 4.5:1** (all text), **≥650 → 7:1**. White text works on every step from 500. Flutter: \`TPRamps.orange[100]\`; web: \`var(--orange-100)\`. For tinted UI prefer roles from tripami_suggest_tone.\n\n` +
          table(['Ramp', ...data.ramps.grades.map(String), 'Use'], names.map((n) => [`\`${n}\``, ...data.ramps.grades.map((g) => data.ramps.ramps[n].steps[g]), data.ramps.ramps[n].description])));
      }
      if (category === 'type') {
        const rows = data.type.filter((t) => hit(t.name, t.usage, t.group));
        if (fmt === 'json') return asJson(rows);
        return reply(`## Type styles\nFamilies: Bricolage Grotesque (display: trip names, day headings), Inter (all UI), Newsreader (journal text). Use \`.tabular\` in Flutter for numbers.\n\n` +
          table(['Style', 'Size / line', 'Weight', 'Tracking', 'Flutter', 'Usage'], rows.map((t) => [`\`${t.name}\``, `${t.fontSize} / ${t.lineHeight}`, t.fontWeight, t.letterSpacing, t.dart ? `\`${t.dart}\`` : null, t.usage])));
      }
      if (category === 'icons') {
        const rows = data.icons.filter((n) => hit(n));
        if (fmt === 'json') return asJson(rows);
        return reply(`## Icons (${rows.length})\nPhosphor, regular by default (\`TPIcons.name\`), fill only for active/toggled (\`TPIconsFill.name\`). Web: \`<Tripami.Icon name="…" />\`. No Material icons, no emoji as icons.\n\n${rows.map((n) => `\`${n}\``).join(', ')}`);
      }
      const rows = data.tokens[category].filter((t) => hit(t.name, t.usage, String(t.value)));
      if (fmt === 'json') return asJson(rows);
      const note: Record<string, string> = {
        motion: 'Calm by default (ease, gentle), playful only for people moments, at most once per screen. Always honor TPMotion.reduced(context).',
        haptics: 'A haptic answers the user\'s own touch or confirms the group finished something; remote changes never buzz. TP widgets already play theirs.',
        spacing: '4pt grid. Screen side margin is TPSpace.margin (24).',
      };
      return reply(`## ${category[0].toUpperCase() + category.slice(1)}\n${note[category] ?? ''}\n\n` +
        table(['Token', 'Value', 'Flutter', 'Usage'], rows.map((t) => [`\`${t.name}\``, typeof t.value === 'object' && t.value ? JSON.stringify(t.value) : (t.value as string | null), t.dart ? `\`${t.dart}\`` : null, t.usage])));
    },
  );

  server.registerTool(
    'tripami_list_components',
    {
      title: 'List Tripami components',
      description: `Lists every Tripami component with its group and the Flutter widget(s) that implement it.

Args:
  - group: optional filter (Actions, Inputs, Containers, People, Planning, Braid, Navigation, Motion, Foundations, Text…)
  - format: 'markdown' (default) or 'json'

Then call tripami_get_component for props, rules and code.`,
      inputSchema: { group: z.string().max(40).optional().describe('Filter by group, case-insensitive'), format },
      annotations: { title: 'List Tripami components', ...READ_ONLY },
    },
    async ({ group, format: fmt }) => {
      const rows = data.components.filter((c) => !group || c.group.toLowerCase() === group.toLowerCase());
      if (!rows.length) return fail(`No components in group "${group}". Groups: ${[...new Set(data.components.map((c) => c.group))].join(', ')}.`);
      const summary = rows.map((c) => ({ name: c.name, group: c.group, flutter: c.flutter, summary: c.guidance.split('\n')[0] }));
      if (fmt === 'json') return asJson({ count: summary.length, components: summary, flutterOnly: data.flutterOnly });
      return reply(`## Tripami components (${rows.length})\n\n` +
        table(['Component', 'Group', 'Flutter', 'What it is'], summary.map((c) => [c.name, c.group, c.flutter.map((f) => `\`${f}\``).join(', '), c.summary])) +
        (group ? '' : `\n\nFlutter-only building blocks: ${data.flutterOnly.map((f) => `\`${f}\``).join(', ')}.`));
    },
  );

  server.registerTool(
    'tripami_get_component',
    {
      title: 'Get a Tripami component',
      description: `Full spec for one component: when to use it, rules, motion and haptics, Flutter API (constructors, params with types and defaults) and web props.

Also accepts any Flutter API name (TPMotion, TPColors, TPMember, TPTone, TPRamps, TPHaptics, TripamiTheme…) and returns its documented members.

Args:
  - name: component or class name, e.g. "PollCard", "TPPollCard", "button", "TPMotion"
  - platform: 'flutter', 'web' or 'both' (default)
  - format: 'markdown' (default) or 'json'`,
      inputSchema: {
        name: z.string().min(2).max(60).describe('Component or Flutter class name'),
        platform: z.enum(['flutter', 'web', 'both']).default('both'),
        format,
      },
      annotations: { title: 'Get a Tripami component', ...READ_ONLY },
    },
    async ({ name, platform, format: fmt }) => {
      const comp = findComponent(data, name);
      const dartByName = new Map(data.dart.map((d) => [d.name.toLowerCase(), d]));
      if (!comp) {
        const d = dartByName.get(name.toLowerCase()) ?? dartByName.get('tp' + name.toLowerCase());
        if (d) return fmt === 'json' ? asJson(d) : reply(dartMarkdown(d));
        const close = [...data.components.map((c) => c.name), ...data.dart.map((t) => t.name)].filter((n) => n.toLowerCase().includes(name.toLowerCase().replace(/^tp/, '').slice(0, 4)));
        return fail(`No component or Flutter API named "${name}".${close.length ? ` Close matches: ${close.slice(0, 8).join(', ')}.` : ''} Use tripami_list_components to browse.`);
      }
      const dart = comp.flutter.map((n) => dartByName.get(n.toLowerCase())!).filter(Boolean);
      if (fmt === 'json') return asJson({ ...comp, flutterApi: platform === 'web' ? undefined : dart, web: platform === 'flutter' ? undefined : comp.web });
      const parts = [`# ${comp.name} (${comp.group})`, comp.guidance];
      if (platform !== 'web') {
        parts.push('## Flutter');
        if (comp.flutterNote) parts.push(comp.flutterNote);
        parts.push(...dart.map(dartMarkdown));
      }
      if (platform !== 'flutter' && comp.web.props.length) {
        parts.push(`## Web (\`<${comp.web.component}>\`)`, table(['Prop', 'Type', 'Required'], comp.web.props.map((p) => [`\`${p.name}\``, `\`${p.type}\``, p.required ? 'yes' : ''])));
      }
      return reply(parts.join('\n\n'));
    },
  );

  server.registerTool(
    'tripami_check_contrast',
    {
      title: 'Check Tripami color contrast',
      description: `Checks a text/background pairing against WCAG and Tripami's grade rule.

Each color can be a semantic token ("text-secondary", "accent", "canvas"), a ramp step ("orange-100", "navy 700"), a CSS var ("var(--accent)"), a hex ("#525D6E") or a Flutter Color ("Color(0xFF525D6E)").

Args:
  - foreground: text or icon color
  - background: the color behind it
  - theme: 'light' (default) or 'dark', for semantic tokens that differ by theme
  - format: 'markdown' (default) or 'json'

Returns the ratio, AA/AAA verdicts and both colors' grades. Grades: any two colors ≥500 apart pass 4.5:1, ≥400 pass 3:1.`,
      inputSchema: {
        foreground: z.string().min(1).max(60).describe('Text/icon color: token, ramp step or hex'),
        background: z.string().min(1).max(60).describe('Background color: token, ramp step or hex'),
        theme: themeArg,
        format,
      },
      annotations: { title: 'Check Tripami color contrast', ...READ_ONLY },
    },
    async ({ foreground, background, theme, format: fmt }) => {
      const fg = resolveColor(data, foreground, theme as Theme);
      if ('error' in fg) return fail(fg.error);
      const bg = resolveColor(data, background, theme as Theme);
      if ('error' in bg) return fail(bg.error);
      const result = wcag(contrast(fg.rgb, bg.rgb));
      const gf = Math.round(gradeOf(fg.rgb)), gb = Math.round(gradeOf(bg.rgb));
      const verdict = result.aaaText ? 'Passes AAA for all text.' : result.aaText ? 'Passes AA for all text.' : result.aaLargeText ? 'Large text (≥18pt, or 14pt bold), icons and UI marks only; fails for body text.' : 'Fails: decorative use only.';
      const payload = { foreground: { ...fg, rgb: undefined, grade: gf }, background: { ...bg, rgb: undefined, grade: gb }, theme, ...result, gradeGap: Math.abs(gf - gb), verdict };
      if (fmt === 'json') return asJson(payload);
      return reply(`**${result.ratio}:1**: ${verdict}\n\n` + table(['', 'Color', 'Hex', 'Grade', 'Flutter'], [
        ['Text', fg.label, fg.hex, gf, fg.dart ? `\`${fg.dart}\`` : null],
        ['Background', bg.label, bg.hex, gb, bg.dart ? `\`${bg.dart}\`` : null],
      ]) + `\n\nGrade gap ${Math.abs(gf - gb)} (≥500 is always AA). AA text ${result.aaText ? '✓' : '✗'} · AA large/UI ${result.aaLargeText ? '✓' : '✗'} · AAA ${result.aaaText ? '✓' : '✗'}`);
    },
  );

  server.registerTool(
    'tripami_suggest_tone',
    {
      title: 'Suggest Tripami tone roles',
      description: `Returns the contrast-safe roles for one tint-and-shade ramp in light and dark: subtle (tinted background), muted (hover/selected), border, text, solid (filled badge), solidPressed and onSolid, with hex, Flutter and CSS for each.

Use for tinted banners, status rows, a member's highlight, badges. Flutter: TPTone.of(context, TPRamps.green).subtle.

Args:
  - ramp: neutral, navy, orange, red, green, amber, or a member color (lagoon, sky, iris, plum, rose, fern, olive, slate)
  - format: 'markdown' (default) or 'json'`,
      inputSchema: { ramp: z.string().min(2).max(20).describe('Ramp name, e.g. "green"'), format },
      annotations: { title: 'Suggest Tripami tone roles', ...READ_ONLY },
    },
    async ({ ramp, format: fmt }) => {
      const r = data.ramps.ramps[ramp.toLowerCase()];
      if (!r) return fail(`No ramp "${ramp}". Ramps: ${Object.keys(data.ramps.ramps).join(', ')}.`);
      const name = ramp.toLowerCase();
      const roles: [string, number | 'white', number, string][] = [
        ['subtle', 50, 950, 'Tinted background'], ['muted', 100, 900, 'Hover, pressed or selected tint'], ['border', 200, 800, 'Decorative outline on a tint'],
        ['text', 700, 200, 'Tinted text and icons (≥7:1 on subtle)'], ['solid', 600, 400, 'Filled badge or strong banner'],
        ['solidPressed', 700, 300, 'Pressed fill'], ['onSolid', 'white', 950, 'Text on solid (≥4.5:1)'],
      ];
      const step = (g: number | 'white') => (g === 'white' ? { grade: 0, hex: '#FFFFFF', css: '#FFFFFF' } : { grade: g, hex: r.steps[g], css: `var(--${name}-${g})` });
      const out = roles.map(([role, l, d, use]) => ({ role, use, light: step(l), dark: step(d), dart: `TPTone.of(context, TPRamps.${name}).${role}` }));
      if (fmt === 'json') return asJson({ ramp: name, description: r.description, roles: out });
      return reply(`## ${name} tone roles\n${r.description}\n\n` +
        table(['Role', 'Light', 'Dark', 'Use'], out.map((o) => [`\`${o.role}\``, `${o.light.hex} (${o.light.grade === 0 ? 'white' : o.light.grade})`, `${o.dark.hex} (${o.dark.grade})`, o.use])) +
        `\n\nFlutter:\n\`\`\`dart\nfinal t = TPTone.of(context, TPRamps.${name});\nContainer(color: t.subtle, child: Text('…', style: TPType.body.copyWith(color: t.text)));\n\`\`\`\nWeb (light): \`background: var(--${name}-50); color: var(--${name}-700);\``);
    },
  );

  server.registerTool(
    'tripami_match_color',
    {
      title: 'Match a color to Tripami tokens',
      description: `Finds the Tripami tokens closest to any color (perceptual OKLab distance), for migrating hard-coded colors or checking a mockup.

Args:
  - color: hex ("#4A6FA5"), Flutter Color(0xFF…) or CSS rgb
  - limit: how many matches (1–10, default 5)
  - format: 'markdown' (default) or 'json'

ΔE under ~2 is the same color to the eye; over ~5 means it's off-system. Semantic tokens are listed before ramp steps when equally close.`,
      inputSchema: { color: z.string().min(3).max(40), limit: z.number().int().min(1).max(10).default(5), format },
      annotations: { title: 'Match a color to Tripami tokens', ...READ_ONLY },
    },
    async ({ color, limit, format: fmt }) => {
      const rgbMatch = color.match(/rgba?\((\d+),\s*(\d+),\s*(\d+)/);
      const resolved = rgbMatch ? null : resolveColor(data, color, 'light');
      const rgb = rgbMatch ? ([1, 2, 3].map((i) => parseInt(rgbMatch[i], 10) / 255) as [number, number, number]) : resolved && !('error' in resolved) ? resolved.rgb : null;
      if (!rgb) return fail(`Couldn't read "${color}" as a color. Use a hex like #4A6FA5, Color(0xFF4A6FA5) or rgb(74, 111, 165).`);
      const near = nearestColors(data, rgb, limit);
      if (fmt === 'json') return asJson({ color, grade: Math.round(gradeOf(rgb)), matches: near });
      const verdict = near[0].deltaE < 2 ? `Same as \`${near[0].name}\`: use the token.` : near[0].deltaE < 5 ? `Close to \`${near[0].name}\`.` : 'Off-system: no token is close. Pick the role you need (tripami_get_tokens) rather than keeping this color.';
      return reply(`${verdict}\n\n` + table(['Token', 'ΔE', 'Flutter', 'Web'], near.map((n) => [`\`${n.name}\``, n.deltaE, `\`${n.dart}\``, `\`${n.css}\``])) + `\n\nGrade of ${color}: ${Math.round(gradeOf(rgb))}.`);
    },
  );

  server.registerTool(
    'tripami_search_guidelines',
    {
      title: 'Search Tripami guidelines',
      description: `Searches the Tripami brand book, foundations, component guidance and app-integration docs. Use for rules and rationale: "can the accent be a button?", "how does the braid scale to 50 people?", "when do I use the playful spring?", "copy for empty states".

Args:
  - query: keywords or a question
  - limit: sections to return (1–10, default 5)
  - format: 'markdown' (default, full section text) or 'json'`,
      inputSchema: { query: z.string().min(2).max(200), limit: z.number().int().min(1).max(10).default(5), format },
      annotations: { title: 'Search Tripami guidelines', ...READ_ONLY },
    },
    async ({ query, limit, format: fmt }) => {
      const hits = searchGuidelines(data, query, limit);
      if (!hits.length) return reply(`No guidelines match "${query}". Try broader words (e.g. "accent", "motion", "braid", "copy", "contrast").`);
      if (fmt === 'json') return asJson(hits.map(({ text: _t, ...h }) => h));
      return reply(hits.map((h) => `## ${h.breadcrumb}\n_${h.source}_\n\n${h.text.length > 2500 ? h.text.slice(0, 2500) + '…' : h.text}`).join('\n\n---\n\n'));
    },
  );

  server.registerTool(
    'tripami_review_code',
    {
      title: 'Review code against Tripami',
      description: `Reviews Flutter (Dart) or web (JSX/CSS) UI code against Tripami and returns findings with line numbers and concrete fixes.

Flags: hard-coded colors (with the nearest token), Material colors/icons/curves, hard-coded font sizes, spacing, radii and durations (with the token to use), raw haptics, platform buttons, the accent used as a button fill, brand-orange on text, bold UI text, tappables without press feedback, and exclamation marks in copy.

Args:
  - code: the source to review (up to ~60k characters)
  - language: 'dart', 'web' or 'auto' (default)
  - format: 'markdown' (default) or 'json'

It's a fast static check, not a compiler: confirm suggestions in context.`,
      inputSchema: {
        code: z.string().min(1).max(60_000),
        language: z.enum(['dart', 'web', 'auto']).default('auto'),
        format,
      },
      annotations: { title: 'Review code against Tripami', ...READ_ONLY },
    },
    async ({ code, language, format: fmt }) => {
      const { language: lang, findings } = reviewCode(data, code, language);
      const counts = { error: 0, warning: 0, info: 0 };
      findings.forEach((f) => counts[f.severity]++);
      if (fmt === 'json') return asJson({ language: lang, counts, findings });
      if (!findings.length) return reply(`No issues found (${lang}). It uses tokens and TP components where this check can tell.`);
      return reply(`**${findings.length} finding(s)** in ${lang}: ${counts.error} error, ${counts.warning} warning, ${counts.info} info.\n\n` +
        findings.map((f) => `- **L${f.line}** [${f.severity}] \`${f.found.slice(0, 80)}\`: ${f.message} ${f.suggestion}`).join('\n'));
    },
  );

  server.registerTool(
    'tripami_get_overview',
    {
      title: 'Tripami overview',
      description: `A short orientation: what Tripami is, its six rules, the foundations at a glance, how to install and theme the Flutter package, and links (Claude Design system, repo). Call this first when starting Tripami work.`,
      inputSchema: {},
      annotations: { title: 'Tripami overview', ...READ_ONLY },
    },
    async () => {
      const pick = (source: string, title: RegExp) => data.guidelines.find((s) => s.source === source && title.test(s.title));
      const rules = pick('claude-design/project/README.md', /Six rules/);
      const minute = pick('README.md', /one minute/);
      const install = pick('docs/05-using-in-the-app.md', /Add the package/);
      const theme = pick('docs/05-using-in-the-app.md', /Turn it on/);
      return reply([
        '# Tripami design system',
        'A collaborative group-travel app: "Marriott Bonvoy\'s editorial restraint + a modern social travel diary + Apple-level utility". Product UI is calmer than marketing.',
        rules && `## ${rules.title}\n${rules.text}`,
        minute && `## ${minute.title}\n${minute.text}`,
        install && `## Install\n${install.text}`,
        theme && `## Theme\n${theme.text}`,
        `## Links\n- Claude Design system: ${data.links.claudeDesign}\n- Repo: ${data.links.repo}\n\nData built ${data.generatedAt}${data.commit ? ` from ${data.commit.slice(0, 7)}` : ''}.`,
      ].filter(Boolean).join('\n\n'));
    },
  );

  return server;
}
