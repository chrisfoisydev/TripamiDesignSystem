// The OS accessibility settings Tripami honors beyond the guideline sweep:
// high contrast, Bold Text, keyboards, color blindness and screen-reader labels.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

double wght(TextStyle s) => s.fontVariations!.firstWhere((v) => v.axis == 'wght').value;

void main() {
  group('high contrast', () {
    for (final (name, c) in [('light', TPColors.lightHighContrast), ('dark', TPColors.darkHighContrast)]) {
      test('$name: every text color reaches 7:1 and borders 3:1', () {
        final grounds = {'canvas': c.canvas, 'surface': c.surface, 'sunken': c.sunken};
        final inks = {'textPrimary': c.textPrimary, 'textSecondary': c.textSecondary, 'textTertiary': c.textTertiary, 'accent': c.accent, 'positive': c.positive, 'caution': c.caution, 'critical': c.critical};
        for (final g in grounds.entries) {
          for (final i in inks.entries) {
            expect(contrast(i.value, g.value), greaterThanOrEqualTo(7), reason: '${i.key} on ${g.key}');
          }
        }
        expect(contrast(c.accent, c.accentSubtle), greaterThanOrEqualTo(7), reason: 'accent on accentSubtle');
        expect(contrast(c.borderStrong, c.canvas), greaterThanOrEqualTo(3));
        expect(contrast(c.borderStrong, c.surface), greaterThanOrEqualTo(3));
        expect(contrast(c.actionPrimaryText, c.actionPrimary), greaterThanOrEqualTo(7));
      });
    }

    testWidgets('MaterialApp picks the high-contrast theme when the OS asks', (tester) async {
      late TPColors seen;
      await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(highContrast: true),
        child: MaterialApp(
          theme: TripamiTheme.light(),
          highContrastTheme: TripamiTheme.highContrastLight(),
          home: Builder(builder: (context) {
            seen = TPColors.of(context);
            return const SizedBox();
          }),
        ),
      ));
      expect(seen.textSecondary, TPColors.lightHighContrast.textSecondary);
    });
  });

  group('Bold Text', () {
    tearDown(() => TPType.boldText = false);

    test('styles step up about two weights, within each font\'s range', () {
      TPType.boldText = false;
      expect(wght(TPType.body), 400);
      expect(wght(TPType.display), 800);
      TPType.boldText = true;
      expect(wght(TPType.body), 600);
      expect(wght(TPType.title2), 700);
      expect(wght(TPType.display), 800, reason: 'Bricolage tops out at 800');
      expect(wght(TPType.body.withWeight(TPType.medium)), 700);
    });

    testWidgets('TripamiTheme.builder follows the OS setting and keeps state', (tester) async {
      Widget app(bool bold) => MediaQuery(
            data: MediaQueryData(boldText: bold),
            child: MaterialApp(
              theme: TripamiTheme.light(),
              builder: TripamiTheme.builder,
              home: Scaffold(body: Column(children: [Builder(builder: (_) => Text('Lisbon', style: TPType.body)), const TextField()])),
            ),
          );
      await tester.pumpWidget(app(false));
      await tester.enterText(find.byType(TextField), 'kept');
      double drawn() => wght(tester.widget<Text>(find.text('Lisbon')).style!);
      expect(drawn(), 400);
      await tester.pumpWidget(app(true));
      expect(drawn(), 600);
      expect(find.text('kept'), findsOneWidget, reason: 'rebuild keeps state');
      await tester.pumpWidget(app(false));
      expect(drawn(), 400);
    });
  });

  group('keyboard', () {
    testWidgets('Tab focuses a chip, shows a ring, Enter activates it', (tester) async {
      var taps = 0;
      await tester.pumpWidget(MaterialApp(
        theme: TripamiTheme.light(),
        home: Scaffold(body: Center(child: TPFilterChip(label: 'Food', selected: false, onTap: () => taps++))),
      ));
      FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final ring = find.descendant(of: find.byType(TPFilterChip), matching: find.byWidgetPredicate((w) => w is DecoratedBox && w.position == DecorationPosition.foreground));
      expect(ring, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(taps, 2);
    });

    testWidgets('cards, tabs and covers are all reachable by Tab', (tester) async {
      final tapped = <String>[];
      await tester.pumpWidget(MaterialApp(
        theme: TripamiTheme.light(),
        home: Scaffold(
          body: Column(children: [
            TPCard(onTap: () => tapped.add('card'), child: const Text('Card')),
            TPUnderlineTabs(labels: const ['A', 'B'], currentIndex: 0, onChanged: (i) => tapped.add('tab$i')),
          ]),
        ),
      ));
      for (var i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      }
      expect(tapped, ['card', 'tab0', 'tab1']);
    });
  });

  group('color blindness', () {
    // Machado, Oliveira & Fernandes (2009), severity 1, in linear sRGB.
    const sims = {
      'protanopia': [0.152286, 1.052583, -0.204868, 0.114503, 0.786281, 0.099216, -0.003882, -0.048116, 1.051998],
      'deuteranopia': [0.367322, 0.860646, -0.227968, 0.280085, 0.672501, 0.047413, -0.011820, 0.042940, 0.968881],
      'tritanopia': [1.255528, -0.076749, -0.178779, -0.078411, 0.930809, 0.147602, 0.004733, 0.691367, 0.303900],
    };
    double lin(double c) => c <= 0.04045 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    List<double> oklab(List<double> rgb) {
      final [r, g, b] = rgb;
      double cbrt(double x) => math.pow(x, 1 / 3).toDouble();
      final l = cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b);
      final m = cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b);
      final s = cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
      return [0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s, 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s, 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s];
    }

    List<double> seen(Color c, List<double> k) {
      final v = [lin(c.r), lin(c.g), lin(c.b)];
      return oklab([for (var i = 0; i < 3; i++) (k[i * 3] * v[0] + k[i * 3 + 1] * v[1] + k[i * 3 + 2] * v[2]).clamp(0.0, 1.0)]);
    }

    double dE(List<double> a, List<double> b) => math.sqrt([0, 1, 2].fold(0.0, (s, i) => s + math.pow(a[i] - b[i], 2))) * 100;

    test('the first six travelers stay distinguishable for every type', () {
      for (final MapEntry(key: kind, value: k) in sims.entries) {
        for (var n = 2; n <= 6; n++) {
          final colors = [for (var i = 0; i < n; i++) TPMemberColor.forJoinIndex(i).color];
          for (var a = 0; a < n; a++) {
            for (var b = a + 1; b < n; b++) {
              expect(dE(seen(colors[a], k), seen(colors[b], k)), greaterThanOrEqualTo(3.5), reason: '$kind, $n travelers, #$a vs #$b');
            }
          }
        }
      }
    });

    test('the trip creator is still lagoon and every color is used', () {
      expect(TPMemberColor.forJoinIndex(0), TPMemberColor.lagoon);
      expect({for (var i = 0; i < 8; i++) TPMemberColor.forJoinIndex(i)}, TPMemberColor.values.toSet());
    });
  });

  group('screen reader labels', () {
    testWidgets('state is spoken, not just shown', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        theme: TripamiTheme.light(),
        home: Scaffold(
          body: Column(children: [
            TPTabBar(
              items: const [
                TPTabItem(label: 'Trips', icon: TPIcons.suitcase, activeIcon: TPIconsFill.suitcase),
                TPTabItem(label: 'Chat', icon: TPIcons.chatsCircle, activeIcon: TPIconsFill.chatsCircle, hasActivity: true, urgent: true),
              ],
              currentIndex: 0,
              onTap: (_) {},
            ),
            const TPFilterChip(label: 'Filters', selected: false, count: 2, onTap: null),
            TPReactionBar(reactions: const [TPReaction(emoji: '👍', count: 3, mine: true)], onReact: (_) {}),
          ]),
        ),
      ));
      expect(find.bySemanticsLabel('Chat, needs you'), findsOneWidget);
      expect(find.bySemanticsLabel('Filters, 2'), findsOneWidget);
      expect(find.bySemanticsLabel('👍 3, including you'), findsOneWidget);
      handle.dispose();
    });
  });
}
