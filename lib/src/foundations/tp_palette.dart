import 'dart:ui';

/// Raw Tripami color values. Mirrors `tokens/tokens.json`.
///
/// Widgets should read colors through `TPColors.of(context)` so that light and
/// dark mode resolve correctly. Use this class only for building themes, tests,
/// and the member palette.
abstract final class TPPalette {
  // Neutrals: paper & ink (light)
  static const canvasLight = Color(0xFFFAFAF7);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const sunkenLight = Color(0xFFF2F1EC);
  static const raisedLight = Color(0xFFFFFFFF);
  static const hairlineLight = Color(0xFFE6E4DE);
  static const borderStrongLight = Color(0xFFD6D3CB);
  static const textPrimaryLight = Color(0xFF16171B);
  static const textSecondaryLight = Color(0xFF5C5E66);
  static const textTertiaryLight = Color(0xFF6F7178);
  static const actionPressedLight = Color(0xFF2C2D33);

  // Neutrals (dark)
  static const canvasDark = Color(0xFF0E0F11);
  static const surfaceDark = Color(0xFF17181B);
  static const sunkenDark = Color(0xFF0A0B0C);
  static const raisedDark = Color(0xFF1F2024);
  static const hairlineDark = Color(0xFF2A2B30);
  static const borderStrongDark = Color(0xFF3A3B41);
  static const textPrimaryDark = Color(0xFFF2F1EC);
  static const textSecondaryDark = Color(0xFFA6A7AD);
  static const textTertiaryDark = Color(0xFF8A8C93);
  static const actionPressedDark = Color(0xFFD9D8D2);

  // Accent: Lagoon. State only (you / now / selected), at most 5% of a screen.
  static const lagoonLight = Color(0xFF0B6B61);
  static const lagoonPressedLight = Color(0xFF08564E);
  static const lagoonSubtleLight = Color(0xFFE3F1EE);
  static const lagoonDark = Color(0xFF5CC4B4);
  static const lagoonPressedDark = Color(0xFF7DD3C5);
  static const lagoonSubtleDark = Color(0xFF12302C);

  // Status
  static const positiveLight = Color(0xFF2E7D4F);
  static const cautionLight = Color(0xFF94600F);
  static const criticalLight = Color(0xFFB42318);
  static const positiveDark = Color(0xFF6FCF97);
  static const cautionDark = Color(0xFFF2B84B);
  static const criticalDark = Color(0xFFF97066);

  // Overlays (same in both themes)
  static const white = Color(0xFFFFFFFF);
  static const glass = Color(0x7A16171B); // 48% ink, used with a 16px blur
  static const dim = Color(0x5C0E0F11); // 36% behind sheets
  static const scrimStart = Color(0x000E0F11);
  static const scrimEnd = Color(0x9E0E0F11); // 62%
}

/// Member colors identify a traveler: avatar, votes, expenses, "added by".
/// Assigned in join order; the trip creator gets [clay]. White initials pass
/// WCAG AA on every hue. Never use them for buttons or backgrounds.
enum TPMemberColor {
  clay(Color(0xFFB4553A)),
  marigold(Color(0xFF9A6410)),
  fern(Color(0xFF3F7D4E)),
  sky(Color(0xFF2F73A8)),
  iris(Color(0xFF5160C9)),
  plum(Color(0xFF7F4FAE)),
  rose(Color(0xFFB2466E)),
  olive(Color(0xFF66692B));

  const TPMemberColor(this.color);
  final Color color;

  static TPMemberColor forJoinIndex(int index) =>
      values[index % values.length];
}
