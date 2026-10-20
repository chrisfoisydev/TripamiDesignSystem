// Every Tripami component with realistic content, for the accessibility and
// text-scaling sweeps. Add new components here so they're checked too.
import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

const maya = TPMember(id: 'maya', name: 'Maya Chen', color: TPMemberColor.plum, online: true);
const leo = TPMember(id: 'leo', name: 'Leo Okafor', color: TPMemberColor.fern);
const alex = TPMember(id: 'alex', name: 'Alex Rivera', color: TPMemberColor.lagoon);
const jonah = TPMember(id: 'jonah', name: 'Jonah Weiss', color: TPMemberColor.sky);
const priya = TPMember(id: 'priya', name: 'Priya Nair', color: TPMemberColor.iris);
const crew = [alex, maya, leo, jonah, priya];

void _noop() {}

final day = [
  const TPBraidMoment(time: '08:00', events: [
    TPBraidEvent(id: 'b', title: 'Breakfast together', start: '08:00', end: '09:00', place: 'Manteigaria', participantIds: {'alex', 'maya', 'leo', 'jonah', 'priya'}),
  ]),
  const TPBraidMoment(time: '09:30', events: [
    TPBraidEvent(id: 't', title: 'Tram 28 to Graça', start: '09:30', end: '11:00', participantIds: {'alex', 'maya'}),
    TPBraidEvent(id: 'm', title: 'Wandering Alfama', start: '09:30', end: '12:00', participantIds: {'leo', 'jonah', 'priya'}, loose: true),
  ]),
];

