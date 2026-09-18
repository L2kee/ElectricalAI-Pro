import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.enableHints,
      builder: (context, enabled, _) {
        if (!enabled) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: Text(
            compact
                ? 'Planning aid only. Confirm against the codebook, manufacturer data, and the AHJ before you pull wire or pull a permit.'
                : 'ElectricalAI Pro is a planning and learning aid. Verify every result against the applicable electrical code, manufacturer documentation, and the authority having jurisdiction before performing electrical work.',
            style: const TextStyle(fontSize: 13, height: 1.35, color: Color(0xFF5D4037)),
          ),
        );
      },
    );
  }
}
