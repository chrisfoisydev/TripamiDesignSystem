import 'dart:async';

import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_format.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
import 'tp_containers.dart';
import 'tp_motion.dart';
import 'tp_people.dart';

/// Rebuilds with the current time every [interval]. Pass [now] to pin the
/// clock (tests, previews, a day that isn't today) and the timer never starts.
class TPNowBuilder extends StatefulWidget {
  const TPNowBuilder({super.key, required this.builder, this.now, this.interval = const Duration(seconds: 30)});

  final Widget Function(BuildContext context, DateTime now) builder;
  final DateTime? now;
  final Duration interval;

  @override
  State<TPNowBuilder> createState() => _TPNowBuilderState();
}

class _TPNowBuilderState extends State<TPNowBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TPNowBuilder old) {
    super.didUpdateWidget(old);
    if ((old.now == null) != (widget.now == null) || old.interval != widget.interval) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _timer = widget.now == null ? Timer.periodic(widget.interval, (_) => setState(() {})) : null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.now ?? DateTime.now());
}

/// A thin progress track: 4pt, pill ends, `sunken` track, accent fill.
/// Eases to new values on the gentle spring (none under Reduce Motion).
class TPProgressBar extends StatelessWidget {
  const TPProgressBar({super.key, required this.value, required this.semanticLabel, this.color});

  /// 0 to 1.
  final double value;

  /// "Vatican Museums progress". The percentage is added.
  final String semanticLabel;

