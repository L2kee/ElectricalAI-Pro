import 'package:flutter/material.dart';

import '../calculators/motor_flc.dart';
import '../calculators/tables.dart';
import '../widgets/calculator_scaffold.dart';

class MotorFlcScreen extends StatefulWidget {
  const MotorFlcScreen({super.key});

  @override
  State<MotorFlcScreen> createState() => _MotorFlcScreenState();
}

class _MotorFlcScreenState extends State<MotorFlcScreen> {
  String _phase = 'three';
  String _horsepower = '10';
  String _voltage = '230';
  String _status = '';
  MotorFlcResult? _result;

  List<String> get _hpOptions => _phase == 'single'
      ? ElectricalTables.motorHpSinglePhase
      : ElectricalTables.motorHpThreePhase;

  List<String> get _voltageOptions => _phase == 'single'
      ? const ['115', '200', '208', '230']
      : const ['200', '208', '230', '460', '575'];

  void _calculate() {
    try {
      final result = calculateMotorFlc(
        horsepower: _horsepower,
        voltage: _voltage,
        phase: _phase,
      );
      setState(() {
        _result = result;
        _status = '✓ Full-load current calculated';
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
      title: 'Motor FLC Calculator',
      icon: Icons.settings_input_component,
      subtitle: 'Look up motor full-load current by horsepower, voltage, and phase.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorDropdown<String>(
          label: 'Phase',
          value: _phase,
          items: const ['single', 'three'],
          itemLabel: (value) => value[0].toUpperCase() + value.substring(1),
          onChanged: (value) {
            setState(() {
              _phase = value;
              if (!_hpOptions.contains(_horsepower)) {
                _horsepower = _hpOptions.first;
              }
              if (!_voltageOptions.contains(_voltage)) {
                _voltage = _voltageOptions.first;
              }
            });
          },
        ),
        CalculatorDropdown<String>(
          label: 'Horsepower',
          value: _horsepower,
          items: _hpOptions,
          itemLabel: (value) => '$value HP',
          onChanged: (value) => setState(() => _horsepower = value),
        ),
        CalculatorDropdown<String>(
          label: 'System voltage',
          value: _voltage,
          items: _voltageOptions,
          itemLabel: (value) => '$value V',
          onChanged: (value) => setState(() => _voltage = value),
        ),
      ],
      result: _result == null
          ? null
          : Column(
              children: [
                ResultMetric(label: 'Full-load current', value: '${_result!.fullLoadCurrent} A'),
                ResultMetric(
                  label: 'Min. conductor ampacity (125%)',
                  value: '${_result!.minConductorAmpacityAmps} A',
                ),
                Text(_result!.notes, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              ],
            ),
    );
  }
}
