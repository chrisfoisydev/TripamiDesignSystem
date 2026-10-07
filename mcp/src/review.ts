// Reviews Flutter or web code against the Tripami rules: hard-coded values that
// should be tokens, raw platform widgets that have TP equivalents, and brand rules.
import { deltaE, parseHex, type RGB } from './color.js';
import type { TripamiData } from './data.js';

export type Severity = 'error' | 'warning' | 'info';
export interface Finding { line: number; severity: Severity; rule: string; found: string; message: string; suggestion: string }

interface Candidate { name: string; dart: string; css: string; rgb: RGB; semantic: boolean }

export function colorCandidates(data: TripamiData): Candidate[] {
  const out: Candidate[] = [];
  for (const c of data.colors) {
    for (const [value, theme] of [[c.light, 'light'], [c.dark, 'dark']] as const) {
      const rgb = value ? parseHex(value) : null;
      if (rgb) out.push({ name: c.dark ? `${c.name} (${theme})` : c.name, dart: c.dart, css: c.css, rgb, semantic: true });
    }
  }
  for (const [ramp, { steps }] of Object.entries(data.ramps.ramps)) {
    for (const [g, hex] of Object.entries(steps)) {
      out.push({ name: `${ramp}-${g}`, dart: `TPRamps.${ramp}[${g}]`, css: `var(--${ramp}-${g})`, rgb: parseHex(hex)!, semantic: false });
    }
  }
  return out;
}

/** Nearest tokens to a color; semantic tokens win ties so UI code reaches for them first. */
export function nearestColors(data: TripamiData, rgb: RGB, limit = 3) {
  return colorCandidates(data)
    .map((c) => ({ ...c, deltaE: deltaE(rgb, c.rgb) - (c.semantic ? 0.5 : 0) }))
    .sort((a, b) => a.deltaE - b.deltaE)
    .slice(0, limit)
    .map((c) => ({ name: c.name, dart: c.dart, css: c.css, deltaE: Math.max(0, Math.round((c.deltaE + (c.semantic ? 0.5 : 0)) * 10) / 10) }));
}

function nearestNumber<T extends { value: unknown }>(tokens: T[], n: number) {
  const parsed = tokens.map((t) => ({ ...t, num: parseFloat(String(t.value)) })).filter((t) => !Number.isNaN(t.num));
  return parsed.sort((a, b) => Math.abs(a.num - n) - Math.abs(b.num - n))[0];
}

const HAPTIC_MAP: Record<string, string> = {
  selectionClick: 'TPHaptics.select()', lightImpact: 'TPHaptics.join()', mediumImpact: 'TPHaptics.reorder()',
  heavyImpact: 'TPHaptics.warning()', vibrate: 'TPHaptics.warning()',
};

