import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_format.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_palette.dart';
import '../foundations/tp_ramp.dart';
import '../foundations/tp_ramps.dart';
import '../foundations/tp_type.dart';
import 'tp_containers.dart';
import 'tp_motion.dart';

/// A traveler on a trip.
@immutable
class TPMember {
  const TPMember({
    required this.id,
    required this.name,
    required this.color,
    this.photo,
    this.online = false,
  });

  final String id;
  final String name;
  final TPMemberColor color;
  final ImageProvider? photo;
  final bool online;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }

  String get firstName => name.trim().split(RegExp(r'\s+')).first;
}

enum TPAvatarSize {
  xs(24),
  sm(32),
  md(40),
  lg(56),
  xl(88);

  const TPAvatarSize(this.dimension);
  final double dimension;
}

/// Avatar. With a photo: 2pt member-color ring and a 2pt surface gap.
/// Without one: member-color fill with white initials.
///
/// [invited]: someone asked to join who hasn't yet. A dashed `border.strong`
/// ring around initials in `text.secondary`, no fill: the system's dashed
/// shape for "a space the group hasn't filled yet".
///
/// [dimmed]: not part of this (not going to a plan): greyscale at 45%
/// opacity, ring included. Screen readers hear "…, not going".
class TPAvatar extends StatelessWidget {
  const TPAvatar(this.member,
      {super.key, this.size = TPAvatarSize.md, this.showPresence = false, this.invited = false, this.dimmed = false});

  final TPMember member;
  final TPAvatarSize size;
  final bool showPresence;
  final bool invited;
  final bool dimmed;

