// Addons: the OS settings Tripami responds to, so every component can be
// checked the way travelers will actually see it.
import 'package:flutter/material.dart';
import 'package:tripami_design_system/tripami_design_system.dart';
import 'package:widgetbook/widgetbook.dart';

class OsSettings {
  const OsSettings({required this.boldText, required this.reduceMotion, required this.vibration});
  final bool boldText;
  final bool reduceMotion;
  final bool vibration;
}

/// Bold Text, Reduce Motion and Vibration, as set on the phone.
class OsSettingsAddon extends WidgetbookAddon<OsSettings> {
  OsSettingsAddon() : super(name: 'Phone settings');

  @override
  List<Field> get fields => [
        BooleanField(name: 'boldText', initialValue: false),
        BooleanField(name: 'reduceMotion', initialValue: false),
        BooleanField(name: 'vibration', initialValue: true),
      ];

  @override
  OsSettings valueFromQueryGroup(Map<String, String> group) => OsSettings(
        boldText: valueOf<bool>('boldText', group) ?? false,
        reduceMotion: valueOf<bool>('reduceMotion', group) ?? false,
        vibration: valueOf<bool>('vibration', group) ?? true,
      );

  @override
  Widget buildUseCase(BuildContext context, Widget child, OsSettings setting) {
    TPHaptics.enabled = setting.vibration;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(boldText: setting.boldText, disableAnimations: setting.reduceMotion),
      // Below the MediaQuery so the builder sees the Bold Text setting.
      child: Builder(builder: (context) => TripamiTheme.builder(context, child)),
    );
  }
}

/// Paints the canvas color behind every use case and gives it room to breathe.
class CanvasAddon extends BuilderAddon {
  CanvasAddon()
      : super(
          name: 'Canvas',
          builder: (context, child) => ColoredBox(
            color: TPColors.of(context).canvas,
            child: DefaultTextStyle(style: TPType.body.copyWith(color: TPColors.of(context).textPrimary), child: child),
          ),
        );
}
