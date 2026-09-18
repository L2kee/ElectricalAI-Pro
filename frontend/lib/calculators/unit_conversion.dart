import 'tables.dart';

const Map<String, Map<String, double>> _factorTables = {
  'length': ElectricalTables.lengthToMeters,
  'power': ElectricalTables.powerToWatts,
};

/// Case-insensitive, whitespace-tolerant lookup that returns the table's canonical key.
MapEntry<String, double>? _lookupUnit(Map<String, double> table, String unit) {
  final trimmed = unit.trim();
  if (table.containsKey(trimmed)) {
    return MapEntry(trimmed, table[trimmed]!);
  }
  final lowered = trimmed.toLowerCase();
  for (final entry in table.entries) {
    if (entry.key.toLowerCase() == lowered) {
      return entry;
    }
  }
  return null;
}

class UnitConversionResult {
  const UnitConversionResult({
    required this.category,
    required this.fromUnit,
    required this.toUnit,
    required this.result,
  });

  final String category;
  final String fromUnit;
  final String toUnit;
  final double result;
}

UnitConversionResult convertUnit({
  required String category,
  required String fromUnit,
  required String toUnit,
  required double value,
}) {
  final cat = category.trim().toLowerCase();

  if (cat == 'temperature') {
    return _convertTemperature(fromUnit: fromUnit, toUnit: toUnit, value: value);
  }

  final table = _factorTables[cat];
  if (table == null) {
    throw CalculatorException('Category must be length, power, or temperature.');
  }

  final fromMatch = _lookupUnit(table, fromUnit);
  final toMatch = _lookupUnit(table, toUnit);
  if (fromMatch == null || toMatch == null) {
    final supported = table.keys.join(', ');
    throw CalculatorException('Unsupported $cat unit. Use one of $supported.');
  }

  return UnitConversionResult(
    category: cat,
    fromUnit: fromMatch.key,
    toUnit: toMatch.key,
    result: roundTo(value * fromMatch.value / toMatch.value, 4),
  );
}

UnitConversionResult _convertTemperature({
  required String fromUnit,
  required String toUnit,
  required double value,
}) {
  final f = fromUnit.trim().toUpperCase();
  final t = toUnit.trim().toUpperCase();
  const units = {'C', 'F'};
  if (!units.contains(f) || !units.contains(t)) {
    throw CalculatorException('Temperature unit must be C or F.');
  }

  double result;
  if (f == t) {
    result = value;
  } else if (f == 'C' && t == 'F') {
    result = value * 9.0 / 5.0 + 32.0;
  } else {
    result = (value - 32.0) * 5.0 / 9.0;
  }

  return UnitConversionResult(
    category: 'temperature',
    fromUnit: f,
    toUnit: t,
    result: roundTo(result, 2),
  );
}
