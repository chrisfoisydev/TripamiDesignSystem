// Components: every TP widget, with knobs for its props and live demos for
// the ones that move.
import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';
import 'package:widgetbook/widgetbook.dart';

import 'sample_data.dart';

void _noop() {}

Widget _frame(Widget child, {double maxWidth = 430}) => Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TPSpace.s6),
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      ),
    );

/// A stateful demo without a StatefulWidget class per use case.
class _Live<T> extends StatefulWidget {
  const _Live({required this.initial, required this.builder});
  final T initial;
  final Widget Function(BuildContext context, T value, void Function(T) set) builder;
  @override
  State<_Live<T>> createState() => _LiveState<T>();
}

class _LiveState<T> extends State<_Live<T>> {
  late T _v = widget.initial;
  @override
  Widget build(BuildContext context) => widget.builder(context, _v, (v) => setState(() => _v = v));
}

WidgetbookComponent _c(String name, List<WidgetbookUseCase> useCases) => WidgetbookComponent(name: name, useCases: useCases);
WidgetbookUseCase _u(String name, Widget Function(BuildContext) builder) => WidgetbookUseCase(name: name, builder: builder);

final _actions = WidgetbookFolder(name: 'Actions', children: [
  _c('TPButton', [
    _u('Playground', (context) {
      final k = context.knobs;
      final variant = k.object.segmented<String>(label: 'Variant', options: ['primary', 'secondary', 'tertiary', 'destructive']);
      final label = k.string(label: 'Label', initialValue: 'Create trip');
      final small = k.boolean(label: 'Small');
      final loading = k.boolean(label: 'Loading (primary)');
      final enabled = k.boolean(label: 'Enabled', initialValue: true);
      final onPressed = enabled ? _noop : null;
      return _frame(switch (variant) {
        'secondary' => TPButton.secondary(label: label, onPressed: onPressed, small: small),
        'tertiary' => TPButton.tertiary(label: label, onPressed: onPressed),
        'destructive' => TPButton.destructive(label: label, onPressed: onPressed),
        _ => TPButton.primary(label: label, onPressed: onPressed, small: small, loading: loading),
      });
    }),
    _u('All variants', (context) => _frame(const Wrap(spacing: 8, runSpacing: 8, children: [
          TPButton.primary(label: 'Create trip', onPressed: _noop),
          TPButton.secondary(label: 'Join with code', onPressed: _noop),
          TPButton.tertiary(label: 'See all', onPressed: _noop),
          TPButton.destructive(label: 'Leave trip', onPressed: _noop),
          TPButton.primary(label: 'Vote', onPressed: _noop, small: true),
          TPButton.primary(label: 'Disabled', onPressed: null),
        ]))),
  ]),
  _c('TPGlassIconButton', [
    _u('On a photo', (context) => _frame(Container(
          height: 160,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [TPRamps.orange[300], TPRamps.navy[700]], begin: Alignment.topCenter, end: Alignment.bottomCenter), borderRadius: BorderRadius.circular(TPRadius.lg)),
          padding: const EdgeInsets.all(TPSpace.s2),
          alignment: Alignment.topCenter,
          child: const Row(children: [
            TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: _noop, semanticLabel: 'Back'),
            Spacer(),
            TPGlassIconButton(icon: TPIcons.export, onPressed: _noop, semanticLabel: 'Share'),
            TPGlassIconButton(icon: TPIcons.dotsThree, onPressed: _noop, semanticLabel: 'More'),
          ]),
        ))),
  ]),
  _c('TPQuickAction', [
    _u('Trip tools', (context) => _frame(const Wrap(children: [
          TPQuickAction(icon: TPIcons.userPlus, label: 'Invite', onPressed: _noop),
          TPQuickAction(icon: TPIcons.plus, label: 'Add plan', onPressed: _noop),
          TPQuickAction(icon: TPIcons.receipt, label: 'Split', onPressed: _noop),
          TPQuickAction(icon: TPIcons.mapTrifold, label: 'Map', onPressed: _noop),
          TPQuickAction(icon: TPIcons.chatsCircle, label: 'Chat', onPressed: _noop),
          TPQuickAction(icon: TPIcons.images, label: 'Photos', onPressed: _noop),
        ]))),
  ]),
  _c('TPFloatingPill', [
    _u('Map / List', (context) => _frame(_Live<bool>(
          initial: false,
          builder: (context, map, set) => TPFloatingPill(label: map ? 'List' : 'Map', icon: map ? TPIcons.notebook : TPIcons.mapTrifold, onPressed: () => set(!map)),
        ))),
  ]),
  _c('TPToggle', [
    _u('Settings rows', (context) => _frame(_Live<List<bool>>(
          initial: [true, false],
          builder: (context, v, set) => Column(children: [
            TPToggle(label: 'Notify me when votes close', detail: 'One message per poll', value: v[0], onChanged: (x) => set([x, v[1]])),
            TPToggle(label: 'Share my location with the group', value: v[1], onChanged: (x) => set([v[0], x])),
          ]),
        ))),
  ]),
]);

