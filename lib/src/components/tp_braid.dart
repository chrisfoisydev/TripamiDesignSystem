import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_palette.dart';
import '../foundations/tp_type.dart';
import 'tp_actions.dart';
import 'tp_motion.dart';
import 'tp_people.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// A named group of travelers ("Rome crew"). On big trips each group is one
/// strand in the braid.
@immutable
class TPBraidGroup {
  const TPBraidGroup({required this.id, required this.name, required this.color, required this.memberIds});

  final String id;
  final String name;
  final TPMemberColor color;
  final Set<String> memberIds;
}

/// One plan on the day.
@immutable
class TPBraidEvent {
  const TPBraidEvent({
    required this.id,
    required this.title,
    required this.participantIds,
    this.start,
    this.end,
    this.place,
    this.loose = false,
    this.now = false,
    this.footer,
  });

  final String id;
  final String title;
  final Set<String> participantIds;
  final String? start;
  final String? end;
  final String? place;

  /// No real plan ("No plans, just vibes"): dashed card, dotted strands.
  final bool loose;

  /// Happening now: the card gets the accent tint.
  final bool now;

  /// Optional extra line, for example a "Scan receipt" link.
  final Widget? footer;
}

/// A point in the day where one or more plans start at the same time.
@immutable
class TPBraidMoment {
  const TPBraidMoment({required this.time, required this.events});

  final String time;
  final List<TPBraidEvent> events;
}

enum TPStrandKind { person, group, others }

/// One strand. A strand is a person on small trips, and a group (or "everyone
/// else") on big ones. Color always means one kind of thing per view.
@immutable
class TPStrand {
  const TPStrand({
    required this.id,
    required this.label,
    required this.kind,
    required this.memberIds,
    this.color,
    this.isYou = false,
  });

  final String id;
  final String label;
  final TPStrandKind kind;
  final Set<String> memberIds;

  /// Null for the neutral "everyone else" ribbon.
  final TPMemberColor? color;
  final bool isYou;

  int get count => memberIds.length;

  double get width => TPBraidMetrics.widthFor(count) + (isYou ? TPBraidMetrics.youExtra : 0);
}

// ---------------------------------------------------------------------------
// Who gets a strand
// ---------------------------------------------------------------------------

