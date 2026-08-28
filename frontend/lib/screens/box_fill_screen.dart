import 'package:flutter/material.dart';

import '../calculators/box_fill.dart';
import '../calculators/tables.dart';
import '../widgets/calculator_scaffold.dart';

class BoxFillScreen extends StatefulWidget {
  const BoxFillScreen({super.key});

  @override
  State<BoxFillScreen> createState() => _BoxFillScreenState();
}

class _BoxFillScreenState extends State<BoxFillScreen> {
  final _volume = TextEditingController();
  final _conductors = TextEditingController();
  final _devices = TextEditingController(text: '1');
  final _clamps = TextEditingController(text: '1');
  final _grounds = TextEditingController(text: '1');

  String _size = '12 AWG';
  String _status = '';
  BoxFillResult? _result;

  void _calculate() {
    final volume = parseDouble(_volume.text);
    final conductors = parseInt(_conductors.text);
    final devices = parseInt(_devices.text) ?? 0;
    final clamps = parseInt(_clamps.text) ?? 0;
    final grounds = parseInt(_grounds.text) ?? 0;

    if (volume == null || conductors == null) {
      setState(() {
        _result = null;
        _status = 'Enter box volume and conductor count.';
      });
      return;
    }

    try {
      final result = calculateBoxFill(
        boxVolume: volume,
        conductorSize: _size,
        conductorCount: conductors,
        deviceCount: devices,
        clampCount: clamps,
        equipmentGroundCount: grounds,
      );
      setState(() {
        _result = result;
        _status = result.boxIsLargeEnough ? '✓ Box is large enough' : '✖ Box is not large enough';
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
      title: 'Box Fill Calculator',
      icon: Icons.inventory_2,
      subtitle: 'Counts conductors, device yokes, clamps, and equipment grounds.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorField(label: 'Box volume (cu. in.)', hint: 'From the box marking', controller: _volume),
        CalculatorDropdown<String>(
          label: 'Largest conductor in the box',
          value: _size,
          items: ElectricalTables.boxFillSizes,
          onChanged: (value) => setState(() => _size = value),
        ),
        CalculatorField(label: 'Conductor count', hint: 'Hot, neutral, and travelers that count', controller: _conductors),
        CalculatorField(label: 'Device yokes', hint: 'Switches and receptacles', controller: _devices),
        CalculatorField(label: 'Internal cable clamps', hint: '0 if none', controller: _clamps),
        CalculatorField(label: 'Equipment grounds', hint: 'Count of grounds, billed once', controller: _grounds),
      ],
      result: _result == null
          ? null
          : Column(
              children: [
                ResultMetric(label: 'Required volume', value: '${_result!.requiredVolume.toStringAsFixed(2)} cu. in.'),
                ResultMetric(label: 'Remaining volume', value: '${_result!.remainingVolume.toStringAsFixed(2)} cu. in.'),
                Text(
                  _result!.boxIsLargeEnough ? '✔ Box is large enough' : '✖ Box is NOT large enough',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _result!.boxIsLargeEnough ? Colors.green : Colors.red,
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
    _volume.dispose();
    _conductors.dispose();
    _devices.dispose();
    _clamps.dispose();
    _grounds.dispose();
    super.dispose();
  }
}