/// name → component, each sized for a 390pt-wide phone.
final Map<String, Widget> gallery = {
  'TPButton': const Wrap(spacing: 8, runSpacing: 8, children: [
    TPButton.primary(label: 'Create trip', onPressed: _noop),
    TPButton.secondary(label: 'Join with code', onPressed: _noop),
    TPButton.tertiary(label: 'See all', onPressed: _noop),
    TPButton.destructive(label: 'Leave trip', onPressed: _noop),
    TPButton.primary(label: 'Saving', onPressed: _noop, loading: true),
  ]),
  'TPGlassIconButton': const ColoredBox(
    color: Color(0xFF3A4A5C),
    child: Row(children: [
      TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: _noop, semanticLabel: 'Back'),
      TPGlassIconButton(icon: TPIcons.export, onPressed: _noop, semanticLabel: 'Share'),
    ]),
  ),
  'TPQuickAction': const Wrap(children: [
    TPQuickAction(icon: TPIcons.userPlus, label: 'Invite', onPressed: _noop),
    TPQuickAction(icon: TPIcons.receipt, label: 'Split', onPressed: _noop),
    TPQuickAction(icon: TPIcons.mapTrifold, label: 'Map', onPressed: _noop),
  ]),
  'TPFloatingPill': const TPFloatingPill(label: 'Map', icon: TPIcons.mapTrifold, onPressed: _noop),
  'TPToggle': TPToggle(label: 'Notify me when votes close', detail: 'One message per poll', value: true, onChanged: (_) {}),
  'TPFilterChip': const Wrap(spacing: 8, runSpacing: 8, children: [
    TPFilterChip(label: 'Fri 13', selected: true, onTap: _noop),
    TPFilterChip(label: 'Sat 14', selected: false, onTap: _noop),
    TPFilterChip(label: 'Filters', selected: false, count: 2, onTap: _noop),
    TPFilterChip(label: 'Budget', selected: false, dropdown: true, onTap: _noop),
  ]),
  'TPUnderlineTabs': TPUnderlineTabs(labels: const ['Upcoming', 'Planning', 'Past'], currentIndex: 0, onChanged: (_) {}),
  'TPTabBar': TPTabBar(
    items: const [
      TPTabItem(label: 'Trips', icon: TPIcons.suitcase, activeIcon: TPIconsFill.suitcase),
      TPTabItem(label: 'Plan', icon: TPIcons.calendarBlank, activeIcon: TPIconsFill.calendarBlank, hasActivity: true),
      TPTabItem(label: 'Chat', icon: TPIcons.chatsCircle, activeIcon: TPIconsFill.chatsCircle, hasActivity: true, urgent: true),
      TPTabItem(label: 'Memories', icon: TPIcons.notebook, activeIcon: TPIconsFill.notebook),
      TPTabItem(label: 'You', icon: TPIcons.userCircle, activeIcon: TPIconsFill.userCircle),
    ],
    currentIndex: 0,
    onTap: (_) {},
  ),
  'TPSectionHeader': const Column(children: [
    TPSectionHeader.eyebrow('Needs your vote', actionLabel: 'See all', onAction: _noop),
    TPSectionHeader.titled('Your trips', subtitle: '2 coming up', actionLabel: 'See all', onAction: _noop),
  ]),
  'TPCard': const TPCard(onTap: _noop, child: Text('Dinner at Taberna da Rua')),
  'TPTripCoverCard': const SizedBox(
    width: 300,
    child: TPTripCoverCard(title: 'Lisbon with the crew', subtitle: '12–17 Jun · Lisbon', status: 'In 6 days', image: null, members: crew, onTap: _noop),
  ),
  'TPPlaceHeader': const Column(children: [
    TPPlaceHeader(
      title: 'Rome',
      eyebrow: 'Today · Day 5 of 14',
      subtitle: 'Wednesday 18 November · Italy with Friends',
      credit: 'Photo: Emiliano Carchia, CC0',
      image: null,
      imageLabel: "The Tiber leading to St Peter's dome",
      leading: TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: _noop, semanticLabel: 'Back to trips'),
      trailing: [
        TPAvatarStack(crew, onImage: true),
        TPGlassIconButton(icon: TPIcons.dotsThree, onPressed: _noop, semanticLabel: 'Trip options'),
      ],
    ),
    TPOverlapSheet(child: TPListRow(label: 'Rome Airbnb', detail: "Where you're staying", icon: TPIcons.bed, onTap: _noop)),
  ]),
  'TPProgressBar': const TPProgressBar(value: 0.39, semanticLabel: 'Vatican Museums progress'),
  'TPNowCard': TPNowCard(
    title: 'Vatican Museums',
    place: 'Viale Vaticano',
    start: DateTime(2026, 11, 18, 9, 30),
    end: DateTime(2026, 11, 18, 12, 30),
    now: DateTime(2026, 11, 18, 10, 40),
    companions: const [maya],
    onTap: _noop,
  ),
  'TPLeaveByHint': Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    for (final m in [40, 50, 57])
      TPLeaveByHint(
        leaveBy: DateTime(2026, 11, 18, 12, 55),
        travel: '5 min walk from the Vatican',
        now: DateTime(2026, 11, 18, 12, m),
      ),
  ]),
  'TPRoleTag': const Wrap(spacing: 8, children: [TPRoleTag.neutral('Organizer'), TPRoleTag.pending('Invited')]),
  'TPAvatar (invited)': const Row(children: [
    TPAvatar(TPMember(id: 'sarah', name: 'Sarah Johnson', color: TPMemberColor.slate), invited: true),
    SizedBox(width: 8),
    TPAvatar(TPMember(id: 'sarah', name: 'Sarah Johnson', color: TPMemberColor.slate), size: TPAvatarSize.xs, invited: true),
  ]),
  'TPGroupRow': const Column(children: [
    TPGroupRow(members: [alex, maya], title: 'Vatican Museums', detail: 'You and Maya', value: 'until 12:30', onTap: _noop),
    TPGroupRow(members: [leo, jonah, priya, maya], title: 'Wine tasting in Tuscany', onTap: _noop, showDivider: false),
  ]),
  'TPConnectCard': const TPConnectCard(
    icon: TPIcons.envelopeSimple,
    title: 'Find your plans in Gmail',
    message: 'Flights, hotels, trains, activities and reservations, pulled from your confirmation emails.',
    kinds: [TPIcons.airplane, TPIcons.bed, TPIcons.train, TPIcons.ticket, TPIcons.forkKnife],
    actionLabel: 'Connect Gmail',
    onConnect: _noop,
  ),
  'TPBackdrop.braid': const TPBackdrop.braid(
    members: crew,
    child: Padding(
      padding: EdgeInsets.fromLTRB(24, 200, 24, 24),
      child: Text('Crew', style: TextStyle(fontSize: 34)),
    ),
  ),
  'TPBackdrop.route': const TPBackdrop.route(
    child: Padding(
      padding: EdgeInsets.fromLTRB(24, 200, 24, 24),
      child: TPButton.primary(label: 'Connect Gmail', onPressed: _noop),
    ),
  ),
  'TPTripStrip': const TPTripStrip(facts: [
    TPTripFact(label: 'Arrive', value: 'Thu 12 Jun', detail: '14:05 TP1351'),
    TPTripFact(label: 'Nights', value: '5'),
    TPTripFact(label: 'Going', value: '5'),
  ]),
  'TPListRow': const Column(children: [
    TPListRow(label: 'Trip settings', icon: TPIcons.gearSix, onTap: _noop),
    TPListRow(label: 'Currency', detail: 'Used for new expenses', value: 'EUR', onTap: _noop),
  ]),
  'TPStickyActionBar': const TPStickyActionBar(label: 'Your share', value: '€35.75', action: TPButton.primary(label: 'Settle up', onPressed: _noop, small: true)),
  'TPEmptyState': const TPEmptyState(title: 'No plans yet', message: 'Add the first idea and the group can vote on it.', action: TPButton.secondary(label: 'Add a plan', onPressed: _noop)),
  'TPAvatar': const Row(children: [TPAvatar(maya, size: TPAvatarSize.lg, showPresence: true), TPAvatar(leo)]),
  'TPAvatarStack': const TPAvatarStack(crew),
  'TPAttribution': const TPAttribution(member: maya, action: 'added', time: '2h'),
  'TPActivityDot': const Row(children: [TPActivityDot(), SizedBox(width: 8), TPActivityDot(urgent: true)]),
  'TPReactionBar': TPReactionBar(reactions: const [TPReaction(emoji: '👍', count: 3, mine: true), TPReaction(emoji: '❤️', count: 2)], onReact: (_) {}, onAdd: _noop),
  'TPPollCard': const TPPollCard(
    eyebrow: 'Dinner · Fri 13 Jun',
    question: 'Where should we eat on Friday?',
    deadline: 'Closes 18:00',
    myVoteId: 'a',
    waitingOn: [jonah, priya],
    onVote: _noop,
    options: [
      TPPollOption(id: 'a', title: 'Taberna da Rua', detail: 'Petiscos · Bairro Alto', voters: [maya, leo, alex]),
      TPPollOption(id: 'b', title: 'Cervejaria Ramiro', detail: 'Seafood · Intendente', voters: []),
    ],
  ),
  'TPItineraryItem': const Column(children: [
    TPItineraryItem(time: '09:30', title: 'Tram 28 to Graça', detail: 'Stop: Martim Moniz', addedBy: maya, addedWhen: '2h', state: TPItineraryState.now, onTap: _noop),
    TPItineraryItem(time: '13:00', title: 'Lunch', state: TPItineraryState.idea, isLast: true),
  ]),
  'TPExpenseRow': const TPExpenseRow(icon: TPIcons.forkKnife, title: 'Dinner at Taberna da Rua', paidBy: maya, splitWays: 6, amount: '€214.50', yourShare: '€35.75', youOwe: true),
  'TPBraidDay': TPBraidDay(members: crew, youId: 'alex', moments: day),
  'TPEyebrow': const TPEyebrow('Arrive'),
  'TPChoiceChip': const TPChoices(fill: true, children: [
    TPChoiceChip(label: 'Meal', selected: false, onTap: _noop),
    TPChoiceChip(label: 'Activity', selected: true, onTap: _noop),
    TPChoiceChip(label: 'Travel', selected: false, onTap: _noop),
    TPChoiceChip(label: 'Free time', selected: false, onTap: _noop),
  ]),
  'TPChoiceChip (status)': TPChoices(children: [
    const TPChoiceChip(label: 'Tentative', selected: false, onTap: _noop),
    Builder(builder: (context) => TPChoiceChip(label: 'Confirmed', selected: true, color: TPColors.of(context).positive, onTap: _noop)),
  ]),
  'TPQuickPill': const Wrap(spacing: 8, children: [
    TPQuickPill(label: 'Everyone here', onTap: _noop),
    TPQuickPill(label: 'Just me', onTap: _noop),
  ]),
  'TPConfirmDelete': const TPConfirmDelete(label: 'Delete event', confirmLabel: 'Tap again to delete for everyone', onConfirmed: _noop),
  'TPAvatar (dimmed)': const Row(children: [TPAvatar(maya, size: TPAvatarSize.lg), TPAvatar(leo, size: TPAvatarSize.lg, dimmed: true)]),
  'TPField.boxed': Builder(
    builder: (context) => TextField(decoration: TPField.boxed(context, hint: 'Dinner, museum, train…')),
  ),
  'TPGlassChip': const ColoredBox(color: Color(0xFF3A4A5C), child: TPGlassChip(label: 'In 6 days', icon: TPIcons.clock)),
  'TPSuccessCheck': const TPSuccessCheck(haptic: false),
  'TPCountUp': TPCountUp(value: 42, format: (v) => '€$v'),
};
