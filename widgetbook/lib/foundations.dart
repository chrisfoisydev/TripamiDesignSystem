// Foundations: colors, tints and shades, type, space, icons, motion, haptics.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';
import 'package:widgetbook/widgetbook.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

Widget _page(BuildContext context, List<Widget> children) => ListView(
      padding: const EdgeInsets.all(TPSpace.s6),
      children: children,
    );

Widget _heading(BuildContext context, String text, [String? note]) => Padding(
      padding: const EdgeInsets.only(top: TPSpace.s6, bottom: TPSpace.s3),
      child: TPSectionHeader.titled(text, subtitle: note),
    );

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, {this.on});
  final String name;
  final Color color;
  final Color? on;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final ground = on ?? c.canvas;
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(TPRadius.sm), border: Border.all(color: c.hairline)),
          ),
          const SizedBox(height: TPSpace.s1),
          Text(name, style: TPType.footnote.copyWith(color: c.textPrimary)),
          Text('${_hex(color)} · ${_contrast(color, ground).toStringAsFixed(1)}:1', style: TPType.caption.tabular.copyWith(color: c.textSecondary)),
        ],
      ),
    );
  }
}

Widget semanticColors(BuildContext context) {
  final c = TPColors.of(context);
  final groups = {
    'Surfaces': {'canvas': c.canvas, 'surface': c.surface, 'sunken': c.sunken, 'raised': c.raised, 'hairline': c.hairline, 'borderStrong': c.borderStrong},
    'Text': {'textPrimary': c.textPrimary, 'textSecondary': c.textSecondary, 'textTertiary': c.textTertiary, 'textInverse': c.textInverse},
    'Action': {'actionPrimary': c.actionPrimary, 'actionPrimaryPressed': c.actionPrimaryPressed, 'actionPrimaryText': c.actionPrimaryText},
    'Accent (state only)': {'accent': c.accent, 'accentPressed': c.accentPressed, 'accentSubtle': c.accentSubtle, 'onAccent': c.onAccent},
    'Status': {'positive': c.positive, 'caution': c.caution, 'critical': c.critical},
    'Brand': {'brandOrange (logo only)': c.brandOrange},
  };
  return _page(context, [
    Text('Contrast is measured against canvas. Switch the theme (top right) to see dark and high contrast.', style: TPType.callout.copyWith(color: c.textSecondary)),
    for (final g in groups.entries) ...[
      _heading(context, g.key),
      Wrap(spacing: TPSpace.s4, runSpacing: TPSpace.s4, children: [for (final e in g.value.entries) _Swatch(e.key, e.value)]),
    ],
    _heading(context, 'Members', 'In join order: chosen to stay distinct for color-blind travelers'),
    Wrap(spacing: TPSpace.s4, runSpacing: TPSpace.s4, children: [
      for (var i = 0; i < 8; i++)
        _Swatch('${i + 1}. ${TPMemberColor.forJoinIndex(i).name}', TPMemberColor.forJoinIndex(i).color, on: Colors.white),
    ]),
  ]);
}