/// Decides the strands for a day, following the braid's scaling rules:
///
/// - **2–8 travelers:** one strand per person, in their member color.
/// - **9–20:** you, plus the people you share plans with (up to
///   `maxStrands - 2`), plus one neutral "Everyone else" ribbon.
/// - **21+:** you, plus one ribbon per group (yours first, then by size).
///   If there are too many groups, the rest fold into a "+N more groups"
///   ribbon so no more than [maxStrands] strands are ever shown.
List<TPStrand> resolveBraidStrands({
  required List<TPMember> members,
  required String youId,
  List<TPBraidGroup> groups = const [],
  List<TPBraidMoment> moments = const [],
  int maxStrands = TPBraidMetrics.maxStrands,
}) {
  TPStrand person(TPMember m) => TPStrand(
        id: m.id,
        label: m.id == youId ? 'You' : m.firstName,
        kind: TPStrandKind.person,
        memberIds: {m.id},
        color: m.color,
        isYou: m.id == youId,
      );

  if (members.length <= 8) return [for (final m in members) person(m)];

  final you = members.firstWhere((m) => m.id == youId, orElse: () => members.first);
  final memberOrder = {for (var i = 0; i < members.length; i++) members[i].id: i};

  if (members.length <= 20) {
    final shared = <String, int>{};
    for (final moment in moments) {
      for (final event in moment.events) {
        if (!event.participantIds.contains(you.id)) continue;
        for (final id in event.participantIds) {
          if (id != you.id) shared[id] = (shared[id] ?? 0) + 1;
        }
      }
    }
    final close = members.where((m) => m.id != you.id && (shared[m.id] ?? 0) > 0).toList()
      ..sort((a, b) {
        final byShared = (shared[b.id] ?? 0).compareTo(shared[a.id] ?? 0);
        return byShared != 0 ? byShared : memberOrder[a.id]!.compareTo(memberOrder[b.id]!);
      });
    final kept = close.take(maxStrands - 2).toList();
    final keptIds = {you.id, ...kept.map((m) => m.id)};
    final rest = members.where((m) => !keptIds.contains(m.id)).map((m) => m.id).toSet();
    return [
      person(you),
      ...kept.map(person),
      if (rest.isNotEmpty)
        TPStrand(id: '_others', label: 'Everyone else', kind: TPStrandKind.others, memberIds: rest),
    ];
  }

  // Group scale.
  final assigned = <String>{you.id};
  final ordered = [...groups]..sort((a, b) {
      final aMine = a.memberIds.contains(you.id) ? 0 : 1;
      final bMine = b.memberIds.contains(you.id) ? 0 : 1;
      if (aMine != bMine) return aMine.compareTo(bMine);
      return b.memberIds.length.compareTo(a.memberIds.length);
    });
  final groupStrands = <TPStrand>[];
  for (final g in ordered) {
    final ids = g.memberIds.where((id) => memberOrder.containsKey(id) && !assigned.contains(id)).toSet();
    if (ids.isEmpty) continue;
    assigned.addAll(ids);
    groupStrands.add(TPStrand(id: g.id, label: g.name, kind: TPStrandKind.group, memberIds: ids, color: g.color));
  }
  final unassigned = members.map((m) => m.id).where((id) => !assigned.contains(id)).toSet();

  if (groupStrands.length + (unassigned.isEmpty ? 0 : 1) <= maxStrands - 1) {
    return [
      person(you),
      ...groupStrands,
      if (unassigned.isNotEmpty)
        TPStrand(id: '_others', label: 'Everyone else', kind: TPStrandKind.others, memberIds: unassigned),
    ];
  }
  final keep = groupStrands.take(maxStrands - 2).toList();
  final folded = groupStrands.skip(maxStrands - 2).toList();
  return [
    person(you),
    ...keep,
    TPStrand(
      id: '_others',
      label: folded.isEmpty ? 'Everyone else' : '+${folded.length} more groups',
      kind: TPStrandKind.others,
      memberIds: {...folded.expand((s) => s.memberIds), ...unassigned},
    ),
  ];
}

/// Which event in [moment] each strand is at: the one holding most of its
/// members, or null when none of its members has a plan then.
List<int?> braidAssignments(List<TPStrand> strands, TPBraidMoment moment) {
  return [
    for (final s in strands)
      () {
        int? best;
        var bestCount = 0;
        for (var i = 0; i < moment.events.length; i++) {
          final c = s.memberIds.where(moment.events[i].participantIds.contains).length;
          if (c > bestCount) {
            best = i;
            bestCount = c;
          }
        }
        return best;
      }(),
  ];
}

// ---------------------------------------------------------------------------
// Copy
// ---------------------------------------------------------------------------

/// Card label: "All 5 together", "You + Sandra", "Rome crew · 14",
/// "You, Maya + 3 more".
String braidEventLabel(TPBraidEvent event, List<TPMember> members, String youId, List<TPBraidGroup> groups) {
  final ids = members.where((m) => event.participantIds.contains(m.id)).toList();
  if (ids.length == members.length) return 'All ${ids.length} together';
  for (final g in groups) {
    final inTrip = g.memberIds.where((id) => members.any((m) => m.id == id)).toSet();
    if (inTrip.length > 2 && inTrip.length == ids.length && ids.every((m) => inTrip.contains(m.id))) {
      return '${g.name} · ${ids.length}';
    }
  }
  final names = [
    if (ids.any((m) => m.id == youId)) 'You',
    ...ids.where((m) => m.id != youId).map((m) => m.firstName),
  ];
  return switch (names.length) {
    0 => 'Nobody yet',
    1 => names[0],
    2 => '${names[0]} + ${names[1]}',
    3 => '${names[0]}, ${names[1]} + ${names[2]}',
    _ => '${names[0]}, ${names[1]} + ${names.length - 2} more',
  };
}