  /// Defaults to the accent: progress is a "now" state.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final v = value.clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel,
      value: '${(v * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TPRadius.pill),
        child: SizedBox(
          height: 4,
          child: ColoredBox(
            color: c.sunken,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: v),
              duration: TPMotion.reduced(context) ? Duration.zero : TPMotion.gentleDuration,
              curve: TPMotion.gentleCurve,
              builder: (context, t, _) => FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: t,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color ?? c.accent,
                    borderRadius: BorderRadius.circular(TPRadius.pill),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What you're doing right now: the heart of a trip day.
///
/// An accent "Now · until 12:30" with a dot, the plan and place, a progress
/// bar with start, time left and end, and who you're with. Accent marks the
/// state; the card itself stays a plain surface, never a filled block.
///
/// Live: updates every 30 seconds. Pass [now] to pin the clock.
class TPNowCard extends StatelessWidget {
  const TPNowCard({
    super.key,
    required this.title,
    required this.start,
    required this.end,
    this.place,
    this.companions = const [],
    this.now,
    this.onTap,
  });

  final String title;
  final String? place;
  final DateTime start;
  final DateTime end;

  /// Everyone on this plan except you. Empty reads "Just you".
  final List<TPMember> companions;
  final DateTime? now;
  final VoidCallback? onTap;

  static String withLabel(List<TPMember> companions) => companions.isEmpty
      ? 'Just you'
      : 'With ${TPFormat.names([for (final m in companions) TPFormat.firstName(m.name)])}';

  @override
  Widget build(BuildContext context) {
    return TPNowBuilder(
      now: now,
      builder: (context, now) {
        final c = TPColors.of(context);
        final large = TPA11y.largeText(context);
        final span = end.difference(start);
        final elapsed = now.difference(start);
        final progress = span.inSeconds <= 0 ? 1.0 : elapsed.inSeconds / span.inSeconds;
        final String left;
        if (now.isBefore(start)) {
          left = 'Starts in ${TPFormat.duration(start.difference(now))}';
        } else if (now.isBefore(end)) {
          left = '${TPFormat.duration(end.difference(now))} left';
        } else {
          left = 'Over by ${TPFormat.duration(now.difference(end))}';
        }
        final eyebrow = 'Now · until ${TPFormat.time(end)}';
        final timeStyle = TPType.footnote.tabular.copyWith(color: c.textSecondary);
        final who = withLabel(companions);

        return Semantics(
          container: true,
          button: onTap != null,
          label: '$eyebrow. $title${place != null ? ', $place' : ''}. $left. $who.',
          excludeSemantics: true,
          child: TPCard(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle)),
                    const SizedBox(width: TPSpace.s2 - 2),
                    Flexible(child: Text(eyebrow.toUpperCase(), style: TPType.eyebrow.copyWith(color: c.accent))),
                  ],
                ),
                const SizedBox(height: TPSpace.s3),
                Text(title, style: TPType.title2.copyWith(color: c.textPrimary)),
                if (place != null) ...[
                  const SizedBox(height: 2),
                  Text(place!, style: TPType.subhead.copyWith(color: c.textSecondary)),
                ],
                const SizedBox(height: TPSpace.s3),
                TPProgressBar(value: progress, semanticLabel: '$title progress'),
                const SizedBox(height: TPSpace.s2 - 2),
                if (large)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${TPFormat.time(start)} – ${TPFormat.time(end)}', style: timeStyle),
                      Text(left, style: timeStyle),
                    ],
                  )
                else
                  Row(
                    children: [
                      Text(TPFormat.time(start), style: timeStyle),
                      Expanded(child: Text(left, textAlign: TextAlign.center, style: timeStyle)),
                      Text(TPFormat.time(end), style: timeStyle),
                    ],
                  ),
                const SizedBox(height: TPSpace.s3),
                Divider(height: 1, thickness: 1, color: c.hairline),
                const SizedBox(height: TPSpace.s3),
                Row(
                  children: [
                    if (companions.isNotEmpty) ...[
                      TPAvatarStack(companions, size: TPAvatarSize.xs),
                      const SizedBox(width: TPSpace.s2),
                    ],
                    Flexible(child: Text(who, style: TPType.subhead.copyWith(color: c.textPrimary))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum TPLeaveState {
  /// More than [TPLeaveByHint.soonWindow] away: quiet secondary text.
  calm,

  /// Inside the window: accent, counting down.
  soon,

  /// Time to go, or past it: caution. Plays the warning haptic once.
  due,
}

/// When to leave for the next plan: "Leave by 12:55 · 5 min walk from the Vatican".
///
/// Quiet until [soonWindow] before [leaveBy], then accent with a countdown
/// ("Leave in 8 min"), then caution once it's time ("Leave now", "Leave now ·
/// 4 min behind"). Turning due plays the warning haptic once, with the color
/// change. Screen readers hear changes politely.
///
/// Live: updates every 30 seconds. Pass [now] to pin the clock.
class TPLeaveByHint extends StatefulWidget {
  const TPLeaveByHint({
    super.key,
    required this.leaveBy,
    required this.travel,
    this.now,
    this.soonWindow = const Duration(minutes: 30),
  });

  final DateTime leaveBy;

  /// "5 min walk from the Vatican".
  final String travel;
  final DateTime? now;
  final Duration soonWindow;

  static TPLeaveState stateAt(DateTime now, DateTime leaveBy, {Duration soonWindow = const Duration(minutes: 30)}) {
    if (!now.isBefore(leaveBy)) return TPLeaveState.due;
    if (leaveBy.difference(now) <= soonWindow) return TPLeaveState.soon;
    return TPLeaveState.calm;
  }

  static String labelAt(DateTime now, DateTime leaveBy, String travel, {Duration soonWindow = const Duration(minutes: 30)}) {
    switch (stateAt(now, leaveBy, soonWindow: soonWindow)) {
      case TPLeaveState.calm:
        return 'Leave by ${TPFormat.time(leaveBy)} · $travel';
      case TPLeaveState.soon:
        return 'Leave in ${TPFormat.duration(leaveBy.difference(now))} · $travel';
      case TPLeaveState.due:
        final behind = now.difference(leaveBy);
        return behind.inMinutes < 1 ? 'Leave now · $travel' : 'Leave now · ${TPFormat.duration(behind)} behind';
    }
  }

  @override
  State<TPLeaveByHint> createState() => _TPLeaveByHintState();
}

class _TPLeaveByHintState extends State<TPLeaveByHint> {
  TPLeaveState? _last;

  @override
  Widget build(BuildContext context) {
    return TPNowBuilder(
      now: widget.now,
      builder: (context, now) {
        final c = TPColors.of(context);
        final state = TPLeaveByHint.stateAt(now, widget.leaveBy, soonWindow: widget.soonWindow);
        // Haptics only for a change the traveler can see happen, never on first show.
        if (_last != null && _last != state && state == TPLeaveState.due) TPHaptics.warning();
        _last = state;
        final color = switch (state) {
          TPLeaveState.calm => c.textSecondary,
          TPLeaveState.soon => c.accent,
          TPLeaveState.due => c.caution,
        };
        final label = TPLeaveByHint.labelAt(now, widget.leaveBy, widget.travel, soonWindow: widget.soonWindow);
        return Semantics(
          liveRegion: true,
          label: label,
          excludeSemantics: true,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(state == TPLeaveState.due ? TPIcons.warning : TPIcons.clock, size: 16, color: color),
              ),
              const SizedBox(width: TPSpace.s2),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: TPMotion.reduced(context) ? Duration.zero : TPMotion.quick,
                  style: TPType.footnote.copyWith(
                    color: color,
                    fontWeight: state == TPLeaveState.calm ? FontWeight.w400 : FontWeight.w600,
                  ),
                  child: Text(label),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
