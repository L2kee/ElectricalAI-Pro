import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/feature_card.dart';
import '../widgets/install_prompt_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_title.dart';

import 'ai_screen.dart';
import 'calculators_screen.dart';
import 'material_screen.dart';
import 'settings_screen.dart';
import 'ohms_law_screen.dart';
import 'voltage_drop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),

          const SizedBox(height: 28),

          const InstallPromptCard(),

          const SizedBox(height: 14),

          const SectionTitle("Quick Actions"),

          const SizedBox(height: 20),

          LayoutBuilder(
            builder: (context, constraints) {
              const cardWidth = 92.0;
              const wideGap = 18.0;
              const narrowGap = 10.0;
              const requiredWidth = cardWidth * 4 + wideGap * 3;
              final fitsUnscaled = constraints.maxWidth >= requiredWidth;

              final cards = [
                QuickActionCard(
                  icon: Icons.bolt,
                  title: "Ohm's\nLaw",
                  width: fitsUnscaled ? cardWidth : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OhmsLawScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.electric_bolt,
                  title: "Voltage\nDrop",
                  width: fitsUnscaled ? cardWidth : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VoltageDropScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.smart_toy,
                  title: "Ask\nAI",
                  width: fitsUnscaled ? cardWidth : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AIScreen(),
                      ),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.inventory_2,
                  title: "Materials",
                  width: fitsUnscaled ? cardWidth : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MaterialScreen(),
                      ),
                    );
                  },
                ),
              ];

              if (fitsUnscaled) {
                return SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      cards[0],
                      const SizedBox(width: wideGap),
                      cards[1],
                      const SizedBox(width: wideGap),
                      cards[2],
                      const SizedBox(width: wideGap),
                      cards[3],
                    ],
                  ),
                );
              }

              // Narrow (phone-width) screens: no room to scroll off the
              // fourth card, so all four share the row evenly instead,
              // each shrinking its icon/label together via the card's
              // own FittedBox rather than clipping or wrapping oddly.
              return SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: cards[0]),
                    const SizedBox(width: narrowGap),
                    Expanded(child: cards[1]),
                    const SizedBox(width: narrowGap),
                    Expanded(child: cards[2]),
                    const SizedBox(width: narrowGap),
                    Expanded(child: cards[3]),
                  ],
                ),
              );
            },
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