/// Moment marker: "All 5 together", "Splits into 2", "Back together", "3 going".
String braidMomentSummary(TPBraidMoment moment, TPBraidMoment? previous, int tripSize) {
  if (moment.events.length > 1) return 'Splits into ${moment.events.length}';
  final count = moment.events.isEmpty ? 0 : moment.events.first.participantIds.length;
  if (count >= tripSize) {
    return previous != null && previous.events.length > 1 ? 'Back together' : 'All $tripSize together';
  }
  return '$count going';
}

// ---------------------------------------------------------------------------
// Event card
// ---------------------------------------------------------------------------

/// The card a braid bundle connects to.
///
/// - Default: surface card.
/// - [mine]: you're in it, so it gets a 1.5px accent outline and an accent label.
/// - [loose]: no real plan, so a dashed border on canvas.
/// - [now]: happening now, so an accent-subtle tint.
class TPBraidEventCard extends StatelessWidget {
  const TPBraidEventCard({
    super.key,
    required this.label,
    required this.title,
    this.detail,
    this.mine = false,
    this.loose = false,
    this.now = false,
    this.footer,
    this.semanticLabel,
  });

  final String label;
  final String title;
  final String? detail;
  final bool mine;
  final bool loose;
  final bool now;
  final Widget? footer;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final brightness = Theme.of(context).brightness;
    final content = Padding(
      padding: const EdgeInsets.all(TPSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TPType.footnote.withWeight(TPType.medium).copyWith(color: mine ? c.accent : c.textSecondary)),
          const SizedBox(height: 2),
          Text(title, style: TPType.title3.copyWith(color: c.textPrimary)),
          if (detail != null) ...[
            const SizedBox(height: 2),
            Text(detail!, style: TPType.footnote.tabular.copyWith(color: c.textSecondary)),
          ],
          if (footer != null) ...[const SizedBox(height: TPSpace.s2), footer!],
        ],
      ),
    );

    final Widget card = loose
        ? CustomPaint(
            foregroundPainter: _DashedBorderPainter(color: mine ? c.accent : c.borderStrong, radius: TPRadius.md),
            child: content,
          )
        : DecoratedBox(
            decoration: ShapeDecoration(
              color: now ? c.accentSubtle : c.surface,
              shadows: mine ? const [] : TPElevation.of(brightness),
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(TPRadius.md),
                side: mine
                    ? BorderSide(color: c.accent, width: 1.5)
                    : brightness == Brightness.dark
                        ? BorderSide(color: c.hairline)
                        : BorderSide.none,
              ),
            ),
            child: content,
          );

    return Semantics(
      container: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: card,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.75), Radius.circular(radius));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < m.length; d += 12) {
        canvas.drawPath(m.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

// ---------------------------------------------------------------------------
// Moment marker
// ---------------------------------------------------------------------------

/// "08:00  All 5 together". Time in title3 tabular, summary in footnote.
class TPBraidMarker extends StatelessWidget {
  const TPBraidMarker({super.key, required this.time, required this.summary});

  final String time;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final timeText = Text(time, style: TPType.title3.tabular.copyWith(color: c.textPrimary));
    final summaryText = Text(summary, style: TPType.footnote.copyWith(color: c.textSecondary));
    // Large text: the summary wraps under the time instead of squeezing beside it.
    if (TPA11y.largeText(context)) {
      return Wrap(spacing: TPSpace.s2, crossAxisAlignment: WrapCrossAlignment.end, children: [timeText, summaryText]);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [timeText, const SizedBox(width: TPSpace.s2), Flexible(child: summaryText)],
    );
  }
}

// ---------------------------------------------------------------------------
// The day
// ---------------------------------------------------------------------------

/// A whole day as a braid: moment markers, event cards, and the strands that
/// bundle and part between them. Scales from 2 to 50+ travelers using
/// [resolveBraidStrands]. Phones get one strand gutter on the left; at
/// [TPBraidMetrics.twoSidedMinWidth] and wider, groups you're not part of
/// move to a right-hand gutter.
class TPBraidDay extends StatefulWidget {
  const TPBraidDay({
    super.key,
    required this.members,
    required this.youId,
    required this.moments,
    this.groups = const [],
    this.maxVisibleEvents = 3,
    this.onEventTap,
  });

  final List<TPMember> members;
  final String youId;
  final List<TPBraidMoment> moments;
  final List<TPBraidGroup> groups;

  /// Events shown per moment before "Show N more".
  final int maxVisibleEvents;
  final ValueChanged<TPBraidEvent>? onEventTap;

  @override
  State<TPBraidDay> createState() => _TPBraidDayState();
}

class _Lane {
  _Lane(this.x, this.loose);
  final double x;
  final bool loose;
}

typedef _Lanes = Map<String, _Lane>;

class _TPBraidDayState extends State<TPBraidDay> with TickerProviderStateMixin {
  final _expanded = <int>{};

  // Draw-in: strands draw top to bottom and cards rise beside them, once per open.
  late final AnimationController _draw = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  // Reroute: when plans change, strands glide from where they were to where
  // they now go, so you can see who moved.
  late final AnimationController _reroute = AnimationController(vsync: this, duration: TPMotion.gentleDuration, value: 1);
  Map<String, List<_Lanes>> _displayed = {};
  Map<String, List<_Lanes>> _from = {};
  bool _started = false;
  bool _settledOnce = false; // knots only pop for changes after the first draw

  static const _cardRise = 300; // ms each card takes to fade and rise

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (TPMotion.reduced(context)) {
        _draw.value = 1;
        WidgetsBinding.instance.addPostFrameCallback((_) => _settledOnce = true);
      } else {
        _draw.forward().whenComplete(() => _settledOnce = true);
      }
    }
  }

  @override
  void didUpdateWidget(TPBraidDay old) {
    super.didUpdateWidget(old);
    if (!identical(old.moments, widget.moments) || old.youId != widget.youId || old.members.length != widget.members.length) {
      _from = Map.of(_displayed);
      if (TPMotion.reduced(context)) {
        _reroute.value = 1;
      } else {
        _reroute.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    _reroute.dispose();
    super.dispose();
  }

  /// Strands draw as one continuous line, top to bottom: row [row] of
  /// [rows] fills its share of the eased sweep.
  double _strandRevealFor(int row, int rows) =>
      (TPMotion.ease.transform(_draw.value) * rows - row).clamp(0.0, 1.0);

  /// Cards fade and rise as the line reaches them.
  double _cardRevealFor(int row, int rows) {
    final total = _draw.duration!.inMilliseconds - _cardRise;
    final ms = _draw.value * _draw.duration!.inMilliseconds;
    final start = rows <= 1 ? 0 : total * row / (rows - 1);
    return TPMotion.ease.transform(((ms - start) / _cardRise).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_draw, _reroute]),
      builder: (context, _) => LayoutBuilder(builder: (context, constraints) {
      final strands = resolveBraidStrands(
        members: widget.members,
        youId: widget.youId,
        groups: widget.groups,
        moments: widget.moments,
      );
      final byId = {for (final s in strands) s.id: s};

      // Sides: you and whoever is with you when the group splits stay left.
      final you = strands.firstWhere((s) => s.isYou, orElse: () => strands.first);
      final leftIds = <String>{you.id};
      for (final m in widget.moments.where((m) => m.events.length > 1)) {
        final a = braidAssignments(strands, m);
        final yourEvent = a[strands.indexOf(you)];
        if (yourEvent == null) continue;
        for (var i = 0; i < strands.length; i++) {
          if (a[i] == yourEvent) leftIds.add(strands[i].id);
        }
      }
      final rightIds = strands.map((s) => s.id).where((id) => !leftIds.contains(id)).toSet();
      final twoSided = constraints.maxWidth >= TPBraidMetrics.twoSidedMinWidth && rightIds.isNotEmpty;
      final sideOf = {for (final s in strands) s.id: twoSided && rightIds.contains(s.id) ? 1 : 0};

      // Lay out every row first, so we know the gutter widths.
      final rows = <_RowSpec>[];
      final keys = <String>[];
      final needed = [0.0, 0.0];
      List<_Lanes> prev = [{}, {}];

      List<_Lanes> layoutFor(TPBraidMoment moment, int? focus) {
        final assign = braidAssignments(strands, moment);
        final lanes = <_Lanes>[{}, {}];
        for (final side in [0, 1]) {
          final order = <int?>[focus, for (var i = 0; i < moment.events.length; i++) if (i != focus) i, null];
          var x = 6.0;
          for (final bundle in order) {
            final members = [
              for (var i = 0; i < strands.length; i++)
                if (assign[i] == bundle && sideOf[strands[i].id] == side) strands[i],
            ]..sort((a, b) => (a.isYou ? 0 : 1).compareTo(b.isYou ? 0 : 1));
            if (members.isEmpty) continue;
            for (final s in members) {
              x += s.width / 2;
              final loose = bundle == null || moment.events[bundle].loose;
              lanes[side][s.id] = _Lane(x, loose);
              x += s.width / 2 + TPBraidMetrics.gap;
            }
            x += TPBraidMetrics.bundleGap - TPBraidMetrics.gap;
          }
          if (x > needed[side]) needed[side] = x;
        }
        return lanes;
      }

      for (var mi = 0; mi < widget.moments.length; mi++) {
        final moment = widget.moments[mi];
        final events = [...moment.events.asMap().entries]..sort((a, b) {
            final aMine = a.value.participantIds.contains(widget.youId) ? 0 : 1;
            final bMine = b.value.participantIds.contains(widget.youId) ? 0 : 1;
            if (aMine != bMine) return aMine.compareTo(bMine);
            return b.value.participantIds.length.compareTo(a.value.participantIds.length);
          });
        final firstLanes = layoutFor(moment, events.isEmpty ? null : events.first.key);
        if (mi == 0) prev = firstLanes;
        keys.add('m$mi');
        rows.add(_RowSpec.marker(
          entry: prev,
          lanes: prev,
          time: moment.time,
          summary: braidMomentSummary(moment, mi == 0 ? null : widget.moments[mi - 1], widget.members.length),
        ));
        final showAll = _expanded.contains(mi) || events.length <= widget.maxVisibleEvents;
        final visible = showAll ? events : events.take(widget.maxVisibleEvents).toList();
        for (final e in visible) {
          final lanes = layoutFor(moment, e.key);
          final assign = braidAssignments(strands, moment);
          final inEvent = [for (var i = 0; i < strands.length; i++) if (assign[i] == e.key) strands[i]];
          final side = inEvent.any((s) => sideOf[s.id] == 0) || inEvent.isEmpty ? 0 : 1;
          keys.add('e$mi:${e.value.id}');
          final revealed = visible.indexOf(e) - widget.maxVisibleEvents;
          rows.add(_RowSpec.event(
            entry: prev,
            lanes: lanes,
            event: e.value,
            eventStrands: inEvent,
            side: side,
            riseIndex: _expanded.contains(mi) && revealed >= 0 ? revealed : null,
          ));
          prev = lanes;
        }
        if (!showAll) {
          final hidden = events.length - visible.length;
          keys.add('x$mi');
          rows.add(_RowSpec.more(entry: prev, lanes: prev, label: 'Show $hidden more', momentIndex: mi));
        }
      }

      // Glide strands from where they were drawn last to where they go now.
      final t = TPMotion.gentleCurve.transform(_reroute.value);
      final shown = <String, List<_Lanes>>{};
      List<_Lanes>? before;
      for (var i = 0; i < rows.length; i++) {
        final target = rows[i].lanes;
        final from = _from[keys[i]];
        final lanes = from == null || _reroute.value >= 1
            ? target
            : [
                for (var side = 0; side < 2; side++)
                  {
                    for (final e in target[side].entries)
                      e.key: _Lane(
                        (from[side][e.key]?.x ?? e.value.x) + (e.value.x - (from[side][e.key]?.x ?? e.value.x)) * t,
                        e.value.loose,
                      ),
                  },
              ];
        rows[i]
          ..entry = before ?? lanes
          ..lanes = lanes;
        before = lanes;
        shown[keys[i]] = lanes;
      }
      _displayed = shown;

      final leftGutter = needed[0].clamp(TPBraidMetrics.gutter, 140.0);
      final rightGutter = twoSided ? needed[1].clamp(TPBraidMetrics.gutter, 140.0) : 0.0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++)
            _BraidRow(
              key: ValueKey(keys[i]),
              spec: rows[i],
              reveal: _strandRevealFor(i, rows.length),
              contentReveal: _cardRevealFor(i, rows.length),
              popKnots: _settledOnce,
              strands: byId,
              members: widget.members,
              youId: widget.youId,
              groups: widget.groups,
              leftGutter: leftGutter,
              rightGutter: rightGutter,
              // Plans revealed by "Show more" rise in, staggered.
              onMore: rows[i].momentIndex == null ? null : () => setState(() => _expanded.add(rows[i].momentIndex!)),
              onTap: widget.onEventTap,
            ),
        ],
      );
    }),
    );
  }
}

