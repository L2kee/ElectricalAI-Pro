import 'package:flutter/material.dart';

import '../calculators/ohms_law.dart';
import '../calculators/tables.dart';
import '../widgets/calculator_scaffold.dart';

class OhmsLawScreen extends StatefulWidget {
  const OhmsLawScreen({super.key});

  @override
  State<OhmsLawScreen> createState() => _OhmsLawScreenState();
}

class _OhmsLawScreenState extends State<OhmsLawScreen> {
  final _voltage = TextEditingController();
  final _current = TextEditingController();
  final _resistance = TextEditingController();

  String _status = '';
  OhmsLawResult? _result;

  void _calculate() {
    try {
      final result = calculateOhmsLaw(
        voltage: parseDouble(_voltage.text),
        current: parseDouble(_current.text),
        resistance: parseDouble(_resistance.text),
      );
      setState(() {
        _result = result;
        _status = '✓ ${result.label} calculated';
      });
      final formatted = result.value.toStringAsFixed(2);
      if (result.label == 'Voltage') _voltage.text = formatted;
      if (result.label == 'Current') _current.text = formatted;
      if (result.label == 'Resistance') _resistance.text = formatted;
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
      title: "Ohm's Law Calculator",
      icon: Icons.bolt,
      subtitle: 'Enter any TWO values.\nLeave the value you want calculated blank.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorField(label: 'Voltage (V)', hint: 'Enter voltage', controller: _voltage),
        CalculatorField(label: 'Current (A)', hint: 'Enter current', controller: _current),
        CalculatorField(label: 'Resistance (Ω)', hint: 'Enter resistance', controller: _resistance),
      ],
      result: _result == null
          ? null
          : ResultMetric(label: _result!.label, value: '${_result!.value.toStringAsFixed(2)} ${_result!.unit}'),
    );
  }

  @override
  void dispose() {
    _voltage.dispose();
    _current.dispose();
    _resistance.dispose();
    super.dispose();
  }
}