Widget tintsAndShades(BuildContext context) {
  final c = TPColors.of(context);
  final text = context.knobs.object.dropdown<String>(label: 'Text step', options: [for (final r in TPRamps.all) for (final g in TPRamp.grades) '${r.name}-$g'], initialOption: 'navy-700');
  final bg = context.knobs.object.dropdown<String>(label: 'Background step', options: [for (final r in TPRamps.all) for (final g in TPRamp.grades) '${r.name}-$g'], initialOption: 'orange-100');
  Color resolve(String s) {
    final [name, grade] = s.split('-');
    return TPRamps.all.firstWhere((r) => r.name == name)[int.parse(grade)];
  }

  final fg = resolve(text), back = resolve(bg);
  final gap = (int.parse(text.split('-')[1]) - int.parse(bg.split('-')[1])).abs();
  final ratio = _contrast(fg, back);
  return _page(context, [
    Text(
      'Grade is luminance: two steps ≥500 apart always pass 4.5:1, in any hues. ≥400 → 3:1, ≥650 → 7:1. Pick any pair in the knobs.',
      style: TPType.callout.copyWith(color: c.textSecondary),
    ),
    const SizedBox(height: TPSpace.s4),
    Container(
      padding: const EdgeInsets.all(TPSpace.s5),
      decoration: BoxDecoration(color: back, borderRadius: BorderRadius.circular(TPRadius.md)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lunch at Armando', style: TPType.title3.copyWith(color: fg)),
        Text('You, Sandra + LeAnn · 13:00', style: TPType.callout.copyWith(color: fg)),
      ]),
    ),
    const SizedBox(height: TPSpace.s2),
    Text('${ratio.toStringAsFixed(2)}:1 · grade gap $gap · ${gap >= 650 ? 'AAA text' : gap >= 500 ? 'AA text' : gap >= 400 ? 'large text and icons only' : 'decorative only'}',
        style: TPType.subhead.tabular.copyWith(color: c.textPrimary)),
    const SizedBox(height: TPSpace.s5),
    for (final r in TPRamps.all)
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          SizedBox(width: 72, child: Text(r.name, style: TPType.footnote.copyWith(color: c.textPrimary))),
          for (final g in TPRamp.grades)
            Expanded(
              child: Tooltip(
                message: '${r.name}-$g ${_hex(r[g])}',
                child: Container(height: 32, margin: const EdgeInsets.only(right: 3), decoration: BoxDecoration(color: r[g], borderRadius: BorderRadius.circular(6))),
              ),
            ),
        ]),
      ),
  ]);
}

Widget tones(BuildContext context) {
  final c = TPColors.of(context);
  final ramp = context.knobs.object.dropdown<TPRamp>(label: 'Ramp', options: TPRamps.all, initialOption: TPRamps.green, labelBuilder: (r) => r.name);
  final t = TPTone.of(context, ramp);
  return _page(context, [
    Text('TPTone.of(context, TPRamps.${ramp.name}): safe pairings, flipped for dark mode.', style: TPType.callout.copyWith(color: c.textSecondary)),
    const SizedBox(height: TPSpace.s4),
    Container(
      padding: const EdgeInsets.all(TPSpace.s4),
      decoration: BoxDecoration(color: t.subtle, border: Border.all(color: t.border), borderRadius: BorderRadius.circular(TPRadius.md)),
      child: Row(children: [
        Icon(TPIcons.checkCircle, color: t.text),
        const SizedBox(width: TPSpace.s3),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Settled with Maya', style: TPType.body.withWeight(TPType.medium).copyWith(color: t.text)),
            Text('You’re all square for Lisbon.', style: TPType.footnote.copyWith(color: t.text)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: ShapeDecoration(color: t.solid, shape: const StadiumBorder()),
          child: Text(ramp.name, style: TPType.caption.copyWith(color: t.onSolid)),
        ),
      ]),
    ),
    const SizedBox(height: TPSpace.s5),
    Wrap(spacing: TPSpace.s4, runSpacing: TPSpace.s4, children: [
      _Swatch('subtle', t.subtle),
      _Swatch('muted', t.muted),
      _Swatch('border', t.border),
      _Swatch('text', t.text),
      _Swatch('solid', t.solid),
      _Swatch('onSolid on solid', t.onSolid, on: t.solid),
    ]),
  ]);
}

Widget typography(BuildContext context) {
  final c = TPColors.of(context);
  final sample = context.knobs.string(label: 'Sample', initialValue: 'Lisbon with the crew');
  final styles = {
    'display': TPType.display,
    'diaryHeading': TPType.diaryHeading,
    'diaryBody': TPType.diaryBody,
    'diaryQuote': TPType.diaryQuote,
    'title1': TPType.title1,
    'title2': TPType.title2,
    'title3': TPType.title3,
    'body': TPType.body,
    'callout': TPType.callout,
    'subhead': TPType.subhead,
    'footnote': TPType.footnote,
    'eyebrow': TPType.eyebrow,
    'caption': TPType.caption,
    'button': TPType.button,
    'buttonSmall': TPType.buttonSmall,
  };
  return _page(context, [
    for (final e in styles.entries)
      Padding(
        padding: const EdgeInsets.only(bottom: TPSpace.s4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('TPType.${e.key} · ${e.value.fontSize!.round()}/${(e.value.fontSize! * e.value.height!).round()}',
              style: TPType.caption.copyWith(color: c.textSecondary)),
          Text(e.key == 'eyebrow' ? sample.toUpperCase() : sample, style: e.value.copyWith(color: c.textPrimary)),
        ]),
      ),
  ]);
}

