import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  AppSettings._();

  static final ValueNotifier<bool> enableHints = ValueNotifier<bool>(true);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    enableHints.value = prefs.getBool('enable_hints') ?? true;
  }

  static Future<void> setEnableHints(bool value) async {
    enableHints.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_hints', value);
  }
}
