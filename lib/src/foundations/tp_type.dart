import 'package:flutter/painting.dart';

/// Tripami type scale.
///
/// Three bundled variable families:
/// - **Bricolage Grotesque** (display): trip names and day headings, set heavy
///   to echo the wordmark. The only face set above Semibold.
/// - **Inter** (UI): every control, label, number and body text.
/// - **Newsreader** (diary voice): long-form journal text and pull quotes.
///
/// Neither display nor diary faces go on buttons, tabs, inputs or eyebrows.
/// UI weights are Regular, Medium and Semibold only.
/// Styles carry no color. Colors come from `TPColors` or the theme.
abstract final class TPType {
  static const package = 'tripami_design_system';
  static const brand = 'BricolageGrotesque';
  static const ui = 'Inter';
  static const diary = 'Newsreader';

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;
  static const heavy = FontWeight.w800; // display face only

  /// Mirrors the OS "Bold Text" setting (iOS) / bold font (Android). Set by
  /// `TripamiTheme.builder`; don't set it yourself. Every style steps up about
  /// two weights while it's on. Our variable fonts pin their weight axis, so
  /// Flutter's own bold-text handling can't reach them.
  static bool boldText = false;

  static final _cache = <(String, bool), TextStyle>{};
  static TextStyle _cached(String name, TextStyle Function() build) => _cache.putIfAbsent((name, boldText), build);

  /// The weight actually drawn for [weight] in [family], given [boldText].
  static FontWeight effectiveWeight(FontWeight weight, {String family = ui}) {
    if (!boldText) return weight;
    final max = family == ui ? 900 : 800;
    final stepped = (weight.value + 200).clamp(100, max);
    return FontWeight.values.firstWhere((w) => w.value == stepped);
  }

  static TextStyle _style(
    String family,
    double size,
    double lineHeight,
    FontWeight weight,
    double tracking, {
    FontStyle style = FontStyle.normal,
  }) {
    weight = effectiveWeight(weight, family: family);
    return TextStyle(
      fontFamily: family,
      package: package,
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      fontStyle: style,
      letterSpacing: tracking,
      // Variable fonts need the axes set explicitly. Optical size follows the
      // font size so small text opens up and display text tightens.
      fontVariations: [
        FontVariation.weight(weight.value.toDouble()),
        FontVariation.opticalSize(switch (family) {
          diary => size.clamp(6, 72),
          brand => size.clamp(12, 96),
          _ => size.clamp(14, 32),
        }),
      ],
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // Display (Bricolage Grotesque), heavy like the wordmark
  static TextStyle get display => _cached('display', () => _style(brand, 34, 38, heavy, -0.7));
  static TextStyle get diaryHeading => _cached('diaryHeading', () => _style(brand, 24, 30, FontWeight.w700, -0.3));

  // Diary voice (Newsreader)
  static TextStyle get diaryBody => _cached('diaryBody', () => _style(diary, 17, 26, regular, 0));
  static TextStyle get diaryQuote => _cached('diaryQuote', () => _style(diary, 22, 30, regular, -0.1, style: FontStyle.italic));

  // UI (Inter)
  static TextStyle get title1 => _cached('title1', () => _style(ui, 28, 34, regular, -0.4));
  static TextStyle get title2 => _cached('title2', () => _style(ui, 22, 28, medium, -0.2));
  static TextStyle get title3 => _cached('title3', () => _style(ui, 18, 24, medium, -0.1));
  static TextStyle get body => _cached('body', () => _style(ui, 17, 24, regular, -0.2));
  static TextStyle get callout => _cached('callout', () => _style(ui, 15, 20, regular, -0.1));
  static TextStyle get subhead => _cached('subhead', () => _style(ui, 14, 19, regular, -0.1));
  static TextStyle get footnote => _cached('footnote', () => _style(ui, 13, 18, regular, 0));

  /// Always uppercase. Use `TPEyebrow`, which applies the transform.
  static TextStyle get eyebrow => _cached('eyebrow', () => _style(ui, 12, 16, semibold, 0.96));
  static TextStyle get caption => _cached('caption', () => _style(ui, 11, 13, medium, 0.1));
  static TextStyle get button => _cached('button', () => _style(ui, 17, 22, medium, -0.2));
  static TextStyle get buttonSmall => _cached('buttonSmall', () => _style(ui, 15, 20, medium, -0.1));

  /// Tabular figures for money, times and counts.
  static const tabular = [FontFeature.tabularFigures()];
}

extension TPTextStyleX on TextStyle {
  /// Returns this style with tabular figures, for aligned numbers.
  TextStyle get tabular => copyWith(fontFeatures: TPType.tabular);

  /// Returns this style at another weight, keeping the variable axis in sync.
  TextStyle withWeight(FontWeight weight) => copyWith(
        fontWeight: TPType.effectiveWeight(weight, family: fontFamily?.split('/').last ?? TPType.ui),
        fontVariations: [
          FontVariation.weight(TPType.effectiveWeight(weight, family: fontFamily?.split('/').last ?? TPType.ui).value.toDouble()),
          ...?fontVariations?.where((v) => v.axis != 'wght'),
        ],
      );
}
