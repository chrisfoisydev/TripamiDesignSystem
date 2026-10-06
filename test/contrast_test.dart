// Every text/background pairing the system allows must pass WCAG 2.1 AA.
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

double _channel(double c) => c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) => 0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final (name, c) in [('light', TPColors.light), ('dark', TPColors.dark)]) {
    group('$name theme', () {
      final text = <String, (Color, Color)>{
        'primary on canvas': (c.textPrimary, c.canvas),
        'primary on sunken': (c.textPrimary, c.sunken),
        'secondary on canvas': (c.textSecondary, c.canvas),
        'secondary on surface': (c.textSecondary, c.surface),
        'secondary on sunken': (c.textSecondary, c.sunken),
        'tertiary on surface': (c.textTertiary, c.surface),
        'tertiary on canvas': (c.textTertiary, c.canvas),
        'accent on surface': (c.accent, c.surface),
        'accent on canvas': (c.accent, c.canvas),
        'accent on accentSubtle': (c.accent, c.accentSubtle),
        'pill text on ink pill': (c.actionPrimaryText, c.actionPrimary),
        'critical on surface': (c.critical, c.surface),
        'caution on surface': (c.caution, c.surface),
        'positive on surface': (c.positive, c.surface),
      };
      text.forEach((label, pair) {
        test('$label ≥ 4.5:1', () {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
        });
      });
    });
  }

  test('white initials pass AA on every member color', () {
    for (final m in TPMemberColor.values) {
      expect(contrast(const Color(0xFFFFFFFF), m.color), greaterThanOrEqualTo(4.5), reason: m.name);
    }
  });

  test('members are assigned in join order and cycle', () {
    expect(TPMemberColor.forJoinIndex(0), TPMemberColor.lagoon);
    expect(TPMemberColor.forJoinIndex(8), TPMemberColor.lagoon);
    expect(TPMemberColor.forJoinIndex(9), TPMemberColor.sky);
  });

  test('initials', () {
    const m = TPMember(id: '1', name: 'Maya  Chen', color: TPMemberColor.lagoon);
    expect(m.initials, 'MC');
    expect(m.firstName, 'Maya');
  });
}
