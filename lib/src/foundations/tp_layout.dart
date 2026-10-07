import 'dart:ui' show Brightness;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

/// 4pt spacing scale.
abstract final class TPSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s16 = 64.0;

  /// Screen side margin, as in Bonvoy.
  static const margin = s6;
  static const screen = EdgeInsets.symmetric(horizontal: margin);

  /// How much of the next card shows in a carousel.
  static const carouselPeek = s8;
}

abstract final class TPRadius {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const sheet = 28.0;
  static const pill = 999.0;
}

abstract final class TPSize {
  static const hitTarget = 44.0;
  static const buttonLarge = 52.0;
  static const buttonSmall = 40.0;
  static const chip = 36.0;
  static const search = 56.0;
  static const quickAction = 56.0;
  static const rowMin = 56.0;
  static const rowTwoLine = 72.0;
  static const sectionBand = 8.0;
}

/// Soft, wide, ink-tinted shadows. In dark mode use surface lightness and a
/// hairline instead (see `TPElevation.of`).
abstract final class TPElevation {
  static const card = [
    BoxShadow(color: Color(0x0A02203A), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0F02203A), offset: Offset(0, 6), blurRadius: 20),
  ];
  static const floating = [
    BoxShadow(color: Color(0x0D02203A), offset: Offset(0, 2), blurRadius: 6),
    BoxShadow(color: Color(0x1A02203A), offset: Offset(0, 12), blurRadius: 32),
  ];
  static const sheet = [
    BoxShadow(color: Color(0x2402203A), offset: Offset(0, -8), blurRadius: 40),
  ];
  static const floatingDark = [
    BoxShadow(color: Color(0x66000000), offset: Offset(0, 12), blurRadius: 32),
  ];

  static List<BoxShadow> of(Brightness brightness, {bool floating = false}) {
    if (brightness == Brightness.dark) return floating ? floatingDark : const [];
    return floating ? TPElevation.floating : card;
  }
}

/// The braid: one strand per traveler (or per group on big trips) running
/// down the day, bundling when people are together and parting when they split.
abstract final class TPBraidMetrics {
  /// Width of a person strand. Group ribbons scale from here to [ribbonMax].
  static const strand = 3.0;
  static const ribbonMax = 12.0;

  /// Extra width on your own strand, which is also drawn on top.
  static const youExtra = 1.5;

  /// Gap between strands in one bundle, and between bundles.
  static const gap = 4.0;
  static const bundleGap = 12.0;

  /// Minimum width of the strand gutter beside the cards.
  static const gutter = 88.0;

  /// Height over which strands move to their new bundle at each event.
  static const turn = 48.0;

  /// Dots for a loose strand (no plans).
  static const looseDash = 2.0;
  static const looseGap = 4.0;

  /// Most strands shown at once; the rest fold into a "+N more" ribbon.
  static const maxStrands = 6;

  /// Phones show strands on the left only; at this width and up, strands of
  /// groups you're not in move to a right-hand gutter.
  static const twoSidedMinWidth = 600.0;

  /// Ribbon width for a strand that stands for [count] people.
  static double widthFor(int count) => (strand + (count - 1) * 0.6).clamp(strand, ribbonMax);
}

abstract final class TPMotion {
  static const instant = Duration(milliseconds: 120);
  static const quick = Duration(milliseconds: 200);
  static const standard = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 480);

  static const ease = Cubic(0.2, 0, 0, 1);
  static const exit = Cubic(0.4, 0, 1, 1);

  /// For sheets and cards settling. Roughly response 0.42s, damping 0.86.
  static const gentle = SpringDescription(mass: 1, stiffness: 224, damping: 25.7);
}
