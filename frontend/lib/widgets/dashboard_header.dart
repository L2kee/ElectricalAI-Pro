import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(
                children: [

                  const Icon(
                    Icons.bolt,
                    color: AppColors.primary,
                    size: 38,
                  ),

                  const SizedBox(width: 10),

                  Flexible(
                    child: Text(
                      "ElectricalAI",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                        letterSpacing: -.5,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "PRO",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Text(
                "Professional Electrical Assistant",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.dark,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Powerful tools.\nSmarter work.\nBuilt for electricians.",
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.lightText,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        Tooltip(
          message: 'Calculators work offline. AI needs the local backend.',
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About this app'),
                  content: const Text(
                    'Calculators work offline. AI needs the local backend.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}