import 'package:flutter/material.dart';

import '../widgets/app_scaffold.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/feature_card.dart';
import '../widgets/install_prompt_card.dart';
import '../widgets/section_title.dart';

import 'ai_screen.dart';
import 'calculators_screen.dart';
import 'material_screen.dart';
import 'settings_screen.dart';
import 'ohms_law_screen.dart';
import 'voltage_drop_screen.dart';
import 'wire_ampacity_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final moreModules = CalculatorsScreen.moduleCount - 3;

    return AppScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(
            onOpenSettings: () => _open(context, const SettingsScreen()),
          ),

          const SizedBox(height: 36),

          DashboardHero(
            moduleCount: CalculatorsScreen.moduleCount,
            onStartCalculating: () => _open(context, const CalculatorsScreen()),
            onAskAssistant: () => _open(context, const AIScreen()),
          ),

          const SizedBox(height: 32),

          const InstallPromptCard(),

          const SizedBox(height: 16),

          SectionTitle(
            'The full bench, one surface.',
            eyebrow: '(a) Calculators',
            trailing: '${CalculatorsScreen.moduleCount} modules',
          ),

          const SizedBox(height: 20),

          FeatureGrid(
            children: [
              FeatureCard(
                index: '01',
                tag: 'V·I·R',
                title: "Ohm's Law",
                subtitle: 'Solve voltage, current, or resistance from any two.',
                footer: 'V = I × R',
                onTap: () => _open(context, const OhmsLawScreen()),
              ),
              FeatureCard(
                index: '02',
                tag: 'DROP',
                title: 'Voltage drop',
                subtitle: 'Single and three phase drop against 3% and 5% targets.',
                footer: 'Copper · aluminum',
                onTap: () => _open(context, const VoltageDropScreen()),
              ),
              FeatureCard(
                index: '03',
                tag: 'AWG',
                title: 'Wire ampacity',
                subtitle: 'Allowable ampacity by size, metal, and 60/75/90°C rating.',
                footer: 'Table 310.16 basis',
                onTap: () => _open(context, const WireAmpacityScreen()),
              ),
              FeatureCard(
                index: '+',
                tag: 'MORE',
                title: '$moreModules more modules',
                subtitle: 'Box fill, conduit fill, motors, transformers, and more.',
                footer: 'Explore the suite',
                highlighted: true,
                onTap: () => _open(context, const CalculatorsScreen()),
              ),
            ],
          ),

          const SizedBox(height: 44),

          const SectionTitle(
            'Ask it like a journeyman.',
            eyebrow: '(b) Assistant',
          ),

          const SizedBox(height: 20),

          FeatureGrid(
            children: [
              FeatureCard(
                index: '04',
                tag: 'AI',
                title: 'AI assistant',
                subtitle: 'Code questions and troubleshooting, checked against the calculators.',
                footer: 'Keeps the conversation',
                onTap: () => _open(context, const AIScreen()),
              ),
              FeatureCard(
                index: '05',
                tag: 'BOM',
                title: 'Material lists',
                subtitle: 'Describe the job, get a structured takeoff you can scan on site.',
                footer: 'Qty · unit · notes',
                onTap: () => _open(context, const MaterialScreen()),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
