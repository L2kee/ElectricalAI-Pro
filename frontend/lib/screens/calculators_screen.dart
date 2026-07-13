import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/feature_card.dart';

import 'ohms_law_screen.dart';
import 'voltage_drop_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Coming Soon"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Electrical Calculators"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            FeatureCard(
              icon: Icons.bolt,
              iconColor: AppColors.primary,
              title: "Ohm's Law",
              subtitle: "Calculate voltage, current, or resistance.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OhmsLawScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.electric_bolt,
              iconColor: AppColors.accent,
              title: "Voltage Drop",
              subtitle: "Calculate conductor voltage drop.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VoltageDropScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.cable,
              iconColor: Colors.deepPurple,
              title: "Wire Ampacity",
              subtitle: "Determine allowable conductor ampacity.",
              onTap: () => _comingSoon(context),
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.inventory_2,
              iconColor: AppColors.success,
              title: "Box Fill",
              subtitle: "Calculate electrical box fill capacity.",
              onTap: () => _comingSoon(context),
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.view_in_ar,
              iconColor: Colors.teal,
              title: "Conduit Fill",
              subtitle: "Calculate conduit fill percentage.",
              onTap: () => _comingSoon(context),
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.calculate,
              iconColor: Colors.orange,
              title: "Circuit Load",
              subtitle: "Calculate branch circuit load.",
              onTap: () => _comingSoon(context),
            ),
          ],
        ),
      ),
    );
  }
}