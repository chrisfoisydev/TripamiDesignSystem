"""Generates Tripami's tints and shades.

    python3 tool/ramps/generate.py

Writes lib/src/foundations/tp_ramps.dart and the `color.ramp` group of
tokens/tokens.json. Edit ANCHORS here, never the outputs.

How a ramp is built:
1. Every step's luminance is fixed by its grade (see color.py), the same for
   every hue. That's what makes the contrast rules hold everywhere.
2. Hue and chroma come from the ramp's anchors: Tripami colours that already
   exist (the accent, the brand orange, each member colour). Between anchors
   they're interpolated in OKLCH; past the last anchor, chroma eases towards
   white and black.
3. Each step is solved for that luminance in OKLCH, pulled into sRGB by
   reducing chroma (never by shifting hue), then rounded to 8 bits.
"""
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
from color import (BASE, contrast, grade_of, hex_to_oklch, hex_to_rgb, in_gamut, linear_to_srgb,
                   luminance, luminance_for_grade, oklch_to_linear, rgb_to_hex)

ROOT = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
GRADES = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]

# name: (anchors, description)
ANCHORS = {
    'neutral': (['#FAFAF7', '#F2F1EC', '#E6E4DE', '#D6D3CB', '#66707F', '#525D6E',
                 '#334058', '#243045', '#1A2333', '#121A29', '#0B1220'],
                'Paper to ink: warm paper in the light steps, navy night in the dark ones. Surfaces, borders, secondary text.'),
    'navy': (['#02203A', '#12355A'], 'The logo navy. Brand surfaces, info states, illustration.'),
    'orange': (['#FFF1E8', '#FF7A3D', '#FC6316', '#B8400F', '#9A3409', '#3A1D10'],
               'Tripami orange, through the brand dot and the accent. State and brand moments only.'),
    'red': (['#FF6B8A', '#B3133F'], 'Crimson, from critical. Errors and destructive actions.'),
    'green': (['#6FCF97', '#2E7D4F'], 'From positive. Settled, confirmed, online.'),
    'amber': (['#E8C054', '#7A5A00'], 'From caution. You owe, heads-up.'),
    'lagoon': (['#0F9083', '#0B6B61'], 'Member colour.'),
    'sky': (['#3683C0', '#2F73A8'], 'Member colour.'),
    'iris': (['#6C79D1', '#5160C9'], 'Member colour.'),
    'plum': (['#966EBD', '#7F4FAE'], 'Member colour.'),
    'rose': (['#BF5D81', '#B2466E'], 'Member colour.'),
    'fern': (['#468B56', '#3F7D4E'], 'Member colour.'),
    'olive': (['#7F8235', '#66692B'], 'Member colour.'),
    'slate': (['#6E809D', '#4F5D75'], 'Member colour.'),
}


def _solve(target, chroma, hue):
    """The OKLCH colour with this hue whose luminance is `target`, chroma reduced to fit sRGB."""
    def at(L):
        c = chroma
        if not in_gamut(oklch_to_linear(L, c, hue)):
            lo, hi = 0.0, c
            for _ in range(40):
                mid = (lo + hi) / 2
                lo, hi = (mid, hi) if in_gamut(oklch_to_linear(L, mid, hue)) else (lo, mid)
            c = lo
        return tuple(linear_to_srgb(min(1, max(0, x))) for x in oklch_to_linear(L, c, hue))

    lo, hi = 0.0, 1.0
    for _ in range(60):
        mid = (lo + hi) / 2
        lo, hi = (mid, hi) if luminance(at(mid)) < target else (lo, mid)
    return at((lo + hi) / 2)


def _round(rgb, target):
    """8-bit rounding that keeps luminance as close to the target as possible."""
    options = [tuple(min(255, max(0, round(x * 255) + d)) / 255 for x in rgb) for d in range(-3, 4)]
    return min(options, key=lambda c: abs(luminance(c) - target))


def _chroma_hue(hex_color):
    _, c, h = hex_to_oklch(hex_color)
    return c, math.radians(h)


