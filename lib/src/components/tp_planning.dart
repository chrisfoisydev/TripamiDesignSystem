import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
import 'tp_actions.dart';
import 'tp_containers.dart';
import 'tp_motion.dart';
import 'tp_people.dart';
import 'tp_text.dart';

@immutable
class TPPollOption {
  const TPPollOption({required this.id, required this.title, required this.voters, this.detail, this.image});

  final String id;
  final String title;
  final String? detail;
  final ImageProvider? image;
  final List<TPMember> voters;
}

/// Group decision card. Each option shows its voters' faces and a 3pt share
/// bar: ink for others, accent orange for the option you voted for.
///
/// Motion: bars spring to their share, counts tick, a new voter's face pops
/// in. When the last person votes while the card is on screen, a check draws
/// itself with a success haptic; when a winner is decided, its check pops.
/// A poll that was already finished when the screen opened shows these at rest.
class TPPollCard extends StatefulWidget {
  const TPPollCard({
    super.key,
    required this.eyebrow,
    required this.question,
    required this.options,
    required this.waitingOn,
    this.myVoteId,
    this.deadline,
    this.decidedId,
    this.onVote,
  });

  final String eyebrow;
  final String question;
  final List<TPPollOption> options;

  /// Travelers who haven't voted yet. Names beat counts.
  final List<TPMember> waitingOn;
  final String? myVoteId;
  final String? deadline;

  /// When set, the poll is closed and this option won.
  final String? decidedId;
  final VoidCallback? onVote;

  @override
  State<TPPollCard> createState() => _TPPollCardState();
}

class _TPPollCardState extends State<TPPollCard> {
  bool _everyoneLive = false;
  bool _decidedLive = false;

  @override
  void didUpdateWidget(TPPollCard old) {
    super.didUpdateWidget(old);
    if (old.waitingOn.isNotEmpty && widget.waitingOn.isEmpty) _everyoneLive = true;
    if (old.decidedId == null && widget.decidedId != null) _decidedLive = true;
  }

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final w = widget;
    final total = w.options.fold<int>(0, (sum, o) => sum + o.voters.length);
    final closed = w.decidedId != null;
    final everyone = !closed && w.waitingOn.isEmpty;
    final large = TPA11y.largeText(context);
    final deadline = w.deadline != null && !closed ? Text(w.deadline!, style: TPType.footnote.copyWith(color: c.accent)) : null;
    final voteButton = !closed && w.onVote != null
        ? TPButton.primary(label: w.myVoteId == null ? 'Vote' : 'Change vote', onPressed: w.onVote, small: true)
        : null;

    return TPCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (large)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [TPEyebrow(w.eyebrow), ?deadline])
          else
            Row(children: [Expanded(child: TPEyebrow(w.eyebrow)), ?deadline]),
          const SizedBox(height: TPSpace.s2),
          Text(w.question, style: TPType.title3.copyWith(color: c.textPrimary)),
          const SizedBox(height: TPSpace.s4),
          for (final o in w.options)
            _PollOptionRow(
              option: o,
              share: total == 0 ? 0 : o.voters.length / total,
              mine: o.id == w.myVoteId,
              won: o.id == w.decidedId,
              celebrate: _decidedLive,
              dimmed: closed && o.id != w.decidedId,
              colors: c,
            ),
          const SizedBox(height: TPSpace.s2),
          Row(
            children: [
              if (everyone) ...[
                TPSuccessCheck(key: ValueKey(_everyoneLive), size: 20, animate: _everyoneLive),
                const SizedBox(width: TPSpace.s1),
              ],
              Expanded(
                child: Text(
                  closed ? 'Decided' : _waitingCopy(),
                  style: TPType.footnote.copyWith(color: c.textSecondary),
                ),
              ),
              if (voteButton != null && !large) ...[const SizedBox(width: TPSpace.s3), voteButton],
            ],
          ),
          if (voteButton != null && large) ...[const SizedBox(height: TPSpace.s3), voteButton],
        ],
      ),
    );
  }

  String _waitingCopy() {
    final names = widget.waitingOn.map((m) => m.firstName).toList();
    return switch (names.length) {
      0 => 'Everyone has voted.',
      1 => 'Waiting on ${names[0]}.',
      2 => 'Waiting on ${names[0]} and ${names[1]}.',
      _ => 'Waiting on ${names[0]}, ${names[1]} and ${names.length - 2} more.',
    };
  }
}

