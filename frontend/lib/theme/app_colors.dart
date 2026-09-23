import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

/// Every color in the app, resolved for the active theme (Kinetic glass or
/// Classic) and mode (dark or light). Callers never need to know about
/// either setting - `AppColors.signal` etc. always read the right value.
///
/// Kinetic glass: near-black ink, glass panels with hairline borders, and
/// a single cyan signal color. Classic: the original red/orange app look,
/// white shadowed cards and solid red title bars.
class AppColors {
  AppColors._();

  static bool get _isDark => AppSettings.isDarkMode.value;
  static bool get isClassic => AppSettings.themeStyle.value == AppThemeStyle.classic;

  static Color _pick({
    required int kineticDark,
    required int kineticLight,
    required int classicDark,
    required int classicLight,
  }) {
    if (isClassic) return Color(_isDark ? classicDark : classicLight);
    return Color(_isDark ? kineticDark : kineticLight);
  }

  /// Page background.
  static Color get background => _pick(
        kineticDark: 0xFF060A12,
        kineticLight: 0xFFF4F6F9,
        classicDark: 0xFF121212,
        classicLight: 0xFFF4F5F7,
      );

  /// Panel surface (cards, forms, result blocks).
  static Color get surface => _pick(
        kineticDark: 0xFF0A111D,
        kineticLight: 0xFFFFFFFF,
        classicDark: 0xFF1E1E1E,
        classicLight: 0xFFFFFFFF,
      );

  /// Recessed surface: inputs, assistant bubbles, table headers.
  static Color get surfaceSunken => _pick(
        kineticDark: 0xFF0C1523,
        kineticLight: 0xFFF0F3F7,
        classicDark: 0xFF262628,
        classicLight: 0xFFF7F7F8,
      );

  /// Hairline border / divider color.
  static Color get line => _pick(
        kineticDark: 0xFF1C2735,
        kineticLight: 0xFFDDE3EA,
        classicDark: 0xFF3A3A3E,
        classicLight: 0xFFE5E7EB,
      );

  /// The accent: cyan in Kinetic glass, the original brand red in Classic.
  static Color get signal => _pick(
        kineticDark: 0xFF00D3E3,
        kineticLight: 0xFF0891A6,
        classicDark: 0xFFE53935,
        classicLight: 0xFFC62828,
      );

  /// Text/icons sitting on a solid signal fill.
  static Color get onSignal =>
      (!isClassic && _isDark) ? const Color(0xFF041016) : Colors.white;

  /// Signal tint for pills, tags, and the user chat bubble.
  static Color get signalSoft => signal.withValues(alpha: _isDark ? 0.12 : 0.10);

  /// Signal ring around tinted elements.
  static Color get signalRing => signal.withValues(alpha: 0.28);

  /// Primary heading/body text.
  static Color get text => _pick(
        kineticDark: 0xFFF1F5F9,
        kineticLight: 0xFF0B1220,
        classicDark: 0xFFF3F4F6,
        classicLight: 0xFF1F2937,
      );

  /// Secondary text.
  static Color get muted => _pick(
        kineticDark: 0xFF94A0B2,
        kineticLight: 0xFF526071,
        classicDark: 0xFF9CA3AF,
        classicLight: 0xFF6B7280,
      );

  /// Labels and the quietest text.
  static Color get faint => _pick(
        kineticDark: 0xFF5E6B7D,
        kineticLight: 0xFF8391A2,
        classicDark: 0xFF8A8F98,
        classicLight: 0xFF8A919C,
      );

  static Color get success => _pick(
        kineticDark: 0xFF34D399,
        kineticLight: 0xFF15803D,
        classicDark: 0xFF66BB6A,
        classicLight: 0xFF2E7D32,
      );

  static Color get warning => _pick(
        kineticDark: 0xFFFBBF24,
        kineticLight: 0xFFB45309,
        classicDark: 0xFFFFA726,
        classicLight: 0xFFEF6C00,
      );

  static Color get danger => _pick(
        kineticDark: 0xFFF87171,
        kineticLight: 0xFFB91C1C,
        classicDark: 0xFFEF5350,
        classicLight: 0xFFC62828,
      );

  /// Color for a passing check. Kinetic glass uses its signal color;
  /// Classic's signal is red, so a pass there has to be green instead.
  static Color get pass => isClassic ? success : signal;

  /// Backdrop behind the centered app frame on wide screens (see
  /// main.dart) - a shade off the page so the frame still reads as framed.
  static Color get backdrop => _pick(
        kineticDark: 0xFF03060B,
        kineticLight: 0xFFE4E9EF,
        classicDark: 0xFF000000,
        classicLight: 0xFFE5E7EB,
      );
}
