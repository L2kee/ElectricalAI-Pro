import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Developer'),
              subtitle: const Text('Mohamed Eltoukhy'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('App Version'),
              subtitle: const Text('1.0.0'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.build_outlined),
              title: const Text('Features'),
              subtitle: const Text('Calculators, AI assistant, material lists, and project tools'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.notifications_none),
              title: const Text('Enable hints'),
              subtitle: const Text('Show helpful tips while using the app'),
              value: true,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.support_agent_outlined),
              title: const Text('Support'),
              subtitle: const Text('Use the AI assistant for project help and troubleshooting'),
            ),
          ),
        ],
      ),
    );
  }
}