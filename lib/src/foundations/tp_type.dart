import 'package:flutter/painting.dart';

/// Tripami type scale.
///
/// Two bundled variable families:
/// - **Inter** (UI): every control, label, number and body text.
/// - **Newsreader** (diary voice): trip names, day headings, journal text.
///   Never on buttons, tabs, inputs or eyebrows.
///
/// Weights are Regular, Medium and Semibold only; product UI has no Bold.
/// Styles carry no color. Colors come from `TPColors` or the theme.
abstract final class TPType {
  static const package = 'tripami_design_system';
  static const ui = 'Inter';
  static const diary = 'Newsreader';

  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semibold = FontWeight.w600;

  static TextStyle _style(
    String family,
    double size,
    double lineHeight,
    FontWeight weight,
    double tracking, {
    FontStyle style = FontStyle.normal,
  }) {
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
        FontVariation.opticalSize(size.clamp(family == diary ? 6 : 14, family == diary ? 72 : 32)),
      ],
      leadingDistribution: TextLeadingDistribution.even,
    );
  }

  // Diary voice (Newsreader)
  static final display = _style(diary, 34, 40, regular, -0.4);
  static final diaryHeading = _style(diary, 24, 30, regular, -0.2);
  static final diaryBody = _style(diary, 17, 26, regular, 0);
  static final diaryQuote = _style(diary, 22, 30, regular, -0.1, style: FontStyle.italic);

  // UI (Inter)
  static final title1 = _style(ui, 28, 34, regular, -0.4);
  static final title2 = _style(ui, 22, 28, medium, -0.2);
  static final title3 = _style(ui, 18, 24, medium, -0.1);
  static final body = _style(ui, 17, 24, regular, -0.2);
  static final callout = _style(ui, 15, 20, regular, -0.1);
  static final subhead = _style(ui, 14, 19, regular, -0.1);
  static final footnote = _style(ui, 13, 18, regular, 0);

  /// Always uppercase. Use `TPEyebrow`, which applies the transform.
  static final eyebrow = _style(ui, 12, 16, semibold, 0.96);
  static final caption = _style(ui, 11, 13, medium, 0.1);
  static final button = _style(ui, 17, 22, medium, -0.2);
  static final buttonSmall = _style(ui, 15, 20, medium, -0.1);

  /// Tabular figures for money, times and counts.
  static const tabular = [FontFeature.tabularFigures()];
}

extension TPTextStyleX on TextStyle {
  /// Returns this style with tabular figures, for aligned numbers.
  TextStyle get tabular => copyWith(fontFeatures: TPType.tabular);

  /// Returns this style at another weight, keeping the variable axis in sync.
  TextStyle withWeight(FontWeight weight) => copyWith(
        fontWeight: weight,
        fontVariations: [
          FontVariation.weight(weight.value.toDouble()),
          ...?fontVariations?.where((v) => v.axis != 'wght'),
        ],
      );
}
