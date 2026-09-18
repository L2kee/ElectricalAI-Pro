import 'tables.dart';

class MotorFlcResult {
  const MotorFlcResult({
    required this.fullLoadCurrent,
    required this.minConductorAmpacityAmps,
    required this.phase,
    required this.notes,
  });

  final double fullLoadCurrent;
  final double minConductorAmpacityAmps;
  final String phase;
  final String notes;
}

MotorFlcResult calculateMotorFlc({
  required String horsepower,
  required String voltage,
  String phase = 'three',
}) {
  final kind = phase.trim().toLowerCase();
  Map<String, Map<String, double>> table;
  String phaseLabel;
  if (kind == 'single' || kind == '1' || kind == '1ph' || kind == 'single-phase') {
    table = ElectricalTables.motorFlcSinglePhase;
    phaseLabel = 'single-phase';
  } else if (kind == 'three' || kind == '3' || kind == '3ph' || kind == 'three-phase') {
    table = ElectricalTables.motorFlcThreePhase;
    phaseLabel = 'three-phase';
  } else {
    throw CalculatorException('Phase must be single or three.');
  }

  final hp = horsepower.trim();
  final row = table[hp];
  if (row == null) {
    throw CalculatorException('Unsupported $phaseLabel horsepower: $horsepower');
  }

  final volts = voltage.trim();
  final flc = row[volts];
  if (flc == null) {
    final supported = row.keys.join(', ');
    throw CalculatorException(
      'Unsupported voltage for $hp HP $phaseLabel: $voltage. Use one of $supported.',
    );
  }

  return MotorFlcResult(
    fullLoadCurrent: flc,
    minConductorAmpacityAmps: double.parse((flc * 1.25).toStringAsFixed(2)),
    phase: phaseLabel,
    notes:
        'Table lookup, not a nameplate reading; use the motor nameplate FLA when it is available. '
        'Conductor ampacity shown is 125% of FLC for a single continuous-duty motor. Branch-circuit '
        "short-circuit/ground-fault protection and overload sizing must still be selected per the "
        "applicable code, the motor's service factor, and its nameplate.",
  );
}
