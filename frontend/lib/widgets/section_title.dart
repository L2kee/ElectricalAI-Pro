import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// Section header in the site's editorial style: a small signal-colored
/// eyebrow ("(A) CALCULATORS") over a Cormorant heading, with an optional
/// note on the right ("11 modules").
///
/// The heading is a heading for screen readers. The eyebrow is decoration
/// (the heading already says what the section is), so it's left out.
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
              ExcludeSemantics(child: MonoLabel(eyebrow, color: AppColors.signal)),
              const SizedBox(height: 10),
              Semantics(
                header: true,
                headingLevel: 2,
                child: Text(text, style: AppTheme.heading(size: 27, height: 1.12)),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              trailing!,
              style: TextStyle(fontFamily: AppTheme.mono, fontSize: 12.5, color: AppColors.faint),
            ),
          ),
        ],
      ],
    );
  }
}