class _PollOptionRow extends StatelessWidget {
  const _PollOptionRow({
    required this.option,
    required this.share,
    required this.mine,
    required this.won,
    required this.celebrate,
    required this.dimmed,
    required this.colors,
  });

  final TPPollOption option;
  final double share;
  final bool mine;
  final bool won;

  /// The win happened while on screen, so its check pops.
  final bool celebrate;
  final bool dimmed;
  final TPColors colors;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final titleColor = dimmed ? c.textSecondary : c.textPrimary;
    // Large text: voters move under the title and nothing truncates.
    final large = TPA11y.largeText(context);
    final n = option.voters.length;
    final votes = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TPAvatarStack(option.voters, size: TPAvatarSize.xs, max: 3),
        const SizedBox(width: TPSpace.s2),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 16),
          child: Align(
            alignment: Alignment.centerRight,
            widthFactor: 1,
            child: TPCountUp(value: n, format: (v) => '$v', style: TPType.subhead.copyWith(color: titleColor)),
          ),
        ),
      ],
    );
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: [
        option.title,
        ?option.detail,
        '$n ${n == 1 ? 'vote' : 'votes'}',
        if (mine) 'your vote',
        if (won) 'chosen',
      ].join(', '),
      child: Padding(
      padding: const EdgeInsets.only(bottom: TPSpace.s4),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(TPRadius.xs),
                child: SizedBox.square(
                  dimension: 48,
                  child: option.image != null
                      ? Image(image: option.image!, fit: BoxFit.cover)
                      : ColoredBox(
                          color: c.sunken,
                          child: Icon(TPIcons.forkKnife, size: 20, color: c.textSecondary),
                        ),
                ),
              ),
              const SizedBox(width: TPSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(option.title,
                              overflow: large ? null : TextOverflow.ellipsis,
                              style: TPType.body.withWeight(TPType.medium).copyWith(color: titleColor)),
                        ),
                        if (won) ...[
                          const SizedBox(width: TPSpace.s1 + 2),
                          TPPop(play: celebrate, child: Icon(TPIconsFill.checkCircle, size: 18, color: c.accent)),
                        ],
                      ],
                    ),
                    if (option.detail != null)
                      Text(
                        option.detail!,
                        maxLines: large ? null : 1,
                        overflow: large ? null : TextOverflow.ellipsis,
                        style: TPType.footnote.copyWith(color: c.textSecondary),
                      ),
                    if (large) ...[const SizedBox(height: TPSpace.s2), votes],
                  ],
                ),
              ),
              if (!large) ...[const SizedBox(width: TPSpace.s2), votes],
            ],
          ),
          const SizedBox(height: TPSpace.s2),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: share),
              // Votes are a people moment: bars spring to their share.
              duration: TPMotion.reduced(context) ? Duration.zero : TPMotion.playfulDuration,
              curve: TPMotion.playfulCurve,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 3,
                backgroundColor: c.hairline,
                color: mine || won ? c.accent : (dimmed ? c.borderStrong : c.textPrimary),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

enum TPItineraryState { planned, now, booked, idea }

/// Timeline row: time column | rail with node | content.
class TPItineraryItem extends StatelessWidget {
  const TPItineraryItem({
    super.key,
    required this.time,
    required this.title,
    this.detail,
    this.addedBy,
    this.addedWhen,
    this.reactions = const [],
    this.state = TPItineraryState.planned,
    this.confirmation,
    this.footer,
    this.isLast = false,
    this.onTap,
  });

