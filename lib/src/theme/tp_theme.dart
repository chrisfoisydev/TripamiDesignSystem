import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../foundations/tp_colors.dart';
import '../foundations/tp_layout.dart';
import '../foundations/tp_type.dart';

/// Builds Tripami's [ThemeData].
///
/// ```dart
/// MaterialApp(
///   theme: TripamiTheme.light(),
///   darkTheme: TripamiTheme.dark(),
/// );
/// ```
///
/// Material components are restyled to follow the system: ink pills for
/// primary actions, Lagoon only for selection, underline inputs, sheets with a
/// grabber, and no Material tint or ripple color shifts.
abstract final class TripamiTheme {
  static ThemeData light() => _build(Brightness.light, TPColors.light);
  static ThemeData dark() => _build(Brightness.dark, TPColors.dark);

  static ThemeData _build(Brightness brightness, TPColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.actionPrimary,
      onPrimary: c.actionPrimaryText,
      secondary: c.accent,
      onSecondary: c.onAccent,
      tertiary: c.accent,
      onTertiary: c.onAccent,
      error: c.critical,
      onError: brightness == Brightness.light ? Colors.white : c.canvas,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.canvas,
      surfaceContainerLow: c.canvas,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.raised,
      surfaceContainerHighest: c.sunken,
      outline: c.borderStrong,
      outlineVariant: c.hairline,
      inverseSurface: c.actionPrimary,
      onInverseSurface: c.actionPrimaryText,
      inversePrimary: brightness == Brightness.light
          ? TPColors.dark.accent
          : TPColors.light.accent,
      shadow: const Color(0xFF16171B),
      scrim: c.dim,
      surfaceTint: Colors.transparent,
    );

