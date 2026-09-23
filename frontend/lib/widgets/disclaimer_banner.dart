import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../theme/app_colors.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.enableHints,
      builder: (context, enabled, _) {
        if (!enabled) return const SizedBox.shrink();
        final tint = AppColors.warning;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: tint.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: tint.withValues(alpha: 0.22)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, size: 16, color: tint),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  compact
                      ? 'Planning aid only. Confirm against the codebook, manufacturer data, and the AHJ before you pull wire or pull a permit.'
                      : 'ElectricalAI Pro is a planning and learning aid. Verify every result against the applicable electrical code, manufacturer documentation, and the authority having jurisdiction before performing electrical work.',
                  style: TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.muted),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
