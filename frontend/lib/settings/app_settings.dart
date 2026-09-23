import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The two visual themes. Both share the same screens; a theme only
/// changes colors, type, and how surfaces are drawn.
enum AppThemeStyle {
  kinetic('Kinetic glass'),
  classic('Classic');

  const AppThemeStyle(this.label);
  final String label;
}

class AppSettings {
  AppSettings._();

  static final ValueNotifier<bool> enableHints = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);
  static final ValueNotifier<AppThemeStyle> themeStyle =
      ValueNotifier<AppThemeStyle>(AppThemeStyle.kinetic);

  /// Fires when anything that affects the look changes.
  static final Listenable appearance = Listenable.merge([isDarkMode, themeStyle]);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    enableHints.value = prefs.getBool('enable_hints') ?? true;
    // Dark is the design's home look; light stays one toggle away.
    isDarkMode.value = prefs.getBool('dark_mode') ?? true;
    themeStyle.value = AppThemeStyle.values.firstWhere(
      (style) => style.name == prefs.getString('theme_style'),
      orElse: () => AppThemeStyle.kinetic,
    );
  }

  static Future<void> setEnableHints(bool value) async {
    enableHints.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_hints', value);
  }

  static Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }

  static Future<void> setThemeStyle(AppThemeStyle value) async {
    themeStyle.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_style', value.name);
  }
}