enum _RowKind { marker, event, more }

class _RowSpec {
  _RowSpec.marker({required this.entry, required this.lanes, required String this.time, required String this.summary})
      : kind = _RowKind.marker,
        event = null,
        eventStrands = const [],
        side = 0,
        label = null,
        momentIndex = null,
        riseIndex = null;
  _RowSpec.event({
    required this.entry,
    required this.lanes,
    required TPBraidEvent this.event,
    required this.eventStrands,
    required this.side,
    this.riseIndex,
  })  : kind = _RowKind.event,
        time = null,
        summary = null,
        label = null,
        momentIndex = null;
  _RowSpec.more({required this.entry, required this.lanes, required String this.label, required int this.momentIndex})
      : kind = _RowKind.more,
        time = null,
        summary = null,
        event = null,
        eventStrands = const [],
        side = 0,
        riseIndex = null;

  final _RowKind kind;
  List<_Lanes> entry;
  List<_Lanes> lanes;
  final String? time;
  final String? summary;
  final TPBraidEvent? event;
  final List<TPStrand> eventStrands;
  final int side;
  final String? label;
  final int? momentIndex;

  /// Set on plans just revealed by "Show more": their stagger position.
  final int? riseIndex;
}

class _BraidRow extends StatelessWidget {
  const _BraidRow({
    super.key,
    required this.spec,
    required this.reveal,
    required this.contentReveal,
    required this.popKnots,
    required this.strands,
    required this.members,
    required this.youId,
    required this.groups,
    required this.leftGutter,
    required this.rightGutter,
    required this.onMore,
    required this.onTap,
  });

