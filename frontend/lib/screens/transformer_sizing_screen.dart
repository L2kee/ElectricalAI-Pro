import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../calculators/transformer_sizing.dart';
import '../widgets/calculator_scaffold.dart';

class TransformerSizingScreen extends StatefulWidget {
  const TransformerSizingScreen({super.key});

  @override
  State<TransformerSizingScreen> createState() => _TransformerSizingScreenState();
}

class _TransformerSizingScreenState extends State<TransformerSizingScreen> {
  final _kva = TextEditingController();
  final _primaryVoltage = TextEditingController();
  final _secondaryVoltage = TextEditingController();
  String _phase = 'three';
  String _status = '';
  TransformerSizingResult? _result;

  void _calculate() {
    try {
      final kva = parseDouble(_kva.text);
      final primaryVoltage = parseDouble(_primaryVoltage.text);
      final secondaryVoltage = parseDouble(_secondaryVoltage.text);
      if (kva == null || primaryVoltage == null || secondaryVoltage == null) {
        throw CalculatorException('Enter kVA, primary voltage, and secondary voltage.');
      }
      final result = calculateTransformerSizing(
        kva: kva,
        primaryVoltage: primaryVoltage,
        secondaryVoltage: secondaryVoltage,
        phase: _phase,
      );
      setState(() {
        _result = result;
        _status = '✓ Transformer FLA calculated';
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
      title: 'Transformer Sizing Calculator',
      icon: Icons.electrical_services,
      subtitle: 'Enter the rated kVA and primary/secondary voltage to get full-load amperes.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorField(label: 'Rated kVA', hint: 'Enter transformer kVA', controller: _kva),
        CalculatorField(
          label: 'Primary voltage (V)',
          hint: 'Enter primary voltage',
          controller: _primaryVoltage,
        ),
        CalculatorField(
          label: 'Secondary voltage (V)',
          hint: 'Enter secondary voltage',
          controller: _secondaryVoltage,
        ),
        CalculatorDropdown<String>(
          label: 'Phase',
          value: _phase,
          items: const ['single', 'three'],
          itemLabel: (value) => value[0].toUpperCase() + value.substring(1),
          onChanged: (value) => setState(() => _phase = value),
        ),
      ],
      result: _result == null
          ? null
          : Column(
              children: [
                ResultMetric(label: 'Primary FLA', value: '${_result!.primaryFla} A'),
                ResultMetric(label: 'Secondary FLA', value: '${_result!.secondaryFla} A'),
                Text(_result!.notes, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _kva.dispose();
    _primaryVoltage.dispose();
    _secondaryVoltage.dispose();
    super.dispose();
  }
}
