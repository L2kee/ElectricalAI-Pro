import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableHints = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _enableHints = prefs.getBool('enable_hints') ?? true;
    });
  }

  Future<void> _updateHints(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('enable_hints', value);

    setState(() {
      _enableHints = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Developer"),
              subtitle: const Text("Mohamed Eltoukhy"),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("App Version"),
              subtitle: const Text("1.0.0"),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.build_outlined),
              title: const Text("Features"),
              subtitle: const Text(
                "Calculators, AI assistant, material lists, and project tools",
              ),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_none),
              title: const Text("Enable hints"),
              subtitle: const Text(
                "Show helpful tips while using the app",
              ),
              value: _enableHints,
              onChanged: _updateHints,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text("Support"),
              subtitle: const Text(
                "Use the AI assistant for project help and troubleshooting",
              ),
            ),
          ),
        ],
      ),
    );
  }
}