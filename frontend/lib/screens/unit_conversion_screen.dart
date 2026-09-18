import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../calculators/unit_conversion.dart';
import '../widgets/calculator_scaffold.dart';

const Map<String, List<String>> _categoryUnits = {
  'length': ['ft', 'in', 'm', 'cm', 'mm'],
  'power': ['W', 'kW', 'HP'],
  'temperature': ['C', 'F'],
};

class UnitConversionScreen extends StatefulWidget {
  const UnitConversionScreen({super.key});

  @override
  State<UnitConversionScreen> createState() => _UnitConversionScreenState();
}

class _UnitConversionScreenState extends State<UnitConversionScreen> {
  final _value = TextEditingController();
  String _category = 'length';
  String _fromUnit = 'ft';
  String _toUnit = 'm';
  String _status = '';
  UnitConversionResult? _result;

  List<String> get _units => _categoryUnits[_category]!;

  void _calculate() {
    try {
      final value = parseDouble(_value.text);
      if (value == null) {
        throw CalculatorException('Enter a value to convert.');
      }
      final result = convertUnit(
        category: _category,
        fromUnit: _fromUnit,
        toUnit: _toUnit,
        value: value,
      );
      setState(() {
        _result = result;
        _status = '✓ Converted';
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
      title: 'Unit Conversion',
      icon: Icons.swap_horiz,
      subtitle: 'Convert common length, power, and temperature units.',
      loading: false,
      onCalculate: _calculate,
      statusMessage: _status,
      fields: [
        CalculatorDropdown<String>(
          label: 'Category',
          value: _category,
          items: const ['length', 'power', 'temperature'],
          itemLabel: (value) => value[0].toUpperCase() + value.substring(1),
          onChanged: (value) {
            setState(() {
              _category = value;
              _fromUnit = _units.first;
              _toUnit = _units.length > 1 ? _units[1] : _units.first;
            });
          },
        ),
        CalculatorDropdown<String>(
          label: 'From',
          value: _fromUnit,
          items: _units,
          onChanged: (value) => setState(() => _fromUnit = value),
        ),
        CalculatorDropdown<String>(
          label: 'To',
          value: _toUnit,
          items: _units,
          onChanged: (value) => setState(() => _toUnit = value),
        ),
        CalculatorField(label: 'Value', hint: 'Enter value to convert', controller: _value),
      ],
      result: _result == null
          ? null
          : Column(
              children: [
                ResultMetric(
                  label: 'Result',
                  value: '${_result!.result} ${_result!.toUnit}',
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }
}
