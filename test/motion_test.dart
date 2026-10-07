import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

import 'braid_test.dart' as b;

double peak(Curve c) {
  var p = 0.0;
  for (var i = 0; i <= 1000; i++) {
    final v = c.transform(i / 1000);
    if (v > p) p = v;
  }
  return p;
}

Widget app(Widget child, {bool reduced = false}) => MaterialApp(
      theme: TripamiTheme.light(),
      home: MediaQuery(
        data: MediaQueryData(size: const Size(390, 2000), disableAnimations: reduced),
        child: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

void main() {
  group('springs', () {
    test('every curve starts at 0 and ends at 1', () {
      for (final c in [TPMotion.gentleCurve, TPMotion.snappyCurve, TPMotion.playfulCurve]) {
        expect(c.transform(0), 0);
        expect(c.transform(1), 1);
        expect(c.transform(0.98), closeTo(1, 0.01), reason: 'settles by the end of its duration');
      }
    });

    test('only the playful spring bounces, and only a little', () {
      expect(peak(TPMotion.gentleCurve), lessThan(1.01));
      expect(peak(TPMotion.snappyCurve), lessThan(1.01));
      expect(peak(TPMotion.playfulCurve), inInclusiveRange(1.03, 1.07));
    });

    test('stagger caps at 6 items', () {
      expect(TPMotion.staggerFor(0), Duration.zero);
      expect(TPMotion.staggerFor(2), const Duration(milliseconds: 60));
      expect(TPMotion.staggerFor(40), const Duration(milliseconds: 180));
    });
  });

  testWidgets('reduced motion: the braid is fully drawn on the first frame', (tester) async {
    await tester.pumpWidget(app(TPBraidDay(members: b.rome, youId: 'you', moments: b.romeDay), reduced: true));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('Vatican Museums'), findsOneWidget);
  });

  testWidgets('the braid draws in, then strands reroute when someone joins a plan', (tester) async {
    await tester.pumpWidget(app(TPBraidDay(members: b.rome, youId: 'you', moments: b.romeDay)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue, reason: 'drawing in');
    await tester.pumpAndSettle();

    // LeAnn joins the Vatican.
    final changed = [
      b.romeDay[0],
      TPBraidMoment(time: '09:30', events: [
        b.romeDay[1].events[0].copyWithParticipants({'you', 'sandra', 'leann'}),
        b.romeDay[1].events[2],
      ]),
      b.romeDay[2],
    ];
    await tester.pumpWidget(app(TPBraidDay(members: b.rome, youId: 'you', moments: changed)));
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.hasRunningAnimations, isTrue, reason: 'strands gliding to their new bundle');
    await tester.pumpAndSettle();
    expect(find.text('You, Sandra + LeAnn'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('count up lands on the new value; reduced motion shows it at once', (tester) async {
    String euro(num v) => '€${v.toStringAsFixed(2)}';
    await tester.pumpWidget(app(TPCountUp(value: 42.10, format: euro), reduced: true));
    expect(find.text('€42.10'), findsOneWidget);

    await tester.pumpWidget(app(TPCountUp(value: 10, format: euro)));
    await tester.pumpAndSettle();
    await tester.pumpWidget(app(TPCountUp(value: 42.10, format: euro)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('€42.10'), findsNothing, reason: 'still ticking');
    await tester.pumpAndSettle();
    expect(find.text('€42.10'), findsOneWidget);
  });

  testWidgets('success check, brand dot and pop settle without errors', (tester) async {
    await tester.pumpWidget(app(const Column(children: [
      TPSuccessCheck(),
      TPBrandDot(),
      TPActivityDot(urgent: true),
      TPRise(index: 3, child: Text('Booked')),
    ])));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200)); // success haptic's second tap
    expect(find.text('Booked'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('haptics', () {
    late List<String> buzz;
    setUp(() => buzz = []);

    Future<void> listen(WidgetTester tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') buzz.add((call.arguments as String).split('.').last);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));
      addTearDown(() => TPHaptics.enabled = true);
    }

    testWidgets('primary buttons tap lightly; other buttons are silent', (tester) async {
      await listen(tester);
      await tester.pumpWidget(app(Column(children: [
        TPButton.primary(label: 'Join', onPressed: () {}),
        TPButton.secondary(label: 'Maybe', onPressed: () {}),
        TPButton.tertiary(label: 'See all', onPressed: () {}),
      ])));
      await tester.tap(find.text('Join'));
      await tester.tap(find.text('Maybe'));
      await tester.tap(find.text('See all'));
      expect(buzz, ['lightImpact']);
    });

    testWidgets('tabs and chips click on a change of selection only', (tester) async {
      await listen(tester);
      var tab = 0;
      await tester.pumpWidget(app(StatefulBuilder(
        builder: (context, set) => Column(children: [
          TPTabBar(items: TPTabItem.defaults, currentIndex: tab, onTap: (i) => set(() => tab = i)),
          TPUnderlineTabs(labels: const ['Upcoming', 'Past'], currentIndex: 0, onChanged: (_) {}),
          TPFilterChip(label: 'Food', selected: false, onTap: () {}),
        ]),
      )));
      await tester.tap(find.text('Trips')); // already current
      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upcoming')); // already current
      await tester.tap(find.text('Past'));
      await tester.tap(find.text('Food'));
      expect(buzz, ['selectionClick', 'selectionClick', 'selectionClick']);
    });

    testWidgets('reacting and toggling; the add-reaction button is silent', (tester) async {
      await listen(tester);
      var on = false;
      await tester.pumpWidget(app(Column(children: [
        TPReactionBar(reactions: const [TPReaction(emoji: '🍝', count: 2)], onReact: (_) {}, onAdd: () {}),
        TPToggle(label: 'Share my location', value: on, onChanged: (v) => on = v),
      ])));
      await tester.tap(find.text('🍝 2'));
      await tester.tap(find.bySemanticsLabel('Add reaction'));
      await tester.tap(find.text('Share my location'));
      expect(buzz, ['lightImpact', 'selectionClick']);
      expect(on, isTrue);
    });

    testWidgets('TPHaptics.enabled = false silences everything', (tester) async {
      await listen(tester);
      TPHaptics.enabled = false;
      await tester.pumpWidget(app(TPButton.primary(label: 'Join', onPressed: () {})));
      await tester.tap(find.text('Join'));
      TPHaptics.success();
      await tester.pump(const Duration(milliseconds: 200));
      expect(buzz, isEmpty);
    });

    testWidgets('the last vote while on screen celebrates; an already-finished poll does not', (tester) async {
      await listen(tester);
      Widget poll(List<TPMember> waiting) => app(TPPollCard(
            eyebrow: 'DINNER',
            question: 'Where tonight?',
            options: const [TPPollOption(id: 'a', title: 'Armando', voters: [b.you, b.sandra])],
            waitingOn: waiting,
          ));

      await tester.pumpWidget(poll(const []));
      await tester.pumpAndSettle();
      expect(find.byType(TPSuccessCheck), findsOneWidget);
      expect(buzz, isEmpty, reason: 'already finished when it appeared');

      await tester.pumpWidget(poll([b.leann]));
      await tester.pumpAndSettle();
      await tester.pumpWidget(poll(const []));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 200));
      expect(buzz, ['mediumImpact', 'lightImpact']);
    });
  });

  group('component motion', () {
    testWidgets('buttons settle to 0.98 while pressed, but not under reduced motion', (tester) async {
      for (final reduced in [false, true]) {
        await tester.pumpWidget(app(TPButton.primary(label: 'Join', onPressed: () {}), reduced: reduced));
        final g = await tester.startGesture(tester.getCenter(find.text('Join')));
        await tester.pumpAndSettle();
        final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;
        expect(scale, reduced ? 1 : 0.98);
        await g.up();
        await tester.pumpAndSettle();
      }
    });

    testWidgets('someone joining pops into an avatar stack; first faces just appear', (tester) async {
      await tester.pumpWidget(app(const TPAvatarStack([b.you, b.sandra])));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(app(const TPAvatarStack([b.you, b.sandra, b.leann])));
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.byType(TPPop), findsOneWidget);
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('a reaction bumps when its count changes', (tester) async {
      Widget bar(int n, bool mine) =>
          app(TPReactionBar(reactions: [TPReaction(emoji: '🍝', count: n, mine: mine)], onReact: (_) {}));
      await tester.pumpWidget(bar(2, false));
      await tester.pumpAndSettle();
      await tester.pumpWidget(bar(3, true));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('🍝 3'), findsOneWidget);
    });

    testWidgets('plans revealed by Show more rise in', (tester) async {
      final day = [
        TPBraidMoment(time: '10:00', events: [
          for (var i = 0; i < 5; i++)
            TPBraidEvent(id: 'e$i', title: 'Plan $i', participantIds: {b.rome[i].id}),
        ]),
      ];
      await tester.pumpWidget(app(TPBraidDay(members: b.rome, youId: 'you', moments: day)));
      await tester.pumpAndSettle();
      expect(find.text('Plan 4'), findsNothing);
      await tester.tap(find.text('Show 2 more'));
      await tester.pump(const Duration(milliseconds: 40));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Plan 4'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

extension on TPBraidEvent {
  TPBraidEvent copyWithParticipants(Set<String> ids) => TPBraidEvent(
        id: id,
        title: title,
        participantIds: ids,
        start: start,
        end: end,
        place: place,
        loose: loose,
        now: now,
        footer: footer,
      );
}
