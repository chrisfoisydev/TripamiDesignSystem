// Backgrounds and the people pieces pulled in from the Crew and Bring-in-a-trip redesigns.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

import 'today_test.dart' show kTransparentPng;

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
      theme: TripamiTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );

const you = TPMember(id: 'you', name: 'Chris', color: TPMemberColor.lagoon);
const sandra = TPMember(id: 'sandra', name: 'Sandra', color: TPMemberColor.plum);
const leann = TPMember(id: 'leann', name: 'LeAnn', color: TPMemberColor.fern);
const sarah = TPMember(id: 'sarah', name: 'Sarah Johnson', color: TPMemberColor.slate);

void main() {
  group('TPBackdrop', () {
    testWidgets('every kind sits behind its content, which stays tappable', (tester) async {
      for (final make in <Widget Function(Widget)>[
        (c) => TPBackdrop.braid(members: const [you, sandra, leann], child: c),
        (c) => TPBackdrop.route(child: c),
        (c) => TPBackdrop.photo(image: MemoryImage(kTransparentPng), child: c),
      ]) {
        var taps = 0;
        await tester.pumpWidget(host(make(Padding(
          padding: const EdgeInsets.only(top: 40),
          child: TPButton.primary(label: 'Add people', onPressed: () => taps++),
        ))));
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Add people'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('is silent to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const TPBackdrop.route(child: Text('Bring in a trip'))));
      expect(find.bySemanticsLabel('Bring in a trip'), findsOneWidget);
      expect(
        find.descendant(of: find.byType(TPBackdrop), matching: find.byType(ExcludeSemantics)),
        findsWidgets,
        reason: 'the art is excluded from semantics',
      );
      handle.dispose();
    });

    testWidgets('the braid draws in once, and at rest under Reduce Motion', (tester) async {
      TPBraidBackdropPainter painter() => tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter)
          .whereType<TPBraidBackdropPainter>()
          .single;

      await tester.pumpWidget(host(const TPBackdrop.braid(members: [you, sandra, leann], child: SizedBox(height: 300))));
      expect(painter().progress, 0);
      await tester.pump(const Duration(milliseconds: 300));
      expect(painter().progress, inExclusiveRange(0, 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(painter().progress, 1);
      expect(painter().colors, [you.color.color, sandra.color.color, leann.color.color]);

      await tester.pumpWidget(Container());
      await tester.pumpWidget(host(const TPBackdrop.braid(members: [you, sandra], child: SizedBox(height: 300)), reduced: true));
      expect(painter().progress, 1);
    });

    test('at most six strands', () {
      const many = [you, sandra, leann, sarah, you, sandra, leann, sarah];
      const backdrop = TPBackdrop.braid(members: many, child: SizedBox());
      expect(backdrop.members.take(6).length, 6);
    });
  });

  group('people pieces', () {
    testWidgets('an invited avatar says so', (tester) async {
      await tester.pumpWidget(host(const TPAvatar(sarah, invited: true)));
      expect(find.bySemanticsLabel('Sarah Johnson, invited'), findsOneWidget);
      expect(find.text('SJ'), findsOneWidget);
    });

    testWidgets('a group row names everyone by first name when no detail is given', (tester) async {
      await tester.pumpWidget(host(TPGroupRow(members: const [you, sandra, leann], title: 'Pizza al taglio', onTap: () {})));
      expect(find.text('Chris, Sandra and LeAnn'), findsOneWidget);
    });

    testWidgets('role tags', (tester) async {
      await tester.pumpWidget(host(const Row(children: [TPRoleTag.neutral('Organizer'), TPRoleTag.pending('Invited')])));
      expect(find.text('Organizer'), findsOneWidget);
      expect(find.text('Invited'), findsOneWidget);
    });

    testWidgets('the connect card holds one primary action', (tester) async {
      var connected = false;
      await tester.pumpWidget(host(TPConnectCard(
        icon: TPIcons.envelopeSimple,
        title: 'Find your plans in Gmail',
        message: 'Flights, hotels, trains, activities and reservations.',
        kinds: const [TPIcons.airplane, TPIcons.train],
        actionLabel: 'Connect Gmail',
        onConnect: () => connected = true,
      )));
      await tester.tap(find.text('Connect Gmail'));
      expect(connected, isTrue);
      expect(find.byType(TPButton), findsOneWidget);
    });
  });
}