final _navigation = WidgetbookFolder(name: 'Navigation', children: [
  _c('TPTabBar', [
    _u('Five tabs', (context) {
      final k = context.knobs;
      final planActivity = k.boolean(label: 'Plan: new activity', initialValue: true);
      final chatUrgent = k.boolean(label: 'Chat: needs you', initialValue: true);
      return Align(
        alignment: Alignment.bottomCenter,
        child: _Live<int>(
          initial: 0,
          builder: (context, i, set) => TPTabBar(
            currentIndex: i,
            onTap: set,
            items: [
              const TPTabItem(label: 'Trips', icon: TPIcons.suitcase, activeIcon: TPIconsFill.suitcase),
              TPTabItem(label: 'Plan', icon: TPIcons.calendarBlank, activeIcon: TPIconsFill.calendarBlank, hasActivity: planActivity),
              TPTabItem(label: 'Chat', icon: TPIcons.chatsCircle, activeIcon: TPIconsFill.chatsCircle, hasActivity: chatUrgent, urgent: true),
              const TPTabItem(label: 'Memories', icon: TPIcons.notebook, activeIcon: TPIconsFill.notebook),
              const TPTabItem(label: 'You', icon: TPIcons.userCircle, activeIcon: TPIconsFill.userCircle),
            ],
          ),
        ),
      );
    }),
  ]),
  _c('TPUnderlineTabs', [
    _u('Trips', (context) => _frame(_Live<int>(
          initial: 0,
          builder: (context, i, set) => TPUnderlineTabs(labels: const ['Upcoming', 'Planning', 'Past'], currentIndex: i, onChanged: set),
        ))),
  ]),
  _c('TPFilterChip', [
    _u('Day chips', (context) => _frame(_Live<int>(
          initial: 0,
          builder: (context, sel, set) => Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (i, d) in ['Fri 13', 'Sat 14', 'Sun 15', 'Mon 16'].indexed) TPFilterChip(label: d, selected: i == sel, onTap: () => set(i)),
          ]),
        ))),
    _u('Playground', (context) {
      final k = context.knobs;
      return _frame(TPFilterChip(
        label: k.string(label: 'Label', initialValue: 'Filters'),
        selected: k.boolean(label: 'Selected'),
        count: k.intOrNull.input(label: 'Count', initialValue: 2),
        dropdown: k.boolean(label: 'Dropdown'),
        onTap: _noop,
      ));
    }),
  ]),
]);

