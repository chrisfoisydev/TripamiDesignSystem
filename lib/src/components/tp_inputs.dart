import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_palette.dart';
import '../foundations/tp_type.dart';
import 'tp_motion.dart';

/// Text field: boxed. A white field with a hairline border and `radius.md`
/// corners, its label the eyebrow above it (the event editor's forms). The
/// border turns ink when focused. Use with `TextField`/`TextFormField`, or an
/// `InputDecorator` for a tappable value such as a time.
abstract final class TPField {
  static InputDecoration boxed(BuildContext context, {String? hint, Widget? suffix}) {
    final c = TPColors.of(context);
    OutlineInputBorder edge(Color color, [double width = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(TPRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TPType.body.copyWith(color: c.textTertiary),
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: TPSpace.s4, vertical: TPSpace.s4),
      suffixIcon: suffix,
      border: edge(c.hairline),
      enabledBorder: edge(c.hairline),
      disabledBorder: edge(c.hairline),
      focusedBorder: edge(c.actionPrimary, 1.5),
      errorBorder: edge(c.critical),
      focusedErrorBorder: edge(c.critical, 1.5),
    );
  }
}

/// Choice chip: one of a set, such as an event's type, status or day. A white
/// pill; selected, it fills ink with ink-text, or [color] (Confirmed's
/// `status.positive`) with white or navy text, whichever reads on it (the
/// green is light in dark mode). Unlike [TPFilterChip] there's no check:
/// the fill is the selection. Plays [TPHaptics.select].
class TPChoiceChip extends StatelessWidget {
  const TPChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.small = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// The selected fill, when it isn't ink.
  final Color? color;

  /// Chip height (36) instead of the 44pt tap height, for a secondary row.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final fill = color ?? c.actionPrimary;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: TPPressable(
        onTap: onTap,
        haptic: TPHaptic.select,
        expandTapTarget: small,
        child: AnimatedContainer(
          duration: TPMotion.reduced(context) ? Duration.zero : TPMotion.quick,
          curve: TPMotion.ease,
          constraints: BoxConstraints(minHeight: small ? TPSize.chip : TPSize.hitTarget),
          padding: const EdgeInsets.symmetric(horizontal: _chipPadding),
          decoration: BoxDecoration(
            color: selected ? fill : c.surface,
            borderRadius: BorderRadius.circular(TPRadius.pill),
          ),
          // As wide as its label: centred in a row's share, never stretched
          // across a wrapping set.
          child: Align(
            widthFactor: 1,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TPType.button.copyWith(
                color: !selected
                    ? c.textPrimary
                    : color == null
                    ? c.actionPrimaryText
                    : ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
                    ? Colors.white
                    : TPPalette.textPrimaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _chipPadding = TPSpace.s3;

/// A set of [TPChoiceChip]s. [fill] spreads them across the width (an
/// event's four types), each sized to its label, when every label fits on
/// one row; otherwise, and at large text, they wrap.
class TPChoices extends StatelessWidget {
  const TPChoices({super.key, required this.children, this.fill = false});

  final List<Widget> children;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    Widget wrap() => Wrap(spacing: TPSpace.s2, runSpacing: TPSpace.s2, children: children);
    if (!fill || TPA11y.largeText(context)) return wrap();
    final scaler = MediaQuery.textScalerOf(context);
    // Each chip's natural width: its label plus padding.
    final widths = [
      for (final c in children)
        c is TPChoiceChip
            ? (TextPainter(
                    text: TextSpan(text: c.label, style: TPType.button),
                    textScaler: scaler,
                    textDirection: TextDirection.ltr,
                    maxLines: 1,
                  )..layout()).width.ceilToDouble() +
                  2 * _chipPadding
            : null,
    ];
    if (widths.contains(null)) {
      return Row(
        spacing: TPSpace.s2,
        children: [for (final c in children) Expanded(child: c)],
      );
    }
    final natural = widths.fold<double>(0, (a, w) => a + w!) + TPSpace.s2 * (children.length - 1);
    return LayoutBuilder(
      builder: (context, constraints) => natural > constraints.maxWidth
          ? wrap()
          // Shares in proportion to each label, so every chip gets at least its own width.
          : Row(
              spacing: TPSpace.s2,
              children: [for (final (i, c) in children.indexed) Expanded(flex: widths[i]!.round(), child: c)],
            ),
    );
  }
}

/// Quick pill: a shortcut that sets a choice rather than being one, such as
/// "Everyone here" and "Just me" above who's going. `accent.subtle` fill,
/// `type.buttonSmall` in `text.primary`, `radius.pill`, 40pt high.
class TPQuickPill extends StatelessWidget {
  const TPQuickPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: TPPressable(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: TPSize.buttonSmall),
          padding: const EdgeInsets.symmetric(horizontal: TPSpace.s4),
          decoration: BoxDecoration(color: c.accentSubtle, borderRadius: BorderRadius.circular(TPRadius.pill)),
          child: Align(
            widthFactor: 1,
            child: Text(
              label,
              style: TPType.buttonSmall.copyWith(color: onTap == null ? c.textTertiary : c.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}
