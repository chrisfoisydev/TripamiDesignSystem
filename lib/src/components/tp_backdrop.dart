import 'dart:ui' show ImageFilter, PathMetric;

import 'package:flutter/material.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_palette.dart';
import 'tp_people.dart';

enum _TPBackdropKind { photo, braid, route }

/// A background for the top of a screen that has no photo header, so it
/// still feels like this trip and these people. It sits behind [child] and
/// fades into `canvas` over [height], so everything below reads as normal.
///
/// - [TPBackdrop.photo]: the trip's cover photo, blurred and washed toward
///   the canvas. For screens inside a trip: Crew, Money, the Map list.
/// - [TPBackdrop.braid]: the crew's strands, in their member colors, parting
///   and gathering across the top. For people moments: Crew, invites,
///   joining, an empty state about people. The strands draw in once.
/// - [TPBackdrop.route]: a faint dotted route between pins, ending in the
///   brand-orange dot. For screens with no trip yet: bringing in a trip,
///   starting one, onboarding.
///
/// One per screen, never with a [TPPlaceHeader]. Decorative: screen readers
/// skip it, and text over it stays on the faded part (see Backgrounds in
/// docs/07-imagery.md).
class TPBackdrop extends StatelessWidget {
  const TPBackdrop.photo({super.key, required ImageProvider this.image, required this.child, this.height = TPSize.backdrop})
      : _kind = _TPBackdropKind.photo,
        members = const [];

  const TPBackdrop.braid({super.key, required this.members, required this.child, this.height = TPSize.backdrop})
      : _kind = _TPBackdropKind.braid,
        image = null;

  const TPBackdrop.route({super.key, required this.child, this.height = TPSize.backdrop})
      : _kind = _TPBackdropKind.route,
        image = null,
        members = const [];

  final _TPBackdropKind _kind;
  final ImageProvider? image;

  /// For [TPBackdrop.braid]: one strand each, up to six, in join order.
  final List<TPMember> members;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final (Widget art, double fadeFrom) = switch (_kind) {
      _TPBackdropKind.photo => (
          Stack(fit: StackFit.expand, children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16, tileMode: TileMode.decal),
              child: Image(
                image: image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
            ),
            // Washed toward the canvas so ink text stays readable on any photo.
            ColoredBox(color: c.canvas.withValues(alpha: 0.35)),
          ]),
          0.3,
        ),
      _TPBackdropKind.braid => (_BraidArt(members: members), 0.55),
      _TPBackdropKind.route => (const _RouteArt(), 0.6),
    };

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: ClipRect(
                child: Stack(fit: StackFit.expand, children: [
                  art,
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [fadeFrom, 1],
                        colors: [c.canvas.withValues(alpha: 0), c.canvas],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _BraidArt extends StatelessWidget {
  const _BraidArt({required this.members});
  final List<TPMember> members;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = [for (final m in members.take(6)) m.color.strand(brightness)];
    final reduced = TPMotion.reduced(context);
    // The braid's own entrance: one 600ms sweep, drawn at rest under Reduce Motion.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: reduced ? 1 : 0, end: 1),
      duration: reduced ? Duration.zero : const Duration(milliseconds: 600),
      curve: TPMotion.ease,
      builder: (context, t, _) => CustomPaint(painter: TPBraidBackdropPainter(colors, progress: t)),
    );
  }
}

/// Strands that start bundled, part, cross over and part again: the braid
/// as a background. Public so apps can paint it elsewhere (a share card).
class TPBraidBackdropPainter extends CustomPainter {
  TPBraidBackdropPainter(this.colors, {this.progress = 1, this.strokeWidth = TPBraidMetrics.strand});

  final List<Color> colors;
  final double progress;
  final double strokeWidth;

  /// The path of strand [i] of [n] across [size]. Same geometry as the web.
  static Path strandPath(int i, int n, Size size) {
    final w = size.width, h = size.height;
    double bundle(int k) => h * 0.32 + (k - (n - 1) / 2) * 5;
    double spread(int k) => h * 0.10 + h * 0.42 * (n == 1 ? 0.5 : k / (n - 1));
    final xs = [-20.0, w * 0.18, w * 0.42, w * 0.66, w * 0.86, w + 20];
    final ys = [bundle(i), bundle(i), spread(i), bundle(n - 1 - i), bundle(n - 1 - i), spread(n - 1 - i)];
    final p = Path()..moveTo(xs[0], ys[0]);
    for (var k = 1; k < xs.length; k++) {
      final mid = (xs[k - 1] + xs[k]) / 2;
      p.cubicTo(mid, ys[k - 1], mid, ys[k], xs[k], ys[k]);
    }
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final n = colors.length;
    for (var i = 0; i < n; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      final path = strandPath(i, n, size);
      if (progress >= 1) {
        canvas.drawPath(path, paint);
      } else {
        for (final PathMetric m in path.computeMetrics()) {
          canvas.drawPath(m.extractPath(0, m.length * progress), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(TPBraidBackdropPainter old) =>
      old.progress != progress || old.strokeWidth != strokeWidth || !_sameColors(old.colors, colors);

  static bool _sameColors(List<Color> a, List<Color> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _RouteArt extends StatelessWidget {
  const _RouteArt();

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return CustomPaint(
      painter: TPRouteBackdropPainter(ink: c.textPrimary.withValues(alpha: 0.24), ground: c.canvas),
    );
  }
}

/// A dotted route across the top of a screen, between two pins, ending in
/// the brand-orange dot: the logo's one orange point.
class TPRouteBackdropPainter extends CustomPainter {
  TPRouteBackdropPainter({required this.ink, required this.ground});

  final Color ink;
  final Color ground;

  /// The route across [size]. Same geometry as the web.
  static Path routePath(Size size) {
    final w = size.width, h = size.height;
    return Path()
      ..moveTo(w * 0.12, h * 0.62)
      ..cubicTo(w * 0.27, h * 0.12, w * 0.40, h * 0.78, w * 0.55, h * 0.40)
      ..cubicTo(w * 0.65, h * 0.14, w * 0.74, h * 0.16, w * 0.82, h * 0.28);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = ink;
    for (final m in routePath(size).computeMetrics()) {
      // Round dots every 8pt.
      for (double d = 0; d < m.length; d += 8) {
        final t = m.getTangentForOffset(d);
        if (t != null) canvas.drawCircle(t.position, 1.5, dot);
      }
    }
    final w = size.width, h = size.height;
    final ring = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final o in [Offset(w * 0.12, h * 0.62), Offset(w * 0.55, h * 0.40)]) {
      canvas.drawCircle(o, 5, Paint()..color = ground);
      canvas.drawCircle(o, 5, ring);
    }
    canvas.drawCircle(Offset(w * 0.82, h * 0.28), 6, Paint()..color = TPPalette.brandOrange);
  }

  @override
  bool shouldRepaint(TPRouteBackdropPainter old) => old.ink != ink || old.ground != ground;
}