final _containers = WidgetbookFolder(name: 'Containers', children: [
  _c('TPTripCoverCard', [
    _u('Playground', (context) {
      final k = context.knobs;
      final width = k.double.slider(label: 'Width', initialValue: 300, min: 150, max: 420);
      return _frame(
        SizedBox(
          width: width,
          child: TPTripCoverCard(
            title: k.string(label: 'Title', initialValue: 'Lisbon with the crew'),
            subtitle: k.string(label: 'Subtitle', initialValue: '12–17 Jun · Lisbon'),
            status: k.stringOrNull(label: 'Status', initialValue: 'In 6 days'),
            image: null,
            members: crew.take(k.int.slider(label: 'Travelers', initialValue: 6, min: 0, max: 8)).toList(),
            onTap: _noop,
          ),
        ),
      );
    }),
  ]),
  _c('TPCard', [
    _u('Tappable', (context) => _frame(TPCard(
          onTap: _noop,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const TPEyebrow('Tonight'),
            const SizedBox(height: TPSpace.s2),
            Text('Dinner at Taberna da Rua', style: TPType.title3.copyWith(color: TPColors.of(context).textPrimary)),
            const SizedBox(height: TPSpace.s3),
            TPAttribution(member: maya, action: 'added', time: '2h'),
          ]),
        ))),
  ]),
  _c('TPTripStrip', [
    _u('Arrive · Leave · Nights · Going', (context) => _frame(TPTripStrip(facts: [
          const TPTripFact(label: 'Arrive', value: 'Thu 12 Jun', detail: '14:05 TP1351'),
          const TPTripFact(label: 'Leave', value: 'Tue 17 Jun'),
          const TPTripFact(label: 'Nights', value: '5'),
          TPTripFact(label: 'Going', value: '6', trailing: TPAvatarStack(crew.take(6).toList(), size: TPAvatarSize.xs)),
        ]))),
  ]),
  _c('TPListRow', [
    _u('Settings', (context) => _frame(const Column(children: [
          TPListRow(label: 'Trip settings', icon: TPIcons.gearSix, onTap: _noop),
          TPListRow(label: 'Currency', detail: 'Used for new expenses', value: 'EUR', onTap: _noop),
          TPListRow(label: 'Leave trip', showChevron: false, showDivider: false, onTap: _noop),
        ]))),
  ]),
  _c('TPStickyActionBar', [
    _u('Settle up', (context) => Align(
          alignment: Alignment.bottomCenter,
          child: TPStickyActionBar(label: 'Your share', value: '€35.75', detail: 'Owed to Maya', action: TPButton.primary(label: 'Settle up', onPressed: _noop, small: true)),
        )),
  ]),
  _c('TPEmptyState', [
    _u('No plans yet', (context) => _frame(TPEmptyState(
          title: 'No plans yet',
          message: 'Add the first idea and the group can vote on it.',
          action: TPButton.secondary(label: 'Add a plan', onPressed: _noop),
        ))),
  ]),
  _c('showTPSheet', [
    _u('Open a sheet', (context) => _frame(Builder(
          builder: (context) => TPButton.primary(
            label: 'Add expense',
            onPressed: () => showTPSheet<void>(
              context: context,
              title: 'Add expense',
              bottomBar: Padding(padding: const EdgeInsets.all(TPSpace.s4), child: TPButton.primary(label: 'Add', expand: true, onPressed: () => Navigator.pop(context))),
              builder: (context) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: TPSpace.margin),
                child: Column(children: [TextField(decoration: InputDecoration(labelText: 'WHAT FOR')), SizedBox(height: TPSpace.s5), TextField(decoration: InputDecoration(labelText: 'AMOUNT'))]),
              ),
            ),
          ),
        ))),
  ]),
]);

