import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;

  const AppScaffold({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1100,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg - 4, AppSpacing.md, AppSpacing.lg - 4, AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
