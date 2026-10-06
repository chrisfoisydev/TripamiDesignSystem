import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

import 'sample_data.dart';

/// Trips tab: large title, underline tabs, cover cards, "Needs you".
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return ListView(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + TPSpace.s4, bottom: TPSpace.s10),
      children: [
        Padding(
          padding: TPSpace.screen,
          child: Row(
            children: [
              Expanded(child: Text('Trips', style: TPType.title1.copyWith(color: c.textPrimary))),
              IconButton(
                tooltip: 'New trip',
                onPressed: () {},
                icon: const Icon(TPIcons.plus, size: 24),
              ),
            ],
          ),
        ),
        const SizedBox(height: TPSpace.s3),
        TPUnderlineTabs(
          labels: const ['Upcoming', 'Planning', 'Past'],
          currentIndex: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: TPSpace.s6),
        if (_tab == 2)
          Padding(
            padding: TPSpace.screen,
            child: TPEmptyState(
              title: 'No past trips yet',
              message: 'When a trip ends, its photos and notes are kept here.',
              action: TPButton.primary(label: 'Start a trip', onPressed: () {}, small: true),
            ),
          )
        else ...[
          Padding(
            padding: TPSpace.screen,
            child: TPTripCoverCard(
              title: _tab == 0 ? 'Lisbon with the crew' : 'Kyoto in autumn',
              subtitle: _tab == 0 ? '12–17 Jun · Lisbon' : 'Dates not set · Kyoto',
              status: _tab == 0 ? 'In 6 days' : 'Planning',
              image: _tab == 0 ? lisbonPhoto : kyotoPhoto,
              members: _tab == 0 ? lisbonCrew : kyotoCrew,
              onTap: () {},
            ),
          ),
          const SizedBox(height: TPSpace.s10),
          const Padding(padding: TPSpace.screen, child: TPSectionHeader.eyebrow('Needs you')),
          TPListRow(
            leading: const TPActivityDot(urgent: true),
            label: 'Vote on Friday dinner',
            detail: 'Lisbon · closes 18:00',
            onTap: () {},
          ),
          TPListRow(
            leading: const TPActivityDot(),
            label: 'Settle up with Maya',
            detail: 'Lisbon',
            value: '€42.10',
            onTap: () {},
            showDivider: false,
          ),
        ],
      ],
    );
  }
}