final _people = WidgetbookFolder(name: 'People', children: [
  _c('TPAvatar', [
    _u('Sizes', (context) => _frame(Wrap(spacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: [
          for (final (i, s) in TPAvatarSize.values.indexed) TPAvatar(crew[i], size: s, showPresence: true),
        ]))),
  ]),
  _c('TPAvatarStack', [
    _u('Someone joins', (context) => _frame(_Live<int>(
          initial: 2,
          builder: (context, n, set) => Row(children: [
            TPAvatarStack(crew.take(n).toList()),
            const SizedBox(width: TPSpace.s4),
            TPButton.secondary(label: n < crew.length ? '${crew[n].firstName} joins' : 'Reset', small: true, onPressed: () => set(n < crew.length ? n + 1 : 2)),
          ]),
        ))),
  ]),
  _c('TPAttribution', [_u('Added by', (context) => _frame(TPAttribution(member: maya, action: 'added', time: '2h')))]),
  _c('TPActivityDot', [
    _u('New and needs you', (context) => _frame(const Row(children: [TPActivityDot(), SizedBox(width: 6), Text('New'), SizedBox(width: 24), TPActivityDot(urgent: true), SizedBox(width: 6), Text('Needs you')]))),
  ]),
  _c('TPReactionBar', [
    _u('React', (context) => _frame(_Live<List<TPReaction>>(
          initial: const [TPReaction(emoji: '👍', count: 3, mine: true), TPReaction(emoji: '❤️', count: 2)],
          builder: (context, rs, set) => TPReactionBar(
            reactions: rs,
            onAdd: _noop,
            onReact: (r) => set([for (final x in rs) x.emoji == r.emoji ? TPReaction(emoji: x.emoji, count: x.count + (x.mine ? -1 : 1), mine: !x.mine) : x]),
          ),
        ))),
  ]),
]);

final _planning = WidgetbookFolder(name: 'Planning', children: [
  _c('TPPollCard', [
    _u('Votes come in', (context) => _frame(_Live<int>(
          initial: 0,
          builder: (context, votedIn, set) {
            final late = [jonah, priya];
            final waiting = late.skip(votedIn).toList();
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TPPollCard(
                eyebrow: 'Dinner · Fri 13 Jun',
                question: 'Where should we eat on Friday?',
                deadline: 'Closes 18:00',
                myVoteId: 'a',
                waitingOn: waiting,
                options: [
                  TPPollOption(id: 'a', title: 'Taberna da Rua', detail: 'Petiscos · Bairro Alto · €€', voters: [maya, leo, alex, ...late.take(votedIn)]),
                  const TPPollOption(id: 'b', title: 'Cervejaria Ramiro', detail: 'Seafood · Intendente · €€€', voters: []),
                ],
              ),
              const SizedBox(height: TPSpace.s3),
              TPButton.secondary(label: waiting.isEmpty ? 'Reset' : '${waiting.first.firstName} votes', small: true, onPressed: () => set(waiting.isEmpty ? 0 : votedIn + 1)),
            ]);
          },
        ))),
  ]),
  _c('TPItineraryItem', [
    _u('A day', (context) => _frame(Column(children: [
          TPItineraryItem(time: '08:00', title: 'Breakfast at Manteigaria', state: TPItineraryState.booked, confirmation: 'MT-2291', addedBy: maya, addedWhen: 'Mon'),
          TPItineraryItem(time: '09:30', title: 'Tram 28 to Graça', detail: 'Stop: Martim Moniz', state: TPItineraryState.now, reactions: const [TPReaction(emoji: '🚋', count: 4)]),
          const TPItineraryItem(time: '13:00', title: 'Lunch somewhere in Alfama', state: TPItineraryState.idea, isLast: true),
        ]), maxWidth: 480)),
  ]),
  _c('TPExpenseRow', [
    _u('Owe and owed', (context) => _frame(Column(children: [
          TPExpenseRow(icon: TPIcons.forkKnife, title: 'Dinner at Taberna da Rua', paidBy: maya, splitWays: 6, amount: '€214.50', yourShare: '€35.75', youOwe: true),
          TPExpenseRow(icon: TPIcons.ticket, title: 'Tram day passes', paidBy: alex, splitWays: 6, amount: '€38.40', yourShare: '€32.00', youOwe: false),
        ]), maxWidth: 480)),
  ]),
]);

