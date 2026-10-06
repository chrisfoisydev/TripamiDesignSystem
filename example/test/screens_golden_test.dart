// Renders each gallery screen in light and dark with the real fonts and
// writes screenshots to test/goldens. Regenerate with:
//   flutter test --update-goldens
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';
import 'package:tripami_design_system_example/sample_data.dart';
import 'package:tripami_design_system_example/screens.dart';

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final a in assets) {
    loader.addFont(rootBundle.load(a));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  const ds = 'packages/tripami_design_system';
  await _loadFont('$ds/Inter', ['$ds/lib/fonts/Inter-Variable.ttf']);
  await _loadFont('$ds/Newsreader', [
    '$ds/lib/fonts/Newsreader-Variable.ttf',
    '$ds/lib/fonts/Newsreader-Italic-Variable.ttf',
  ]);
  await _loadFont('$ds/PhosphorRegular', ['$ds/lib/fonts/Phosphor-Regular.ttf']);
  await _loadFont('$ds/PhosphorFill', ['$ds/lib/fonts/Phosphor-Fill.ttf']);
}

const _screens = <String, (Widget, int)>{
  'trips': (TripsScreen(), 0),
  'trip_home': (TripHomeScreen(), 1),
  'plan': (PlanScreen(), 2),
  'foundations': (FoundationsScreen(), 3),
};

const _tabs = [
  TPTabItem(label: 'Trips', icon: TPIcons.suitcase, activeIcon: TPIconsFill.suitcase),
  TPTabItem(label: 'Trip', icon: TPIcons.house, activeIcon: TPIconsFill.house),
  TPTabItem(
    label: 'Plan',
    icon: TPIcons.calendarBlank,
    activeIcon: TPIconsFill.calendarBlank,
    hasActivity: true,
  ),
  TPTabItem(label: 'System', icon: TPIcons.notebook, activeIcon: TPIconsFill.notebook),
];

/// flutter_test draws shadows as solid shapes by default. Render them for real
/// for the screenshot, then restore the flag before the test ends.
Future<void> _expectGolden(String path) async {
  debugDisableShadows = false;
  try {
    await expectLater(find.byType(MaterialApp), matchesGoldenFile(path));
  } finally {
    debugDisableShadows = true;
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final entry in _screens.entries) {
    for (final dark in [false, true]) {
      final name = '${entry.key}_${dark ? 'dark' : 'light'}';
      testWidgets(name, (tester) async {
        // iPhone 15-ish viewport, tall enough to show the whole screen.
        final height = entry.key == 'trips' || entry.key == 'plan' ? 1000.0 : 1900.0;
        tester.view.physicalSize = Size(390 * 2, height * 2);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: dark ? TripamiTheme.dark() : TripamiTheme.light(),
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844), padding: EdgeInsets.only(top: 47, bottom: 34)),
            child: Scaffold(
              body: entry.value.$1,
              bottomNavigationBar: TPTabBar(items: _tabs, currentIndex: entry.value.$2, onTap: (_) {}),
            ),
          ),
        ));

        // Decode the placeholder photos before the screenshot.
        await tester.runAsync(() async {
          final ctx = tester.element(find.byType(Scaffold));
          for (final img in [lisbonPhoto, kyotoPhoto, dinner1, dinner2, dinner3]) {
            await precacheImage(img, ctx);
          }
        });
        await tester.pumpAndSettle();

        await _expectGolden('goldens/$name.png');
      });
    }
  }

  testWidgets('vote sheet', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TripamiTheme.light(),
      home: const Scaffold(body: TripHomeScreen()),
    ));
    await tester.runAsync(() async {
      final ctx = tester.element(find.byType(Scaffold));
      for (final img in [lisbonPhoto, dinner1, dinner2, dinner3]) {
        await precacheImage(img, ctx);
      }
    });
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Change vote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change vote'));
    await tester.pumpAndSettle();
    expect(find.text('4 of 6 voted'.toUpperCase()), findsOneWidget);
    await _expectGolden('goldens/vote_sheet_light.png');
  });
}