    final textTheme = TextTheme(
      displaySmall: TPType.display,
      headlineLarge: TPType.title1,
      headlineMedium: TPType.diaryHeading,
      headlineSmall: TPType.title2,
      titleLarge: TPType.title3,
      titleMedium: TPType.body.withWeight(TPType.medium),
      titleSmall: TPType.callout.withWeight(TPType.medium),
      bodyLarge: TPType.body,
      bodyMedium: TPType.callout,
      bodySmall: TPType.footnote,
      labelLarge: TPType.button,
      labelMedium: TPType.buttonSmall,
      labelSmall: TPType.caption,
    ).apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);

    const pill = StadiumBorder();
    WidgetStateProperty<T> all<T>(T v) => WidgetStatePropertyAll<T>(v);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      fontFamily: TPType.ui,
      package: TPType.package,
      scaffoldBackgroundColor: c.canvas,
      canvasColor: c.canvas,
      dividerColor: c.hairline,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      extensions: [c],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      // Platform-native page transitions everywhere.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.canvas,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TPType.body.withWeight(TPType.medium).copyWith(color: c.textPrimary),
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
      ),
      // Primary: ink pill.
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: all(pill),
          minimumSize: all(const Size(TPSize.hitTarget, TPSize.buttonLarge)),
          padding: all(const EdgeInsets.symmetric(horizontal: TPSpace.s6)),
          textStyle: all(TPType.button),
          elevation: all(0),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.disabled)
              ? c.actionPrimaryText.withValues(alpha: 0.6)
              : c.actionPrimaryText),
          backgroundColor: WidgetStateProperty.resolveWith((s) {
            if (s.contains(WidgetState.disabled)) return c.actionPrimary.withValues(alpha: 0.32);
            if (s.contains(WidgetState.pressed)) return c.actionPrimaryPressed;
            return c.actionPrimary;
          }),
          overlayColor: all(Colors.transparent),
          animationDuration: TPMotion.instant,
        ),
      ),
      // Secondary: outline pill.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: all(pill),
          minimumSize: all(const Size(TPSize.hitTarget, TPSize.buttonLarge)),
          padding: all(const EdgeInsets.symmetric(horizontal: TPSpace.s6)),
          textStyle: all(TPType.button),
          foregroundColor: all(c.textPrimary),
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.pressed) ? c.sunken : c.surface),
          side: all(BorderSide(color: c.borderStrong)),
          overlayColor: all(Colors.transparent),
        ),
      ),
      // Tertiary: text + arrow. The arrow is added by TPButton.tertiary.
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: all(const Size(TPSize.hitTarget, TPSize.hitTarget)),
          padding: all(EdgeInsets.zero),
          textStyle: all(TPType.buttonSmall),
          foregroundColor: WidgetStateProperty.resolveWith(
              (s) => s.contains(WidgetState.pressed) ? c.textSecondary : c.textPrimary),
          overlayColor: all(Colors.transparent),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: all(c.textPrimary),
          minimumSize: all(const Size.square(TPSize.hitTarget)),
          overlayColor: all(Colors.transparent),
        ),
      ),
      // Underline text fields with uppercase eyebrow labels.
      inputDecorationTheme: InputDecorationTheme(
        floatingLabelBehavior: FloatingLabelBehavior.always,
        labelStyle: TPType.eyebrow.copyWith(color: c.textSecondary),
        floatingLabelStyle: TPType.eyebrow.copyWith(color: c.textSecondary),
        hintStyle: TPType.body.copyWith(color: c.textTertiary),
        helperStyle: TPType.footnote.copyWith(color: c.textSecondary),
        errorStyle: TPType.footnote.copyWith(color: c.critical),
        contentPadding: const EdgeInsets.only(top: TPSpace.s2, bottom: TPSpace.s3),
        border: UnderlineInputBorder(borderSide: BorderSide(color: c.borderStrong)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.borderStrong)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.textPrimary, width: 2)),
        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.critical)),
        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: c.critical, width: 2)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.accent,
        selectionColor: c.accentSubtle,
        selectionHandleColor: c.accent,
      ),
      chipTheme: ChipThemeData(
        shape: StadiumBorder(side: BorderSide(color: c.borderStrong)),
        side: BorderSide(color: c.borderStrong),
        backgroundColor: c.surface,
        selectedColor: c.accentSubtle,
        checkmarkColor: c.accent,
        labelStyle: TPType.buttonSmall.copyWith(color: c.textPrimary),
        secondaryLabelStyle: TPType.buttonSmall.copyWith(color: c.accent),
        padding: const EdgeInsets.symmetric(horizontal: TPSpace.s3),
        showCheckmark: true,
      ),
      // Toggle on-state is ink, not green and not accent.
      switchTheme: SwitchThemeData(
        thumbColor: all(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.actionPrimary : c.borderStrong),
        trackOutlineColor: all(Colors.transparent),
        thumbIcon: all(null),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(TPRadius.xs)),
        fillColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? c.actionPrimary : Colors.transparent),
        checkColor: all(c.actionPrimaryText),
        side: BorderSide(color: c.borderStrong, width: 1.5),
      ),
      radioTheme: RadioThemeData(fillColor: all(c.actionPrimary)),
      dividerTheme: DividerThemeData(color: c.hairline, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        minTileHeight: TPSize.rowMin,
        contentPadding: TPSpace.screen,
        iconColor: c.textPrimary,
        textColor: c.textPrimary,
        titleTextStyle: TPType.body,
        subtitleTextStyle: TPType.footnote.copyWith(color: c.textSecondary),
        leadingAndTrailingTextStyle: TPType.callout.copyWith(color: c.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(TPRadius.md)),
        clipBehavior: Clip.antiAlias,
      ),
      // Every secondary task is a sheet with a grabber.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        modalBarrierColor: c.dim,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: c.borderStrong,
        dragHandleSize: const Size(36, 5),
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(TPRadius.sheet)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        elevation: 0,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(TPRadius.lg)),
        titleTextStyle: TPType.title3.copyWith(color: c.textPrimary),
        contentTextStyle: TPType.callout.copyWith(color: c.textSecondary),
        barrierColor: c.dim,
      ),
      // Toast: ink capsule with inverse text; Undo in the opposite theme's Lagoon.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.actionPrimary,
        contentTextStyle: TPType.callout.copyWith(color: c.actionPrimaryText),
        actionTextColor: scheme.inversePrimary,
        shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(TPRadius.md)),
        elevation: 0,
        insetPadding: const EdgeInsets.fromLTRB(TPSpace.s4, 0, TPSpace.s4, TPSpace.s4),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.textPrimary,
        linearTrackColor: c.hairline,
        circularTrackColor: Colors.transparent,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.actionPrimary,
          borderRadius: BorderRadius.circular(TPRadius.sm),
        ),
        textStyle: TPType.footnote.copyWith(color: c.actionPrimaryText),
      ),
    );
  }
}