  final _RowSpec spec;
  final Map<String, TPStrand> strands;
  final List<TPMember> members;
  final String youId;
  final List<TPBraidGroup> groups;
  final double leftGutter;
  final double rightGutter;
  final VoidCallback? onMore;
  final ValueChanged<TPBraidEvent>? onTap;

  /// 0→1 draw-in progress of this row's strands.
  final double reveal;

  /// 0→1 fade-and-rise progress of this row's card, avatars and text.
  final double contentReveal;

  /// After the first draw, knots pop when the people in them change.
  final bool popKnots;

  static const _knotY = 44.0;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final brightness = Theme.of(context).brightness;

    Widget gutter(int side, double width) {
      final isKnotSide = spec.kind == _RowKind.event && spec.side == side;
      final ids = spec.eventStrands.map((s) => s.id).toSet();
      final xs = [for (final id in ids) if (spec.lanes[side][id] != null) spec.lanes[side][id]!.x];
      double? bundleCenter;
      if (isKnotSide && xs.isNotEmpty) {
        xs.sort();
        bundleCenter = (xs.first + xs.last) / 2;
      }
      List<TPMember> knotPeople = const [];
      if (isKnotSide) {
        knotPeople = members.where((m) => spec.event!.participantIds.contains(m.id)).toList()
          ..sort((a, b) => (a.id == youId ? 0 : 1).compareTo(b.id == youId ? 0 : 1));
      }
      const avatar = 24.0;
      final shown = knotPeople.length > 3 ? 4 : knotPeople.length;
      final stackW = shown == 0 ? 0.0 : (avatar + 4) + (shown - 1) * (avatar + 4 - TPSpace.s2);
      double toX(double x) => side == 1 ? width - x : x;
      final stackLeft = bundleCenter == null ? 0.0 : (toX(bundleCenter) - stackW / 2).clamp(0.0, width - stackW);

      final draws = <_StrandDraw>[
        for (final s in strands.values)
          if (spec.lanes[side][s.id] != null)
            _StrandDraw(
              entryX: toX((spec.entry[side][s.id] ?? spec.lanes[side][s.id]!).x),
              x: toX(spec.lanes[side][s.id]!.x),
              width: s.width,
              color: s.color?.strand(brightness) ?? c.textTertiary,
              loose: spec.lanes[side][s.id]!.loose,
              isYou: s.isYou,
            ),
      ];

      return SizedBox(
        width: width,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _StrandPainter(
                  reveal: reveal,
                  strands: draws,
                  knotY: spec.kind == _RowKind.event ? _knotY : 0,
                  connector: bundleCenter != null
                      ? (side == 0 ? (stackLeft + stackW + 4, width) : (0.0, stackLeft - 4))
                      // Strands on the other side that are also in this plan still join it.
                      : spec.kind == _RowKind.event && xs.isNotEmpty
                          ? (side == 0 ? (toX(xs.reduce((a, b) => a > b ? a : b)) + 6, width) : (0.0, toX(xs.reduce((a, b) => a > b ? a : b)) - 6))
                          : null,
                  connectorColor: c.borderStrong,
                ),
              ),
            ),
            if (bundleCenter != null && shown > 0)
              Positioned(
                left: stackLeft,
                top: _knotY - avatar / 2 - 2,
                child: Opacity(
                  opacity: contentReveal,
                  child: TPPop(
                    key: ValueKey(knotPeople.map((m) => m.id).join(',')),
                    play: popKnots,
                    child: TPAvatarStack(knotPeople, size: TPAvatarSize.xs, max: 3),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final Widget body = switch (spec.kind) {
      _RowKind.marker => Padding(
          padding: const EdgeInsets.only(top: TPSpace.s5, bottom: TPSpace.s2),
          child: TPBraidMarker(time: spec.time!, summary: spec.summary!),
        ),
      _RowKind.more => Padding(
          padding: const EdgeInsets.only(bottom: TPSpace.s2),
          child: Align(alignment: Alignment.centerLeft, child: TPButton.tertiary(label: spec.label!, onPressed: onMore)),
        ),
      _RowKind.event => Padding(
          padding: const EdgeInsets.only(top: TPSpace.s2, bottom: TPSpace.s2),
          child: TPRise(
            play: spec.riseIndex != null,
            index: spec.riseIndex ?? 0,
            child: TPPressable(
              onTap: onTap == null ? null : () => onTap!(spec.event!),
              pressedScale: 0.99,
              focusShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TPRadius.md)),
              child: _eventCard(),
            ),
          ),
        ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          gutter(0, leftGutter),
          const SizedBox(width: TPSpace.s2),
          Expanded(
            child: Opacity(
              opacity: contentReveal,
              child: Transform.translate(offset: Offset(0, 8 * (1 - contentReveal)), child: body),
            ),
          ),
          if (rightGutter > 0) ...[const SizedBox(width: TPSpace.s2), gutter(1, rightGutter)],
        ],
      ),
    );
  }

  Widget _eventCard() {
    final e = spec.event!;
    // The outline marks a subgroup you're in; when everyone is together it would only add noise.
    final everyone = members.every((m) => e.participantIds.contains(m.id));
    final mine = e.participantIds.contains(youId) && !everyone;
    final detail = [
      if (e.start != null) e.end != null ? '${e.start}–${e.end}' : e.start!,
      if (e.place != null) e.place!,
    ].join(' · ');
    final names = members.where((m) => e.participantIds.contains(m.id)).map((m) => m.id == youId ? 'you' : m.firstName).toList();
    final withWho = names.length <= 1
        ? (names.isEmpty ? '' : ', ${names.first == 'you' ? 'just you' : 'with ${names.first}'}')
        : ', with ${names.take(names.length - 1).join(', ')} and ${names.last}';
    return TPBraidEventCard(
      label: braidEventLabel(e, members, youId, groups),
      title: e.title,
      detail: detail.isEmpty ? null : detail,
      mine: mine,
      loose: e.loose,
      now: e.now,
      footer: e.footer,
      semanticLabel: '${e.title}${detail.isEmpty ? '' : ', $detail'}$withWho',
    );
  }
}

