import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

double _channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
double _lum(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);
double contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

List<TPMember> people(int n) => [
      for (var i = 0; i < n; i++)
        TPMember(id: 'p$i', name: 'Person$i Test', color: TPMemberColor.forJoinIndex(i)),
    ];

// The Rome day from the mockup: 5 travelers.
const shannon = TPMember(id: 'shannon', name: 'Shannon Lee', color: TPMemberColor.lagoon);
const christy = TPMember(id: 'christy', name: 'Christy Park', color: TPMemberColor.rose);
const you = TPMember(id: 'you', name: 'Chris Foisy', color: TPMemberColor.sky);
const sandra = TPMember(id: 'sandra', name: 'Sandra Diaz', color: TPMemberColor.fern);
const leann = TPMember(id: 'leann', name: 'LeAnn Moss', color: TPMemberColor.plum);
const rome = [you, sandra, leann, shannon, christy];

final romeDay = [
  const TPBraidMoment(time: '08:00', events: [
    TPBraidEvent(
      id: 'b1',
      title: 'Breakfast together',
      start: '08:00',
      end: '09:00',
      place: 'Roscioli Caffè',
      participantIds: {'you', 'sandra', 'leann', 'shannon', 'christy'},
    ),
  ]),
  const TPBraidMoment(time: '09:30', events: [
    TPBraidEvent(id: 'v', title: 'Vatican Museums', start: '09:30', end: '12:30', place: 'Viale Vaticano', participantIds: {'you', 'sandra'}),
    TPBraidEvent(id: 'm', title: 'Wandering Monti', start: '09:30', end: '12:30', place: 'No plans, just vibes', participantIds: {'leann'}, loose: true),
    TPBraidEvent(id: 'f', title: 'Farmhouse breakfast', start: '09:30', end: '11:00', place: "Val d'Orcia", participantIds: {'shannon', 'christy'}),
  ]),
  const TPBraidMoment(time: '13:00', events: [
    TPBraidEvent(id: 'l', title: 'Lunch at Armando', start: '13:00', end: '14:30', place: 'Pantheon', participantIds: {'you', 'sandra', 'leann', 'shannon', 'christy'}, now: true),
  ]),
];

