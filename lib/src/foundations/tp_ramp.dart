import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A tonal ramp: 11 tints and shades of one hue, from 50 (lightest) to 950
/// (darkest). Read a step with `TPRamps.orange[100]`.
///
/// **Grade is luminance.** Every ramp puts the same luminance at the same grade,
/// so contrast depends only on the gap between two grades, whatever their hues:
///
/// | Gap | Contrast | Good for |
/// |---|---|---|
/// | ≥ 400 | ≥ 3:1 | Large text, icons, borders that carry meaning |
/// | ≥ 500 | ≥ 4.5:1 | All text (WCAG AA) |
/// | ≥ 650 | ≥ 7:1 | WCAG AAA |
///
/// White is grade 0 and black 1000, so white text works on any step ≥ 500.
/// Use [TPTone] for ready-made, theme-aware roles instead of picking steps by hand.
@immutable
class TPRamp {
  const TPRamp(this.name, this.colors);

  final String name;

  /// The 11 steps, lightest first, matching [grades].
  final List<Color> colors;

  static const grades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950];

  /// The step at [grade] (one of [grades]).
  Color operator [](int grade) {
    final i = grades.indexOf(grade);
    if (i < 0) throw ArgumentError.value(grade, 'grade', 'Use one of $grades');
    return colors[i];
  }

  /// The contrast two grades are guaranteed to have, from any two ramps.
  static double contrastFor(int gradeA, int gradeB) => math.pow(4.5, (gradeA - gradeB).abs() / 500).toDouble();

  /// Where any color sits on the grade scale (0 = white, 1000 = black),
  /// for checking semantic colors against the rules above.
  static double gradeOf(Color color) {
    final y = color.computeLuminance();
    return 500 * math.log(1.05 / (y + 0.05)) / math.log(4.56);
  }

  @override
  String toString() => 'TPRamp($name)';
}

/// The roles a ramp plays in the UI, resolved for light or dark. Each pairing
/// is contrast-safe by construction (grade gaps in brackets):
///
/// - [subtle] tinted background (50 / 950); [muted] hover or selected (100 / 900)
/// - [border] decorative outline (200 / 800)
/// - [text] tinted text and icons on [subtle], [muted], canvas or surface (700 / 200: ≥ 7:1 on subtle)
/// - [solid] filled badge or banner (600 / 400) with [onSolid] text (white / 950: ≥ 4.5:1)
/// - [solidPressed] pressed fill (700 / 300)
///
/// ```dart
/// final t = TPTone.of(context, TPRamps.green);
/// Container(color: t.subtle, child: Text('Settled', style: TextStyle(color: t.text)));
/// ```
@immutable
class TPTone {
  const TPTone(this.ramp, this.brightness);

  /// Resolves [ramp] for the current theme's brightness.
  factory TPTone.of(BuildContext context, TPRamp ramp) => TPTone(ramp, Theme.of(context).brightness);

  final TPRamp ramp;
  final Brightness brightness;

  bool get _dark => brightness == Brightness.dark;

  Color get subtle => ramp[_dark ? 950 : 50];
  Color get muted => ramp[_dark ? 900 : 100];
  Color get border => ramp[_dark ? 800 : 200];
  Color get text => ramp[_dark ? 200 : 700];
  Color get solid => ramp[_dark ? 400 : 600];
  Color get solidPressed => ramp[_dark ? 300 : 700];
  Color get onSolid => _dark ? ramp[950] : const Color(0xFFFFFFFF);
}

