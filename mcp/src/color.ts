// Color math: parsing, WCAG contrast, Tripami grades and perceptual distance.

export type RGB = [number, number, number]; // 0–1 sRGB

/** Tripami's grade law: luminance + 0.05 = 1.05 · BASE^(−grade/500). See tool/ramps/color.py. */
export const GRADE_BASE = 4.56;

export function parseHex(input: string): RGB | null {
  const m = input.trim().match(/^#?([0-9a-f]{3}|[0-9a-f]{6}|[0-9a-f]{8})$/i);
  if (!m) return null;
  let h = m[1];
  if (h.length === 3) h = h.split('').map((c) => c + c).join('');
  if (h.length === 8) {
    // Flutter's 0xAARRGGBB order only reaches here via toHex; plain input is #RRGGBBAA.
    if (h.slice(6).toLowerCase() !== 'ff') return null;
    h = h.slice(0, 6);
  }
  return [0, 2, 4].map((i) => parseInt(h.slice(i, i + 2), 16) / 255) as RGB;
}

export function toHex(rgb: RGB): string {
  return '#' + rgb.map((x) => Math.round(Math.min(1, Math.max(0, x)) * 255).toString(16).padStart(2, '0')).join('').toUpperCase();
}

/** WCAG 2 relative luminance. */
export function luminance([r, g, b]: RGB): number {
  const f = (c: number) => (c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
  return 0.2126 * f(r) + 0.7152 * f(g) + 0.0722 * f(b);
}

export function contrast(a: RGB, b: RGB): number {
  const la = luminance(a), lb = luminance(b);
  return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
}

/** Where a color sits on Tripami's 0 (white) – 1000 (black) grade scale. */
export function gradeOf(rgb: RGB): number {
  return (500 * Math.log(1.05 / (luminance(rgb) + 0.05))) / Math.log(GRADE_BASE);
}

export interface WcagResult {
  ratio: number;
  aaText: boolean; // 4.5:1
  aaLargeText: boolean; // 3:1
  aaaText: boolean; // 7:1
  uiComponents: boolean; // 3:1, WCAG 1.4.11
}

export function wcag(ratio: number): WcagResult {
  return { ratio: Math.round(ratio * 100) / 100, aaText: ratio >= 4.5, aaLargeText: ratio >= 3, aaaText: ratio >= 7, uiComponents: ratio >= 3 };
}

function toOklab([r, g, b]: RGB): [number, number, number] {
  const lin = (c: number) => (c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4);
  const [R, G, B] = [lin(r), lin(g), lin(b)];
  const l = Math.cbrt(0.4122214708 * R + 0.5363325363 * G + 0.0514459929 * B);
  const m = Math.cbrt(0.2119034982 * R + 0.6806995451 * G + 0.1073969566 * B);
  const s = Math.cbrt(0.0883024619 * R + 0.2817188376 * G + 0.6299787005 * B);
  return [
    0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s,
    1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s,
    0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s,
  ];
}

/** Perceptual distance (OKLab ΔE × 100). Under ~2 is hard to tell apart; under ~5 is close. */
export function deltaE(a: RGB, b: RGB): number {
  const [L1, a1, b1] = toOklab(a), [L2, a2, b2] = toOklab(b);
  return Math.hypot(L1 - L2, a1 - a2, b1 - b2) * 100;
}