void main() {
  group('resolveBraidStrands', () {
    test('2–8 travelers: one strand per person, you marked', () {
      final s = resolveBraidStrands(members: rome, youId: 'you', moments: romeDay);
      expect(s.length, 5);
      expect(s.every((x) => x.kind == TPStrandKind.person), isTrue);
      expect(s.singleWhere((x) => x.isYou).id, 'you');
      expect(s.singleWhere((x) => x.isYou).label, 'You');
    });

    test('9–20: you + people you share plans with + one Everyone else ribbon', () {
      final m = people(14);
      final day = [
        TPBraidMoment(time: '09:00', events: [
          const TPBraidEvent(id: 'a', title: 'A', participantIds: {'p0', 'p3', 'p5'}),
          TPBraidEvent(id: 'b', title: 'B', participantIds: {for (var i = 6; i < 14; i++) 'p$i', 'p1', 'p2', 'p4'}),
        ]),
        const TPBraidMoment(time: '12:00', events: [
          TPBraidEvent(id: 'c', title: 'C', participantIds: {'p0', 'p3'}),
        ]),
      ];
      final s = resolveBraidStrands(members: m, youId: 'p0', moments: day);
      expect(s.first.isYou, isTrue);
      expect(s[1].id, 'p3', reason: 'shares two plans with you, so comes first');
      expect(s[2].id, 'p5');
      expect(s.last.kind, TPStrandKind.others);
      expect(s.last.label, 'Everyone else');
      expect(s.last.count, 11);
      expect(s.length, lessThanOrEqualTo(TPBraidMetrics.maxStrands));
    });

    test('21+: you + groups (yours first, then by size), capped at 6 strands', () {
      final m = people(50);
      final groups = [
        for (var g = 0; g < 7; g++)
          TPBraidGroup(
            id: 'g$g',
            name: 'Group $g',
            color: TPMemberColor.forJoinIndex(g),
            memberIds: {for (var i = g * 7; i < math.min(50, g * 7 + 7 + (g == 6 ? 1 : 0)); i++) 'p$i'},
          ),
      ];
      final s = resolveBraidStrands(members: m, youId: 'p20', groups: groups);
      expect(s.length, TPBraidMetrics.maxStrands);
      expect(s.first.isYou, isTrue);
      expect(s[1].id, 'g2', reason: 'your own group comes first');
      expect(s.last.kind, TPStrandKind.others);
      expect(s.last.label, '+3 more groups');
      final total = s.fold<int>(0, (n, x) => n + x.count);
      expect(total, 50, reason: 'every traveler is in exactly one strand');
    });

    test('21+ with few groups: no overflow, ungrouped people become Everyone else', () {
      final m = people(30);
      final groups = [
        TPBraidGroup(id: 'a', name: 'A', color: TPMemberColor.sky, memberIds: {for (var i = 0; i < 10; i++) 'p$i'}),
        TPBraidGroup(id: 'b', name: 'B', color: TPMemberColor.iris, memberIds: {for (var i = 10; i < 25; i++) 'p$i'}),
      ];
      final s = resolveBraidStrands(members: m, youId: 'p0', groups: groups);
      expect(s.map((x) => x.id), ['p0', 'a', 'b', '_others']);
      expect(s[1].count, 9, reason: 'you are shown on your own strand, not twice');
      expect(s.last.count, 5);
    });
  });

  group('copy', () {
    test('event labels use plain language', () {
      expect(braidEventLabel(romeDay[0].events[0], rome, 'you', const []), 'All 5 together');
      expect(braidEventLabel(romeDay[1].events[0], rome, 'you', const []), 'You + Sandra');
      expect(braidEventLabel(romeDay[1].events[1], rome, 'you', const []), 'LeAnn');
      expect(braidEventLabel(romeDay[1].events[2], rome, 'you', const []), 'Shannon + Christy');
      const e = TPBraidEvent(id: 'x', title: 'x', participantIds: {'you', 'sandra', 'leann', 'shannon'});
      expect(braidEventLabel(e, rome, 'you', const []), 'You, Sandra + 2 more');
    });

    test('moment summaries', () {
      expect(braidMomentSummary(romeDay[0], null, 5), 'All 5 together');
      expect(braidMomentSummary(romeDay[1], romeDay[0], 5), 'Splits into 3');
      expect(braidMomentSummary(romeDay[2], romeDay[1], 5), 'Back together');
    });

    test('a group that goes out together is named', () {
      final m = people(30);
      final g = TPBraidGroup(id: 'r', name: 'Rome crew', color: TPMemberColor.rose, memberIds: {for (var i = 0; i < 12; i++) 'p$i'});
      final e = TPBraidEvent(id: 'e', title: 'e', participantIds: g.memberIds);
      expect(braidEventLabel(e, m, 'p40', [g]), 'Rome crew · 12');
    });
  });

  test('strand colors hold 3:1 (meaningful marks) on canvas in both themes', () {
    for (final mc in TPMemberColor.values) {
      expect(contrast(mc.strand(Brightness.light), TPColors.light.canvas), greaterThanOrEqualTo(3), reason: mc.name);
      expect(contrast(mc.strand(Brightness.dark), TPColors.dark.canvas), greaterThanOrEqualTo(3), reason: mc.name);
      expect(contrast(mc.strand(Brightness.dark), TPColors.dark.surface), greaterThanOrEqualTo(3), reason: mc.name);
    }
    expect(contrast(TPColors.light.textTertiary, TPColors.light.canvas), greaterThanOrEqualTo(3), reason: 'Everyone else ribbon');
    expect(contrast(TPColors.dark.textTertiary, TPColors.dark.canvas), greaterThanOrEqualTo(3), reason: 'Everyone else ribbon');
  });

  test('ribbon width scales with headcount and caps', () {
    expect(TPBraidMetrics.widthFor(1), TPBraidMetrics.strand);
    expect(TPBraidMetrics.widthFor(10), greaterThan(TPBraidMetrics.strand));
    expect(TPBraidMetrics.widthFor(500), TPBraidMetrics.ribbonMax);
  });

  for (final dark in [false, true]) {
    for (final width in [390.0, 768.0]) {
      testWidgets('TPBraidDay renders (${dark ? 'dark' : 'light'}, ${width.toInt()}px)', (tester) async {
        tester.view.physicalSize = Size(width, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        final big = people(50);
        final groups = [
          for (var g = 0; g < 7; g++)
            TPBraidGroup(
              id: 'g$g',
              name: 'Group $g',
              color: TPMemberColor.forJoinIndex(g),
              memberIds: {for (var i = g * 7; i < math.min(50, g * 7 + 8); i++) 'p$i'},
            ),
        ];
        final bigDay = [
          TPBraidMoment(time: '09:00', events: [
            TPBraidEvent(id: 'all', title: 'Welcome breakfast', participantIds: {for (final m in big) m.id}),
          ]),
          TPBraidMoment(time: '10:00', events: [
            for (var g = 0; g < 6; g++) TPBraidEvent(id: 'e$g', title: 'Tour $g', participantIds: groups[g].memberIds),
          ]),
        ];

        await tester.pumpWidget(MaterialApp(
          theme: dark ? TripamiTheme.dark() : TripamiTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                TPBraidDay(members: rome, youId: 'you', moments: romeDay),
                TPBraidDay(members: big, youId: 'p20', groups: groups, moments: bigDay),
              ]),
            ),
          ),
        ));
        await tester.pumpAndSettle();

        expect(find.text('All 5 together'), findsWidgets);
        expect(find.text('Splits into 3'), findsOneWidget);
        expect(find.text('Back together'), findsOneWidget);
        expect(find.text('Show 3 more'), findsOneWidget, reason: '6 plans at once: 3 shown, 3 behind Show more');
        await tester.tap(find.text('Show 3 more'));
        await tester.pumpAndSettle();
        expect(find.text('Show 3 more'), findsNothing);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
