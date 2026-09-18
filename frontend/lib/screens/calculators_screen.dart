import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/feature_card.dart';

import 'ohms_law_screen.dart';
import 'voltage_drop_screen.dart';
import 'wire_ampacity_screen.dart';
import 'box_fill_screen.dart';
import 'conduit_fill_screen.dart';
import 'circuit_load_screen.dart';
import 'motor_flc_screen.dart';
import 'nec_reference_screen.dart';
import 'transformer_sizing_screen.dart';
import 'unit_conversion_screen.dart';
import 'voltage_drop_comparison_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WireAmpacityScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.inventory_2,
              iconColor: AppColors.success,
              title: "Box Fill",
              subtitle: "Calculate electrical box fill capacity.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BoxFillScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.view_in_ar,
              iconColor: Colors.teal,
              title: "Conduit Fill",
              subtitle: "Calculate conduit fill percentage.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ConduitFillScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.calculate,
              iconColor: Colors.orange,
              title: "Circuit Load",
              subtitle: "Calculate branch circuit load.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CircuitLoadScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.settings_input_component,
              iconColor: Colors.indigo,
              title: "Motor FLC",
              subtitle: "Look up motor full-load current by HP and voltage.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MotorFlcScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.electrical_services,
              iconColor: Colors.blueGrey,
              title: "Transformer Sizing",
              subtitle: "Get primary/secondary FLA from rated kVA.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TransformerSizingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.swap_horiz,
              iconColor: Colors.brown,
              title: "Unit Conversion",
              subtitle: "Convert length, power, and temperature units.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UnitConversionScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.compare_arrows,
              iconColor: Colors.pink,
              title: "Voltage Drop Comparison",
              subtitle: "Find the smallest wire size that meets your target.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VoltageDropComparisonScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            FeatureCard(
              icon: Icons.menu_book,
              iconColor: Colors.blueAccent,
              title: "NEC Quick Reference",
              subtitle: "Breaker sizes, box volumes, and conduit bend radius.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NecReferenceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}