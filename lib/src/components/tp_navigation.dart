import 'package:flutter/material.dart';

import '../foundations/tp_a11y.dart';
import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
import 'tp_motion.dart';
import 'tp_people.dart';

@immutable
class TPTabItem {
  const TPTabItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.hasActivity = false,
    this.urgent = false,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool hasActivity;
  final bool urgent;

  /// Trips · Plan · Chat · Memories · You
  static const defaults = [
    TPTabItem(label: 'Trips', icon: TPIcons.suitcase, activeIcon: TPIconsFill.suitcase),
    TPTabItem(label: 'Plan', icon: TPIcons.calendarBlank, activeIcon: TPIconsFill.calendarBlank),
    TPTabItem(label: 'Chat', icon: TPIcons.chatsCircle, activeIcon: TPIconsFill.chatsCircle),
    TPTabItem(label: 'Memories', icon: TPIcons.notebook, activeIcon: TPIconsFill.notebook),
    TPTabItem(label: 'You', icon: TPIcons.userCircle, activeIcon: TPIconsFill.userCircle),
  ];
}

/// Tab bar with Bonvoy's top-edge indicator, in the accent orange. Outline icons,
/// filled when active. Activity is a dot, never a number.
///
/// Changing tab plays [TPHaptics.select]; the new tab's filled icon settles
/// in on the snappy spring. Tapping the current tab is silent.
class TPTabBar extends StatelessWidget {
  const TPTabBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<TPTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: c.surface, border: Border(top: BorderSide(color: c.hairline))),
      child: SafeArea(
        top: false,
        // Grows with large text instead of clipping; labels cap at 130% (as iOS
        // tab bars do), so five tabs still fit.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: IntrinsicHeight(
            child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == currentIndex,
                    button: true,
                    label: items[i].label +
                        (items[i].hasActivity ? (items[i].urgent ? ', needs you' : ', new activity') : ''),
                    excludeSemantics: true,
                    child: TPPressable(
                      pressedScale: 1,
                      focusShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(TPRadius.sm))),
                      onTap: () {
                        if (i != currentIndex) TPHaptics.select();
                        onTap(i);
                      },
                      child: _TabCell(item: items[i], active: i == currentIndex, colors: c),
                    ),
                  ),
                ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}

class _TabCell extends StatelessWidget {
  const _TabCell({required this.item, required this.active, required this.colors});
  final TPTabItem item;
  final bool active;
  final TPColors colors;

  @override
  Widget build(BuildContext context) {
    final color = active ? colors.textPrimary : colors.textTertiary;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AnimatedContainer(
          duration: TPMotion.snappyDuration,
          curve: TPMotion.snappyCurve,
          width: 32,
          height: 2,
          color: active ? colors.accent : Colors.transparent,
        ),
        Padding(
          padding: const EdgeInsets.only(top: TPSpace.s2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: TPMotion.reduced(context) ? Duration.zero : TPMotion.snappyDuration,
                    switchInCurve: TPMotion.snappyCurve,
                    switchOutCurve: TPMotion.exit,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: ScaleTransition(scale: Tween(begin: 0.8, end: 1.0).animate(a), child: child),
                    ),
                    child: Icon(
                      active ? item.activeIcon : item.icon,
                      key: ValueKey(active),
                      size: 24,
                      color: color,
                    ),
                  ),
                  if (item.hasActivity)
                    Positioned(right: -4, top: -2, child: TPActivityDot(urgent: item.urgent)),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textScaler: TPA11y.capped(context, 1.3),
                style: TPType.caption.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Text tabs with a 2pt accent underline on the active tab and a hairline
/// under the row: Upcoming · Planning · Past. Changing tab plays
/// [TPHaptics.select].
class TPUnderlineTabs extends StatelessWidget {
  const TPUnderlineTabs({super.key, required this.labels, required this.currentIndex, required this.onChanged});

  final List<String> labels;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.hairline))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: TPSpace.screen,
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Padding(
                padding: EdgeInsets.only(right: i == labels.length - 1 ? 0 : TPSpace.s6),
                child: Semantics(
                  selected: i == currentIndex,
                  button: true,
                  child: TPPressable(
                    pressedScale: 1,
                    focusShape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(TPRadius.xs))),
                    onTap: () {
                      if (i != currentIndex) TPHaptics.select();
                      onChanged(i);
                    },
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: TPSize.hitTarget,
                            child: Center(
                              child: Text(
                                labels[i],
                                style: TPType.callout.copyWith(
                                  color: i == currentIndex ? c.textPrimary : c.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          AnimatedContainer(
                            duration: TPMotion.snappyDuration,
                            curve: TPMotion.snappyCurve,
                            height: 2,
                            color: i == currentIndex ? c.accent : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Filter chip. Selected uses the accent (subtle fill, accent border and text).
/// [count] shows an ink badge on the leading edge.
///
/// Tapping plays [TPHaptics.select]. The check grows in on the snappy spring,
/// and the count badge bumps when its number changes.
class TPFilterChip extends StatelessWidget {
  const TPFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
    this.dropdown = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final int? count;
  final bool dropdown;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final fg = selected ? c.accent : c.textPrimary;
    return Semantics(
      selected: selected,
      button: true,
      label: count != null ? '$label, $count' : label,
      excludeSemantics: true,
      child: TPPressable(
        onTap: onTap,
        haptic: TPHaptic.select,
        expandTapTarget: true,
        child: AnimatedContainer(
          duration: TPMotion.snappyDuration,
          curve: TPMotion.snappyCurve,
          constraints: const BoxConstraints(minHeight: TPSize.chip),
          padding: EdgeInsets.only(left: count != null ? TPSpace.s1 + 2 : TPSpace.s3 + 2, right: TPSpace.s3 + 2),
          decoration: ShapeDecoration(
            color: selected ? c.accentSubtle : c.surface,
            shape: StadiumBorder(side: BorderSide(color: selected ? c.accent : c.borderStrong)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count != null) ...[
                TPBump(
                  value: count,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: c.actionPrimary, shape: BoxShape.circle),
                    child: Text('$count', style: TPType.caption.tabular.copyWith(color: c.actionPrimaryText)),
                  ),
                ),
                const SizedBox(width: TPSpace.s2),
              ] else
                AnimatedSize(
                  duration: TPMotion.reduced(context) ? Duration.zero : TPMotion.snappyDuration,
                  curve: TPMotion.snappyCurve,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(right: TPSpace.s1 + 2),
                          // Snappy, not playful: choosing a filter isn't a people moment.
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: TPMotion.reduced(context) ? 1 : 0.5, end: 1),
                            duration: TPMotion.snappyDuration,
                            curve: TPMotion.snappyCurve,
                            builder: (context, v, child) =>
                                Opacity(opacity: ((v - 0.5) * 2).clamp(0, 1), child: Transform.scale(scale: v, child: child)),
                            child: Icon(TPIcons.check, size: 16, color: fg),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              // One line, hugging the label. Only a chip wider than its row
              // (very large text) ellipsizes; the chip's label is in Semantics.
              Flexible(
                child: Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis, style: TPType.buttonSmall.copyWith(color: fg)),
              ),
              if (dropdown) ...[
                const SizedBox(width: TPSpace.s1),
                Icon(TPIcons.caretDown, size: 14, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
