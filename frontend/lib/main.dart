import 'package:flutter/material.dart';

import 'settings/app_settings.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.load();
  runApp(const ElectricalAIProApp());
}

/// Below this width the app fills the viewport edge to edge, the same as
/// the real Windows desktop build. Above it (a desktop browser tab), every
/// screen - regardless of which internal Scaffold/wrapper it uses - gets
/// framed as a centered card instead of a phone-width layout stretched
/// thin across a huge, otherwise-empty browser window.
const double _wideScreenBreakpoint = 720;
const double _wideScreenCardWidth = 560;

class ElectricalAIProApp extends StatelessWidget {
  const ElectricalAIProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.isDarkMode,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          title: 'ElectricalAI Pro',
          debugShowCheckedModeBanner: false,
          theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
          home: const HomeScreen(),
          builder: (context, child) {
            if (child == null) return const SizedBox.shrink();

            final isWideScreen = MediaQuery.of(context).size.width > _wideScreenBreakpoint;
            if (!isWideScreen) return child;

            return ColoredBox(
              color: AppColors.border,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _wideScreenCardWidth),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