class _StrandDraw {
  const _StrandDraw({
    required this.entryX,
    required this.x,
    required this.width,
    required this.color,
    required this.loose,
    required this.isYou,
  });
  final double entryX;
  final double x;
  final double width;
  final Color color;
  final bool loose;
  final bool isYou;
}

class _StrandPainter extends CustomPainter {
  _StrandPainter({required this.reveal, required this.strands, required this.knotY, required this.connector, required this.connectorColor});

  final double reveal;

  final List<_StrandDraw> strands;
  final double knotY;
  final (double, double)? connector;
  final Color connectorColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (reveal <= 0) return;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(-24, 0, size.width + 48, size.height * reveal));
    _paintStrands(canvas, size);
    canvas.restore();
  }

  void _paintStrands(Canvas canvas, Size size) {
    if (connector != null && connector!.$2 > connector!.$1) {
      final p = Paint()
        ..color = connectorColor
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;
      for (double x = connector!.$1; x < connector!.$2; x += 6) {
        canvas.drawLine(Offset(x, knotY), Offset((x + 1.5).clamp(0, connector!.$2), knotY), p);
      }
    }
    // You last, so your strand sits on top.
    final ordered = [...strands]..sort((a, b) => (a.isYou ? 1 : 0).compareTo(b.isYou ? 1 : 0));
    for (final s in ordered) {
      final path = Path()..moveTo(s.entryX, 0);
      final turnEnd = knotY > 0 ? knotY.clamp(0.0, TPBraidMetrics.turn) : 0.0;
      if (turnEnd > 0 && (s.entryX - s.x).abs() > 0.5) {
        path.cubicTo(s.entryX, turnEnd * 0.5, s.x, turnEnd * 0.5, s.x, turnEnd);
      } else {
        path.lineTo(s.x, turnEnd);
      }
      path.lineTo(s.x, size.height);
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width
        ..strokeCap = s.loose ? StrokeCap.round : StrokeCap.butt;
      if (!s.loose) {
        canvas.drawPath(path, paint);
      } else {
        paint.strokeWidth = s.width.clamp(TPBraidMetrics.strand, TPBraidMetrics.ribbonMax);
        const step = TPBraidMetrics.looseDash + TPBraidMetrics.looseGap;
        for (final m in path.computeMetrics()) {
          for (double d = 0; d < m.length; d += step) {
            canvas.drawPath(m.extractPath(d, d + 0.01), paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_StrandPainter old) => true;
}
