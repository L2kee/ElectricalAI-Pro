import 'package:flutter/material.dart';

import 'ai_screen.dart';
import 'calculators_screen.dart';
import 'material_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget buildButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 30),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ElectricalAI Pro"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Icon(
              Icons.electrical_services,
              size: 90,
              color: Colors.red,
            ),

            const SizedBox(height: 15),

            const Text(
              "ElectricalAI Pro",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            buildButton(
              context: context,
              icon: Icons.smart_toy,
              title: "AI Assistant",
              page: AIScreen(),
            ),

            const SizedBox(height: 15),

            buildButton(
              context: context,
              icon: Icons.calculate,
              title: "Calculators",
              page: CalculatorsScreen(),
            ),

            const SizedBox(height: 15),

            buildButton(
              context: context,
              icon: Icons.list_alt,
              title: "Material List",
              page: MaterialScreen(),
            ),

            const SizedBox(height: 15),

            buildButton(
              context: context,
              icon: Icons.settings,
              title: "Settings",
              page: SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}