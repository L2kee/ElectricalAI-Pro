import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../calculators/voltage_drop_comparison.dart';
import '../theme/app_colors.dart';
import '../widgets/calculator_scaffold.dart';
import '../widgets/glass.dart';

class VoltageDropComparisonScreen extends StatefulWidget {
  const VoltageDropComparisonScreen({super.key});

  @override
  State<VoltageDropComparisonScreen> createState() => _VoltageDropComparisonScreenState();
}

class _VoltageDropComparisonScreenState extends State<VoltageDropComparisonScreen> {
  final _current = TextEditingController();
  final _length = TextEditingController();
  final _voltage = TextEditingController(text: '120');

  String _material = 'copper';
  String _phase = 'single';
  String _status = '';
  VoltageDropComparisonResult? _result;

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
      final result = compareVoltageDrop(
        current: current,
        lengthFt: length,
        material: _material,
        voltage: voltage,
        phase: _phase,
      );
      setState(() {
        _result = result;
        _status = '✓ Compared across ${result.results.length} wire sizes';
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
      title: 'Voltage Drop Comparison',
      icon: Icons.compare_arrows,
      subtitle: 'Compare voltage drop across every standard wire size to find the smallest that fits.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorField(label: 'Load current (A)', hint: 'Enter current', controller: _current),
        CalculatorField(label: 'One-way length (ft)', hint: 'Enter one-way length', controller: _length),
        CalculatorField(label: 'System voltage (V)', hint: '120, 208, 240, 277, 480…', controller: _voltage),
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
      result: _result == null ? null : _buildResult(_result!),
    );
  }

  Widget _buildResult(VoltageDropComparisonResult result) {
    String mark(bool within3, bool within5) => within3 ? '✔' : (within5 ? '⚠' : '✖');
    Color markColor(bool within3, bool within5) =>
        within3 ? AppColors.pass : (within5 ? AppColors.warning : AppColors.danger);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StatusTag(
          result.smallestSizeWithin3Percent != null
              ? '✔ Smallest within 3%: ${result.smallestSizeWithin3Percent}'
              : '✖ No listed size meets a 3% target for this run',
        ),
        const SizedBox(height: 8),
        StatusTag(
          result.smallestSizeWithin5Percent != null
              ? '⚠ Smallest within 5%: ${result.smallestSizeWithin5Percent}'
              : '✖ No listed size meets a 5% target for this run',
        ),
        const SizedBox(height: 16),
        MonoTable(
          headers: const ['Size', 'Drop', '%', ''],
          flex: const [2, 2, 2, 1],
          rows: [
            for (final row in result.results)
              [
                Text(row.wireSize),
                Text('${row.voltageDrop.toStringAsFixed(2)} V'),
                Text('${row.percentDrop.toStringAsFixed(2)}%'),
                Text(
                  mark(row.within3Percent, row.within5Percent),
                  style: TextStyle(color: markColor(row.within3Percent, row.within5Percent)),
                ),
              ],
          ],
        ),
      ],
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
