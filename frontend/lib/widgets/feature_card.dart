import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: iconColor.withOpacity(.12),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}