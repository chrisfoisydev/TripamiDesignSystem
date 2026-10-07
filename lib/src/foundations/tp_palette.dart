import 'dart:ui';

import 'tp_ramp.dart';
import 'tp_ramps.dart';

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
  static const textPrimaryLight = Color(0xFF02203A); // Tripami navy (logo)
  static const textSecondaryLight = Color(0xFF525D6E);
  static const textTertiaryLight = Color(0xFF66707F);
  static const actionPressedLight = Color(0xFF12355A);

  // Neutrals (dark)
  static const canvasDark = Color(0xFF0B1220);
  static const surfaceDark = Color(0xFF121A29);
  static const sunkenDark = Color(0xFF070C16);
  static const raisedDark = Color(0xFF1A2333);
  static const hairlineDark = Color(0xFF243045);
  static const borderStrongDark = Color(0xFF334058);
  static const textPrimaryDark = Color(0xFFF2F1EC);
  static const textSecondaryDark = Color(0xFFA7AFBD);
  static const textTertiaryDark = Color(0xFF8C95A3);
  static const actionPressedDark = Color(0xFFD9D8D2);

  // Brand orange: the dot on the logo's "i". Logo and brand moments only;
  // 3.0:1 on white, so never text or a meaningful UI mark.
  static const brandOrange = Color(0xFFFC6316);

  // Accent: the brand orange deepened to pass AA as text. State only
  // (you / now / selected / needs you), at most 5% of a screen.
  static const accentLight = Color(0xFFB8400F);
  static const accentPressedLight = Color(0xFF9A3409);
  static const accentSubtleLight = Color(0xFFFFF1E8);
  static const accentDark = Color(0xFFFF7A3D);
  static const accentPressedDark = Color(0xFFFF9866);
  static const accentSubtleDark = Color(0xFF3A1D10);

  // Status
  static const positiveLight = Color(0xFF2E7D4F);
  static const cautionLight = Color(0xFF7A5A00);
  static const criticalLight = Color(0xFFB3133F);
  static const positiveDark = Color(0xFF6FCF97);
  static const cautionDark = Color(0xFFE8C054);
  static const criticalDark = Color(0xFFFF6B8A);

  // Overlays (same in both themes)
  static const white = Color(0xFFFFFFFF);
  static const glass = Color(0x7A02203A); // 48% navy, used with a 16px blur
  static const dim = Color(0x5C02203A); // 36% navy behind sheets
  static const scrimStart = Color(0x0002101E);
  static const scrimEnd = Color(0x9E02101E); // 62%
}

/// Member colors identify a traveler: avatar, votes, expenses, "added by".
/// Assigned in join order; the trip creator gets [lagoon]. None is close to the
/// brand orange, so a member is never mistaken for the accent. White initials pass
/// WCAG AA on every hue. Never use them for buttons or backgrounds.
///
/// [strandDark] is the same hue lightened for braid strands on dark grounds
/// (≥4.5:1 on dark canvas). Avatar fills keep [color] in both themes.
enum TPMemberColor {
  lagoon(Color(0xFF0B6B61), Color(0xFF0F9083)),
  sky(Color(0xFF2F73A8), Color(0xFF3683C0)),
  iris(Color(0xFF5160C9), Color(0xFF6C79D1)),
  plum(Color(0xFF7F4FAE), Color(0xFF966EBD)),
  rose(Color(0xFFB2466E), Color(0xFFBF5D81)),
  fern(Color(0xFF3F7D4E), Color(0xFF468B56)),
  olive(Color(0xFF66692B), Color(0xFF7F8235)),
  slate(Color(0xFF4F5D75), Color(0xFF6E809D));

  const TPMemberColor(this.color, this.strandDark);
  final Color color;
  final Color strandDark;

  /// This member's full set of tints and shades, for example a tinted
  /// background behind their name (`TPTone(member.color.ramp, brightness).subtle`).
  TPRamp get ramp => switch (this) {
        lagoon => TPRamps.lagoon,
        sky => TPRamps.sky,
        iris => TPRamps.iris,
        plum => TPRamps.plum,
        rose => TPRamps.rose,
        fern => TPRamps.fern,
        olive => TPRamps.olive,
        slate => TPRamps.slate,
      };

  /// The braid strand color for this member (or group) in [brightness].
  Color strand(Brightness brightness) => brightness == Brightness.dark ? strandDark : color;

  /// The color for the [index]th traveler to join (0 = the trip creator).
  ///
  /// The order is chosen for color-vision deficiency: with protanopia,
  /// deuteranopia or tritanopia simulated, the first k colors stay as far apart
  /// as possible for every trip size (worst pair ΔE ≥ 3.7 up to 6 travelers,
  /// against 2.0 in enum order). Color is still never the only cue: avatars
  /// carry initials and the braid labels every plan with names.
  static TPMemberColor forJoinIndex(int index) => joinOrder[index % joinOrder.length];

  static const joinOrder = [lagoon, plum, fern, iris, olive, rose, sky, slate];
}
