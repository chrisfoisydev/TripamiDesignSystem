// The Tripami component catalog.
//
//   cd widgetbook
//   flutter run                 # on a phone: feel the haptics, test VoiceOver
//   flutter run -d chrome       # in a browser
import 'package:accessibility_tools/accessibility_tools.dart';
import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';
import 'package:widgetbook/widgetbook.dart';

import 'addons.dart';
import 'components.dart';
import 'foundations.dart';

void main() => runApp(const TripamiCatalog());

/// Every page in the catalog, for tests and deep links.
List<WidgetbookNode> catalogDirectories() => [foundations(), components()];

class TripamiCatalog extends StatelessWidget {
  const TripamiCatalog({super.key, this.initialRoute = '/'});

  /// e.g. `/?path=components/planning/tppollcard/votes-come-in`
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      initialRoute: initialRoute,
      directories: catalogDirectories(),
      home: const _Home(),
      addons: [
        MaterialThemeAddon(themes: [
          WidgetbookTheme(name: 'Light', data: TripamiTheme.light()),
          WidgetbookTheme(name: 'Dark', data: TripamiTheme.dark()),
          WidgetbookTheme(name: 'High contrast light', data: TripamiTheme.highContrastLight()),
          WidgetbookTheme(name: 'High contrast dark', data: TripamiTheme.highContrastDark()),
        ]),
        TextScaleAddon(min: 1, max: 3.1, divisions: 21),
        OsSettingsAddon(),
        ViewportAddon([Viewports.none, IosViewports.iPhone13, IosViewports.iPhoneSE, IosViewports.iPadAir4, AndroidViewports.samsungGalaxyS20]),
        // ignore: experimental_member_use
        SemanticsAddon(),
        BuilderAddon(name: 'Accessibility checker', builder: (context, child) => AccessibilityTools(child: child)),
        CanvasAddon(),
        InspectorAddon(),
      ],
    );
  }
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final c = TPColors.light;
    return Theme(
      data: TripamiTheme.light(),
      child: ColoredBox(
        color: c.canvas,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(TPSpace.s8),
              children: [
                Text('Tripami', style: TPType.display.copyWith(color: c.textPrimary)),
                const SizedBox(height: TPSpace.s3),
                Text(
                  'Every component and foundation, live. Pick one on the left, then use the panel on the right: '
                  'theme (light, dark, high contrast), text size up to 310%, phone settings (Bold Text, Reduce Motion, Vibration), '
                  'device, the screen-reader view and the accessibility checker.',
                  style: TPType.body.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: TPSpace.s5),
                Text(
                  'Haptics only play on a real phone: run this catalog with `flutter run` from the widgetbook folder.',
                  style: TPType.callout.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
