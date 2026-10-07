import 'package:flutter/material.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_palette.dart';
import '../foundations/tp_type.dart';

/// Full-bleed photo header for a place or a day: "Rome", "Day 5 of 14".
///
/// The photo fills the width with [TPColors.headerScrim] over it: a light
/// wash at the top so glass controls read on bright skies, clear through the
/// middle, dark at the foot under the title. Controls go top ([leading],
/// [trailing]: [TPGlassIconButton], an on-image [TPAvatarStack]); text sits
/// bottom-left in the display face.
///
/// Use a real photo of the place (see Imagery in the docs). Without one the
/// header falls back to brand navy, never a drawing.
///
/// Put the rest of the screen in a [TPOverlapSheet] right below it: the
/// header leaves room for the sheet's [TPSize.sheetOverlap] at its foot.
///
/// At least [minHeight] tall; it grows instead of clipping at large text.
class TPPlaceHeader extends StatelessWidget {
  const TPPlaceHeader({
    super.key,
    required this.title,
    required this.image,
    required this.imageLabel,
    this.eyebrow,
    this.subtitle,
    this.credit,
    this.leading,
    this.trailing = const [],
    this.minHeight = TPSize.placeHeader,
    this.sheetBelow = true,
  });

  final String title;
  final ImageProvider? image;

  /// What the photo shows, for screen readers: "The Tiber leading to St Peter's dome".
  final String imageLabel;

  /// Above the title: "Today · Day 5 of 14".
  final String? eyebrow;

  /// Below the title: "Wednesday 18 November · Italy with Friends".
  final String? subtitle;

  /// Required by some licenses: "Photo: Gareth Williams, CC BY 2.0".
  final String? credit;

  /// Usually the back button.
  final Widget? leading;

  /// Right-aligned controls: travelers, options.
  final List<Widget> trailing;

  final double minHeight;

  /// Leave room at the foot for a [TPOverlapSheet].
  final bool sheetBelow;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final onImage = c.textOnImage;
    final bottom = TPSpace.s6 + (sheetBelow ? TPSize.sheetOverlap : 0);
    final hasControls = leading != null || trailing.isNotEmpty;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Stack(
        children: [
          Positioned.fill(
            child: image != null
                ? Semantics(
                    image: true,
                    label: imageLabel,
                    child: Image(
                      image: image!,
                      fit: BoxFit.cover,
                      // A photo that fails to load falls back to the same navy as no photo.
                      errorBuilder: (context, error, stack) => const ColoredBox(color: TPPalette.textPrimaryLight),
                    ),
                  )
                : const ColoredBox(color: TPPalette.textPrimaryLight),
          ),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: c.headerScrim))),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: IntrinsicHeight(
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasControls)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(TPSpace.s2, TPSpace.s2, TPSpace.s2, TPSpace.s4),
                        child: Row(
                          children: [
                            if (leading != null) leading!,
                            const Spacer(),
                            for (final w in trailing) Padding(padding: const EdgeInsets.only(left: TPSpace.s1), child: w),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: TPSpace.s6),
                    Padding(
                      padding: EdgeInsets.fromLTRB(TPSpace.s6, 0, TPSpace.s6, bottom),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (eyebrow != null) ...[
                            Text(eyebrow!.toUpperCase(), style: TPType.eyebrow.copyWith(color: onImage.withValues(alpha: 0.9))),
                            const SizedBox(height: TPSpace.s1),
                          ],
                          Semantics(
                            header: true,
                            child: Text(title, maxLines: 3, overflow: TextOverflow.ellipsis, style: TPType.display.copyWith(color: onImage)),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: TPSpace.s1),
                            Text(subtitle!, style: TPType.subhead.copyWith(color: onImage)),
                          ],
                          if (credit != null) ...[
                            const SizedBox(height: TPSpace.s2),
                            Text(credit!, style: TPType.caption.copyWith(color: onImage.withValues(alpha: 0.8))),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The surface that rises over a [TPPlaceHeader]: `radius.sheet` top corners
/// on the canvas color, pulled up by [TPSize.sheetOverlap] so the photo shows
/// behind its corners. Put the rest of the screen inside it.
///
/// ```dart
/// ListView(children: [
///   TPPlaceHeader(title: 'Rome', image: rome, imageLabel: '…'),
///   TPOverlapSheet(child: Column(children: [tabs, dayStrip, nowCard, …])),
/// ])
/// ```
class TPOverlapSheet extends StatelessWidget {
  const TPOverlapSheet({super.key, required this.child, this.padding = const EdgeInsets.only(top: TPSpace.s3)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    // Translate rather than negative-margin: hit testing follows the transform,
    // and the sheet's own height is unchanged. Its foot gains overlap-sized
    // canvas, which reads as bottom padding.
    return Transform.translate(
      offset: const Offset(0, -TPSize.sheetOverlap),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: c.canvas,
          shape: const RoundedSuperellipseBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(TPRadius.sheet)),
          ),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
