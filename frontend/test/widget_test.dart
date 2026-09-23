import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/main.dart';
import 'package:frontend/settings/app_settings.dart';
import 'package:frontend/theme/app_colors.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppSettings.themeStyle.value = AppThemeStyle.kinetic;
    AppSettings.isDarkMode.value = true;
  });

  testWidgets('ElectricalAI Pro app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectricalAIProApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('ElectricalAI'), findsWidgets);
    expect(find.text('ElectricalAI Pro', findRichText: true), findsOneWidget);
    expect(find.text('Start calculating'), findsOneWidget);
  });

  testWidgets('switching to Classic re-themes the running app', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectricalAIProApp());
    final kineticBackground = AppColors.background;

    await AppSettings.setThemeStyle(AppThemeStyle.classic);
    // Not pumpAndSettle: the home screen's pulse dot animates forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    final context = tester.element(find.text('Start calculating'));
    expect(AppColors.isClassic, isTrue);
    expect(Theme.of(context).scaffoldBackgroundColor, AppColors.background);
    expect(AppColors.background, isNot(kineticBackground));
    expect(Theme.of(context).colorScheme.primary, const Color(0xFFE53935));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('theme_style'), 'classic');
  });

  testWidgets('Settings shows the theme picker', (WidgetTester tester) async {
    await tester.pumpWidget(const ElectricalAIProApp());
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Kinetic glass'), findsOneWidget);
    expect(find.text('Classic'), findsOneWidget);

    await tester.tap(find.text('Classic'));
    await tester.pumpAndSettle();
    expect(AppSettings.themeStyle.value, AppThemeStyle.classic);
  });
}
