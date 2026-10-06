import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_icons.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
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
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: Semantics(
                    selected: i == currentIndex,
                    button: true,
                    label: items[i].label,
                    excludeSemantics: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
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
          duration: TPMotion.quick,
          curve: TPMotion.ease,
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
                  Icon(active ? item.activeIcon : item.icon, size: 24, color: color),
                  if (item.hasActivity)
                    Positioned(right: -4, top: -2, child: TPActivityDot(urgent: item.urgent)),
                ],
              ),
              const SizedBox(height: 3),
              Text(item.label, style: TPType.caption.copyWith(color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Text tabs with a 2pt accent underline on the active tab and a hairline
/// under the row: Upcoming · Planning · Past.
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
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
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
                            duration: TPMotion.quick,
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: TPMotion.quick,
          curve: TPMotion.ease,
          height: TPSize.chip,
          padding: EdgeInsets.only(left: count != null ? TPSpace.s1 + 2 : TPSpace.s3 + 2, right: TPSpace.s3 + 2),
          decoration: ShapeDecoration(
            color: selected ? c.accentSubtle : c.surface,
            shape: StadiumBorder(side: BorderSide(color: selected ? c.accent : c.borderStrong)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count != null) ...[
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.actionPrimary, shape: BoxShape.circle),
                  child: Text('$count', style: TPType.caption.tabular.copyWith(color: c.actionPrimaryText)),
                ),
                const SizedBox(width: TPSpace.s2),
              ] else if (selected) ...[
                Icon(TPIcons.check, size: 16, color: fg),
                const SizedBox(width: TPSpace.s1 + 2),
              ],
              Text(label, style: TPType.buttonSmall.copyWith(color: fg)),
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
