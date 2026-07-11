import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/feature_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_title.dart';

import 'ai_screen.dart';
import 'calculators_screen.dart';
import 'material_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),

          const SizedBox(height: 42),

          const SectionTitle("Quick Actions"),

          const SizedBox(height: 20),

          SizedBox(
            height: 125,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                QuickActionCard(
                  icon: Icons.bolt,
                  title: "Ohm's\nLaw",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CalculatorsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),

                QuickActionCard(
                  icon: Icons.electric_bolt,
                  title: "Voltage\nDrop",
                  onTap: () {},
                ),

                const SizedBox(width: 18),

                QuickActionCard(
                  icon: Icons.smart_toy,
                  title: "Ask\nAI",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(width: 18),

                QuickActionCard(
                  icon: Icons.inventory_2,
                  title: "Materials",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MaterialScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 50),

          const SectionTitle("Features"),

          const SizedBox(height: 22),

          FeatureCard(
            icon: Icons.smart_toy,
            iconColor: AppColors.primary,
            title: "AI Assistant",
            subtitle:
                "Ask electrical questions and troubleshoot problems.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AIScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          FeatureCard(
            icon: Icons.calculate,
            iconColor: AppColors.accent,
            title: "Calculators",
            subtitle:
                "Professional electrical calculators for the field.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalculatorsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          FeatureCard(
            icon: Icons.list_alt,
            iconColor: AppColors.success,
            title: "Material Lists",
            subtitle:
                "Generate project material lists in seconds.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MaterialScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          FeatureCard(
            icon: Icons.settings,
            iconColor: Colors.grey,
            title: "Settings",
            subtitle:
                "Customize ElectricalAI to fit your workflow.",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}