Widget spaceAndShape(BuildContext context) {
  final c = TPColors.of(context);
  const space = {'s1': TPSpace.s1, 's2': TPSpace.s2, 's3': TPSpace.s3, 's4': TPSpace.s4, 's5': TPSpace.s5, 's6': TPSpace.s6, 's8': TPSpace.s8, 's10': TPSpace.s10, 's12': TPSpace.s12, 's16': TPSpace.s16};
  const radius = {'xs': TPRadius.xs, 'sm': TPRadius.sm, 'md': TPRadius.md, 'lg': TPRadius.lg, 'sheet': TPRadius.sheet};
  return _page(context, [
    _heading(context, 'Spacing', '4pt grid · screen margin TPSpace.margin (24)'),
    for (final e in space.entries)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          SizedBox(width: 90, child: Text('TPSpace.${e.key}', style: TPType.footnote.copyWith(color: c.textSecondary))),
          Container(width: e.value, height: 16, color: TPRamps.orange[300]),
          const SizedBox(width: 8),
          Text('${e.value.round()}', style: TPType.footnote.tabular.copyWith(color: c.textPrimary)),
        ]),
      ),
    _heading(context, 'Radius'),
    Wrap(spacing: TPSpace.s4, runSpacing: TPSpace.s4, children: [
      for (final e in radius.entries)
        Column(children: [
          Container(width: 88, height: 88, decoration: BoxDecoration(color: c.surface, border: Border.all(color: c.borderStrong), borderRadius: BorderRadius.circular(e.value))),
          Text('${e.key} · ${e.value.round()}', style: TPType.footnote.copyWith(color: c.textSecondary)),
        ]),
    ]),
    _heading(context, 'Elevation'),
    Wrap(spacing: TPSpace.s6, children: [
      for (final (name, floating) in [('card', false), ('floating', true)])
        Container(
          width: 140,
          height: 88,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(TPRadius.md), boxShadow: TPElevation.of(Theme.of(context).brightness, floating: floating)),
          child: Text(name, style: TPType.footnote.copyWith(color: c.textSecondary)),
        ),
    ]),
  ]);
}

Widget icons(BuildContext context) {
  final c = TPColors.of(context);
  final fill = context.knobs.boolean(label: 'Fill (active / toggled only)');
  const names = {
    'house': (TPIcons.house, TPIconsFill.house),
    'suitcase': (TPIcons.suitcase, TPIconsFill.suitcase),
    'calendarBlank': (TPIcons.calendarBlank, TPIconsFill.calendarBlank),
    'chatsCircle': (TPIcons.chatsCircle, TPIconsFill.chatsCircle),
    'notebook': (TPIcons.notebook, TPIconsFill.notebook),
    'userCircle': (TPIcons.userCircle, TPIconsFill.userCircle),
    'mapPin': (TPIcons.mapPin, TPIconsFill.mapPin),
    'mapTrifold': (TPIcons.mapTrifold, TPIconsFill.mapTrifold),
    'forkKnife': (TPIcons.forkKnife, TPIconsFill.forkKnife),
    'receipt': (TPIcons.receipt, TPIconsFill.receipt),
    'heart': (TPIcons.heart, TPIconsFill.heart),
    'checkCircle': (TPIcons.checkCircle, TPIconsFill.checkCircle),
    'userPlus': (TPIcons.userPlus, TPIconsFill.userPlus),
    'images': (TPIcons.images, TPIconsFill.images),
    'clock': (TPIcons.clock, TPIconsFill.clock),
    'gearSix': (TPIcons.gearSix, TPIconsFill.gearSix),
  };
  return _page(context, [
    Wrap(spacing: TPSpace.s4, runSpacing: TPSpace.s4, children: [
      for (final e in names.entries)
        SizedBox(
          width: 96,
          child: Column(children: [
            Icon(fill ? e.value.$2 : e.value.$1, size: 28, color: c.textPrimary),
            const SizedBox(height: 4),
            Text(e.key, style: TPType.caption.copyWith(color: c.textSecondary), textAlign: TextAlign.center),
          ]),
        ),
    ]),
  ]);
}

