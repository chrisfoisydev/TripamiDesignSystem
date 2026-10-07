import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripami_design_system/tripami_design_system.dart';

double contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  final steps = [
    for (final r in TPRamps.all)
      for (final g in TPRamp.grades) (ramp: r.name, grade: g, color: r[g]),
  ];

  test('14 ramps of 11 steps, each lighter to darker', () {
    expect(TPRamps.all, hasLength(14));
    for (final r in TPRamps.all) {
      for (var i = 1; i < 11; i++) {
        expect(r.colors[i].computeLuminance(), lessThan(r.colors[i - 1].computeLuminance()), reason: '${r.name} step $i');
      }
    }
  });

  test('every step sits on its grade, in every hue', () {
    for (final s in steps) {
      expect(TPRamp.gradeOf(s.color), closeTo(s.grade, 6), reason: '${s.ramp}-${s.grade}');
    }
  });

  test('contrast depends only on the grade gap, across all ramps', () {
    var checked = 0;
    for (final a in steps) {
      for (final b in steps) {
        final gap = (a.grade - b.grade).abs();
        if (gap < 400) continue;
        final c = contrast(a.color, b.color);
        final where = '${a.ramp}-${a.grade} vs ${b.ramp}-${b.grade}';
        expect(c, greaterThanOrEqualTo(TPRamp.contrastFor(a.grade, b.grade)), reason: where);
        if (gap >= 400) expect(c, greaterThanOrEqualTo(3), reason: where);
        if (gap >= 500) expect(c, greaterThanOrEqualTo(4.5), reason: where);
        if (gap >= 650) expect(c, greaterThanOrEqualTo(7), reason: where);
        checked++;
      }
    }
    expect(checked, greaterThan(10000));
  });

  test('white text works on every step from 500', () {
    for (final r in TPRamps.all) {
      for (final g in [500, 600, 700, 800, 900, 950]) {
        expect(contrast(Colors.white, r[g]), greaterThanOrEqualTo(4.5), reason: '${r.name}-$g');
      }
    }
  });

  test('tone roles are contrast-safe in both themes and on both canvases', () {
    for (final b in Brightness.values) {
      final canvas = b == Brightness.dark ? TPColors.dark.canvas : TPColors.light.canvas;
      final surface = b == Brightness.dark ? TPColors.dark.surface : TPColors.light.surface;
      for (final r in TPRamps.all) {
        final t = TPTone(r, b);
        final where = '${r.name} ${b.name}';
        for (final bg in [t.subtle, t.muted, canvas, surface]) {
          expect(contrast(t.text, bg), greaterThanOrEqualTo(4.5), reason: '$where text');
        }
        expect(contrast(t.text, t.subtle), greaterThanOrEqualTo(7), reason: '$where text on subtle');
        expect(contrast(t.onSolid, t.solid), greaterThanOrEqualTo(4.5), reason: '$where onSolid');
        expect(contrast(t.onSolid, t.solidPressed), greaterThanOrEqualTo(4.5), reason: '$where onSolid pressed');
      }
    }
  });

  test('each member color has its ramp', () {
    for (final m in TPMemberColor.values) {
      expect(m.ramp.name, m.name);
    }
  });

  test('asking for a step that does not exist fails loudly', () {
    expect(() => TPRamps.orange[550], throwsArgumentError);
  });
}