  final String time;
  final String title;
  final String? detail;
  final TPMember? addedBy;
  final String? addedWhen;
  final List<TPReaction> reactions;
  final TPItineraryState state;
  final String? confirmation;
  final Widget? footer;
  final bool isLast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final isNow = state == TPItineraryState.now;
    final isIdea = state == TPItineraryState.idea;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: isNow ? c.accentSubtle : null,
        padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 48,
                child: Padding(
                  padding: const EdgeInsets.only(top: TPSpace.s4),
                  child: Text(time,
                      style: TPType.subhead.tabular.copyWith(color: isNow ? c.accent : c.textSecondary)),
                ),
              ),
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(width: 1, height: TPSpace.s4 + 5, color: c.hairline),
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isIdea ? c.canvas : (isNow ? c.accent : c.textPrimary),
                        border: isIdea ? Border.all(color: c.textSecondary) : null,
                      ),
                    ),
                    Expanded(child: Container(width: 1, color: isLast ? Colors.transparent : c.hairline)),
                  ],
                ),
              ),
              const SizedBox(width: TPSpace.s2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: TPSpace.s4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TPType.body
                                  .withWeight(TPType.medium)
                                  .copyWith(color: isIdea ? c.textSecondary : c.textPrimary),
                            ),
                          ),
                          if (state == TPItineraryState.booked)
                            Icon(TPIcons.sealCheck, size: 18, color: c.textSecondary),
                        ],
                      ),
                      if (detail != null || confirmation != null)
                        Text(
                          [?detail, if (confirmation != null) 'Conf. $confirmation'].join(' · '),
                          style: TPType.footnote.tabular.copyWith(color: c.textSecondary),
                        ),
                      if (addedBy != null) ...[
                        const SizedBox(height: TPSpace.s2),
                        TPAttribution(member: addedBy!, action: 'added', time: addedWhen),
                      ],
                      if (reactions.isNotEmpty) ...[
                        const SizedBox(height: TPSpace.s2),
                        TPReactionBar(reactions: reactions),
                      ],
                      if (footer != null) ...[const SizedBox(height: TPSpace.s2), footer!],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expense row. Shows who paid (member dot), the total, and your share in
/// caution (you owe) or positive (you're owed).
class TPExpenseRow extends StatelessWidget {
  const TPExpenseRow({
    super.key,
    required this.icon,
    required this.title,
    required this.paidBy,
    required this.splitWays,
    required this.amount,
    required this.yourShare,
    required this.youOwe,
  });

  final IconData icon;
  final String title;
  final TPMember paidBy;
  final int splitWays;
  final String amount;
  final String yourShare;
  final bool youOwe;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    // Large text stacks the amounts under the details instead of squeezing both.
    final large = TPA11y.largeText(context);
    final details = <Widget>[
      Text(title, style: TPType.body.copyWith(color: c.textPrimary)),
      const SizedBox(height: 2),
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: paidBy.color.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: TPSpace.s1 + 2),
          Flexible(
            child: Text(
              'Paid by ${paidBy.firstName} · split $splitWays ways',
              overflow: large ? null : TextOverflow.ellipsis,
              style: TPType.footnote.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    ];
    final amounts = Column(
      crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(amount, style: TPType.body.tabular.copyWith(color: c.textPrimary)),
        const SizedBox(height: 2),
        Text(
          youOwe ? 'You owe $yourShare' : 'You get $yourShare',
          style: TPType.footnote.tabular.copyWith(color: youOwe ? c.caution : c.positive),
        ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin, vertical: TPSpace.s3),
      child: Row(
        crossAxisAlignment: large ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.sunken, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: c.textPrimary),
          ),
          const SizedBox(width: TPSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...details, if (large) ...[const SizedBox(height: TPSpace.s2), amounts]],
            ),
          ),
          if (!large) ...[const SizedBox(width: TPSpace.s3), amounts],
        ],
      ),
    );
  }
}
