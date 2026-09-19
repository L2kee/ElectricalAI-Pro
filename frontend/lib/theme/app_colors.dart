import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

/// Values below switch on the persisted dark-mode setting. Callers don't
/// need to know about the setting - `AppColors.primary` etc. always read
/// the correct value for whatever mode is currently active, the same as
/// before this became theme-aware.
class AppColors {
  AppColors._();

  static bool get _isDark => AppSettings.isDarkMode.value;

  static Color get background =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFF4F5F7);

  /// Elevated card/tile surface - white in light mode, a lighter dark
  /// surface (not pure black) in dark mode so cards still read as raised
  /// above the page background.
  static Color get surface =>
      _isDark ? const Color(0xFF1E1E1E) : Colors.white;

  static const primary = Color(0xFFC62828);
  static const accent = Color(0xFFFF9800);

  static Color get success =>
      _isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);

  /// Primary heading/title text.
  static Color get dark =>
      _isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1F2937);

  static const white = Colors.white;

  /// Secondary/muted text.
  static Color get lightText =>
      _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  /// Currently only used as the page backdrop behind the centered app
  /// card on wide screens (see main.dart) - needs to read as visibly
  /// darker than `surface`/`background` in both modes so the card still
  /// looks framed rather than blending into the page.
  static Color get border =>
      _isDark ? const Color(0xFF000000) : const Color(0xFFE5E7EB);
}
