import 'package:flutter/widgets.dart';

/// Accessibility helpers shared by the components.
abstract final class TPA11y {
  /// Smallest tap area for anything tappable: 48×48 (Android's minimum; iOS asks
  /// for 44). Visuals can be smaller; the tappable area around them can't.
  static const minTapTarget = 48.0;

  /// True when the reader has turned text up to about 150% or more. Components
  /// switch side-by-side layouts to stacked ones here instead of truncating.
  static bool largeText(BuildContext context) => MediaQuery.textScalerOf(context).scale(10) >= 15;

  /// The reader's text scale, capped at [max]. Only for chrome that can't grow
  /// (tab bar labels, which iOS also caps); never for content.
  static TextScaler capped(BuildContext context, double max) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: max);
}
