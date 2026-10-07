import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';

/// Haptics, mapped to what happened rather than to a strength.
/// Nothing fires on scroll or navigation.
abstract final class TPHaptics {
  /// Selecting a chip, tab or option.
  static void select() => HapticFeedback.selectionClick();

  /// Joining a plan, casting a vote, pressing a primary button.
  static void join() => HapticFeedback.lightImpact();

  /// Reordering plans by drag.
  static void reorder() => HapticFeedback.mediumImpact();

  /// "Everyone's in", "Back together", "Settled": a firm tap, then a light one.
  static void success() {
    HapticFeedback.mediumImpact();
    Timer(const Duration(milliseconds: 90), HapticFeedback.lightImpact);
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
  const TPSuccessCheck({super.key, this.size = 40, this.haptic = true});

  final double size;
  final bool haptic;

  @override
  State<TPSuccessCheck> createState() => _TPSuccessCheckState();
}

class _TPSuccessCheckState extends State<TPSuccessCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: TPMotion.standard);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.value == 0 && !_c.isAnimating) {
      if (TPMotion.reduced(context)) {
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
