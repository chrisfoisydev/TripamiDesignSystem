import 'package:flutter/material.dart';

import 'tp_palette.dart';

/// Semantic colors, resolved for the current brightness.
///
/// ```dart
/// final c = TPColors.of(context);
/// Text('Lisbon', style: TextStyle(color: c.textSecondary));
/// ```
@immutable
class TPColors extends ThemeExtension<TPColors> {
  const TPColors({
    required this.canvas,
    required this.surface,
    required this.sunken,
    required this.raised,
    required this.hairline,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnImage,
    required this.textInverse,
    required this.actionPrimary,
    required this.actionPrimaryPressed,
    required this.actionPrimaryText,
    required this.accent,
    required this.accentPressed,
    required this.accentSubtle,
    required this.onAccent,
    required this.positive,
    required this.caution,
    required this.critical,
  });

  final Color canvas;
  final Color surface;
  final Color sunken;
  final Color raised;
  final Color hairline;
  final Color borderStrong;

  final Color textPrimary;
  final Color textSecondary;

  /// Placeholders and disabled labels. Use on [canvas] or [surface] only.
  final Color textTertiary;
  final Color textOnImage;
  final Color textInverse;

  /// The ink pill. Never use [accent] for primary actions.
  final Color actionPrimary;
  final Color actionPrimaryPressed;
  final Color actionPrimaryText;

  /// Deep Tripami orange. State only: you / now / selected / needs you.
  /// At most 5% of a screen.
  final Color accent;
  final Color accentPressed;
  final Color accentSubtle;
  final Color onAccent;

  final Color positive;
  final Color caution;
  final Color critical;

  /// The logo's orange. Logo and brand moments only, never text.
  Color get brandOrange => TPPalette.brandOrange;

  // Overlays don't change with brightness.
  Color get glass => TPPalette.glass;
  Color get dim => TPPalette.dim;
  LinearGradient get scrim => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.4, 1],
        colors: [TPPalette.scrimStart, TPPalette.scrimEnd],
      );

  static const light = TPColors(
    canvas: TPPalette.canvasLight,
    surface: TPPalette.surfaceLight,
    sunken: TPPalette.sunkenLight,
    raised: TPPalette.raisedLight,
    hairline: TPPalette.hairlineLight,
    borderStrong: TPPalette.borderStrongLight,
    textPrimary: TPPalette.textPrimaryLight,
    textSecondary: TPPalette.textSecondaryLight,
    textTertiary: TPPalette.textTertiaryLight,
    textOnImage: TPPalette.white,
    textInverse: TPPalette.canvasLight,
    actionPrimary: TPPalette.textPrimaryLight,
    actionPrimaryPressed: TPPalette.actionPressedLight,
    actionPrimaryText: TPPalette.canvasLight,
    accent: TPPalette.accentLight,
    accentPressed: TPPalette.accentPressedLight,
    accentSubtle: TPPalette.accentSubtleLight,
    onAccent: TPPalette.white,
    positive: TPPalette.positiveLight,
    caution: TPPalette.cautionLight,
    critical: TPPalette.criticalLight,
  );

  /// In dark mode the ink pill inverts to a paper pill.
  static const dark = TPColors(
    canvas: TPPalette.canvasDark,
    surface: TPPalette.surfaceDark,
    sunken: TPPalette.sunkenDark,
    raised: TPPalette.raisedDark,
    hairline: TPPalette.hairlineDark,
    borderStrong: TPPalette.borderStrongDark,
    textPrimary: TPPalette.textPrimaryDark,
    textSecondary: TPPalette.textSecondaryDark,
    textTertiary: TPPalette.textTertiaryDark,
    textOnImage: TPPalette.white,
    textInverse: TPPalette.textPrimaryLight,
    actionPrimary: TPPalette.textPrimaryDark,
    actionPrimaryPressed: TPPalette.actionPressedDark,
    actionPrimaryText: TPPalette.textPrimaryLight,
    accent: TPPalette.accentDark,
    accentPressed: TPPalette.accentPressedDark,
    accentSubtle: TPPalette.accentSubtleDark,
    onAccent: TPPalette.textPrimaryLight,
    positive: TPPalette.positiveDark,
    caution: TPPalette.cautionDark,
    critical: TPPalette.criticalDark,
  );

  static TPColors of(BuildContext context) =>
      Theme.of(context).extension<TPColors>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  TPColors copyWith({
    Color? canvas,
    Color? surface,
    Color? sunken,
    Color? raised,
    Color? hairline,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnImage,
    Color? textInverse,
    Color? actionPrimary,
    Color? actionPrimaryPressed,
    Color? actionPrimaryText,
    Color? accent,
    Color? accentPressed,
    Color? accentSubtle,
    Color? onAccent,
    Color? positive,
    Color? caution,
    Color? critical,
  }) {
    return TPColors(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      sunken: sunken ?? this.sunken,
      raised: raised ?? this.raised,
      hairline: hairline ?? this.hairline,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnImage: textOnImage ?? this.textOnImage,
      textInverse: textInverse ?? this.textInverse,
      actionPrimary: actionPrimary ?? this.actionPrimary,
      actionPrimaryPressed: actionPrimaryPressed ?? this.actionPrimaryPressed,
      actionPrimaryText: actionPrimaryText ?? this.actionPrimaryText,
      accent: accent ?? this.accent,
      accentPressed: accentPressed ?? this.accentPressed,
      accentSubtle: accentSubtle ?? this.accentSubtle,
      onAccent: onAccent ?? this.onAccent,
      positive: positive ?? this.positive,
      caution: caution ?? this.caution,
      critical: critical ?? this.critical,
    );
  }

  @override
  TPColors lerp(TPColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return TPColors(
      canvas: l(canvas, other.canvas),
      surface: l(surface, other.surface),
      sunken: l(sunken, other.sunken),
      raised: l(raised, other.raised),
      hairline: l(hairline, other.hairline),
      borderStrong: l(borderStrong, other.borderStrong),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      textTertiary: l(textTertiary, other.textTertiary),
      textOnImage: l(textOnImage, other.textOnImage),
      textInverse: l(textInverse, other.textInverse),
      actionPrimary: l(actionPrimary, other.actionPrimary),
      actionPrimaryPressed: l(actionPrimaryPressed, other.actionPrimaryPressed),
      actionPrimaryText: l(actionPrimaryText, other.actionPrimaryText),
      accent: l(accent, other.accent),
      accentPressed: l(accentPressed, other.accentPressed),
      accentSubtle: l(accentSubtle, other.accentSubtle),
      onAccent: l(onAccent, other.onAccent),
      positive: l(positive, other.positive),
      caution: l(caution, other.caution),
      critical: l(critical, other.critical),
    );
  }
}
