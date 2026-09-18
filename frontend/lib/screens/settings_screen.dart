import 'package:flutter/material.dart';

import '../settings/app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Card(
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Developer'),
              subtitle: Text('Mohamed Eltoukhy'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('App Version'),
              subtitle: Text('1.0.1'),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.build_outlined),
              title: Text('Features'),
              subtitle: Text(
                'Offline calculators, AI assistant, material lists',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ValueListenableBuilder<bool>(
              valueListenable: AppSettings.enableHints,
              builder: (context, enabled, _) {
                return SwitchListTile(
                  secondary: const Icon(Icons.notifications_none),
                  title: const Text('Enable hints'),
                  subtitle: const Text(
                    'Show the planning-aid disclaimer on calculators and AI screens',
                  ),
                  value: enabled,
                  onChanged: AppSettings.setEnableHints,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.support_agent_outlined),
              title: Text('Support'),
              subtitle: Text(
                'Calculators work offline. AI and material lists need the local FastAPI backend.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
