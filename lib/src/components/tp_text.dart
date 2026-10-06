import 'package:flutter/material.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';
import 'tp_actions.dart';

/// Small uppercase, letter-spaced section label: "NEEDS YOUR VOTE".
class TPEyebrow extends StatelessWidget {
  const TPEyebrow(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TPType.eyebrow.copyWith(color: color ?? TPColors.of(context).textSecondary),
    );
  }
}

/// Section header. Eyebrow style by default; [TPSectionHeader.titled] for the
/// main sections of a hub screen. Optional trailing "See all →".
class TPSectionHeader extends StatelessWidget {
  const TPSectionHeader.eyebrow(
    this.title, {
    super.key,
    this.actionLabel,
    this.onAction,
  })  : titled = false,
        subtitle = null;

  const TPSectionHeader.titled(
    this.title, {
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  }) : titled = true;

  final String title;
  final String? subtitle;
  final bool titled;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = TPColors.of(context);
    final heading = titled
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TPType.title2.copyWith(color: c.textPrimary)),
              if (subtitle != null) ...[
                const SizedBox(height: TPSpace.s1),
                Text(subtitle!, style: TPType.callout.copyWith(color: c.textSecondary)),
              ],
            ],
          )
        : TPEyebrow(title);

    return Padding(
      padding: EdgeInsets.only(bottom: titled ? TPSpace.s5 : TPSpace.s3),
      child: Row(
        crossAxisAlignment: titled ? CrossAxisAlignment.end : CrossAxisAlignment.center,
        children: [
          Expanded(child: heading),
          if (actionLabel != null) TPButton.tertiary(label: actionLabel!, onPressed: onAction),
        ],
      ),
    );
  }
}
