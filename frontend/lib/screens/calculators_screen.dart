import 'package:flutter/material.dart';

import '../widgets/feature_card.dart';
import '../widgets/section_title.dart';

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

class _Module {
  const _Module(this.tag, this.title, this.subtitle, this.footer, this.builder);

  final String tag;
  final String title;
  final String subtitle;
  final String footer;
  final Widget Function() builder;
}

final _modules = <_Module>[
  _Module('V·I·R', "Ohm's Law", 'Solve voltage, current, or resistance.', 'V = I × R', () => const OhmsLawScreen()),
  _Module('DROP', 'Voltage Drop', 'Conductor voltage drop against 3% and 5% targets.', 'Single · three phase', () => const VoltageDropScreen()),
  _Module('AWG', 'Wire Ampacity', 'Allowable conductor ampacity by size and rating.', '60 · 75 · 90°C', () => const WireAmpacityScreen()),
  _Module('BOX', 'Box Fill', 'Box fill volume from conductors, yokes, and clamps.', 'cu. in. required', () => const BoxFillScreen()),
  _Module('FILL', 'Conduit Fill', 'Fill percentage by raceway, trade size, and wire.', '53 · 31 · 40%', () => const ConduitFillScreen()),
  _Module('LOAD', 'Circuit Load', 'Branch circuit load with the 125% continuous rule.', 'Next standard breaker', () => const CircuitLoadScreen()),
  _Module('M', 'Motor FLC', 'Motor full load current by HP and voltage.', 'FLC · 125% ampacity', () => const MotorFlcScreen()),
  _Module('kVA', 'Transformer Sizing', 'Primary and secondary FLA from rated kVA.', 'Single · three phase', () => const TransformerSizingScreen()),
  _Module('UNIT', 'Unit Conversion', 'Length, power, and temperature conversions.', 'ft · m · HP · °C', () => const UnitConversionScreen()),
  _Module('CMP', 'Voltage Drop Comparison', 'Find the smallest wire size that meets your target.', 'Every size, one table', () => const VoltageDropComparisonScreen()),
  _Module('REF', 'NEC Quick Reference', 'Breaker sizes, box volumes, and bend radius.', 'Lookup tables', () => const NecReferenceScreen()),
];

class CalculatorsScreen extends StatelessWidget {
  const CalculatorsScreen({super.key});

  /// Shown on the dashboard, so the number there can never drift from
  /// the modules actually listed here.
  static int get moduleCount => _modules.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculators'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        children: [
          SectionTitle(
            'The full bench.',
            eyebrow: '(a) Calculators',
            trailing: '$moduleCount modules',
          ),
          const SizedBox(height: 20),
          FeatureGrid(
            children: [
              for (var i = 0; i < _modules.length; i++)
                FeatureCard(
                  index: (i + 1).toString().padLeft(2, '0'),
                  tag: _modules[i].tag,
                  title: _modules[i].title,
                  subtitle: _modules[i].subtitle,
                  footer: _modules[i].footer,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _modules[i].builder()),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
