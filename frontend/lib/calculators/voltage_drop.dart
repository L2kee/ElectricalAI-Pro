import 'tables.dart';

class VoltageDropResult {
  const VoltageDropResult({
    required this.voltageDrop,
    required this.percentDrop,
    required this.within3Percent,
    required this.within5Percent,
    required this.notes,
  });

  final double voltageDrop;
  final double percentDrop;
  final bool within3Percent;
  final bool within5Percent;
  final String notes;
}

VoltageDropResult calculateVoltageDrop({
  required double current,
  required String wireSize,
  required double lengthFt,
  required String material,
  required double voltage,
  required String phase,
}) {
  if (current <= 0) throw CalculatorException('Current must be greater than zero.');
  if (lengthFt <= 0) {
    throw CalculatorException('One-way circuit length must be greater than zero.');
  }
  if (voltage <= 0) {
    throw CalculatorException('System voltage must be greater than zero.');
  }

  var ohmsPerKft = ElectricalTables.copperOhmsPerKft75c[wireSize];
  if (ohmsPerKft == null) {
    throw CalculatorException('Unsupported wire size: $wireSize');
  }

  final metal = material.toLowerCase();
  if (metal == 'aluminum') {
    ohmsPerKft *= ElectricalTables.aluminumResistanceMultiplier;
  } else if (metal != 'copper') {
    throw CalculatorException('Material must be copper or aluminum.');
  }

  final kind = phase.toLowerCase();
  late final double multiplier;
  if (kind.startsWith('single') || kind == '1') {
    multiplier = 2.0;
  } else if (kind.startsWith('three') || kind == '3') {
    multiplier = 1.732;
  } else {
    throw CalculatorException('Phase must be single or three.');
  }

  final voltageDrop = current * ohmsPerKft * (lengthFt / 1000.0) * multiplier;
  final percent = (voltageDrop / voltage) * 100.0;

  return VoltageDropResult(
    voltageDrop: voltageDrop,
    percentDrop: percent,
    within3Percent: percent <= 3.0,
    within5Percent: percent <= 5.0,
    notes:
        'Uses approximate 75°C conductor resistance. 3% is a common branch-circuit target and 5% a common feeder-plus-branch target.',
  );
}
