// The compiled design system (built from the repo by scripts/build-data.mjs).
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { parseHex, type RGB } from './color.js';

export type Theme = 'light' | 'dark';

export interface ColorToken { name: string; light: string; dark: string | null; usage: string; dart: string; css: string }
export interface SimpleToken { name: string; value: unknown; usage: string; dart: string | null; css?: string }
export interface TypeStyle {
  name: string; group: string; family: string; fontSize: string; lineHeight: string; fontWeight: number;
  letterSpacing: string; fontStyle: string; usage: string; sample?: string; dart: string | null; css: string;
}
export interface DartParam { name: string; type: string | null; required: boolean; default: string | null; doc: string; positional?: boolean }
export interface DartType {
  name: string; kind: 'widget' | 'class' | 'enum' | 'constants' | 'function'; file: string; doc: string;
  constructors?: { name: string; params: DartParam[] }[];
  members?: { name: string; value: string | null; doc: string; getter?: boolean }[];
  values?: string[];
}
export interface Component {
  name: string; group: string; guidance: string; flutter: string[]; flutterNote: string | null;
  web: { component: string; props: { name: string; required: boolean; type: string }[] };
}
export interface Section { source: string; title: string; breadcrumb: string; text: string }

export interface TripamiData {
  name: string;
  generatedAt: string;
  commit: string | null;
  colors: ColorToken[];
  ramps: { base: number; grades: number[]; ramps: Record<string, { description: string; steps: Record<string, string> }> };
  type: TypeStyle[];
  tokens: Record<'spacing' | 'radius' | 'size' | 'elevation' | 'braid' | 'motion' | 'haptics', SimpleToken[]>;
  icons: string[];
  components: Component[];
  flutterOnly: string[];
  dart: DartType[];
  guidelines: Section[];
  links: { claudeDesign: string; repo: string };
}

let cached: TripamiData | null = null;

export function loadData(path = process.env.TRIPAMI_DATA ?? fileURLToPath(new URL('../data/tripami.json', import.meta.url))): TripamiData {
  if (!cached) cached = JSON.parse(readFileSync(path, 'utf8')) as TripamiData;
  return cached;
}

/** A color the tools can work with, resolved from a token name, a ramp step or a hex value. */
export interface ResolvedColor { input: string; label: string; hex: string; rgb: RGB; kind: 'semantic' | 'ramp' | 'hex'; dart?: string; css?: string }

export function resolveColor(data: TripamiData, input: string, theme: Theme): ResolvedColor | { error: string } {
  const raw = input.trim();
  const key = raw.toLowerCase().replace(/^var\(--(.+)\)$/, '$1').replace(/^--/, '').replace(/[\s._]+/g, '-');
  const named: Record<string, string> = { white: '#FFFFFF', black: '#000000' };
  if (named[key]) return { input: raw, label: key, hex: named[key], rgb: parseHex(named[key])!, kind: 'hex' };

  const ramp = key.match(/^([a-z]+)-?(\d{2,3})$/);
  if (ramp && data.ramps.ramps[ramp[1]]) {
    const hex = data.ramps.ramps[ramp[1]].steps[ramp[2]];
    if (!hex) return { error: `${ramp[1]} has no step ${ramp[2]}. Steps: ${data.ramps.grades.join(', ')}.` };
    return { input: raw, label: `${ramp[1]}-${ramp[2]}`, hex: hex.toUpperCase(), rgb: parseHex(hex)!, kind: 'ramp', dart: `TPRamps.${ramp[1]}[${ramp[2]}]`, css: `var(--${ramp[1]}-${ramp[2]})` };
  }

  const token = data.colors.find((c) => c.name === key || c.dart.endsWith(`.${raw}`));
  if (token) {
    const value = theme === 'dark' && token.dark ? token.dark : token.light;
    const rgb = parseHex(value);
    if (!rgb) return { error: `${token.name} is translucent (${value}); contrast depends on what's behind it. Check the color underneath instead.` };
    return { input: raw, label: token.name + (token.dark ? ` (${theme})` : ''), hex: value.toUpperCase(), rgb, kind: 'semantic', dart: token.dart, css: token.css };
  }

  const flutter = raw.match(/^(?:const\s+)?Color\(0x([0-9a-f]{2})([0-9a-f]{6})\)$/i);
  const rgb = flutter ? (flutter[1].toLowerCase() === 'ff' ? parseHex(flutter[2]) : null) : parseHex(raw);
  if (rgb) return { input: raw, label: raw, hex: '#' + (flutter ? flutter[2] : raw.replace('#', '')).toUpperCase().slice(0, 6), rgb, kind: 'hex' };

  const near = [...data.colors.map((c) => c.name), ...Object.keys(data.ramps.ramps).map((r) => `${r}-500`)]
    .filter((n) => n.includes(key.split('-')[0]))
    .slice(0, 5);
  return {
    error: `Unknown color "${raw}". Use a semantic token (e.g. text-primary, accent, canvas), a ramp step (e.g. orange-100, navy-700), or a hex value (#02203A).` +
      (near.length ? ` Did you mean: ${near.join(', ')}?` : ''),
  };
}
