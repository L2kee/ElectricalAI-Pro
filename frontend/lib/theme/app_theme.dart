import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static bool get _classic => AppColors.isClassic;

  /// Body, UI, and number font. Classic keeps the platform default
  /// (Roboto), exactly as the original app did.
  ///
  /// The site sets everything in Cormorant Garamond. The app deliberately
  /// doesn't for body copy and numbers (Moe approved 2026-11-17): a thin
  /// display serif at small sizes, read on a phone outside, is how 2.04
  /// gets misread as 2.84. Cormorant carries the headings and wordmark.
  static String? get sans => _classic ? null : 'Inter';

  /// Headings and the wordmark: the site's Cormorant Garamond.
  static String? get display => _classic ? null : 'CormorantGaramond';

  /// Numbers and labels. Inter with tabular figures, so columns of values
  /// line up the way the old monospace did.
  static String? get mono => sans;

  /// Fixed-width digits for any value a user compares down a column.
  static const List<FontFeature> numeric = [FontFeature.tabularFigures()];

  /// Small uppercase label, e.g. "(A) CALCULATORS" or "VOLTAGE DROP".
  static TextStyle monoLabel({Color? color, double size = 11}) => TextStyle(
        fontFamily: mono,
        fontSize: size,
        letterSpacing: _classic ? 0.4 : 1.1,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.faint,
      );

  /// Heading style. Cormorant's lowercase is short (x height .39), so the
  /// brand theme sets it 12% bigger, the same as the site's
  /// font-size-adjust.
  static TextStyle heading({required double size, Color? color, double height = 1.1}) {
    if (_classic) {
      return TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: height,
        color: color ?? AppColors.text,
      );
    }
    return TextStyle(
      fontFamily: display,
      // Lining figures, like the site's font-variant-numeric: Cormorant's
      // default old style digits made "11" read as "II".
      fontFeatures: const [FontFeature.liningFigures()],
      fontSize: size * 1.12,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: height,
      color: color ?? AppColors.text,
    );
  }

  /// The site's faceted shape (the nav highlight's 10px cut corners, top
  /// left and bottom right). Used for small tiles and tags.
  static ShapeBorder facet({double cut = 10, BorderSide side = BorderSide.none}) {
    if (_classic) {
      return RoundedRectangleBorder(borderRadius: BorderRadius.circular(cut), side: side);
    }
    return BeveledRectangleBorder(
      side: side,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(cut),
        bottomRight: Radius.circular(cut),
      ),
    );
  }

  /// The surface every card, form, and result block is drawn on: a
  /// hairline-bordered glass panel in EVOGENCY, a white card with a
  /// soft drop shadow in Classic.
  static BoxDecoration panel({Color? color, double radius = 16, Color? borderColor, double borderWidth = 1}) {
    if (_classic) {
      return BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius + 4),
        border: borderColor == null ? null : Border.all(color: borderColor, width: borderWidth),
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
      border: Border.all(color: borderColor ?? AppColors.line, width: borderWidth),
    );
  }

  /// Built on demand (not cached) because AppColors reads the persisted
  /// theme and dark-mode settings - main.dart rebuilds MaterialApp when
  /// either one flips.
  static ThemeData get lightTheme => _build(Brightness.light);
  static ThemeData get darkTheme => _build(Brightness.dark);

  /// A visible keyboard focus ring for buttons (the Material default is a
  /// faint overlay tint that disappears on black).
  static WidgetStateProperty<BorderSide?> _focusSide(BorderSide normal) =>
      WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.focused)
            ? BorderSide(color: _classic ? AppColors.text : AppColors.focus, width: 2.5)
            : normal,
      );

  static ThemeData _build(Brightness brightness) {
    final classic = _classic;
    final radius = BorderRadius.circular(classic ? 16 : 12);
    OutlineInputBorder outline(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );
    final OutlinedBorder buttonShape = classic
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        : const StadiumBorder();
    final focusTint = AppColors.focus.withValues(alpha: 0.22);

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: sans,
      // Desktop browsers default to compact density and shrink-wrapped tap
      // targets. WCAG 2.2 asks for 24px; we hold every control to 48px.
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );

    // The brand's primary button: the site's .btn-solid gradient pill.
    Widget gradientBackground(BuildContext context, Set<WidgetState> states, Widget? child) {
      final disabled = states.contains(WidgetState.disabled);
      return DecoratedBox(
        decoration: ShapeDecoration(
          shape: buttonShape,
          gradient: AppColors.signalGradient,
        ),
        child: Opacity(opacity: disabled ? 0.55 : 1, child: child),
      );
    }

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.line,
      focusColor: focusTint,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.signal,
        onPrimary: AppColors.onSignal,
        secondary: classic ? const Color(0xFFFF9800) : AppColors.signalDeep,
        onSecondary: AppColors.onSignal,
        error: AppColors.danger,
        onError: brightness == Brightness.dark ? Colors.black : Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.text,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.fieldLine,
        outlineVariant: AppColors.line,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: sans,
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: classic
          ? AppBarTheme(
              backgroundColor: AppColors.isClassic && brightness == Brightness.dark
                  ? const Color(0xFFB71C1C)
                  : AppColors.signal,
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
                fontFamily: display,
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
              shape: Border(bottom: BorderSide(color: AppColors.line)),
            ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: Size(0, classic ? 56 : 52),
          backgroundColor: classic ? AppColors.signal : Colors.transparent,
          foregroundColor: AppColors.onSignal,
          disabledBackgroundColor: classic ? AppColors.signal.withValues(alpha: 0.45) : Colors.transparent,
          disabledForegroundColor: AppColors.onSignal,
          shadowColor: classic ? null : AppColors.signal.withValues(alpha: 0.5),
          elevation: 0,
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: classic ? 16 : 15,
            fontWeight: classic ? FontWeight.bold : FontWeight.w600,
          ),
          shape: buttonShape,
        ).copyWith(
          side: _focusSide(BorderSide.none),
          backgroundBuilder: classic ? null : gradientBackground,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size(0, classic ? 56 : 52),
          foregroundColor: classic ? AppColors.signal : AppColors.text,
          backgroundColor: classic ? AppColors.surface : AppColors.surface.withValues(alpha: 0.6),
          textStyle: TextStyle(
            fontFamily: sans,
            fontSize: classic ? 16 : 15,
            fontWeight: classic ? FontWeight.bold : FontWeight.w500,
          ),
          shape: buttonShape,
        ).copyWith(
          side: _focusSide(BorderSide(color: classic ? AppColors.signal : AppColors.fieldLine)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.signal,
          minimumSize: const Size(48, 48),
        ).copyWith(side: _focusSide(BorderSide.none)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: classic ? AppColors.surface : AppColors.surfaceSunken,
        hintStyle: TextStyle(color: AppColors.faint),
        labelStyle: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        floatingLabelStyle: WidgetStateTextStyle.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.error)
                ? AppColors.danger
                : states.contains(WidgetState.focused)
                    ? AppColors.signal
                    : AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        errorStyle: TextStyle(color: AppColors.danger, fontSize: 12.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: outline(AppColors.fieldLine),
        enabledBorder: outline(AppColors.fieldLine),
        focusedBorder: outline(AppColors.focus, 2.5),
        errorBorder: outline(AppColors.danger, 1.5),
        focusedErrorBorder: outline(AppColors.danger, 2.5),
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
      switchTheme: SwitchThemeData(
        thumbColor: classic
            ? null
            : WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? AppColors.onSignal : AppColors.muted,
              ),
        trackColor: classic
            ? null
            : WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected) ? AppColors.signal : AppColors.surfaceSunken,
              ),
        trackOutlineColor: classic ? null : WidgetStatePropertyAll(AppColors.fieldLine),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused) ? AppColors.focus.withValues(alpha: 0.35) : null,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceSunken,
        side: BorderSide(color: AppColors.line),
        labelStyle: TextStyle(fontFamily: mono, fontSize: 13, color: AppColors.text, fontFeatures: numeric),
        shape: const StadiumBorder(),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: classic ? Colors.white : AppColors.signal,
        unselectedLabelColor: classic ? Colors.white : AppColors.muted,
        indicatorColor: classic ? Colors.white : AppColors.signal,
        dividerColor: classic ? Colors.transparent : AppColors.line,
        labelStyle: TextStyle(fontFamily: sans, fontWeight: FontWeight.w600),
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.focused) ? AppColors.focus.withValues(alpha: 0.3) : null,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: classic ? BorderSide.none : BorderSide(color: AppColors.line),
        ),
        titleTextStyle: heading(size: 20),
        contentTextStyle: TextStyle(fontFamily: sans, fontSize: 14, color: AppColors.muted, height: 1.45),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: AppColors.signalSoft,
          selectedForegroundColor: AppColors.signal,
          foregroundColor: AppColors.muted,
          minimumSize: const Size(0, 48),
        ).copyWith(side: _focusSide(BorderSide(color: AppColors.fieldLine))),
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
