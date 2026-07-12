import 'package:flutter/material.dart';

import 'ohms_law_screen.dart';

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  Widget buildCalculatorButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool enabled,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        width: double.infinity,
        height: 65,
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 28),
          label: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            if (enabled) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OhmsLawScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Coming Soon"),
                ),
              );
            }
          },
        ),
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
        child: Column(
          children: [
            buildCalculatorButton(
              context: context,
              icon: Icons.bolt,
              title: "Ohm's Law",
              enabled: true,
            ),

            buildCalculatorButton(
              context: context,
              icon: Icons.electric_bolt,
              title: "Voltage Drop",
              enabled: false,
            ),

            buildCalculatorButton(
              context: context,
              icon: Icons.cable,
              title: "Wire Ampacity",
              enabled: false,
            ),

            buildCalculatorButton(
              context: context,
              icon: Icons.inventory_2,
              title: "Box Fill",
              enabled: false,
            ),

            buildCalculatorButton(
              context: context,
              icon: Icons.view_in_ar,
              title: "Conduit Fill",
              enabled: false,
            ),

            buildCalculatorButton(
              context: context,
              icon: Icons.calculate,
              title: "Circuit Load",
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}