final _braid = WidgetbookFolder(name: 'Braid', children: [
  _c('TPBraidDay', [
    _u('Five travelers', (context) => _frame(_Live<int>(
          initial: 0,
          builder: (context, n, set) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TPButton.secondary(label: 'Replay draw-in', small: true, onPressed: () => set(n + 1)),
            const SizedBox(height: TPSpace.s4),
            TPBraidDay(key: ValueKey(n), members: crew.take(5).toList(), youId: 'alex', moments: lisbonDay),
          ]),
        ), maxWidth: 480)),
    _u('Fifty travelers', (context) {
      final (people, groups, moments) = bigTrip();
      return _frame(TPBraidDay(members: people, youId: 'p20', groups: groups, moments: moments), maxWidth: 760);
    }),
  ]),
]);

final _text = WidgetbookFolder(name: 'Text', children: [
  _c('TPSectionHeader', [
    _u('Eyebrow and titled', (context) => _frame(const Column(children: [
          TPSectionHeader.eyebrow('Needs your vote', actionLabel: 'See all', onAction: _noop),
          SizedBox(height: TPSpace.s6),
          TPSectionHeader.titled('Your trips', subtitle: '2 coming up', actionLabel: 'See all', onAction: _noop),
        ]))),
  ]),
  _c('TPEyebrow', [_u('Label', (context) => _frame(TPEyebrow(context.knobs.string(label: 'Text', initialValue: 'Arrive'))))]),
]);

const _rome = AssetImage('assets/places/rome-tiber-st-peters.jpg');
const _romeLabel = "The Tiber and Ponte Sant'Angelo leading to St Peter's dome";
DateTime _at(int h, int m) => DateTime(2026, 11, 18, h, m);