/// Trip Home: the hub. Hero photo, trip strip, quick actions, then sections
/// on sunken bands.
class TripHomeScreen extends StatelessWidget {
  const TripHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: c.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 420,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Image(image: lisbonPhoto, fit: BoxFit.cover),
                DecoratedBox(decoration: BoxDecoration(gradient: c.scrim)),
                Positioned(
                  top: top + TPSpace.s2,
                  left: TPSpace.s3,
                  right: TPSpace.s3,
                  child: Row(
                    children: [
                      TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: () {}, semanticLabel: 'Back'),
                      const Spacer(),
                      TPGlassIconButton(icon: TPIcons.export, onPressed: () {}, semanticLabel: 'Share'),
                      TPGlassIconButton(icon: TPIcons.dotsThree, onPressed: () {}, semanticLabel: 'More'),
                    ],
                  ),
                ),
                Positioned(
                  left: TPSpace.margin,
                  right: TPSpace.margin,
                  bottom: TPSpace.s10 + TPSpace.s2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lisbon with the crew', style: TPType.display.copyWith(color: c.textOnImage)),
                      const SizedBox(height: TPSpace.s3),
                      const Wrap(
                        spacing: TPSpace.s2,
                        children: [
                          TPGlassChip(label: '6 days to go'),
                          TPGlassChip(label: 'Alfama, Lisbon', icon: TPIcons.mapPin),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // The surface rises over the photo like a sheet, as in Bonvoy's stay hub.
          Transform.translate(
            offset: const Offset(0, -TPSpace.s6),
            child: Container(
              decoration: ShapeDecoration(
                color: c.surface,
                shape: const RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(TPRadius.sheet)),
                ),
              ),
              padding: const EdgeInsets.only(top: TPSpace.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: TPSpace.screen,
                    child: TPTripStrip(facts: [
                      TPTripFact(label: 'Arrive', value: 'Thu 12 Jun', detail: '15:00'),
                      TPTripFact(label: 'Leave', value: 'Tue 17 Jun', detail: '11:00'),
                      TPTripFact(label: 'Nights', value: '5'),
                    ]),
                  ),
                  const SizedBox(height: TPSpace.s4),
                  Padding(
                    padding: TPSpace.screen,
                    child: Row(
                      children: [
                        const TPAvatarStack(lisbonCrew, size: TPAvatarSize.sm),
                        const SizedBox(width: TPSpace.s3),
                        Text('6 going', style: TPType.subhead.copyWith(color: c.textSecondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: TPSpace.s6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: TPSpace.margin - 8),
                    child: Row(
                      children: [
                        TPQuickAction(icon: TPIcons.userPlus, label: 'Invite', onPressed: () {}),
                        TPQuickAction(icon: TPIcons.plus, label: 'Add plan', onPressed: () {}),
                        TPQuickAction(icon: TPIcons.receipt, label: 'Split', onPressed: () {}),
                        TPQuickAction(icon: TPIcons.mapTrifold, label: 'Map', onPressed: () {}),
                        TPQuickAction(icon: TPIcons.chatsCircle, label: 'Chat', onPressed: () {}),
                        TPQuickAction(icon: TPIcons.images, label: 'Photos', onPressed: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: TPSpace.s6),
                  const TPSectionBand(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(TPSpace.margin, TPSpace.s8, TPSpace.margin, TPSpace.s8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const TPSectionHeader.titled('Needs your vote'),
                        TPPollCard(
                          eyebrow: 'Dinner · Fri 13 Jun',
                          question: 'Where should we eat on Friday?',
                          deadline: 'Closes 18:00',
                          options: fridayDinnerOptions,
                          myVoteId: 'taberna',
                          waitingOn: const [jonah, priya],
                          onVote: () => _openVoteSheet(context),
                        ),
                      ],
                    ),
                  ),
                  const TPSectionBand(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(TPSpace.margin, TPSpace.s8, TPSpace.margin, 0),
                    child: TPSectionHeader.titled('Up next', actionLabel: 'Full plan', onAction: () {}),
                  ),
                  const TPItineraryItem(
                    time: '15:00',
                    title: 'Check in · Casa do Largo',
                    detail: 'Alfama',
                    state: TPItineraryState.booked,
                    confirmation: '94730172',
                    addedBy: maya,
                    addedWhen: '3d',
                  ),
                  const TPItineraryItem(
                    time: '20:30',
                    title: 'Dinner (voting)',
                    detail: '3 options · closes 18:00',
                    state: TPItineraryState.idea,
                    isLast: true,
                  ),
                  const SizedBox(height: TPSpace.s6),
                  const TPSectionBand(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(TPSpace.margin, TPSpace.s8, TPSpace.margin, TPSpace.s2),
                    child: TPSectionHeader.titled('Money', actionLabel: 'Details', onAction: () {}),
                  ),
                  const TPListRow(label: 'You owe Maya', value: '€42.10', showChevron: false),
                  const TPListRow(label: 'Trip total so far', value: '€1,284.00', showChevron: false, showDivider: false),
                  const SizedBox(height: TPSpace.s10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _openVoteSheet(BuildContext context) {
    showTPSheet<void>(
      context: context,
      title: 'Friday dinner',
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(TPSpace.margin, TPSpace.s2, TPSpace.margin, TPSpace.s6),
        child: VoteSheetBody(),
      ),
      bottomBar: TPStickyActionBar(
        label: '4 of 6 voted',
        detail: 'Waiting on Jonah and Priya',
        action: TPButton.primary(label: 'Vote', onPressed: () => Navigator.pop(context)),
      ),
    );
  }
}

class VoteSheetBody extends StatefulWidget {
  const VoteSheetBody({super.key});

  @override
  State<VoteSheetBody> createState() => _VoteSheetBodyState();
}

class _VoteSheetBodyState extends State<VoteSheetBody> {
  String _selected = 'taberna';

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TPEyebrow('Dinner · Fri 13 Jun'),
        const SizedBox(height: TPSpace.s2),
        Text('Where should we eat on Friday?', style: TPType.title3.copyWith(color: c.textPrimary)),
        const SizedBox(height: TPSpace.s5),
        for (final o in fridayDinnerOptions)
          Padding(
            padding: const EdgeInsets.only(bottom: TPSpace.s3),
            child: GestureDetector(
              onTap: () => setState(() => _selected = o.id),
              child: AnimatedContainer(
                duration: TPMotion.quick,
                padding: const EdgeInsets.all(TPSpace.s3),
                decoration: ShapeDecoration(
                  color: o.id == _selected ? c.accentSubtle : c.surface,
                  shape: RoundedSuperellipseBorder(
                    borderRadius: BorderRadius.circular(TPRadius.md),
                    side: BorderSide(color: o.id == _selected ? c.accent : c.hairline, width: o.id == _selected ? 1.5 : 1),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(TPRadius.xs),
                      child: Image(image: o.image!, width: 56, height: 56, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: TPSpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.title, style: TPType.body.withWeight(TPType.medium).copyWith(color: c.textPrimary)),
                          Text(o.detail!, style: TPType.footnote.copyWith(color: c.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(
                      o.id == _selected ? TPIconsFill.checkCircle : TPIcons.circle,
                      color: o.id == _selected ? c.accent : c.borderStrong,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Plan tab: day chips, a diary heading, and the timeline.
class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  int _tab = 0;
  int _day = 1;
  static const _days = ['Thu 12', 'Fri 13', 'Sat 14', 'Sun 15', 'Mon 16'];

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return ListView(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top + TPSpace.s4, bottom: TPSpace.s10),
      children: [
        Padding(
          padding: TPSpace.screen,
          child: Row(
            children: [
              Expanded(child: Text('Plan', style: TPType.title1.copyWith(color: c.textPrimary))),
              IconButton(tooltip: 'Add plan', onPressed: () {}, icon: const Icon(TPIcons.plus, size: 24)),
            ],
          ),
        ),
        const SizedBox(height: TPSpace.s3),
        TPUnderlineTabs(
          labels: const ['Plan', 'Ideas', 'Booked'],
          currentIndex: _tab,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: TPSpace.s4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: TPSpace.screen,
          child: Row(
            children: [
              for (var i = 0; i < _days.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: TPSpace.s2),
                  child: TPFilterChip(label: _days[i], selected: i == _day, onTap: () => setState(() => _day = i)),
                ),
            ],
          ),
        ),
        const SizedBox(height: TPSpace.s8),
        Padding(
          padding: TPSpace.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Friday, 13 June', style: TPType.diaryHeading.copyWith(color: c.textPrimary)),
              const SizedBox(height: TPSpace.s1),
              Text('Day 2 · 4 plans · Sunny 24°', style: TPType.subhead.copyWith(color: c.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: TPSpace.s3),
        const TPItineraryItem(
          time: '09:30',
          title: 'Pastéis at Manteigaria',
          detail: 'Chiado · 30 min',
          addedBy: leo,
          addedWhen: '2d',
          reactions: [TPReaction(emoji: '👍', count: 3, mine: true), TPReaction(emoji: '❤️', count: 2)],
        ),
        const TPItineraryItem(
          time: '12:00',
          title: 'Tram 28 to Graça',
          detail: 'Martim Moniz · 40 min',
          state: TPItineraryState.now,
          addedBy: priya,
          addedWhen: '1d',
        ),
        const TPItineraryItem(
          time: '16:00',
          title: 'Miradouro da Senhora do Monte',
          detail: 'Graça · sunset',
          state: TPItineraryState.booked,
          addedBy: alex,
          addedWhen: '4h',
        ),
        TPItineraryItem(
          time: '20:30',
          title: 'Dinner (voting)',
          detail: '3 options · closes 18:00',
          state: TPItineraryState.idea,
          isLast: true,
          footer: Align(
            alignment: Alignment.centerLeft,
            child: TPButton.tertiary(label: 'Vote', onPressed: () {}),
          ),
        ),
      ],
    );
  }
}

/// Foundations gallery: color roles, member colors, type scale, controls.
class FoundationsScreen extends StatelessWidget {
  const FoundationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);

    Widget swatch(String name, Color color, {bool outline = false}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(TPRadius.sm),
                border: Border.all(color: c.hairline),
              ),
            ),
            const SizedBox(height: TPSpace.s1),
            Text(name, style: TPType.caption.copyWith(color: c.textSecondary)),
          ],
        );

    Widget sample(String token, TextStyle style, String text) => Padding(
          padding: const EdgeInsets.only(bottom: TPSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(token, style: TPType.caption.copyWith(color: c.textTertiary)),
              Text(text, style: style.copyWith(color: c.textPrimary)),
            ],
          ),
        );

    return ListView(
      padding: EdgeInsets.fromLTRB(
          TPSpace.margin, MediaQuery.paddingOf(context).top + TPSpace.s4, TPSpace.margin, TPSpace.s10),
      children: [
        Text('Foundations', style: TPType.title1.copyWith(color: c.textPrimary)),
        const SizedBox(height: TPSpace.s6),
        const TPSectionHeader.eyebrow('Paper & ink'),
        Wrap(spacing: TPSpace.s3, runSpacing: TPSpace.s3, children: [
          swatch('canvas', c.canvas),
          swatch('surface', c.surface),
          swatch('sunken', c.sunken),
          swatch('ink', c.actionPrimary),
          swatch('lagoon', c.accent),
          swatch('lagoon subtle', c.accentSubtle),
        ]),
        const SizedBox(height: TPSpace.s6),
        const TPSectionHeader.eyebrow('Members'),
        Wrap(spacing: TPSpace.s2, runSpacing: TPSpace.s2, children: [
          for (final m in TPMemberColor.values)
            TPAvatar(TPMember(id: m.name, name: '${m.name[0].toUpperCase()}${m.name.substring(1)}', color: m)),
        ]),
        const SizedBox(height: TPSpace.s8),
        const TPSectionHeader.eyebrow('Type'),
        sample('display · Newsreader', TPType.display, 'Lisbon with the crew'),
        sample('diaryHeading · Newsreader', TPType.diaryHeading, 'Friday, 13 June'),
        sample('title1', TPType.title1, 'Trips'),
        sample('title2', TPType.title2, 'Needs your vote'),
        sample('title3', TPType.title3, 'Where should we eat?'),
        sample('body', TPType.body, 'Waiting on Jonah and Priya.'),
        sample('diaryBody · Newsreader', TPType.diaryBody,
            'We missed the last tram and walked home through Alfama, singing.'),
        sample('footnote', TPType.footnote, 'Paid by Maya · split 6 ways'),
        sample('eyebrow', TPType.eyebrow, 'NEEDS YOUR VOTE'),
        const SizedBox(height: TPSpace.s5),
        const TPSectionHeader.eyebrow('Actions'),
        Wrap(spacing: TPSpace.s3, runSpacing: TPSpace.s3, crossAxisAlignment: WrapCrossAlignment.center, children: [
          TPButton.primary(label: 'Create trip', onPressed: () {}),
          TPButton.secondary(label: 'Join with code', onPressed: () {}),
          TPButton.tertiary(label: 'See all', onPressed: () {}),
          TPFilterChip(label: 'Food', selected: true, onTap: () {}),
          TPFilterChip(label: 'Budget', selected: false, onTap: () {}, dropdown: true),
          TPFilterChip(label: 'Filters', selected: false, onTap: () {}, count: 2),
        ]),
        const SizedBox(height: TPSpace.s8),
        const TPSectionHeader.eyebrow('Split'),
        const TPExpenseRow(
          icon: TPIcons.forkKnife,
          title: 'Dinner at Taberna da Rua',
          paidBy: maya,
          splitWays: 6,
          amount: '€214.50',
          yourShare: '€35.75',
          youOwe: true,
        ),
        const SizedBox(height: TPSpace.s6),
        TPEmptyState(
          title: 'Nothing saved yet',
          message: 'Add a place and the group can vote on it.',
          action: TPButton.primary(label: 'Add a place', onPressed: () {}, small: true),
        ),
      ],
    );
  }
}
