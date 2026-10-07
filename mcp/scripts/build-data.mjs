// Compiles the Tripami design system into one JSON file the MCP server serves.
//
//   node scripts/build-data.mjs [repoRoot] [outFile]
//
// Sources (all in this repo, so the server can never drift from them):
//   tokens/tokens.json                      tints and shades (DTCG)
//   claude-design/project/tokens.json       semantic colors, type, space, radius, size, shadow, braid
//   claude-design/project/components/*      component guidance and web props
//   lib/src/**/*.dart                       Flutter API: widgets, params, constants, docs
//   README.md, docs/*.md, claude-design/project/README.md   guidelines
import { readFileSync, readdirSync, writeFileSync, mkdirSync, existsSync, statSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = process.argv[2] ?? join(here, '..', '..');
const out = process.argv[3] ?? join(here, '..', 'dist', 'data', 'tripami.json');

const read = (p) => readFileSync(join(root, p), 'utf8');
const json = (p) => JSON.parse(read(p));
const camel = (s) => s.replace(/-(\w)/g, (_, c) => c.toUpperCase());

function walk(dir, ext) {
  const abs = join(root, dir);
  return readdirSync(abs).flatMap((f) => {
    const p = join(dir, f);
    return statSync(join(root, p)).isDirectory() ? walk(p, ext) : p.endsWith(ext) ? [p] : [];
  });
}

// ---------- Dart ----------

/// Doc comment (`///` lines) directly above line `i`, skipping annotations.
function docAbove(lines, i) {
  const doc = [];
  for (let j = i - 1; j >= 0; j--) {
    const t = lines[j].trim();
    if (t.startsWith('@')) continue;
    if (!t.startsWith('///')) break;
    doc.unshift(t.replace(/^\/\/\/ ?/, ''));
  }
  return doc.join('\n').trim();
}

/// Index just past the bracket that closes the one opening at `start`.
function matchClose(src, start) {
  const open = src[start];
  const close = { '{': '}', '(': ')', '[': ']' }[open];
  let depth = 0;
  for (let i = start; i < src.length; i++) {
    if (src[i] === open) depth++;
    else if (src[i] === close && --depth === 0) return i + 1;
  }
  return src.length;
}

function parseParams(text, fieldDocs, fieldTypes) {
  return text
    .split(/,(?![^(\[{]*[)\]}])/)
    .map((p) => p.trim())
    .filter((p) => p && !p.startsWith('super.'))
    .map((p) => {
      const m = p.match(/^(required\s+)?(?:([\w<>?.,\s]+?)\s+)?(?:this\.)?(\w+)(?:\s*=\s*([\s\S]+))?$/);
      if (!m) return null;
      const name = m[3];
      return {
        name,
        type: fieldTypes[name] ?? m[2]?.trim() ?? null,
        required: !!m[1],
        default: m[4]?.trim() ?? null,
        doc: fieldDocs[name] ?? '',
      };
    })
    .filter(Boolean);
}

function extractDart(file) {
  const src = read(file);
  const lines = src.split('\n');
  const lineAt = (idx) => src.slice(0, idx).split('\n').length - 1;
  const types = [];
  const re = /^(abstract final class|class|enum)\s+(TP\w+|TripamiTheme)\b([^{]*)\{/gm;
  for (let m; (m = re.exec(src)); ) {
    const [, kw, name, rest] = m;
    const bodyStart = m.index + m[0].length - 1;
    const bodyEnd = matchClose(src, bodyStart);
    const body = src.slice(bodyStart + 1, bodyEnd - 1);
    const bodyLines = body.split('\n');
    const kind = kw === 'enum' ? 'enum' : /extends (StatelessWidget|StatefulWidget)/.test(rest) ? 'widget' : kw === 'abstract final class' ? 'constants' : 'class';
    const entry = { name, kind, file, doc: docAbove(lines, lineAt(m.index)) };

    // Fields with their types and docs.
    const fieldDocs = {}, fieldTypes = {};
    bodyLines.forEach((l, i) => {
      const f = l.match(/^\s+final\s+([\w<>?,\s]+?)\s+(\w+);/);
      if (f) { fieldTypes[f[2]] = f[1].trim(); fieldDocs[f[2]] = docAbove(bodyLines, i); }
    });

    if (kind === 'enum') {
      const head = body.split(';')[0];
      entry.values = head.split(/,(?![^(]*\))/).map((v) => v.trim().split('(')[0]).filter((v) => /^\w+$/.test(v));
    }
    if (kind === 'widget' || kind === 'class') {
      entry.constructors = [];
      const cre = new RegExp(`(?:const\\s+)?${name}(\\.\\w+)?\\(\\{`, 'g');
      for (let c; (c = cre.exec(body)); ) {
        const pStart = c.index + c[0].length - 1;
        const params = body.slice(pStart + 1, matchClose(body, pStart) - 1);
        entry.constructors.push({ name: name + (c[1] ?? ''), params: parseParams(params, fieldDocs, fieldTypes) });
      }
      // Positional constructors like `TPAvatar(this.member, {...})` / `TPRamp(this.name, this.colors)`.
      const pre = new RegExp(`const\\s+${name}(\\.\\w+)?\\((this\\.\\w+[^{)]*?)(?:,\\s*\\{([\\s\\S]*?)\\})?\\)`, 'g');
      for (let c; (c = pre.exec(body)); ) {
        const positional = parseParams(c[2], fieldDocs, fieldTypes).map((p) => ({ ...p, required: true, positional: true }));
        entry.constructors.push({ name: name + (c[1] ?? ''), params: [...positional, ...(c[3] ? parseParams(c[3], fieldDocs, fieldTypes) : [])] });
      }
      if (!entry.constructors.length) delete entry.constructors;
    }
    // Public static members (constants and helpers).
    const members = [];
    bodyLines.forEach((l, i) => {
      const s = l.match(/^  static (?:const\s+)?(?:[\w<>?]+\s+)?(\w+)(?:\s*=\s*(.+?);|\s*\(|\s*=>)/);
      if (s && !s[1].startsWith('_')) members.push({ name: s[1], value: s[2]?.trim() ?? null, doc: docAbove(bodyLines, i) });
    });
    // Instance getters (TPTone roles, TPColors.brandOrange…).
    bodyLines.forEach((l, i) => {
      const g = l.match(/^  (?:\w+)\s+get\s+(\w+)\s*=>\s*(.+?);/);
      if (g && !g[1].startsWith('_')) members.push({ name: g[1], value: g[2].trim(), doc: docAbove(bodyLines, i), getter: true });
    });
    if (members.length) entry.members = members;
    types.push(entry);
  }
  // Top-level functions such as showTPSheet.
  const fre = /^(Future<[^>]+>|void|Widget)\s+(show\w+|\w+TP\w*)<?\w*>?\(\{([\s\S]*?)\}\)/gm;
  for (let m; (m = fre.exec(src)); ) {
    types.push({ name: m[2], kind: 'function', file, doc: docAbove(lines, lineAt(m.index)), constructors: [{ name: m[2], params: parseParams(m[3], {}, {}) }] });
  }
  return types;
}

const dart = walk('lib/src', '.dart').flatMap(extractDart);
const dartByName = Object.fromEntries(dart.map((t) => [t.name, t]));
const hasMember = (cls, member) => !!dartByName[cls]?.members?.some((m) => m.name === member);

// ---------- Tokens ----------

const cd = json('claude-design/project/tokens.json');
const dtcg = json('tokens/tokens.json');
const rampSrc = dtcg.color.ramp;
const rampNames = Object.keys(rampSrc).filter((k) => !k.startsWith('$'));
const rampTokenRe = new RegExp(`^(${rampNames.join('|')})-(\\d+)$`);

const colorDart = (name) => {
  const special = {
    'brand-navy': 'TPPalette.textPrimaryLight',
    'brand-orange': 'TPColors.of(context).brandOrange',
    'logo-ground': 'TPPalette.canvasLight',
    'scrim-end': 'TPColors.of(context).scrim (gradient)',
  };
  if (special[name]) return special[name];
  let m;
  if ((m = name.match(/^member-(\w+)$/))) return `TPMemberColor.${m[1]}.color`;
  if ((m = name.match(/^strand-(\w+)$/))) return `TPMemberColor.${m[1]}.strand(brightness)`;
  return `TPColors.of(context).${camel(name)}`;
};

const colors = cd.color.tokens
  .filter((t) => !rampTokenRe.test(t.name))
  .map((t) => ({
    name: t.name,
    light: typeof t.value === 'string' ? t.value : t.value.light,
    dark: typeof t.value === 'string' ? null : t.value.dark,
    usage: t.usage,
    dart: colorDart(t.name),
    css: `var(--${t.name})`,
  }));

const grades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950];
const ramps = Object.fromEntries(rampNames.map((n) => [n, {
  description: rampSrc[n].$description,
  steps: Object.fromEntries(grades.map((g) => [g, rampSrc[n][String(g)].$value])),
}]));

const typeStyles = cd.type.groups.flatMap((g) => g.styles.map((s) => {
  const dartName = camel(s.name);
  return {
    name: s.name, group: g.name, family: s.family ?? g.family,
    fontSize: s.fontSize, lineHeight: s.lineHeight, fontWeight: s.fontWeight, letterSpacing: s.letterSpacing,
    fontStyle: s.fontStyle ?? 'normal', usage: s.usage, sample: s.sample,
    dart: hasMember('TPType', dartName) ? `TPType.${dartName}` : null,
    css: `class="${s.name}"`,
  };
}));

function simple(list, cls, toMember) {
  return list.map((t) => {
    const member = toMember(t.name);
    return { name: t.name, value: t.value, usage: t.usage, dart: member && hasMember(cls, member) ? `${cls}.${member}` : null, css: `var(--${t.name})` };
  });
}

const tokens = {
  spacing: simple(cd.spacing.tokens, 'TPSpace', (n) => 's' + n.replace('space-', '')),
  radius: simple(cd.radius.tokens, 'TPRadius', (n) => camel(n.replace('radius-', ''))),
  size: simple(cd.size.tokens, 'TPSize', (n) => camel(n.replace('size-', ''))),
  elevation: simple(cd.shadow.tokens, 'TPElevation', () => null).map((t) => ({
    ...t,
    dart: { 'elevation-1': 'TPElevation.of(brightness)', 'elevation-2': 'TPElevation.of(brightness, floating: true)', 'elevation-3': 'TPElevation.sheet (applied by showTPSheet)' }[t.name] ?? null,
  })),
  braid: simple(cd.braid.tokens, 'TPBraidMetrics', (n) => ({ 'braid-two-sided-min': 'twoSidedMinWidth' })[n] ?? camel(n.replace('braid-', ''))),
  motion: (dartByName.TPMotion?.members ?? []).map((m) => ({ name: m.name, value: m.value, usage: m.doc, dart: `TPMotion.${m.name}` })),
  haptics: (dartByName.TPHaptics?.members ?? []).map((m) => ({ name: m.name, value: null, usage: m.doc, dart: `TPHaptics.${m.name}${m.name === 'enabled' ? '' : '()'}` })),
};

const icons = (dartByName.TPIcons?.members ?? []).filter((m) => m.value?.startsWith('IconData')).map((m) => m.name);

// ---------- Components ----------

const dts = read('claude-design/project/components/index.d.ts');
const webProps = {};
for (const m of dts.matchAll(/export interface (\w+)Props \{(.*)\}/g)) {
  webProps[m[1]] = m[2].split(';').map((p) => p.trim()).filter(Boolean).map((p) => {
    const pm = p.match(/^(\w+)(\?)?:\s*(.+)$/);
    return pm ? { name: pm[1], required: !pm[2], type: pm[3] } : null;
  }).filter(Boolean);
}

const flutterFor = {
  Sheet: ['showTPSheet'], Toast: [], TextField: [], Icon: ['TPIcons', 'TPIconsFill'],
  Haptics: ['TPHaptics', 'TPHaptic', 'TPPressable'], TintsAndShades: ['TPRamps', 'TPRamp'], Tones: ['TPTone'],
  BraidDayLarge: ['TPBraidDay', 'TPBraidGroup'], BraidDay: ['TPBraidDay', 'TPBraidMoment', 'TPBraidEvent'],
  PollCard: ['TPPollCard', 'TPPollOption'], Avatar: ['TPAvatar', 'TPMember', 'TPAvatarSize'], ReactionBar: ['TPReactionBar', 'TPReaction'],
  TabBar: ['TPTabBar', 'TPTabItem'], TripStrip: ['TPTripStrip', 'TPTripFact'], Button: ['TPButton', 'TPButtonVariant'],
  ItineraryItem: ['TPItineraryItem', 'TPItineraryState'],
};
const flutterNote = {
  Toast: 'Flutter: a standard `SnackBar` (`ScaffoldMessenger.of(context).showSnackBar`), styled by `TripamiTheme`.',
  TextField: 'Flutter: a standard `TextField`, styled by `TripamiTheme`\'s input theme.',
};

const compDir = 'claude-design/project/components';
const components = readdirSync(join(root, compDir))
  .filter((n) => existsSync(join(root, compDir, n, 'README.md')))
  .map((name) => {
    const readme = read(join(compDir, name, 'README.md'));
    const preview = existsSync(join(root, compDir, name, 'preview.html')) ? read(join(compDir, name, 'preview.html')) : '';
    const group = preview.match(/@dsCard group="([^"]+)"/)?.[1] ?? 'Other';
    const flutter = (flutterFor[name] ?? [`TP${name}`]).filter((n) => dartByName[n]);
    return {
      name, group,
      guidance: readme.replace(/^# .*\n+/, '').trim(),
      flutter, flutterNote: flutterNote[name] ?? null,
      web: { component: `Tripami.${name}`, props: webProps[name] ?? [] },
    };
  });

// Flutter-only building blocks that have no Claude Design card.
const covered = new Set(components.flatMap((c) => c.flutter));
const flutterOnly = dart.filter((t) => (t.kind === 'widget' || t.kind === 'function') && !covered.has(t.name)).map((t) => t.name);

// ---------- Guidelines ----------

function sections(path) {
  const text = read(path);
  const outS = [];
  const trail = [];
  let cur = null;
  for (const line of text.split('\n')) {
    const h = line.match(/^(#{1,4})\s+(.*)$/);
    if (h) {
      if (cur && cur.text.trim()) outS.push(cur);
      const level = h[1].length;
      trail.length = level - 1;
      trail[level - 1] = h[2].trim();
      cur = { source: path, title: h[2].trim(), breadcrumb: trail.filter(Boolean).join(' › '), text: '' };
    } else if (cur) {
      cur.text += line + '\n';
    } else {
      cur = { source: path, title: path, breadcrumb: path, text: line + '\n' };
    }
  }
  if (cur && cur.text.trim()) outS.push(cur);
  return outS.map((s) => ({ ...s, text: s.text.trim() }));
}

const guidelineFiles = ['README.md', 'claude-design/project/README.md', ...readdirSync(join(root, 'docs')).filter((f) => f.endsWith('.md')).sort().map((f) => `docs/${f}`)];
const guidelines = guidelineFiles.flatMap(sections);

let commit = null;
try {
  const head = read('.git/HEAD').trim();
  commit = head.startsWith('ref:') ? read(join('.git', head.slice(5))).trim() : head;
} catch { /* not a git checkout */ }

const data = {
  name: 'Tripami',
  generatedAt: new Date().toISOString(),
  commit,
  colors,
  ramps: { base: 4.56, grades, ramps },
  type: typeStyles,
  tokens,
  icons,
  components,
  flutterOnly,
  dart,
  guidelines,
  links: {
    claudeDesign: 'https://claude.ai/artifact/RfRNGEUDTXnSNNXjGYTbpa',
    repo: 'https://github.com/chrisfoisydev/TripamiDesignSystem',
  },
};

mkdirSync(dirname(out), { recursive: true });
writeFileSync(out, JSON.stringify(data));
console.error(`tripami data: ${colors.length} colors, ${rampNames.length} ramps, ${typeStyles.length} type styles, ${components.length} components, ${dart.length} Dart types, ${guidelines.length} guideline sections → ${relative(process.cwd(), out)}`);