  static const _greyscale = ColorFilter.matrix([
    .2126, .7152, .0722, 0, 0, //
    .2126, .7152, .0722, 0, 0,
    .2126, .7152, .0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final d = size.dimension;
    final initialsStyle = (d >= 40 ? TPType.subhead.withWeight(TPType.medium) : TPType.caption)
        .copyWith(color: Colors.white, fontSize: d >= 56 ? d * 0.36 : null, height: 1);

    final Widget face = invited
        ? CustomPaint(
            painter: _DashedCirclePainter(color: c.borderStrong),
            child: Container(
              width: d,
              height: d,
              alignment: Alignment.center,
              child: Text(
                d < 32 ? member.initials.characters.first : member.initials,
                style: initialsStyle.copyWith(color: c.textSecondary),
              ),
            ),
          )
        : member.photo != null
        ? Container(
            width: d,
            height: d,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, color: member.color.color),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface),
              child: ClipOval(child: Image(image: member.photo!, fit: BoxFit.cover)),
            ),
          )
        : Container(
            width: d,
            height: d,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: member.color.color),
            // Two letters crowd anything under 32pt.
            child: Text(d < 32 ? member.initials.characters.first : member.initials, style: initialsStyle),
          );

    final Widget shown = dimmed ? Opacity(opacity: .45, child: ColorFiltered(colorFilter: _greyscale, child: face)) : face;
    return Semantics(
      label: [
        member.name,
        if (invited) 'invited',
        if (dimmed) 'not going',
        if (!invited && !dimmed && member.online && showPresence) 'online',
      ].join(', '),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: d,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            shown,
            if (showPresence && member.online && !dimmed)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.positive,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.surface, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Overlapping avatars, max [max] shown, then "+N".
///
/// Someone joining after the stack first appears pops in on the playful
/// spring while the others glide over to make room, and "+N" bumps. The
/// people already there on first build just appear.
class TPAvatarStack extends StatefulWidget {
  const TPAvatarStack(this.members, {super.key, this.size = TPAvatarSize.sm, this.max = 4, this.onImage = false});

  final List<TPMember> members;
  final TPAvatarSize size;
  final int max;

  /// On photos the separating stroke and "+N" use dark glass.
  final bool onImage;

  @override
  State<TPAvatarStack> createState() => _TPAvatarStackState();
}

class _TPAvatarStackState extends State<TPAvatarStack> {
  late final Set<String> _initial = {for (final m in widget.members) m.id};

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final members = widget.members;
    final d = widget.size.dimension;
    final shown = members.take(widget.max).toList();
    final extra = members.length - shown.length;
    const overlap = TPSpace.s2;
    final count = shown.length + (extra > 0 ? 1 : 0);
    final stroke = widget.onImage ? c.glass : c.surface;
    final step = d + 4 - overlap;
    final reduced = TPMotion.reduced(context);
    final glide = reduced ? Duration.zero : TPMotion.gentleDuration;

    Widget ring(Widget child) => Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: stroke, width: 2)),
          child: child,
        );

    return Semantics(
      label: '${members.length} travelers: ${members.map((m) => m.firstName).join(', ')}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: glide,
        curve: TPMotion.gentleCurve,
        height: d + 4,
        width: count == 0 ? 0 : (d + 4) + (count - 1) * step,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < shown.length; i++)
              AnimatedPositioned(
                key: ValueKey(shown[i].id),
                duration: glide,
                curve: TPMotion.gentleCurve,
                left: i * step,
                top: 0,
                child: _initial.contains(shown[i].id)
                    ? ring(TPAvatar(shown[i], size: widget.size))
                    : TPPop(child: ring(TPAvatar(shown[i], size: widget.size))),
              ),
            if (extra > 0)
              AnimatedPositioned(
                key: const ValueKey('_more'),
                duration: glide,
                curve: TPMotion.gentleCurve,
                left: shown.length * step,
                top: 0,
                child: TPBump(
                  value: extra,
                  child: ring(Container(
                    width: d,
                    height: d,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: widget.onImage ? c.glass : c.sunken),
                    child: Text(
                      '+$extra',
                      style: TPType.caption.tabular.copyWith(color: widget.onImage ? c.textOnImage : c.textSecondary),
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "[avatar] Maya added · 2h". The main way presence shows up in content.
class TPAttribution extends StatelessWidget {
  const TPAttribution({super.key, required this.member, required this.action, this.time});

  final TPMember member;
  final String action;
  final String? time;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TPAvatar(member, size: TPAvatarSize.xs),
        const SizedBox(width: TPSpace.s2),
        Flexible(
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: member.firstName, style: TextStyle(color: c.textPrimary)),
              TextSpan(text: ' $action${time != null ? ' · $time' : ''}'),
            ]),
            style: TPType.footnote.copyWith(color: c.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 8pt dot. [urgent] = mentioned or action needed (accent orange); otherwise new
/// since your last visit (ink). Red stays for errors. Use instead of numeric badges.
class TPActivityDot extends StatelessWidget {
  const TPActivityDot({super.key, this.urgent = false});
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: urgent ? c.accent : c.textPrimary),
    );
    // A needs-you dot arrives with the brand's pop; a "new" dot just appears.
    return urgent ? TPPop(child: dot) : dot;
  }
}

@immutable
class TPReaction {
  const TPReaction({required this.emoji, required this.count, this.mine = false});
  final String emoji;
  final int count;
  final bool mine;
}

/// User reactions. Emoji appear here because they are user content; they are
/// never used as UI icons.
///
/// Reacting plays [TPHaptics.join] and presses like a button; a pill bumps
/// when its count changes and eases between the plain and "mine" colors.
class TPReactionBar extends StatelessWidget {
  const TPReactionBar({super.key, required this.reactions, this.onReact, this.onAdd});

  final List<TPReaction> reactions;
  final ValueChanged<TPReaction>? onReact;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    Widget pill({required Widget child, bool mine = false, VoidCallback? onTap, TPHaptic haptic = TPHaptic.join}) =>
        TPPressable(
          onTap: onTap,
          haptic: haptic,
          pressedScale: 0.94,
          expandTapTarget: onTap != null,
          child: AnimatedContainer(
            duration: TPMotion.snappyDuration,
            curve: TPMotion.snappyCurve,
            constraints: const BoxConstraints(minHeight: 28),
            padding: const EdgeInsets.symmetric(horizontal: TPSpace.s2),
            decoration: ShapeDecoration(
              color: mine ? c.accentSubtle : c.sunken,
              shape: StadiumBorder(side: BorderSide(color: mine ? c.accent : Colors.transparent)),
            ),
            child: Center(widthFactor: 1, child: child),
          ),
        );

    return Wrap(
      spacing: TPSpace.s1 + 2,
      runSpacing: TPSpace.s1 + 2,
      children: [
        for (final r in reactions.take(3))
          TPBump(
            key: ValueKey(r.emoji),
            value: (r.count, r.mine),
            child: Semantics(
              button: onReact != null,
              toggled: onReact != null ? r.mine : null,
              label: '${r.emoji} ${r.count}${r.mine ? ', including you' : ''}',
              excludeSemantics: true,
              child: pill(
              mine: r.mine,
              onTap: onReact == null ? null : () => onReact!(r),
              child: Text(
                '${r.emoji} ${r.count}',
                style: TPType.caption.tabular.copyWith(color: r.mine ? c.accent : c.textSecondary),
              ),
            ),
            ),
          ),
        if (onAdd != null)
          Semantics(
            button: true,
            label: 'Add reaction',
            child: pill(
              onTap: onAdd,
              haptic: TPHaptic.none,
              child: Icon(TPIcons.smiley, size: 16, color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}


class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.5;
    final r = size.shortestSide / 2 - stroke / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    // About 4pt dashes with equal gaps, a whole number around the circle.
    final dashes = (2 * 3.14159265 * r / 8).floor().clamp(8, 64);
    final sweep = 2 * 3.14159265 / dashes;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    for (var i = 0; i < dashes; i++) {
      canvas.drawArc(rect, i * sweep, sweep / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

/// A small label for someone's role or status on a trip: "Organizer",
/// "Invited". Caption weight 600 in a pill.
///
/// [TPRoleTag.neutral] (`sunken`, `text.secondary`) for roles.
/// [TPRoleTag.pending] (amber tone) for something waiting on that person.
/// Never navy or orange fills: those mean "action" and "you, now".
class TPRoleTag extends StatelessWidget {
  const TPRoleTag.neutral(this.label, {super.key}) : pending = false;
  const TPRoleTag.pending(this.label, {super.key}) : pending = true;

  final String label;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final tone = TPTone.of(context, TPRamps.amber);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: TPSpace.s2, vertical: 2),
      decoration: BoxDecoration(
        color: pending ? tone.subtle : c.sunken,
        borderRadius: BorderRadius.circular(TPRadius.pill),
      ),
      child: Text(
        label,
        style: TPType.caption.withWeight(TPType.semibold).copyWith(color: pending ? tone.text : c.textSecondary),
      ),
    );
  }
}

/// A row about a group of people: their faces, what they're doing, who, and
/// an optional time. "Vatican Museums · You and Sandra · until 12:30".
/// The faces sit in a fixed-width slot so titles line up down a list.
class TPGroupRow extends StatelessWidget {
  const TPGroupRow({
    super.key,
    required this.members,
    required this.title,
    this.detail,
    this.value,
    this.onTap,
    this.showDivider = true,
  });

  final List<TPMember> members;
  final String title;

  /// Usually who: "You and Sandra". Defaults to their first names.
  final String? detail;

  /// "until 12:30".
  final String? value;
  final VoidCallback? onTap;
  final bool showDivider;

  static const _slot = 72.0;

  @override
  Widget build(BuildContext context) {
    final who = detail ?? TPFormat.names([for (final m in members) m.firstName]);
    if (TPA11y.largeText(context)) {
      // Large text: faces on top, then the words full width, time last.
      final c = TPColors.of(context);
      return Semantics(
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin, vertical: TPSpace.s3),
            decoration: showDivider ? BoxDecoration(border: Border(bottom: BorderSide(color: c.hairline))) : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TPAvatarStack(members, size: TPAvatarSize.xs, max: 3),
                const SizedBox(height: TPSpace.s2),
                Text(title, style: TPType.body.copyWith(color: c.textPrimary)),
                Text(who, style: TPType.footnote.copyWith(color: c.textSecondary)),
                if (value != null) Text(value!, style: TPType.footnote.tabular.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }
    return TPListRow(
      label: title,
      detail: who,
      value: value,
      onTap: onTap,
      showDivider: showDivider,
      leading: SizedBox(
        width: _slot,
        child: Align(alignment: Alignment.centerLeft, child: TPAvatarStack(members, size: TPAvatarSize.xs, max: 3)),
      ),
    );
  }
}
