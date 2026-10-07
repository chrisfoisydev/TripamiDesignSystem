import 'dart:ui';

import 'package:flutter/material.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
import 'tp_motion.dart';
import 'tp_people.dart';
import 'tp_text.dart';

/// Surface card: radius md, soft elevation (hairline in dark mode).
/// Tappable cards settle to 0.99 while pressed.
class TPCard extends StatelessWidget {
  const TPCard({super.key, required this.child, this.padding = const EdgeInsets.all(TPSpace.s4), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final brightness = Theme.of(context).brightness;
    return TPPressable.scaleOnly(
      enabled: onTap != null,
      pressedScale: 0.99,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: c.surface,
          shadows: TPElevation.of(brightness),
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(TPRadius.md),
            side: brightness == Brightness.dark ? BorderSide(color: c.hairline) : BorderSide.none,
          ),
        ),
        child: ClipRSuperellipse(
          borderRadius: BorderRadius.circular(TPRadius.md),
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Dark glass chip for metadata on photos: "In 6 days", "Alfama, Lisbon".
class TPGlassChip extends StatelessWidget {
  const TPGlassChip({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(TPRadius.sm),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: c.glass,
          padding: const EdgeInsets.symmetric(horizontal: TPSpace.s3 - 2, vertical: TPSpace.s1 + 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: c.textOnImage),
                const SizedBox(width: TPSpace.s1 + 2),
              ],
              Text(label, style: TPType.footnote.copyWith(color: c.textOnImage)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trip cover card: 4:5 photo, serif trip name bottom-left on a scrim, status
/// chip top-left, traveler stack bottom-right. Settles to 0.98 while pressed.
class TPTripCoverCard extends StatelessWidget {
  const TPTripCoverCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.members,
    this.status,
    this.onTap,
    this.aspectRatio = 4 / 5,
  });

  final String title;
  final String subtitle;
  final ImageProvider? image;
  final List<TPMember> members;
  final String? status;
  final VoidCallback? onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final brightness = Theme.of(context).brightness;
    final hasImage = image != null;
    final textColor = hasImage ? c.textOnImage : c.textPrimary;

    return Semantics(
      button: onTap != null,
      label: '$title, $subtitle${status != null ? ', $status' : ''}',
      child: TPPressable(
        onTap: onTap,
        behavior: HitTestBehavior.deferToChild,
        child: DecoratedBox(
          decoration: ShapeDecoration(
            shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(TPRadius.lg)),
            shadows: TPElevation.of(brightness),
          ),
          child: ClipRSuperellipse(
            borderRadius: BorderRadius.circular(TPRadius.lg),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // No photo: sunken card with the destination in the diary face.
                  if (hasImage) Image(image: image!, fit: BoxFit.cover) else ColoredBox(color: c.sunken),
                  if (hasImage) DecoratedBox(decoration: BoxDecoration(gradient: c.scrim)),
                  if (status != null)
                    Positioned(top: TPSpace.s4, left: TPSpace.s4, child: TPGlassChip(label: status!)),
                  Positioned(
                    left: TPSpace.s6,
                    right: TPSpace.s6,
                    bottom: TPSpace.s6,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(title, style: TPType.display.copyWith(color: textColor)),
                              const SizedBox(height: TPSpace.s2),
                              Text(
                                subtitle,
                                style: TPType.subhead.copyWith(color: hasImage ? textColor : c.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: TPSpace.s3),
                        TPAvatarStack(members, size: TPAvatarSize.xs, onImage: hasImage),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@immutable
class TPTripFact {
  const TPTripFact({required this.label, required this.value, this.detail, this.trailing});
  final String label;
  final String value;
  final String? detail;

  /// Replaces [value] and [detail], for example an avatar stack under GOING.
  final Widget? trailing;
}

/// The trip strip: ARRIVE · LEAVE · NIGHTS · GOING with hairline dividers.
class TPTripStrip extends StatelessWidget {
  const TPTripStrip({super.key, required this.facts});

  final List<TPTripFact> facts;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            if (i > 0) VerticalDivider(width: TPSpace.s6, color: c.hairline),
            Expanded(
              flex: facts[i].detail != null ? 3 : 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPEyebrow(facts[i].label),
                  const SizedBox(height: TPSpace.s2),
                  if (facts[i].trailing != null)
                    facts[i].trailing!
                  else ...[
                    Text(facts[i].value, style: TPType.body.tabular.copyWith(color: c.textPrimary)),
                    if (facts[i].detail != null)
                      Text(facts[i].detail!, style: TPType.footnote.tabular.copyWith(color: c.textSecondary)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// List row: optional leading icon, label, optional second line, trailing
/// value or chevron. Hairline divider inset to the label.
class TPListRow extends StatelessWidget {
  const TPListRow({
    super.key,
    required this.label,
    this.detail,
    this.icon,
    this.leading,
    this.value,
    this.trailing,
    this.showChevron = true,
    this.showDivider = true,
    this.onTap,
  });

  final String label;
  final String? detail;
  final IconData? icon;
  final Widget? leading;
  final String? value;
  final Widget? trailing;
  final bool showChevron;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final lead = leading ?? (icon != null ? Icon(icon, size: 22, color: c.textPrimary) : null);
    final indent = TPSpace.margin + (lead != null ? 22 + TPSpace.s4 : 0);

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: detail != null ? TPSize.rowTwoLine : TPSize.rowMin),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin, vertical: TPSpace.s3),
                child: Row(
                  children: [
                    if (lead != null) ...[lead, const SizedBox(width: TPSpace.s4)],
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
                    if (value != null) ...[
                      const SizedBox(width: TPSpace.s3),
                      Text(value!, style: TPType.callout.tabular.copyWith(color: c.textSecondary)),
                    ],
                    if (trailing != null) ...[const SizedBox(width: TPSpace.s3), trailing!],
                    if (showChevron && onTap != null) ...[
                      const SizedBox(width: TPSpace.s2),
                      Icon(TPIcons.caretRight, size: 18, color: c.textPrimary),
                    ],
                  ],
                ),
              ),
            ),
            if (showDivider) Divider(indent: indent, endIndent: 0, height: 1),
          ],
        ),
      ),
    );
  }
}

/// 8pt sunken band between sections. Use on hub screens (Trip Home) only;
/// elsewhere separate sections with space.
class TPSectionBand extends StatelessWidget {
  const TPSectionBand({super.key});

  @override
  Widget build(BuildContext context) =>
      Container(height: TPSize.sectionBand, color: TPColors.of(context).sunken);
}

/// Sticky bottom bar: a fact on the left (eyebrow + value), primary on the right.
class TPStickyActionBar extends StatelessWidget {
  const TPStickyActionBar({super.key, required this.action, this.label, this.value, this.detail});

  final Widget action;
  final String? label;
  final String? value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin, vertical: TPSpace.s4),
          child: Row(
            children: [
              if (label != null || value != null || detail != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (label != null) TPEyebrow(label!),
                      if (value != null)
                        Text(value!, style: TPType.title3.tabular.copyWith(color: c.textPrimary)),
                      if (detail != null)
                        Text(detail!, style: TPType.footnote.copyWith(color: c.textSecondary)),
                    ],
                  ),
                )
              else
                const Spacer(),
              const SizedBox(width: TPSpace.s4),
              action,
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state: a dashed container, "a space the group hasn't filled yet".
class TPEmptyState extends StatelessWidget {
  const TPEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.illustration,
    this.action,
  });

  final String title;
  final String message;

  /// Grey-scale spot illustration with one accent detail, about 120pt.
  final Widget? illustration;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return CustomPaint(
      painter: _DashedRRectPainter(color: c.borderStrong, radius: TPRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(TPSpace.s8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null) ...[
              SizedBox(height: 120, child: illustration),
              const SizedBox(height: TPSpace.s5),
            ],
            Text(title, textAlign: TextAlign.center, style: TPType.title3.copyWith(color: c.textPrimary)),
            const SizedBox(height: TPSpace.s2),
            Text(message, textAlign: TextAlign.center, style: TPType.callout.copyWith(color: c.textSecondary)),
            if (action != null) ...[const SizedBox(height: TPSpace.s5), action!],
          ],
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;
  static const dash = 6.0;
  static const gap = 6.0;
  static const stroke = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(stroke / 2),
      Radius.circular(radius),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.color != color || old.radius != radius;
}

/// Opens a Tripami sheet: grabber, centered title, close button, optional
/// pinned bottom bar. Use for every secondary task.
Future<T?> showTPSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
  Widget? bottomBar,
  bool large = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: TPMotion.standard,
      reverseDuration: TPMotion.quick,
    ),
    builder: (context) {
      final c = TPColors.of(context);
      final body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(TPSpace.margin + TPSize.hitTarget, 0, TPSpace.s3, TPSpace.s2),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, textAlign: TextAlign.center, style: TPType.title3.copyWith(color: c.textPrimary)),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(TPIcons.x, size: 22),
                ),
              ],
            ),
          ),
          Flexible(child: SingleChildScrollView(child: builder(context))),
          ?bottomBar,
        ],
      );
      return large
          ? SizedBox(height: MediaQuery.sizeOf(context).height * 0.9, child: body)
          : body;
    },
  );
}