class _Replay extends StatefulWidget {
  const _Replay({required this.builder});
  final WidgetBuilder builder;
  @override
  State<_Replay> createState() => _ReplayState();
}

class _ReplayState extends State<_Replay> {
  int _n = 0;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TPButton.secondary(label: 'Replay', small: true, onPressed: () => setState(() => _n++)),
        const SizedBox(height: TPSpace.s4),
        KeyedSubtree(key: ValueKey(_n), child: widget.builder(context)),
      ]);
}

Widget motion(BuildContext context) {
  final c = TPColors.of(context);
  final amount = context.knobs.double.slider(label: 'CountUp value', initialValue: 214.5, min: 0, max: 500);
  return _page(context, [
    Text('Calm by default; playful only when people come together. Turn on Reduce Motion in Phone settings to see the fallbacks.', style: TPType.callout.copyWith(color: c.textSecondary)),
    _heading(context, 'People moments (playful spring)'),
    _Replay(builder: (_) => Row(children: [
          const TPPop(child: TPActivityDot(urgent: true)),
          const SizedBox(width: TPSpace.s6),
          const TPSuccessCheck(haptic: false),
          const SizedBox(width: TPSpace.s6),
          TPBrandDot(size: 24, delay: Duration.zero),
        ])),
    _heading(context, 'Everyday entrances (Rise, staggered)'),
    _Replay(builder: (_) => Column(children: [
          for (var i = 0; i < 4; i++) TPRise(index: i, child: TPListRow(label: ['Pastéis at Manteigaria', 'Tram 28 to Graça', 'Miradouro da Senhora do Monte', 'Dinner at Taberna da Rua'][i], showDivider: i < 3)),
        ])),
    _heading(context, 'Numbers (CountUp)', 'Drag the knob'),
    TPCountUp(value: amount, format: (v) => '€${v.toStringAsFixed(2)}', style: TPType.title1.copyWith(color: c.textPrimary)),
  ]);
}

Widget haptics(BuildContext context) {
  final c = TPColors.of(context);
  const rows = [
    ('select', 'Selection tick', 'Tab, chip, toggle, option', TPHaptics.select),
    ('join', 'Light tap', 'Vote, react, primary button', TPHaptics.join),
    ('reorder', 'Medium tap', 'Pick up or drop a plan', TPHaptics.reorder),
    ('success', 'Firm, then light', 'Everyone’s in', TPHaptics.success),
    ('warning', 'Heavy tap', 'Something refused', TPHaptics.warning),
  ];
  return _page(context, [
    TPCard(
      child: Text(
        'Run the catalog on a phone to feel these (`flutter run` in widgetbook/). Browsers and simulators don\'t vibrate. Turn Vibration off in Phone settings to check the off state.',
        style: TPType.callout.copyWith(color: c.textSecondary),
      ),
    ),
    const SizedBox(height: TPSpace.s4),
    for (final (i, (name, feel, use, play)) in rows.indexed)
      TPListRow(label: name, detail: '$feel · $use', showChevron: false, showDivider: i < rows.length - 1, trailing: TPButton.secondary(label: 'Try', small: true, onPressed: play)),
  ]);
}

WidgetbookCategory foundations() => WidgetbookCategory(name: 'Foundations', children: [
      WidgetbookComponent(name: 'Colors', useCases: [WidgetbookUseCase(name: 'Semantic', builder: semanticColors)]),
      WidgetbookComponent(name: 'Tints and shades', useCases: [WidgetbookUseCase(name: 'Ramps', builder: tintsAndShades)]),
      WidgetbookComponent(name: 'Tones', useCases: [WidgetbookUseCase(name: 'Roles', builder: tones)]),
      WidgetbookComponent(name: 'Typography', useCases: [WidgetbookUseCase(name: 'Scale', builder: typography)]),
      WidgetbookComponent(name: 'Space and shape', useCases: [WidgetbookUseCase(name: 'Tokens', builder: spaceAndShape)]),
      WidgetbookComponent(name: 'Icons', useCases: [WidgetbookUseCase(name: 'Set', builder: icons)]),
      WidgetbookComponent(name: 'Motion', useCases: [WidgetbookUseCase(name: 'Playground', builder: motion)]),
      WidgetbookComponent(name: 'Haptics', useCases: [WidgetbookUseCase(name: 'Playground', builder: haptics)]),
    ]);
