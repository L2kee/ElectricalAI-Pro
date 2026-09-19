import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static final ValueNotifier<bool> enableHints = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    enableHints.value = prefs.getBool('enable_hints') ?? true;
    isDarkMode.value = prefs.getBool('dark_mode') ?? false;
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
}
