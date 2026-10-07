import 'package:flutter/material.dart';
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
