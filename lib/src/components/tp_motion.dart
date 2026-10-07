import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';

/// Haptics, mapped to what happened rather than to a strength.
///
/// Rules:
/// - A haptic answers your own touch, or confirms the group finished something.
///   Other people's changes arriving from the server never buzz.
/// - Nothing fires on scroll, navigation, opening a sheet or a toast.
/// - At most one haptic per gesture.
///
/// The TP components already call these. Call them yourself only for custom
/// controls built from tokens.
abstract final class TPHaptics {
  /// Set false to silence every Tripami haptic, for example from an in-app
  /// "Vibration" setting. The phone's own system haptics setting still applies.
  static bool enabled = true;

  /// Selecting a chip, tab, segment, toggle or option.
  static void select() {
    if (enabled) HapticFeedback.selectionClick();
  }

  /// Joining a plan, casting a vote, reacting, pressing a primary button.
  static void join() {
    if (enabled) HapticFeedback.lightImpact();
  }

  /// Picking up or dropping a plan while reordering by drag.
  static void reorder() {
    if (enabled) HapticFeedback.mediumImpact();
  }

  /// "Everyone's in", "Back together", "Settled": a firm tap, then a light one.
  static void success() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    Timer(const Duration(milliseconds: 90), () {
      if (enabled) HapticFeedback.lightImpact();
    });
  }

  /// Something failed or was refused: a delete that can't happen, an invalid field.
  static void warning() {
    if (enabled) HapticFeedback.heavyImpact();
  }
}

enum TPHaptic { none, select, join, reorder, success, warning }

extension TPHapticFire on TPHaptic {
  /// Plays this haptic (respects [TPHaptics.enabled]).
  void fire() => switch (this) {
        TPHaptic.none => null,
        TPHaptic.select => TPHaptics.select(),
        TPHaptic.join => TPHaptics.join(),
        TPHaptic.reorder => TPHaptics.reorder(),
        TPHaptic.success => TPHaptics.success(),
        TPHaptic.warning => TPHaptics.warning(),
      };
}

/// Press feedback for anything tappable: the child settles to [pressedScale]
/// while your finger is down (120ms, standard ease) and springs back on
/// release, and [haptic] fires on tap. Under reduced motion it doesn't scale.
///
/// Scale by size: 0.98 for buttons and rows, 0.96 for small round controls,
/// 0.99 for cards so big surfaces barely move.
class TPPressable extends StatefulWidget {
  const TPPressable({
    super.key,
    required this.child,
    required this.onTap,
    this.haptic = TPHaptic.none,
    this.pressedScale = 0.98,
    this.behavior = HitTestBehavior.opaque,
    this.expandTapTarget = false,
    this.focusShape = const StadiumBorder(),
  });

  final Widget child;

  /// Null disables both the scale and the haptic.
  final VoidCallback? onTap;
  final TPHaptic haptic;
  final double pressedScale;
  final HitTestBehavior behavior;

  /// Grows the tappable area to [TPA11y.minTapTarget] around a smaller visual
  /// (chips, reaction pills), centered, without changing how it looks.
  final bool expandTapTarget;

  /// Shape of the keyboard focus ring. Pills and circles use the default;
  /// cards pass their rounded rectangle.
  final OutlinedBorder focusShape;

  /// Wraps [child] in press-scale only and leaves the tap to the child
  /// (for Material buttons that handle their own taps and focus).
  static Widget scaleOnly({required Widget child, required bool enabled, double pressedScale = 0.98}) =>
      _PressScale(enabled: enabled, pressedScale: pressedScale, child: child);

  @override
  State<TPPressable> createState() => _TPPressableState();
}

class _TPPressableState extends State<TPPressable> {
  bool _focused = false;

