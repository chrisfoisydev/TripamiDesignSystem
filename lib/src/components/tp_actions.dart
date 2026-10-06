import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';

enum TPButtonVariant { primary, secondary, tertiary, destructive }

/// Tripami button.
///
/// - [TPButton.primary]: ink pill. One per screen.
/// - [TPButton.secondary]: outline pill, an equal alternative to a primary.
/// - [TPButton.tertiary]: text + arrow, for low-emphasis navigation.
/// - [TPButton.destructive]: tertiary in critical red; confirm in a sheet.
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
            if (variant == TPButtonVariant.primary) HapticFeedback.lightImpact();
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

    return _PressScale(
      enabled: onTap != null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// Scales a child to 0.98 while pressed.
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.enabled});
  final Widget child;
  final bool enabled;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (widget.enabled && v != _down) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down ? 0.98 : 1,
        duration: TPMotion.instant,
        curve: TPMotion.ease,
        child: widget.child,
      ),
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
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: TPSize.hitTarget,
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
      child: GestureDetector(
        onTap: onPressed,
        behavior: HitTestBehavior.opaque,
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
    return DecoratedBox(
      decoration: const ShapeDecoration(shape: StadiumBorder(), shadows: TPElevation.floating),
      child: FilledButton(
        onPressed: onPressed,
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
    );
  }
}
