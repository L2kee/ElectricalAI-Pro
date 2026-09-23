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
/// framed as a centered glass panel instead of a layout stretched thin
/// across a huge, otherwise-empty browser window.
const double _wideScreenBreakpoint = 760;
const double _wideScreenCardWidth = 680;

void _rebuildAll(BuildContext context) {
  if (!context.mounted) return;
  void visit(Element element) {
    element.markNeedsBuild();
    element.visitChildren(visit);
  }
  (context as Element).visitChildren(visit);
}

class ElectricalAIProApp extends StatelessWidget {
  const ElectricalAIProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.appearance,
      builder: (context, _) {
        final isDarkMode = AppSettings.isDarkMode.value;
        final isClassic = AppColors.isClassic;
        // Most widgets read AppColors directly rather than through
        // Theme.of, so a new ThemeData alone wouldn't repaint them. After a
        // theme or mode flip, mark the whole tree dirty so every screen on
        // the stack (Settings included) redraws in place, without losing
        // the navigation stack the way re-keying MaterialApp would.
        WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildAll(context));
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
              color: AppColors.backdrop,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _wideScreenCardWidth),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 32),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: isClassic ? null : Border.all(color: AppColors.line),
                      boxShadow: [
                        if (!isClassic)
                          BoxShadow(
                            color: AppColors.signal.withValues(alpha: isDarkMode ? 0.06 : 0.04),
                            blurRadius: 80,
                            spreadRadius: 4,
                          ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDarkMode ? 0.5 : 0.12),
                          blurRadius: 40,
                          offset: const Offset(0, 16),
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
