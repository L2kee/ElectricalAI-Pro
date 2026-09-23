import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// Section header in the design's editorial style: a small signal-colored
/// mono eyebrow ("(A) CALCULATORS") over a bold heading, with an optional
/// mono note on the right ("11 modules").
class SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String text;
  final String? trailing;

  const SectionTitle(
    this.text, {
    super.key,
    required this.eyebrow,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoLabel(eyebrow, color: AppColors.signal),
              const SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.15,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(trailing!, style: TextStyle(fontFamily: AppTheme.mono, fontSize: 12, color: AppColors.faint)),
          ),
        ],
      ],
    );
  }
}
