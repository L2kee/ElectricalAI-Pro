import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../calculators/wire_ampacity.dart';
import '../widgets/calculator_scaffold.dart';

class WireAmpacityScreen extends StatefulWidget {
  const WireAmpacityScreen({super.key});

  @override
  State<WireAmpacityScreen> createState() => _WireAmpacityScreenState();
}

class _WireAmpacityScreenState extends State<WireAmpacityScreen> {
  String _material = 'copper';
  String _wireSize = '12 AWG';
  String _temperature = '75';
  String _status = '';
  WireAmpacityResult? _result;

  List<String> get _sizes => _material == 'copper'
      ? ElectricalTables.copperWireSizes
      : ElectricalTables.aluminumWireSizes;

  void _calculate() {
    try {
      final result = calculateWireAmpacity(
        wireSize: _wireSize,
        temperatureRating: _temperature,
        material: _material,
      );
      setState(() {
        _result = result;
        _status = '✓ Ampacity calculated';
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
      title: 'Wire Ampacity Calculator',
      icon: Icons.cable,
      subtitle: 'Select conductor metal, size, and insulation temperature rating.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorDropdown<String>(
          label: 'Material',
          value: _material,
          items: const ['copper', 'aluminum'],
          itemLabel: (value) => value[0].toUpperCase() + value.substring(1),
          onChanged: (value) {
            setState(() {
              _material = value;
              if (!_sizes.contains(_wireSize)) {
                _wireSize = _sizes.first;
              }
            });
          },
        ),
        CalculatorDropdown<String>(
          label: 'Wire size',
          value: _wireSize,
          items: _sizes,
          onChanged: (value) => setState(() => _wireSize = value),
        ),
        CalculatorDropdown<String>(
          label: 'Temperature rating',
          value: _temperature,
          items: const ['60', '75', '90'],
          itemLabel: (value) => '$value°C',
          onChanged: (value) => setState(() => _temperature = value),
        ),
      ],
      result: _result == null
          ? null
          : Column(
              children: [
                ResultMetric(label: 'Allowable ampacity', value: '${_result!.ampacity} A'),
                if (_result!.typicalBranchOcpdAmps != null)
                  ResultMetric(
                    label: 'Typical branch-circuit OCPD',
                    value: '${_result!.typicalBranchOcpdAmps} A',
                  ),
                Text(_result!.notes, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              ],
            ),
    );
  }
}
