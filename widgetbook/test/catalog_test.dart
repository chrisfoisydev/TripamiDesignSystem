// Opens every page of the catalog and checks it renders without errors.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_widgetbook/main.dart';
import 'package:widgetbook/widgetbook.dart';

Iterable<String> paths(List<WidgetbookNode> nodes, [String prefix = '']) sync* {
  for (final n in nodes) {
    final p = '$prefix${prefix.isEmpty ? '' : '/'}${n.name.replaceAll(' ', '-').toLowerCase()}';
    if (n is WidgetbookUseCase) {
      yield p;
    } else {
      yield* paths(n.children ?? const [], p);
    }
  }
}

void main() {
  final all = paths(catalogDirectories()).toList();

  test('the catalog covers foundations and every component group', () {
    expect(all.length, greaterThan(35));
    for (final group in ['today', 'actions', 'navigation', 'containers', 'people', 'planning', 'braid', 'text']) {
      expect(all.any((p) => p.startsWith('components/$group/')), isTrue, reason: group);
    }
  });

  for (final path in all) {
    testWidgets('renders $path', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(TripamiCatalog(initialRoute: '/?path=$path'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(find.text('Tripami'), findsNothing, reason: 'should show the page, not the home screen');
    });
  }
}