  void _activate() {
    widget.haptic.fire();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    Widget child = _PressScale(enabled: onTap != null, pressedScale: widget.pressedScale, child: widget.child);
    if (_focused) {
      // Keyboard focus ring: 2pt text-primary, as on the web.
      child = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: ShapeDecoration(
          shape: widget.focusShape.copyWith(side: BorderSide(color: TPColors.of(context).textPrimary, width: 2)),
        ),
        child: child,
      );
    }
    if (widget.expandTapTarget) {
      child = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: TPA11y.minTapTarget, minHeight: TPA11y.minTapTarget),
        child: Center(widthFactor: 1, heightFactor: 1, child: child),
      );
    }
    // Keyboards (iPad, Android with a keyboard, web): Tab to focus, Enter or Space to activate.
    return FocusableActionDetector(
      enabled: onTap != null,
      mouseCursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => _activate())},
      child: GestureDetector(
        behavior: widget.expandTapTarget ? HitTestBehavior.opaque : widget.behavior,
        onTap: onTap == null ? null : _activate,
        child: child,
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  const _PressScale({required this.child, required this.enabled, required this.pressedScale});
  final Widget child;
  final bool enabled;
  final double pressedScale;

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
    final reduced = TPMotion.reduced(context);
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !reduced ? widget.pressedScale : 1,
        // Down is quick and plain; release springs back.
        duration: _down ? TPMotion.instant : TPMotion.snappyDuration,
        curve: _down ? TPMotion.ease : TPMotion.snappyCurve,
        child: widget.child,
      ),
    );
  }
}

/// A small playful bump (1 → 1.12 → 1, 320ms) whenever [value] changes after
/// the first build: a count going up, a reaction toggled, a badge changing.
/// Reduced motion skips it.
class TPBump extends StatefulWidget {
  const TPBump({super.key, required this.value, required this.child, this.amount = 0.12});

  final Object? value;
  final Widget child;
  final double amount;

  @override
  State<TPBump> createState() => _TPBumpState();
}

class _TPBumpState extends State<TPBump> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: TPMotion.standard, value: 1);

  @override
  void didUpdateWidget(TPBump old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && !TPMotion.reduced(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = _c.value;
        // Up fast on the standard ease, then settle back on the playful spring.
        final s = t < 0.3
            ? 1 + widget.amount * TPMotion.ease.transform(t / 0.3)
            : 1 + widget.amount * (1 - TPMotion.playfulCurve.transform((t - 0.3) / 0.7));
        return Transform.scale(scale: s, child: child);
      },
    );
  }
}

/// Scales its child in on the playful spring (0 → ~1.05 → 1), once, when it
/// first appears. Give it a new key to play again (for example keyed by who's
/// in a plan, so it pops when someone joins). Under reduced motion it
/// fades in over 120ms instead.
class TPPop extends StatefulWidget {
  const TPPop({super.key, required this.child, this.play = true, this.delay = Duration.zero});

  final Widget child;

  /// False shows the child at rest with no animation.
  final bool play;
  final Duration delay;

  @override
  State<TPPop> createState() => _TPPopState();
}

class _TPPopState extends State<TPPop> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: TPMotion.playfulDuration);
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = TPMotion.reduced(context);
    if (!widget.play) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.duration = _reduced ? TPMotion.instant : TPMotion.playfulDuration;
      if (widget.delay == Duration.zero) {
        _c.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _c.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (_reduced) return Opacity(opacity: _c.value, child: child);
        final t = TPMotion.playfulCurve.transform(_c.value);
        return Opacity(
          opacity: Curves.easeOut.transform((_c.value * 3).clamp(0, 1)),
          child: Transform.scale(scale: t, child: child),
        );
      },
    );
  }
}

/// Fades its child in and rises it 8pt into place on the standard ease.
/// Pass [index] to stagger a group (30ms apart, capped at 6). Under reduced
/// motion it fades only, over 120ms.
class TPRise extends StatefulWidget {
  const TPRise({super.key, required this.child, this.index = 0, this.play = true});

  final Widget child;
  final int index;
  final bool play;

