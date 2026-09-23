import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static bool get _classic => AppColors.isClassic;

  /// Body font. Classic keeps the platform default (Roboto), exactly as
  /// the original app did.
  static String? get sans => _classic ? null : 'Inter';

  /// Numbers and labels. Classic has no mono type, so it falls back to
  /// the body font.
  static String? get mono => _classic ? null : 'JetBrainsMono';

  /// Small uppercase label, e.g. "(A) CALCULATORS" or "VOLTAGE DROP".
  static TextStyle monoLabel({Color? color, double size = 11}) => TextStyle(
        fontFamily: mono,
        fontSize: size,
        letterSpacing: _classic ? 0.4 : 0.6,
        fontWeight: _classic ? FontWeight.w600 : FontWeight.w400,
        color: color ?? AppColors.faint,
      );

  /// The surface every card, form, and result block is drawn on: a
  /// hairline-bordered glass panel in Kinetic glass, a white card with a
  /// soft drop shadow in Classic.
  static BoxDecoration panel({Color? color, double radius = 16, Color? borderColor}) {
    if (_classic) {
      return BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius + 4),
        border: borderColor == null ? null : Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.line),
    );
  }

  /// Built on demand (not cached) because AppColors reads the persisted
  /// theme and dark-mode settings - main.dart rebuilds MaterialApp when
  /// either one flips.
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final classic = _classic;
    final radius = BorderRadius.circular(classic ? 16 : 12);
    OutlineInputBorder outline(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    final buttonShape = classic
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        : const StadiumBorder();

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: sans,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.line,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.signal,
        onPrimary: AppColors.onSignal,
        secondary: classic ? const Color(0xFFFF9800) : AppColors.signal,
        onSecondary: AppColors.onSignal,
        error: AppColors.danger,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.line,
        outlineVariant: AppColors.line,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: sans,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: classic
          ? AppBarTheme(
              backgroundColor: AppColors.signal,
              foregroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
          : AppBarTheme(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              foregroundColor: AppColors.text,
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              titleTextStyle: TextStyle(
                fontFamily: sans,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              shape: Border(bottom: BorderSide(color: AppColors.line)),
            ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, classic ? 56 : 52),
          backgroundColor: AppColors.signal,
          foregroundColor: AppColors.onSignal,
          disabledBackgroundColor: AppColors.signal.withValues(alpha: 0.35),
          disabledForegroundColor: AppColors.onSignal,
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: classic ? 16 : 15,
            fontWeight: classic ? FontWeight.bold : FontWeight.w600,
          ),
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, classic ? 56 : 52),
          foregroundColor: classic ? AppColors.signal : AppColors.text,
          backgroundColor: classic ? AppColors.surface : AppColors.surface.withValues(alpha: 0.4),
          side: BorderSide(color: classic ? AppColors.signal : AppColors.line),
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: classic ? 16 : 15,
            fontWeight: classic ? FontWeight.bold : FontWeight.w500,
          ),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.signal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: classic ? AppColors.surface : AppColors.surfaceSunken,
        hintStyle: TextStyle(color: AppColors.faint),
        labelStyle: TextStyle(color: AppColors.muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: outline(AppColors.line),
        enabledBorder: outline(AppColors.line),
        focusedBorder: outline(AppColors.signal, 1.4),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: classic ? 3 : 0,
        shadowColor: classic ? Colors.black26 : null,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: classic ? BorderSide.none : BorderSide(color: AppColors.line),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.signal,
        textColor: AppColors.text,
        subtitleTextStyle: TextStyle(fontFamily: sans, fontSize: 13, color: AppColors.muted),
      ),
      switchTheme: classic
          ? null
          : SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? AppColors.onSignal : AppColors.muted,
              ),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? AppColors.signal : AppColors.surfaceSunken,
              ),
              trackOutlineColor: WidgetStatePropertyAll(AppColors.line),
            ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSunken,
        side: BorderSide(color: AppColors.line),
        labelStyle: TextStyle(fontFamily: mono, fontSize: 12, color: AppColors.text),
        shape: const StadiumBorder(),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: classic ? Colors.white : AppColors.signal,
        unselectedLabelColor: classic ? Colors.white70 : AppColors.muted,
        indicatorColor: classic ? Colors.white : AppColors.signal,
        dividerColor: classic ? Colors.transparent : AppColors.line,
        labelStyle: TextStyle(fontFamily: sans, fontWeight: FontWeight.w600),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: classic ? BorderSide.none : BorderSide(color: AppColors.line),
        ),
        titleTextStyle: TextStyle(
          fontFamily: sans,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
        contentTextStyle: TextStyle(fontFamily: sans, fontSize: 14, color: AppColors.muted, height: 1.45),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.signalSoft,
          selectedForegroundColor: AppColors.signal,
          foregroundColor: AppColors.muted,
          side: BorderSide(color: AppColors.line),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.signal,
        linearTrackColor: AppColors.line,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.line),
        ),
        textStyle: TextStyle(fontFamily: sans, fontSize: 12, color: AppColors.text),
      ),
    );
  }
}