export function detectLanguage(code: string): 'dart' | 'web' {
  return /\b(Widget|BuildContext|const\s+\w+\(|EdgeInsets|TextStyle|setState)\b/.test(code) ? 'dart' : 'web';
}

export function reviewCode(data: TripamiData, code: string, language: 'dart' | 'web' | 'auto' = 'auto'): { language: 'dart' | 'web'; findings: Finding[] } {
  const lang = language === 'auto' ? detectLanguage(code) : language;
  const findings: Finding[] = [];
  const lines = code.split('\n');
  const add = (line: number, severity: Severity, rule: string, found: string, message: string, suggestion: string) =>
    findings.push({ line: line + 1, severity, rule, found: found.trim(), message, suggestion });
  const colorSuggestion = (rgb: RGB, dartSide: boolean) => {
    const near = nearestColors(data, rgb, 2);
    const best = near[0];
    const exact = best.deltaE < 1;
    const fmt = (c: (typeof near)[number]) => `${dartSide ? c.dart : c.css} (${c.name}, ΔE ${c.deltaE})`;
    return (exact ? 'Use ' : 'Closest tokens: ') + near.map(fmt).join(' or ') + (exact ? '' : '. If none fits, the color is off-system.');
  };
  const spacing = data.tokens.spacing;
  const radius = data.tokens.radius;
  const durations = data.tokens.motion.filter((m) => /^Duration\(milliseconds: \d+\)$/.test(m.value as string ?? ''))
    .map((m) => ({ name: m.name, value: parseInt((m.value as string).match(/\d+/)![0], 10), dart: m.dart }));

  lines.forEach((text, i) => {
    const code = text.replace(/\/\/.*$/, '');
    if (!code.trim()) return;

    if (lang === 'dart') {
      for (const m of code.matchAll(/Color\(0x([0-9a-fA-F]{2})([0-9a-fA-F]{6})\)/g)) {
        add(i, 'error', 'hard-coded-color', m[0], 'Hard-coded color.', colorSuggestion(parseHex(m[2])!, true));
      }
      for (const m of code.matchAll(/\bColors\.(\w+)/g)) {
        if (m[1] === 'transparent') continue;
        add(i, 'error', 'material-color', m[0], 'Material palette color.', 'Use a semantic color from TPColors.of(context) (textPrimary, surface, accent…). White text on photos is c.textOnImage.');
      }
      for (const m of code.matchAll(/fontSize:\s*([\d.]+)/g)) {
        const size = parseFloat(m[1]);
        const style = data.type.filter((t) => t.dart).sort((a, b) => Math.abs(parseFloat(a.fontSize) - size) - Math.abs(parseFloat(b.fontSize) - size))[0];
        add(i, 'error', 'hard-coded-type', m[0], 'Hard-coded font size.', `Use a TPType style${style ? `, e.g. ${style.dart} (${style.fontSize}, ${style.usage.split('.')[0]})` : ''}.`);
      }
      if (/fontWeight:\s*FontWeight\.(bold|w[789]00)/.test(code) && !/TPType\.(display|diaryHeading)/.test(code)) {
        add(i, 'warning', 'bold-ui-text', code.match(/fontWeight:\s*FontWeight\.\w+/)![0], 'Bold UI text.', 'Tripami UI text is never bold: use TPType styles (Inter at 400–500). Heavy weights belong to TPType.display / diaryHeading only.');
      }
      for (const m of code.matchAll(/\bIcons\.(\w+)/g)) {
        add(i, 'error', 'material-icon', m[0], 'Material icon.', `Use TPIcons (outline) or TPIconsFill (active/toggled). Available: ${data.icons.slice(0, 12).join(', ')}… (${data.icons.length} in all).`);
      }
      for (const m of code.matchAll(/HapticFeedback\.(\w+)/g)) {
        add(i, 'warning', 'raw-haptic', m[0], 'Raw platform haptic.', `Use ${HAPTIC_MAP[m[1]] ?? 'TPHaptics'} so it respects TPHaptics.enabled. TP widgets already play their own haptics; don't double up.`);
      }
      for (const m of code.matchAll(/Duration\(milliseconds:\s*(\d+)\)/g)) {
        const ms = parseInt(m[1], 10);
        const near = durations.sort((a, b) => Math.abs(a.value - ms) - Math.abs(b.value - ms))[0];
        add(i, 'warning', 'hard-coded-duration', m[0], 'Hard-coded duration.', near ? `Use ${near.dart} (${near.value}ms)${near.value !== ms ? ' or a spring duration (TPMotion.gentleDuration / snappyDuration / playfulDuration)' : ''}.` : 'Use a TPMotion duration.');
      }
      for (const m of code.matchAll(/\bCurves\.(\w+)/g)) {
        add(i, 'warning', 'material-curve', m[0], 'Material curve.', 'Use TPMotion.ease (everyday), TPMotion.gentleCurve / snappyCurve, or playfulCurve for people moments only.');
      }
      for (const m of code.matchAll(/(EdgeInsets\.(?:all|symmetric|only|fromLTRB)\(([^)]*)\)|SizedBox\((?:height|width):\s*([\d.]+))/g)) {
        const nums = (m[2] ?? m[3] ?? '').match(/(?<![\w.])\d+(?:\.\d+)?(?![\w.])/g)?.map(Number).filter((n) => n > 0) ?? [];
        if (!nums.length) continue;
        const sugg = [...new Set(nums)].map((n) => {
          const t = nearestNumber(spacing, n);
          return t ? `${n} → ${t.dart} (${t.value})${parseFloat(String(t.value)) !== n ? ' (off the 4pt scale)' : ''}` : String(n);
        });
        add(i, 'warning', 'hard-coded-spacing', m[0], 'Hard-coded spacing.', `Use TPSpace: ${sugg.join(', ')}. Screen side margin is TPSpace.margin.`);
      }
      for (const m of code.matchAll(/(?:BorderRadius\.circular|Radius\.circular)\(([\d.]+)\)/g)) {
        const t = nearestNumber(radius, parseFloat(m[1]));
        add(i, 'warning', 'hard-coded-radius', m[0], 'Hard-coded radius.', t ? `Use ${t.dart} (${t.value}: ${t.usage})` : 'Use TPRadius.');
      }
      if (/\b(ElevatedButton|MaterialButton|RaisedButton)\(/.test(code)) {
        add(i, 'warning', 'raw-button', code.match(/\b(ElevatedButton|MaterialButton|RaisedButton)\(/)![0], 'Platform button.', 'Use TPButton.primary (one per screen), .secondary, .tertiary or .destructive. They carry press feedback and the primary haptic.');
      }
      if (/\.accent\b/.test(code) && /(backgroundColor|ButtonStyle|FilledButton|ElevatedButton)/.test(code)) {
        add(i, 'error', 'accent-fill', code.match(/\S*\.accent\b/)![0], 'Accent used as a button fill.', 'The accent marks state only (you / now / selected / needs you), never a button fill. Primary actions are ink pills: TPButton.primary.');
      }
      if (/brandOrange/.test(code) && /(TextStyle|Text\(|Icon\()/.test(code)) {
        add(i, 'error', 'brand-orange-ui', 'brandOrange', 'Brand orange on text or icons.', 'brand-orange is 3.0:1 on white: logo and brand moments only. For state use accent; for tints use TPRamps.orange via TPTone.');
      }
      if (/GestureDetector\(/.test(code) && /onTap/.test(lines.slice(i, i + 4).join(' '))) {
        add(i, 'info', 'no-press-feedback', 'GestureDetector', 'Tap target without press feedback.', 'Wrap custom tappables in TPPressable(onTap: …, haptic: TPHaptic.select) for the press scale and the right haptic.');
      }
    } else {
      for (const m of code.matchAll(/#([0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b/g)) {
        add(i, 'error', 'hard-coded-color', m[0], 'Hard-coded color.', colorSuggestion(parseHex(m[1])!, false));
      }
      for (const m of code.matchAll(/rgba?\((\d+),\s*(\d+),\s*(\d+)/g)) {
        const rgb = [m[1], m[2], m[3]].map((x) => parseInt(x, 10) / 255) as RGB;
        add(i, 'warning', 'hard-coded-color', m[0], 'Hard-coded color.', colorSuggestion(rgb, false) + ' Overlays use var(--glass), var(--dim) or var(--scrim-end).');
      }
      for (const m of code.matchAll(/font-?[sS]ize:\s*['"]?([\d.]+)px/g)) {
        const size = parseFloat(m[1]);
        const style = [...data.type].sort((a, b) => Math.abs(parseFloat(a.fontSize) - size) - Math.abs(parseFloat(b.fontSize) - size))[0];
        add(i, 'error', 'hard-coded-type', m[0], 'Hard-coded font size.', `Use a type class, e.g. class="${style.name}" (${style.fontSize}).`);
      }
      for (const m of code.matchAll(/\b(margin|padding|gap|row-gap|column-gap)(?:-\w+)?:\s*([^;'"}]+)/g)) {
        const nums = m[2].match(/(\d+(?:\.\d+)?)px/g)?.map((n) => parseFloat(n)).filter((n) => n > 0) ?? [];
        if (!nums.length) continue;
        const sugg = [...new Set(nums)].map((n) => { const t = nearestNumber(spacing, n); return `${n}px → ${t?.css ?? '?'}`; });
        add(i, 'warning', 'hard-coded-spacing', m[0], 'Hard-coded spacing.', `Use spacing tokens: ${sugg.join(', ')}.`);
      }
      for (const m of code.matchAll(/border-?[rR]adius:\s*['"]?(\d+)px/g)) {
        const t = nearestNumber(radius, parseFloat(m[1]));
        add(i, 'warning', 'hard-coded-radius', m[0], 'Hard-coded radius.', `Use ${t?.css ?? 'a radius token'}.`);
      }
      if (/navigator\.vibrate/.test(code)) {
        add(i, 'warning', 'raw-haptic', 'navigator.vibrate', 'Raw vibration call.', "Use Tripami.haptic('select' | 'join' | 'reorder' | 'success' | 'warning').");
      }
      if (/var\(--accent\)/.test(code) && /background/.test(code) && /(button|btn)/i.test(lines.slice(Math.max(0, i - 3), i + 1).join(' '))) {
        add(i, 'error', 'accent-fill', 'var(--accent)', 'Accent used as a button fill.', 'The accent marks state only. Primary actions are the ink pill: <Tripami.Button>.');
      }
    }
    // Copy rules apply on both platforms.
    for (const m of code.matchAll(/(['"`])([^'"`]*[A-Za-z][^'"`]*!)\1/g)) {
      if (/^[!=]/.test(m[2]) || m[2].includes('!=')) continue;
      add(i, 'info', 'copy-exclamation', m[0], 'Exclamation mark in copy.', 'System copy is plain and calm: no exclamation marks ("Everyone’s in." not "Everyone’s in!").');
    }
  });
  return { language: lang, findings };
}
