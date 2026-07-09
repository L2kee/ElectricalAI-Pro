import 'package:flutter/material.dart';

void main() {
  runApp(const ElectricalAIProApp());
}

class ElectricalAIProApp extends StatelessWidget {
  const ElectricalAIProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElectricalAI Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildButton(
    BuildContext context,
    IconData icon,
    String title,
  ) {
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
        onPressed: () {},
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
              context,
              Icons.smart_toy,
              "AI Assistant",
            ),

            const SizedBox(height: 15),

            buildButton(
              context,
              Icons.calculate,
              "Calculators",
            ),

            const SizedBox(height: 15),

            buildButton(
              context,
              Icons.list_alt,
              "Material List",
            ),

            const SizedBox(height: 15),

            buildButton(
              context,
              Icons.settings,
              "Settings",
            ),
          ],
        ),
      ),
    );
  }
}