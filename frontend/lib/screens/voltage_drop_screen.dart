import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../calculators/voltage_drop.dart';
import '../widgets/calculator_scaffold.dart';

class VoltageDropScreen extends StatefulWidget {
  const VoltageDropScreen({super.key});

  @override
  State<VoltageDropScreen> createState() => _VoltageDropScreenState();
}

class _VoltageDropScreenState extends State<VoltageDropScreen> {
  final _current = TextEditingController();
  final _length = TextEditingController();
  final _voltage = TextEditingController(text: '120');

  String _wireSize = '12 AWG';
  String _material = 'copper';
  String _phase = 'single';
  String _status = '';
  VoltageDropResult? _result;

  void _calculate() {
    final current = parseDouble(_current.text);
    final length = parseDouble(_length.text);
    final voltage = parseDouble(_voltage.text);
    if (current == null || length == null || voltage == null) {
      setState(() {
        _result = null;
        _status = 'Enter current, one-way length, and system voltage.';
      });
      return;
    }

    try {
      final result = calculateVoltageDrop(
        current: current,
        wireSize: _wireSize,
        lengthFt: length,
        material: _material,
        voltage: voltage,
        phase: _phase,
      );
      setState(() {
        _result = result;
        _status = '✓ Voltage drop calculated';
      });
    } on CalculatorException catch (e) {
      setState(() {
        _result = null;
        _status = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CalculatorScaffold(
      title: 'Voltage Drop Calculator',
      icon: Icons.electric_bolt,
      subtitle: 'Uses wire size, material, one-way length, load, and system voltage.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorField(label: 'Load current (A)', hint: 'Enter current', controller: _current),
        CalculatorField(label: 'One-way length (ft)', hint: 'Enter one-way length', controller: _length),
        CalculatorField(label: 'System voltage (V)', hint: '120, 208, 240, 277, 480…', controller: _voltage),
        CalculatorDropdown<String>(
          label: 'Wire size',
          value: _wireSize,
          items: ElectricalTables.voltageDropWireSizes,
          onChanged: (value) => setState(() => _wireSize = value),
        ),
        CalculatorDropdown<String>(
          label: 'Material',
          value: _material,
          items: const ['copper', 'aluminum'],
          itemLabel: (value) => value[0].toUpperCase() + value.substring(1),
          onChanged: (value) => setState(() => _material = value),
        ),
        CalculatorDropdown<String>(
          label: 'System',
          value: _phase,
          items: const ['single', 'three'],
          itemLabel: (value) => value == 'single' ? 'Single-phase' : 'Three-phase',
          onChanged: (value) => setState(() => _phase = value),
        ),
      ],
      result: _result == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultMetric(label: 'Voltage drop', value: '${_result!.voltageDrop.toStringAsFixed(2)} V'),
                ResultMetric(label: 'Percent drop', value: '${_result!.percentDrop.toStringAsFixed(2)}%'),
                const SizedBox(height: 16),
                StatusTag(
                  _result!.within3Percent
                      ? '✔ Within a common 3% branch-circuit target'
                      : _result!.within5Percent
                          ? '⚠ Over 3%, within a common 5% feeder-plus-branch target'
                          : '✖ Over a common 5% feeder-plus-branch target',
                ),
                ResultNote(_result!.notes),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _current.dispose();
    _length.dispose();
    _voltage.dispose();
    super.dispose();
  }
}
