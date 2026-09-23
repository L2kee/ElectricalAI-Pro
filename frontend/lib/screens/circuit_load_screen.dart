import 'package:flutter/material.dart';

import '../calculators/circuit_load.dart';
import '../calculators/tables.dart';
import '../widgets/calculator_scaffold.dart';

class CircuitLoadScreen extends StatefulWidget {
  const CircuitLoadScreen({super.key});

  @override
  State<CircuitLoadScreen> createState() => _CircuitLoadScreenState();
}

class _CircuitLoadScreenState extends State<CircuitLoadScreen> {
  final _power = TextEditingController();
  final _voltage = TextEditingController();
  final _current = TextEditingController();
  bool _continuous = false;
  String _status = '';
  CircuitLoadResult? _result;

  void _calculate() {
    try {
      final result = calculateCircuitLoad(
        power: parseDouble(_power.text),
        voltage: parseDouble(_voltage.text),
        current: parseDouble(_current.text),
        continuous: _continuous,
      );
      setState(() {
        _result = result;
        _status = '✓ Circuit load calculated';
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
      title: 'Circuit Load Calculator',
      icon: Icons.calculate,
      subtitle: 'Enter any TWO of power, voltage, and current. Optional 125% for continuous loads.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorField(label: 'Power (W)', hint: 'Enter wattage', controller: _power),
        CalculatorField(label: 'Voltage (V)', hint: 'Enter voltage', controller: _voltage),
        CalculatorField(label: 'Current (A)', hint: 'Enter current', controller: _current),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Continuous load (3 hours or more)'),
          subtitle: const Text('Sizes the breaker at 125% of calculated current'),
          value: _continuous,
          onChanged: (value) => setState(() => _continuous = value),
        ),
      ],
      result: _result == null
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ResultMetric(label: 'Power', value: '${_result!.power.toStringAsFixed(2)} W'),
                ResultMetric(label: 'Voltage', value: '${_result!.voltage.toStringAsFixed(2)} V'),
                ResultMetric(label: 'Current', value: '${_result!.current.toStringAsFixed(2)} A'),
                ResultMetric(label: 'Design current', value: '${_result!.designCurrent.toStringAsFixed(2)} A'),
                if (_result!.suggestedBreakerAmps != null)
                  ResultMetric(
                    label: 'Next standard breaker',
                    value: '${_result!.suggestedBreakerAmps} A',
                  ),
                ResultNote(_result!.notes),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _power.dispose();
    _voltage.dispose();
    _current.dispose();
    super.dispose();
  }
}
