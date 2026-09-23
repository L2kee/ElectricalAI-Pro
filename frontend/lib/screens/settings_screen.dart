import 'package:flutter/material.dart';

import '../settings/app_settings.dart';
import '../theme/app_colors.dart';
import '../widgets/section_title.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          const SectionTitle('Preferences', eyebrow: '(c) Settings'),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined, color: AppColors.signal),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Theme', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 2),
                            Text('Same screens, two looks'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ValueListenableBuilder<AppThemeStyle>(
                    valueListenable: AppSettings.themeStyle,
                    builder: (context, style, _) {
                      return SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<AppThemeStyle>(
                          showSelectedIcon: false,
                          segments: [
                            for (final option in AppThemeStyle.values)
                              ButtonSegment(value: option, label: Text(option.label)),
                          ],
                          selected: {style},
                          onSelectionChanged: (selection) =>
                              AppSettings.setThemeStyle(selection.first),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ValueListenableBuilder<bool>(
              valueListenable: AppSettings.isDarkMode,
              builder: (context, isDark, _) {
                return SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  subtitle: const Text('Works with either theme'),
                  value: isDark,
                  onChanged: AppSettings.setDarkMode,
                );
              },
            ),
          ),
          Card(
            child: ValueListenableBuilder<bool>(
              valueListenable: AppSettings.enableHints,
              builder: (context, enabled, _) {
                return SwitchListTile(
                  secondary: const Icon(Icons.shield_outlined),
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
          const SizedBox(height: 28),
          const SectionTitle('About', eyebrow: '(d) App'),
          const SizedBox(height: 20),
          const Card(
            child: ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Developer'),
              subtitle: Text('Mohamed Eltoukhy'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('App Version'),
              subtitle: Text('1.0.1'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.build_outlined),
              title: Text('Features'),
              subtitle: Text(
                'Offline calculators, AI assistant, material lists',
              ),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.support_agent_outlined),
              title: Text('Support'),
              subtitle: Text(
                'Calculators work offline. The AI assistant and material lists need the AI backend: hosted on the web version, started locally with the desktop app.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
