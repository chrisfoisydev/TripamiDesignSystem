// Accessibility sweep: every component, in light, dark and high contrast, at
// 100% and 200% text, against Flutter's accessibility guidelines.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

import 'support/gallery.dart';

Widget host(Widget child, {required ThemeData theme, double textScale = 1, bool bold = false, bool reduced = true}) {
  return MaterialApp(
    theme: theme,
    debugShowCheckedModeBanner: false,
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale), boldText: bold, disableAnimations: reduced),
        child: Scaffold(body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: child)),
      ),
    ),
  );
}

void main() {
  final themes = {
    'light': TripamiTheme.light(),
    'dark': TripamiTheme.dark(),
    'high-contrast light': TripamiTheme.highContrastLight(),
    'high-contrast dark': TripamiTheme.highContrastDark(),
  };

  for (final MapEntry(key: name, value: widget) in gallery.entries) {
    for (final MapEntry(key: themeName, value: theme) in themes.entries) {
      testWidgets('$name ($themeName) meets the tap-target, label and contrast guidelines', (tester) async {
        tester.view.physicalSize = const Size(390, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(host(widget, theme: theme));
        await tester.pump(const Duration(seconds: 2));
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }

    for (final scale in [2.0, 3.1]) {
      testWidgets('$name lays out at ${(scale * 100).round()}% text without overflow', (tester) async {
        tester.view.physicalSize = const Size(390, 4000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(host(widget, theme: themes['light']!, textScale: scale));
        await tester.pump(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