final _today = WidgetbookFolder(name: 'Today', children: [
  _c('Trip day screen', [
    _u('Rome · Wed 18', (context) {
      final k = context.knobs;
      final minutes = k.int.slider(label: 'Minutes since 09:30', initialValue: 70, min: 0, max: 240);
      final now = _at(9, 30).add(Duration(minutes: minutes));
      final c = TPColors.of(context);
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: ColoredBox(
            color: c.canvas,
            child: ListView(children: [
              TPPlaceHeader(
                title: 'Rome',
                eyebrow: 'Today · Day 5 of 14',
                subtitle: 'Wednesday 18 November · Italy with Friends',
                image: k.boolean(label: 'Photo', initialValue: true) ? _rome : null,
                imageLabel: _romeLabel,
                leading: const TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: _noop, semanticLabel: 'Back to trips'),
                trailing: [
                  TPAvatarStack(crew, onImage: true),
                  const TPGlassIconButton(icon: TPIcons.dotsThree, onPressed: _noop, semanticLabel: 'Trip options'),
                ],
              ),
              TPOverlapSheet(
                child: _Live<int>(
                  initial: 4,
                  builder: (context, day, set) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Padding(
                      padding: TPSpace.screen,
                      child: TPUnderlineTabs(labels: const ['Days', 'Whole trip'], currentIndex: 0, onChanged: (_) {}),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(TPSpace.s6, TPSpace.s4, TPSpace.s6, TPSpace.s1),
                      child: Row(children: [
                        for (var i = 0; i < 7; i++)
                          Padding(
                            padding: const EdgeInsets.only(right: TPSpace.s2),
                            child: TPFilterChip(
                              label: TPFormat.dayShort(DateTime(2026, 11, 14 + i)),
                              selected: i == day,
                              onTap: () => set(i),
                            ),
                          ),
                      ]),
                    ),
                    const TPListRow(
                      icon: TPIcons.bed,
                      label: 'Rome Airbnb',
                      detail: "Where you're staying",
                      onTap: _noop,
                      showDivider: false,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: TPSpace.s4),
                      child: TPNowCard(
                        title: 'Vatican Museums',
                        place: 'Viale Vaticano',
                        start: _at(9, 30),
                        end: _at(12, 30),
                        now: now,
                        companions: [maya],
                      ),
                    ),
                    const SizedBox(height: TPSpace.s8),
                    const Padding(padding: TPSpace.screen, child: TPEyebrow('Next · 13:00')),
                    const SizedBox(height: TPSpace.s2),
                    Padding(
                      padding: TPSpace.screen,
                      child: Text('Pizza al taglio', style: TPType.title3.copyWith(color: c.textPrimary)),
                    ),
                    Padding(
                      padding: TPSpace.screen,
                      child: Text('Pizzarium · the crew rejoins here', style: TPType.subhead.copyWith(color: c.textSecondary)),
                    ),
                    const SizedBox(height: TPSpace.s2),
                    Padding(
                      padding: TPSpace.screen,
                      child: TPLeaveByHint(leaveBy: _at(12, 55), travel: '5 min walk from the Vatican', now: now),
                    ),
                    const SizedBox(height: TPSpace.s16),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      );
    }),
  ]),
  _c('TPPlaceHeader', [
    _u('Playground', (context) {
      final k = context.knobs;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 390),
          child: SingleChildScrollView(
            child: Column(children: [
              TPPlaceHeader(
                title: k.string(label: 'Title', initialValue: 'Rome'),
                eyebrow: k.stringOrNull(label: 'Eyebrow', initialValue: 'Today · Day 5 of 14'),
                subtitle: k.stringOrNull(label: 'Subtitle', initialValue: 'Wednesday 18 November · Italy with Friends'),
                credit: k.stringOrNull(label: 'Credit', initialValue: null),
                image: k.boolean(label: 'Photo', initialValue: true) ? _rome : null,
                imageLabel: _romeLabel,
                leading: const TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: _noop, semanticLabel: 'Back to trips'),
                trailing: [
                  TPAvatarStack(crew, onImage: true),
                  const TPGlassIconButton(icon: TPIcons.dotsThree, onPressed: _noop, semanticLabel: 'Trip options'),
                ],
              ),
              const TPOverlapSheet(
                child: TPListRow(icon: TPIcons.bed, label: 'Rome Airbnb', detail: "Where you're staying", onTap: _noop, showDivider: false),
              ),
            ]),
          ),
        ),
      );
    }),
  ]),
  _c('TPNowCard', [
    _u('Playground', (context) {
      final k = context.knobs;
      final minutes = k.int.slider(label: 'Minutes since 09:30', initialValue: 70, min: -30, max: 210);
      final people = k.int.slider(label: 'With', initialValue: 1, min: 0, max: 4);
      return _frame(TPNowCard(
        title: 'Vatican Museums',
        place: 'Viale Vaticano',
        start: _at(9, 30),
        end: _at(12, 30),
        now: _at(9, 30).add(Duration(minutes: minutes)),
        companions: crew.skip(1).take(people).toList(),
        onTap: _noop,
      ));
    }),
  ]),
  _c('TPLeaveByHint', [
    _u('Playground', (context) {
      final before = context.knobs.int.slider(label: 'Minutes before 12:55', initialValue: 135, min: -10, max: 180);
      return _frame(TPLeaveByHint(
        leaveBy: _at(12, 55),
        travel: '5 min walk from the Vatican',
        now: _at(12, 55).subtract(Duration(minutes: before)),
      ));
    }),
    _u('All states', (context) => _frame(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final m in [40, 47, 55, 59]) ...[
            TPLeaveByHint(leaveBy: _at(12, 55), travel: '5 min walk from the Vatican', now: _at(m == 40 ? 10 : 12, m)),
            const SizedBox(height: TPSpace.s3),
          ],
        ]))),
  ]),
  _c('TPProgressBar', [
    _u('Playground', (context) => _frame(TPProgressBar(
          value: context.knobs.double.slider(label: 'Value', initialValue: 0.39, min: 0, max: 1),
          semanticLabel: 'Visit progress',
        ))),
  ]),
]);

WidgetbookCategory components() => WidgetbookCategory(name: 'Components', children: [_today, _actions, _navigation, _containers, _people, _planning, _braid, _text]);
