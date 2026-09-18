import 'package:flutter/material.dart';

import '../calculators/conduit_fill.dart';
import '../calculators/tables.dart';
import '../widgets/calculator_scaffold.dart';

class ConduitFillScreen extends StatefulWidget {
  const ConduitFillScreen({super.key});

  @override
  State<ConduitFillScreen> createState() => _ConduitFillScreenState();
}

class _ConduitFillScreenState extends State<ConduitFillScreen> {
  final _count = TextEditingController(text: '3');

  String _type = 'EMT';
  String _trade = '1/2';
  String _wire = '12 AWG';
  String _status = '';
  ConduitFillResult? _result;

  void _calculate() {
    final count = parseInt(_count.text);
    if (count == null) {
      setState(() {
        _result = null;
        _status = 'Enter wire count.';
      });
      return;
    }

    try {
      final result = calculateConduitFill(
        conduitType: _type,
        tradeSize: _trade,
        wireSize: _wire,
        wireCount: count,
      );
      setState(() {
        _result = result;
        _status = result.withinLimit ? '✓ Within fill limit' : '✖ Over fill limit';
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
      title: 'Conduit Fill Calculator',
      icon: Icons.view_in_ar,
      subtitle: 'Pick raceway, trade size, and THHN conductors. Fill limits: 53 / 31 / 40%.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorDropdown<String>(
          label: 'Conduit type',
          value: _type,
          items: ElectricalTables.conduitTypes,
          onChanged: (value) => setState(() => _type = value),
        ),
        CalculatorDropdown<String>(
          label: 'Trade size',
          value: _trade,
          items: ElectricalTables.tradeSizes,
          onChanged: (value) => setState(() => _trade = value),
        ),
        CalculatorDropdown<String>(
          label: 'THHN/THWN size',
          value: _wire,
          items: ElectricalTables.thhnSizes,
          onChanged: (value) => setState(() => _wire = value),
        ),
        CalculatorField(label: 'Wire count', hint: 'Number of conductors', controller: _count),
      ],
      result: _result == null
          ? null
          : Column(
              children: [
                ResultMetric(label: 'Total wire area', value: '${_result!.totalWireArea.toStringAsFixed(4)} sq. in.'),
                ResultMetric(label: 'Fill', value: '${_result!.percentFill.toStringAsFixed(2)}%'),
                ResultMetric(label: 'Limit', value: '${_result!.fillLimitPercent.toStringAsFixed(0)}%'),
                Text(
                  _result!.withinLimit ? '✔ Within fill limit' : '✖ Over fill limit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _result!.withinLimit ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Text(_result!.notes, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _count.dispose();
    super.dispose();
  }
}