def ramp(anchors, ease_light=0.55, ease_dark=0.45):
    pts = sorted((grade_of(h), *_chroma_hue(h)) for h in anchors)
    out = {}
    for g in GRADES:
        if g <= pts[0][0]:
            g0, c, h = pts[0]
            c *= (g / g0) ** ease_light
        elif g >= pts[-1][0]:
            g0, c, h = pts[-1]
            c *= ((1000 - g) / (1000 - g0)) ** ease_dark
        else:
            for (g0, c0, h0), (g1, c1, h1) in zip(pts, pts[1:]):
                if g0 <= g <= g1:
                    u = (g - g0) / (g1 - g0)
                    if min(c0, c1) < 0.02:
                        # Near-grey anchors (the neutral ramp turning from warm to cool): blend in
                        # OKLab so the hue change passes through grey instead of round the wheel.
                        a = c0 * math.cos(h0) * (1 - u) + c1 * math.cos(h1) * u
                        b = c0 * math.sin(h0) * (1 - u) + c1 * math.sin(h1) * u
                        c, h = math.hypot(a, b), math.atan2(b, a)
                    else:
                        dh = (h1 - h0 + math.pi) % (2 * math.pi) - math.pi
                        c, h = c0 + (c1 - c0) * u, h0 + dh * u
                    break
        y = luminance_for_grade(g)
        out[g] = rgb_to_hex(_round(_solve(y, c, math.degrees(h) % 360), y))
    return out


def check(ramps):
    """Fail loudly if any colour breaks the published contrast rules."""
    colors = [(n, g, hex_to_rgb(h)) for n, r in ramps.items() for g, h in r.items()]
    for n1, g1, c1 in colors:
        for n2, g2, c2 in colors:
            gap = abs(g1 - g2)
            for need_gap, need in ((400, 3.0), (500, 4.5), (650, 7.0)):
                assert gap < need_gap or contrast(c1, c2) >= need, (n1, g1, n2, g2, contrast(c1, c2))


def write_dart(ramps):
    lines = [
        '// GENERATED by tool/ramps/generate.py. Do not edit; change the anchors there.',
        '',
        "import 'dart:ui';",
        '',
        "import 'tp_ramp.dart';",
        '',
        '/// Tripami tints and shades. See [TPRamp] for the contrast rules.',
        'abstract final class TPRamps {',
    ]
    for name, r in ramps.items():
        lines.append(f'  /// {ANCHORS[name][1]}')
        lines.append(f"  static const {name} = TPRamp('{name}', [")
        lines += [f'    Color(0xFF{r[g][1:]}), // {g}' for g in GRADES]
        lines.append('  ]);')
        lines.append('')
    lines.append('  static const all = [' + ', '.join(ramps) + '];')
    lines.append('}')
    path = os.path.join(ROOT, 'lib/src/foundations/tp_ramps.dart')
    open(path, 'w').write('\n'.join(lines) + '\n')


def write_tokens(ramps):
    path = os.path.join(ROOT, 'tokens/tokens.json')
    tokens = json.load(open(path))
    tokens['color']['ramp'] = {
        '$description': (
            f'Tints and shades. Grade = luminance: contrast between any two steps is {BASE}^(gap/500), whatever the hue. '
            'Gap ≥ 400: 3:1 (large text, UI marks). Gap ≥ 500: 4.5:1 (all text). Gap ≥ 650: 7:1. White is grade 0, black 1000.'),
        **{name: {'$description': ANCHORS[name][1], **{str(g): {'$value': r[g]} for g in GRADES}}
           for name, r in ramps.items()},
    }
    open(path, 'w').write(json.dumps(tokens, indent=2, ensure_ascii=False) + '\n')


if __name__ == '__main__':
    ramps = {name: ramp(anchors) for name, (anchors, _) in ANCHORS.items()}
    check(ramps)
    write_dart(ramps)
    write_tokens(ramps)
    json.dump({'base': BASE, 'grades': GRADES, 'ramps': ramps}, sys.stdout if '--json' in sys.argv else open(os.devnull, 'w'))
    print('ramps:', len(ramps), 'x', len(GRADES), file=sys.stderr)
