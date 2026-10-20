// The event editor's pieces: boxed fields, choice chips, quick pills, the
// two-step delete and the dimmed avatar.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

Widget host(Widget child, {ThemeData? theme, double scale = 1}) => MaterialApp(
      theme: theme ?? TripamiTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale), disableAnimations: true),
          child: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
        ),
      ),
    );

void main() {
  testWidgets('a choice chip fills when selected, and says so', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await tester.pumpWidget(host(TPChoices(children: [
      TPChoiceChip(label: 'Meal', selected: true, onTap: () => taps++),
      TPChoiceChip(label: 'Activity', selected: false, onTap: () => taps++),
    ])));
    final c = TPColors.light;
    Color fill(String label) => ((tester.widget<AnimatedContainer>(
          find.ancestor(of: find.text(label), matching: find.byType(AnimatedContainer)),
        )).decoration! as BoxDecoration).color!;
    expect(fill('Meal'), c.actionPrimary);
    expect(fill('Activity'), c.surface);
    expect(tester.getSemantics(find.bySemanticsLabel('Meal')).flagsCollection.isSelected, isTrue);
    await tester.tap(find.text('Activity'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('choices spread across the width, and wrap at large text', (tester) async {
    Widget four(double scale) => host(
          const TPChoices(fill: true, children: [
            TPChoiceChip(label: 'Meal', selected: false, onTap: null),
            TPChoiceChip(label: 'Activity', selected: false, onTap: null),
            TPChoiceChip(label: 'Travel', selected: false, onTap: null),
            TPChoiceChip(label: 'Free time', selected: false, onTap: null),
          ]),
          scale: scale,
        );
    await tester.pumpWidget(four(1));
    expect(find.byType(Row), findsWidgets);
    expect(tester.getSize(find.byType(TPChoiceChip).first).width, tester.getSize(find.byType(TPChoiceChip).last).width);
    await tester.pumpWidget(four(2));
    expect(find.byType(Wrap), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the first tap arms a delete; only the second deletes', (tester) async {
    var deleted = 0;
    await tester.pumpWidget(host(TPConfirmDelete(
      label: 'Delete event',
      confirmLabel: 'Tap again to delete for everyone',
      onConfirmed: () => deleted++,
    )));
    await tester.tap(find.text('Delete event'));
    await tester.pump();
    expect(deleted, 0);
    expect(find.text('Tap again to delete for everyone'), findsOneWidget);
    await tester.tap(find.text('Tap again to delete for everyone'));
    expect(deleted, 1);
  });

  testWidgets('a dimmed avatar is greyed and says not going', (tester) async {
    final handle = tester.ensureSemantics();
    const sam = TPMember(id: 's', name: 'Sam Rivera', color: TPMemberColor.lagoon);
    await tester.pumpWidget(host(const TPAvatar(sam, dimmed: true)));
    expect(find.byType(ColorFiltered), findsOneWidget);
    expect(find.bySemanticsLabel('Sam Rivera, not going'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('a boxed field is white with a hairline, ink when focused', (tester) async {
    late InputDecoration d;
    await tester.pumpWidget(host(Builder(builder: (context) {
      d = TPField.boxed(context, hint: 'Dinner, museum, train…');
      return TextField(decoration: d);
    })));
    final c = TPColors.light;
    expect(d.filled, isTrue);
    expect(d.fillColor, c.surface);
    expect((d.enabledBorder! as OutlineInputBorder).borderSide.color, c.hairline);
    expect((d.focusedBorder! as OutlineInputBorder).borderSide.color, c.actionPrimary);
    expect(find.text('Dinner, museum, train…'), findsOneWidget);
  });
}
