import 'tables.dart';

const double threePhaseFactor = 1.732;

class TransformerSizingResult {
  const TransformerSizingResult({
    required this.primaryFla,
    required this.secondaryFla,
    required this.phase,
    required this.notes,
  });

  final double primaryFla;
  final double secondaryFla;
  final String phase;
  final String notes;
}

double _round2(double value) => double.parse(value.toStringAsFixed(2));

TransformerSizingResult calculateTransformerSizing({
  required double kva,
  required double primaryVoltage,
  required double secondaryVoltage,
  String phase = 'three',
}) {
  if (kva <= 0) {
    throw CalculatorException('kVA must be greater than zero.');
  }
  if (primaryVoltage <= 0 || secondaryVoltage <= 0) {
    throw CalculatorException('Primary and secondary voltage must be greater than zero.');
  }

  final kind = normalizePhase(phase);
  final factor = kind == 'single' ? 1.0 : threePhaseFactor;
  final divisorPrimary = primaryVoltage * factor;
  final divisorSecondary = secondaryVoltage * factor;
  final phaseLabel = kind == 'single' ? 'single-phase' : 'three-phase';

  final va = kva * 1000.0;

  return TransformerSizingResult(
    primaryFla: _round2(va / divisorPrimary),
    secondaryFla: _round2(va / divisorSecondary),
    phase: phaseLabel,
    notes:
        "Full-load amperes at the transformer's rated kVA, not a measured load. Overcurrent "
        'protection and conductor sizing must still be selected per the applicable code and the AHJ.',
  );
}
