import 'dart:ui';

import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
import 'tp_motion.dart';

enum TPButtonVariant { primary, secondary, tertiary, destructive }

/// Tripami button.
///
/// - [TPButton.primary]: ink pill. One per screen.
/// - [TPButton.secondary]: outline pill, an equal alternative to a primary.
/// - [TPButton.tertiary]: text + arrow, for low-emphasis navigation.
/// - [TPButton.destructive]: tertiary in critical red; confirm in a sheet.
///
/// Every variant scales to 0.98 while pressed. The primary also plays
/// [TPHaptics.join] on tap; the others are silent.
class TPButton extends StatelessWidget {
  const TPButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.small = false,
    this.expand = false,
    this.loading = false,
  }) : variant = TPButtonVariant.primary;

  const TPButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.small = false,
    this.expand = false,
  })  : variant = TPButtonVariant.secondary,
        loading = false;

  const TPButton.tertiary({
    super.key,
    required this.label,
    required this.onPressed,
  })  : variant = TPButtonVariant.tertiary,
        small = true,
        expand = false,
        loading = false;

  const TPButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
  })  : variant = TPButtonVariant.destructive,
        small = true,
        expand = false,
        loading = false;

  final String label;
  final VoidCallback? onPressed;
  final TPButtonVariant variant;
  final bool small;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final height = small ? TPSize.buttonSmall : TPSize.buttonLarge;
    final text = small ? TPType.buttonSmall : TPType.button;
    final onTap = onPressed == null || loading
        ? null
        : () {
            if (variant == TPButtonVariant.primary) TPHaptics.join();
            onPressed!();
          };

    final Widget button = switch (variant) {
      TPButtonVariant.primary => FilledButton(
          onPressed: onTap,
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(TPSize.hitTarget, height)),
            textStyle: WidgetStatePropertyAll(text),
          ),
          child: loading
              ? SizedBox.square(
                  dimension: 17,
                  child: CircularProgressIndicator(strokeWidth: 2, color: c.actionPrimaryText),
                )
              : Text(label),
        ),
      TPButtonVariant.secondary => OutlinedButton(
          onPressed: onTap,
          style: ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(TPSize.hitTarget, height)),
            textStyle: WidgetStatePropertyAll(text),
          ),
          child: Text(label),
        ),
      TPButtonVariant.tertiary => TextButton(
          onPressed: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: TPSpace.s1),
              const Icon(TPIcons.arrowRight, size: 16),
            ],
          ),
        ),
      TPButtonVariant.destructive => TextButton(
          onPressed: onTap,
          style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(c.critical)),
          child: Text(label),
        ),
    };

    return TPPressable.scaleOnly(
      enabled: onTap != null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// 40pt glass circle for back / share / save on top of photos.
class TPGlassIconButton extends StatelessWidget {
  const TPGlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: TPPressable(
        onTap: onPressed,
        pressedScale: 0.94,
        child: SizedBox.square(
          dimension: TPA11y.minTapTarget,
          child: Center(
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  width: 40,
                  height: 40,
                  color: c.glass,
                  child: Icon(icon, size: 20, color: c.textOnImage),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular quick action with a label, used in a scrolling row on Trip Home:
/// Invite · Add plan · Split · Map · Chat · Photos.
/// Glyphs are ink so the accent stays reserved for state.
class TPQuickAction extends StatelessWidget {
  const TPQuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final brightness = Theme.of(context).brightness;
    return Semantics(
      button: true,
      child: TPPressable(
        onTap: onPressed,
        pressedScale: 0.96,
        focusShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(TPRadius.sm))),
        child: SizedBox(
          width: 72,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: TPSize.quickAction,
                height: TPSize.quickAction,
                decoration: BoxDecoration(
                  color: c.raised,
                  shape: BoxShape.circle,
                  boxShadow: TPElevation.of(brightness, floating: true),
                  border: brightness == Brightness.dark ? Border.all(color: c.hairline) : null,
                ),
                child: Icon(icon, size: 22, color: c.textPrimary),
              ),
              const SizedBox(height: TPSpace.s2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TPType.footnote.copyWith(color: c.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating ink pill above the tab bar, for example "Map" / "List".
/// It switches views, so it plays [TPHaptics.select].
class TPFloatingPill extends StatelessWidget {
  const TPFloatingPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return TPPressable.scaleOnly(
      enabled: onPressed != null,
      pressedScale: 0.96,
      child: DecoratedBox(
        decoration: const ShapeDecoration(shape: StadiumBorder(), shadows: TPElevation.floating),
        child: FilledButton(
          onPressed: onPressed == null
              ? null
              : () {
                  TPHaptics.select();
                  onPressed!();
                },
          style: const ButtonStyle(
            minimumSize: WidgetStatePropertyAll(Size(TPSize.hitTarget, TPSize.hitTarget)),
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TPSpace.s5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: c.actionPrimaryText),
                const SizedBox(width: TPSpace.s2),
              ],
              Text(label, style: TPType.buttonSmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// Settings toggle row: label (and optional detail) with an ink switch.
/// Plays [TPHaptics.select] when flipped. The switch itself slides on
/// the platform's own motion.
class TPToggle extends StatelessWidget {
  const TPToggle({super.key, required this.label, required this.value, required this.onChanged, this.detail});

  final String label;
  final String? detail;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final change = onChanged == null
        ? null
        : (bool v) {
            TPHaptics.select();
            onChanged!(v);
          };
    return MergeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: change == null ? null : () => change(!value),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: detail != null ? TPSize.rowTwoLine : TPSize.rowMin),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin, vertical: TPSpace.s2),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: TPType.body.copyWith(color: c.textPrimary)),
                      if (detail != null) ...[
                        const SizedBox(height: 2),
                        Text(detail!, style: TPType.footnote.copyWith(color: c.textSecondary)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: TPSpace.s3),
                Switch.adaptive(value: value, onChanged: change),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
