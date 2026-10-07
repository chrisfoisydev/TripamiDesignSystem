import 'dart:ui' show Brightness;

import 'package:flutter/animation.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart' show BuildContext, MediaQuery;

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

  /// Minimum height of a photo header ([TPPlaceHeader]). It grows with large text.
  static const placeHeader = 340.0;

  /// How far a content sheet rises over the photo above it ([TPOverlapSheet]).
  static const sheetOverlap = 24.0;

  /// How far a [TPBackdrop] reaches down the screen before it has faded out.
  static const backdrop = 280.0;
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

/// Motion: calm by default, playful when people come together.
///
/// About 90% of motion uses [ease] and [gentle]: quick to respond, soft to
/// settle, no overshoot. Only people moments (joining a plan, voting, the
/// group coming back together, the brand dot) use [playful], and at most once
/// per screen. Chrome, navigation and text never bounce.
abstract final class TPMotion {
  static const instant = Duration(milliseconds: 120);
  static const quick = Duration(milliseconds: 200);
  static const standard = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 480);

  /// Delay between items entering together (list rows, braid rows). Cap the
  /// staggered items at [staggerMax]; later ones enter with the last.
  static const stagger = Duration(milliseconds: 30);
  static const staggerMax = 6;

  static const ease = Cubic(0.2, 0, 0, 1);
  static const exit = Cubic(0.4, 0, 1, 1);

  /// Sheets and cards settling. Response ~0.42s, damping 0.86, no overshoot.
  static const gentle = SpringDescription(mass: 1, stiffness: 224, damping: 25.7);

  /// Presses, toggles, chips, tab indicators. Response ~0.28s, damping 0.9.
  static const snappy = SpringDescription(mass: 1, stiffness: 504, damping: 40.4);

  /// People moments only. Response ~0.45s, damping 0.7: about 5% overshoot.
  static const playful = SpringDescription(mass: 1, stiffness: 195, damping: 19.5);

  /// The springs as curves, for implicit animations (`AnimatedFoo`,
  /// `TweenAnimationBuilder`) together with their settle durations.
  static const gentleCurve = TPSpringCurve(gentle, settle: 0.43);
  static const snappyCurve = TPSpringCurve(snappy, settle: 0.25);
  static const playfulCurve = TPSpringCurve(playful, settle: 0.5);
  static const gentleDuration = Duration(milliseconds: 430);
  static const snappyDuration = Duration(milliseconds: 250);
  static const playfulDuration = Duration(milliseconds: 500);

  /// True when the OS asks for reduced motion: swap movement for 120ms
  /// crossfades (or nothing), and show end states directly.
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Delay for the [index]th of a group entering together.
  static Duration staggerFor(int index) => stagger * (index.clamp(0, staggerMax));
}

/// A [Curve] that follows a spring from 0 to 1. The curve maps the animation's
/// whole duration onto the spring's settle time, so pair it with the matching
/// `TPMotion.*Duration`.
class TPSpringCurve extends Curve {
  const TPSpringCurve(this.spring, {required this.settle});

  final SpringDescription spring;

  /// Seconds of spring time the curve covers: the spring's settle time
  /// (within 0.5%), so the motion fills the whole duration.
  final double settle;

  @override
  double transformInternal(double t) {
    final sim = SpringSimulation(spring, 0, 1, 0);
    return sim.x(t * settle);
  }
}
