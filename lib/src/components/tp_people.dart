import 'package:flutter/material.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_palette.dart';
import '../foundations/tp_type.dart';

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
class TPAvatar extends StatelessWidget {
  const TPAvatar(this.member, {super.key, this.size = TPAvatarSize.md, this.showPresence = false});

  final TPMember member;
  final TPAvatarSize size;
  final bool showPresence;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final d = size.dimension;
    final initialsStyle = (d >= 40 ? TPType.subhead.withWeight(TPType.medium) : TPType.caption)
        .copyWith(color: Colors.white, fontSize: d >= 56 ? d * 0.36 : null, height: 1);

    final Widget face = member.photo != null
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

    return Semantics(
      label: member.online && showPresence ? '${member.name}, online' : member.name,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: d,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            face,
            if (showPresence && member.online)
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
class TPAvatarStack extends StatelessWidget {
  const TPAvatarStack(this.members, {super.key, this.size = TPAvatarSize.sm, this.max = 4, this.onImage = false});

  final List<TPMember> members;
  final TPAvatarSize size;
  final int max;

  /// On photos the separating stroke and "+N" use dark glass.
  final bool onImage;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final d = size.dimension;
    final shown = members.take(max).toList();
    final extra = members.length - shown.length;
    const overlap = TPSpace.s2;
    final count = shown.length + (extra > 0 ? 1 : 0);
    final stroke = onImage ? c.glass : c.surface;

    Widget ring(Widget child) => Container(
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: stroke, width: 2)),
          child: child,
        );

    return Semantics(
      label: '${members.length} travelers: ${members.map((m) => m.firstName).join(', ')}',
      excludeSemantics: true,
      child: SizedBox(
        height: d + 4,
        width: count == 0 ? 0 : (d + 4) + (count - 1) * (d + 4 - overlap),
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(left: i * (d + 4 - overlap), child: ring(TPAvatar(shown[i], size: size))),
            if (extra > 0)
              Positioned(
                left: shown.length * (d + 4 - overlap),
                child: ring(Container(
                  width: d,
                  height: d,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: onImage ? c.glass : c.sunken),
                  child: Text(
                    '+$extra',
                    style: TPType.caption.tabular.copyWith(color: onImage ? c.textOnImage : c.textSecondary),
                  ),
                )),
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
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(shape: BoxShape.circle, color: urgent ? c.accent : c.textPrimary),
    );
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
class TPReactionBar extends StatelessWidget {
  const TPReactionBar({super.key, required this.reactions, this.onReact, this.onAdd});

  final List<TPReaction> reactions;
  final ValueChanged<TPReaction>? onReact;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    Widget pill({required Widget child, bool mine = false, VoidCallback? onTap}) => GestureDetector(
          onTap: onTap,
          child: Container(
            height: 28,
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
          pill(
            mine: r.mine,
            onTap: onReact == null ? null : () => onReact!(r),
            child: Text(
              '${r.emoji} ${r.count}',
              style: TPType.caption.tabular.copyWith(color: r.mine ? c.accent : c.textSecondary),
            ),
          ),
        if (onAdd != null)
          Semantics(
            button: true,
            label: 'Add reaction',
            child: pill(
              onTap: onAdd,
              child: Icon(TPIcons.smiley, size: 16, color: c.textSecondary),
            ),
          ),
      ],
    );
  }
}
