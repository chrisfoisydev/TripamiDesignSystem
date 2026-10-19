// Trip-day pieces from the Italy redesign: formatting, the Now card, the
// Leave-by hint, the photo header and the sheet that overlaps it.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

Widget host(Widget child, {double textScale = 1}) => MaterialApp(
      theme: TripamiTheme.light(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale), disableAnimations: true),
          child: Scaffold(body: SingleChildScrollView(child: child)),
        ),
      ),
    );

DateTime at(int h, int m) => DateTime(2026, 11, 18, h, m);

const sandra = TPMember(id: 'sandra', name: 'Sandra', color: TPMemberColor.plum);
const leann = TPMember(id: 'leann', name: 'LeAnn Moss', color: TPMemberColor.rose);

void main() {
  group('TPFormat', () {
    test('durations', () {
      expect(TPFormat.duration(const Duration(minutes: 110)), '1 h 50 min');
      expect(TPFormat.duration(const Duration(hours: 2)), '2 h');
      expect(TPFormat.duration(const Duration(minutes: 45)), '45 min');
      expect(TPFormat.duration(const Duration(seconds: 20)), '1 min', reason: 'rounds up, never "0 min" while time is left');
      expect(TPFormat.duration(Duration.zero), '0 min');
    });
    test('times and days', () {
      expect(TPFormat.time(at(9, 5)), '9:05am');
      expect(TPFormat.time(at(15, 0)), '3pm');
      expect(TPFormat.time(at(12, 0)), '12pm', reason: 'noon');
      expect(TPFormat.time(at(0, 30)), '12:30am', reason: 'just after midnight');
      expect(TPFormat.time(at(23, 45)), '11:45pm');
      expect(TPFormat.dayShort(at(0, 0)), 'Wed 18');
      expect(TPFormat.dayLong(at(0, 0)), 'Wednesday 18 November');
    });
    test('names', () {
      expect(TPFormat.names(['Sandra']), 'Sandra');
      expect(TPFormat.names(['Sandra', 'LeAnn']), 'Sandra and LeAnn');
      expect(TPFormat.names(['Shannon', 'Christy', 'Sarah']), 'Shannon, Christy and Sarah');
      expect(TPFormat.names(['A', 'B', 'C', 'D', 'E']), 'A, B and 3 others');
      expect(TPFormat.firstName('Sarah Johnson'), 'Sarah');
    });
  });

  group('TPLeaveByHint', () {
    final by = at(12, 55);
    const travel = '5 min walk from the Vatican';
    test('quiet, then counting down, then due', () {
      expect(TPLeaveByHint.stateAt(at(10, 40), by), TPLeaveState.calm);
      expect(TPLeaveByHint.labelAt(at(10, 40), by, travel), 'Leave by 12:55pm · 5 min walk from the Vatican');
      expect(TPLeaveByHint.stateAt(at(12, 47), by), TPLeaveState.soon);
      expect(TPLeaveByHint.labelAt(at(12, 47), by, travel), 'Leave in 8 min · 5 min walk from the Vatican');
      expect(TPLeaveByHint.stateAt(by, by), TPLeaveState.due);
      expect(TPLeaveByHint.labelAt(by, by, travel), 'Leave now · 5 min walk from the Vatican');
      expect(TPLeaveByHint.labelAt(at(12, 59), by, travel), 'Leave now · 4 min behind');
    });

    testWidgets('colors follow the state', (tester) async {
      const c = TPColors.light;
      Color colorAt(DateTime now) {
        final text = tester.widget<AnimatedDefaultTextStyle>(
          find.descendant(of: find.byType(TPLeaveByHint), matching: find.byType(AnimatedDefaultTextStyle)),
        );
        return text.style.color!;
      }

      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(10, 40))));
      expect(colorAt(at(10, 40)), c.textSecondary);
      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(12, 47))));
      expect(colorAt(at(12, 47)), c.accent);
      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(12, 56))));
      expect(colorAt(at(12, 56)), c.caution);
    });

    testWidgets('plays the warning haptic once, when it turns due, not on first show', (tester) async {
      final calls = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') calls.add(call.arguments as String);
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(12, 57))));
      expect(calls, isEmpty, reason: 'already due when shown: no surprise buzz');
      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(12, 50))));
      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(12, 55))));
      await tester.pump(const Duration(milliseconds: 300));
      final afterDue = calls.length;
      expect(afterDue, greaterThan(0));
      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: by, travel: travel, now: at(12, 56))));
      await tester.pump(const Duration(milliseconds: 300));
      expect(calls.length, afterDue, reason: 'staying due does not buzz again');
    });

    testWidgets('ticks on its own when no time is pinned', (tester) async {
      await tester.pumpWidget(host(TPLeaveByHint(leaveBy: DateTime.now().add(const Duration(hours: 1)), travel: travel)));
      await tester.pump(const Duration(seconds: 31));
      expect(find.byType(TPLeaveByHint), findsOneWidget);
      await tester.pumpWidget(const SizedBox()); // disposes the timer
    });
  });

  group('TPNowCard', () {
    testWidgets('shows time left, progress and who you are with', (tester) async {
      await tester.pumpWidget(host(TPNowCard(
        title: 'Vatican Museums',
        place: 'Viale Vaticano',
        start: at(9, 30),
        end: at(12, 30),
        now: at(10, 40),
        companions: const [sandra],
      )));
      expect(find.text('NOW · UNTIL 12:30PM'), findsOneWidget);
      expect(find.text('1 h 50 min left'), findsOneWidget);
      expect(find.text('With Sandra'), findsOneWidget);
      final bar = tester.widget<TPProgressBar>(find.byType(TPProgressBar));
      expect(bar.value, closeTo(70 / 180, 0.001));
      expect(
        tester.getSemantics(find.byType(TPNowCard)).label,
        'Now · until 12:30pm. Vatican Museums, Viale Vaticano. 1 h 50 min left. With Sandra.',
      );
    });

    testWidgets('before the start, after the end, and alone', (tester) async {
      await tester.pumpWidget(host(TPNowCard(title: 'Vatican Museums', start: at(9, 30), end: at(12, 30), now: at(9, 10))));
      expect(find.text('Starts in 20 min'), findsOneWidget);
      expect(find.text('Just you'), findsOneWidget);
      await tester.pumpWidget(host(TPNowCard(title: 'Vatican Museums', start: at(9, 30), end: at(12, 30), now: at(12, 45))));
      expect(find.text('Over by 15 min'), findsOneWidget);
      expect(TPNowCard.withLabel(const [sandra, leann]), 'With Sandra and LeAnn');
    });

    testWidgets('stacks the times at large text instead of squeezing them', (tester) async {
      tester.view.physicalSize = const Size(390, 2000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(host(
        TPNowCard(title: 'Vatican Museums', start: at(9, 30), end: at(12, 30), now: at(10, 40), companions: const [sandra]),
        textScale: 3.1,
      ));
      expect(find.text('9:30am – 12:30pm'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TPPlaceHeader and TPOverlapSheet', () {
    Widget screen({double textScale = 1}) => host(
          const Column(children: [
            TPPlaceHeader(
              title: 'Rome',
              eyebrow: 'Today · Day 5 of 14',
              subtitle: 'Wednesday 18 November · Italy with Friends',
              image: null,
              imageLabel: "The Tiber leading to St Peter's dome",
              leading: TPGlassIconButton(icon: TPIcons.arrowLeft, onPressed: null, semanticLabel: 'Back'),
            ),
            TPOverlapSheet(child: SizedBox(height: 200, child: Text('Rome Airbnb'))),
          ]),
          textScale: textScale,
        );

    testWidgets('is at least the header height and the sheet rises over it', (tester) async {
      await tester.pumpWidget(screen());
      final header = tester.getRect(find.byType(TPPlaceHeader));
      expect(header.height, greaterThanOrEqualTo(TPSize.placeHeader));
      final sheet = tester.getRect(find.byType(DecoratedBox).last);
      expect(sheet.top, closeTo(header.bottom - TPSize.sheetOverlap, 0.5));
      expect(find.bySemanticsLabel('Rome'), findsOneWidget);
    });

    testWidgets('grows instead of clipping at 310% text', (tester) async {
      tester.view.physicalSize = const Size(390, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(screen(textScale: 3.1));
      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(TPPlaceHeader)).height, greaterThan(TPSize.placeHeader));
    });

    testWidgets('the photo is described for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(TPPlaceHeader(
        title: 'Rome',
        image: MemoryImage(kTransparentPng),
        imageLabel: "The Tiber leading to St Peter's dome",
      )));
      expect(find.bySemanticsLabel("The Tiber leading to St Peter's dome"), findsOneWidget);
      handle.dispose();
    });
  });
}

/// A 1×1 transparent PNG.
final kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);
