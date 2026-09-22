import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class QuickActionCard extends StatelessWidget {

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final double? width;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.width = 92,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(

      borderRadius: BorderRadius.circular(18),

      onTap: onTap,

      child: Container(

        width: width,
        padding: const EdgeInsets.all(14),

        decoration: BoxDecoration(

          color: AppColors.surface,

          borderRadius: BorderRadius.circular(18),

          boxShadow: const [

            BoxShadow(

              blurRadius: 8,

              color: Colors.black12,

              offset: Offset(0,3),

            ),

          ],

        ),

        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Icon(
                icon,
                color: Colors.red,
                size: 34,
              ),

              const SizedBox(height:12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.dark,
                ),
              ),

            ],

          ),
        ),

      ),

    );

  }

}