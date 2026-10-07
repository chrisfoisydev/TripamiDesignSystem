import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

void main() {
  test('Tripami is light by default', () {
    expect(TripamiTheme.defaultMode, ThemeMode.light);
  });

  const people = [
    TPMember(id: 'a', name: 'Alex Rivera', color: TPMemberColor.lagoon),
    TPMember(id: 'm', name: 'Maya Chen', color: TPMemberColor.plum),
    TPMember(id: 'l', name: 'Leo Okafor', color: TPMemberColor.fern),
    TPMember(id: 'j', name: 'Jonah Weiss', color: TPMemberColor.sky),
    TPMember(id: 'p', name: 'Priya Nair', color: TPMemberColor.iris),
    TPMember(id: 's', name: 'Sam Torres', color: TPMemberColor.rose),
  ];

  for (final width in [160.0, 200.0, 280.0, 360.0]) {
    testWidgets('trip cover keeps its title clear of the status chip at ${width.toInt()}px', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: TripamiTheme.light(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: const TPTripCoverCard(
                title: 'Lisbon with the crew and everyone else who said yes',
                subtitle: '12–17 Jun · Lisbon',
                status: 'In 6 days',
                image: null,
                members: people,
              ),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: 'no overflow');
      final chip = tester.getRect(find.byType(TPGlassChip));
      final title = tester.getRect(find.textContaining('Lisbon with'));
      final card = tester.getRect(find.byType(TPTripCoverCard));
      expect(title.top, greaterThanOrEqualTo(chip.bottom), reason: 'title never runs into the chip');
      final stack = tester.getRect(find.byType(TPAvatarStack));
      expect(stack.right, lessThanOrEqualTo(card.right), reason: 'travelers stay inside the card');
    });
  }
}
