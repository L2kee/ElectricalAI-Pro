import 'package:flutter/material.dart';

import '../widgets/feature_card.dart';
import '../widgets/quick_action_card.dart';

import 'ai_screen.dart';
import 'calculators_screen.dart';
import 'material_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F5F7),

      appBar: AppBar(
        title: const Text("ElectricalAI"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.notifications_none),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Welcome Back",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 4),

            const Text(
              "Electrician",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 130,

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

                  const SizedBox(width: 14),

                  QuickActionCard(
                    icon: Icons.electric_bolt,
                    title: "Voltage\nDrop",
                    onTap: () {},
                  ),

                  const SizedBox(width: 14),

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

                  const SizedBox(width: 14),

                  QuickActionCard(
                    icon: Icons.inventory,
                    title: "Material\nList",
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

            const SizedBox(height: 35),

            const Text(
              "Features",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            FeatureCard(
              icon: Icons.smart_toy,
              iconColor: Colors.red,
              title: "AI Assistant",
              subtitle: "Ask questions, troubleshoot, and learn.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AIScreen(),
                  ),
                );
              },
            ),

            FeatureCard(
              icon: Icons.calculate,
              iconColor: Colors.orange,
              title: "Calculators",
              subtitle: "Professional NEC electrical calculators.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CalculatorsScreen(),
                  ),
                );
              },
            ),

            FeatureCard(
              icon: Icons.list_alt,
              iconColor: Colors.green,
              title: "Material Lists",
              subtitle: "Generate project material lists.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MaterialScreen(),
                  ),
                );
              },
            ),

            FeatureCard(
              icon: Icons.settings,
              iconColor: Colors.grey,
              title: "Settings",
              subtitle: "Customize your experience.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}