  @override
  State<TPRise> createState() => _TPRiseState();
}

class _TPRiseState extends State<TPRise> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: TPMotion.standard);
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = TPMotion.reduced(context);
    if (!widget.play) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.duration = _reduced ? TPMotion.instant : TPMotion.standard;
      final delay = _reduced ? Duration.zero : TPMotion.staggerFor(widget.index);
      if (delay == Duration.zero) {
        _c.forward();
      } else {
        Future.delayed(delay, () {
          if (mounted) _c.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = TPMotion.ease.transform(_c.value);
        return Opacity(
          opacity: t,
          child: _reduced ? child : Transform.translate(offset: Offset(0, 8 * (1 - t)), child: child),
        );
      },
    );
  }
}

/// A number that ticks to its new value over 480ms in tabular figures:
/// money, counts, vote tallies. Reduced motion shows the new value at once.
class TPCountUp extends StatelessWidget {
  const TPCountUp({super.key, required this.value, required this.format, this.style});

  final num value;
  final String Function(num value) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final s = (style ?? TPType.body).tabular;
    if (TPMotion.reduced(context)) return Text(format(value), style: s);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.toDouble()),
      duration: TPMotion.slow,
      curve: TPMotion.ease,
      builder: (context, v, _) => Text(format(value is int ? v.round() : v), style: s),
    );
  }
}

/// The confirmation moment: a single accent check draws itself, then a success
/// haptic. Use it for "Everyone's in", "Back together" and "Settled". There is
/// no confetti.
class TPSuccessCheck extends StatefulWidget {
  const TPSuccessCheck({super.key, this.size = 40, this.haptic = true, this.animate = true});

  final double size;
  final bool haptic;

  /// False shows the finished check with no draw and no haptic, for a state
  /// that was already true when the screen opened.
  final bool animate;

  @override
  State<TPSuccessCheck> createState() => _TPSuccessCheckState();
}

class _TPSuccessCheckState extends State<TPSuccessCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: TPMotion.standard);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.value == 0 && !_c.isAnimating) {
      if (!widget.animate) {
        _c.value = 1;
      } else if (TPMotion.reduced(context)) {
        _c.value = 1;
        if (widget.haptic) TPHaptics.success();
      } else {
        _c.forward().whenComplete(() {
          if (mounted && widget.haptic) TPHaptics.success();
        });
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return Semantics(
      label: 'Done',
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            painter: _CheckPainter(progress: TPMotion.ease.transform(_c.value), color: c.accent),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final path = Path()
      ..moveTo(w * 0.2, w * 0.53)
      ..lineTo(w * 0.42, w * 0.74)
      ..lineTo(w * 0.82, w * 0.3);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress || old.color != color;
}

/// The brand's playful signature: the orange dot from the logo's "i" drops
/// into place with one small bounce. Use it on the launch screen (over a
/// wordmark without its dot) or on its own at brand moments. It's
/// `brand-orange`, so never use it as a UI state marker.
class TPBrandDot extends StatefulWidget {
  const TPBrandDot({super.key, this.size = 24, this.delay = const Duration(milliseconds: 120)});

  final double size;
  final Duration delay;

  @override
  State<TPBrandDot> createState() => _TPBrandDotState();
}

class _TPBrandDotState extends State<TPBrandDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: TPMotion.playfulDuration);
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = TPMotion.reduced(context);
    if (_c.value == 0 && !_c.isAnimating) {
      if (_reduced) {
        _c.value = 1;
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _c.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = TPMotion.playfulCurve.transform(_c.value);
          return Opacity(
            opacity: (_c.value * 4).clamp(0, 1),
            child: Transform.translate(
              offset: Offset(0, -widget.size * 1.2 * (1 - t)),
              child: DecoratedBox(decoration: BoxDecoration(color: c.brandOrange, shape: BoxShape.circle)),
            ),
          );
        },
      ),
    );
  }
}
