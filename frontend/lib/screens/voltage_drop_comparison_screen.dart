import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../calculators/voltage_drop_comparison.dart';
import '../widgets/calculator_scaffold.dart';

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
    return Column(
      children: [
        if (result.smallestSizeWithin3Percent != null)
          Text(
            '✔ Smallest within 3%: ${result.smallestSizeWithin3Percent}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          )
        else
          const Text(
            '✖ No listed size meets a 3% target for this run',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        const SizedBox(height: 4),
        if (result.smallestSizeWithin5Percent != null)
          Text(
            '✔ Smallest within 5%: ${result.smallestSizeWithin5Percent}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
          )
        else
          const Text(
            '✖ No listed size meets a 5% target for this run',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        const SizedBox(height: 16),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(1),
          },
          children: [
            const TableRow(
              children: [
                Padding(padding: EdgeInsets.all(6), child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(6), child: Text('Drop', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(6), child: Text('%', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(6), child: Text('', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            for (final row in result.results)
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(6), child: Text(row.wireSize)),
                  Padding(padding: const EdgeInsets.all(6), child: Text('${row.voltageDrop.toStringAsFixed(2)} V')),
                  Padding(padding: const EdgeInsets.all(6), child: Text('${row.percentDrop.toStringAsFixed(2)}%')),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Text(
                      row.within3Percent ? '✔' : (row.within5Percent ? '⚠' : '✖'),
                      style: TextStyle(
                        color: row.within3Percent
                            ? Colors.green
                            : (row.within5Percent ? Colors.orange : Colors.red),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
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
