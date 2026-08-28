import 'tables.dart';

class BoxFillResult {
  const BoxFillResult({
    required this.allowanceCuIn,
    required this.conductorVolume,
    required this.deviceVolume,
    required this.clampVolume,
    required this.groundVolume,
    required this.requiredVolume,
    required this.remainingVolume,
    required this.boxIsLargeEnough,
    required this.notes,
  });

  final double allowanceCuIn;
  final double conductorVolume;
  final double deviceVolume;
  final double clampVolume;
  final double groundVolume;
  final double requiredVolume;
  final double remainingVolume;
  final bool boxIsLargeEnough;
  final String notes;
}

BoxFillResult calculateBoxFill({
  required double boxVolume,
  required String conductorSize,
  required int conductorCount,
  int deviceCount = 0,
  int clampCount = 0,
  int equipmentGroundCount = 0,
}) {
  if (boxVolume <= 0) {
    throw CalculatorException('Box volume must be greater than zero.');
  }
  if (conductorCount < 0 || deviceCount < 0 || clampCount < 0 || equipmentGroundCount < 0) {
    throw CalculatorException('Counts cannot be negative.');
  }

  final allowance = ElectricalTables.boxFillAllowanceCuIn[conductorSize];
  if (allowance == null) {
    throw CalculatorException('Unsupported conductor size for box fill: $conductorSize');
  }

  final conductorVolume = conductorCount * allowance;
  final deviceVolume = deviceCount * 2 * allowance;
  final clampVolume = clampCount > 0 ? allowance : 0.0;
  final groundVolume = equipmentGroundCount > 0 ? allowance : 0.0;
  final required = conductorVolume + deviceVolume + clampVolume + groundVolume;

  return BoxFillResult(
    allowanceCuIn: allowance,
    conductorVolume: conductorVolume,
    deviceVolume: deviceVolume,
    clampVolume: clampVolume,
    groundVolume: groundVolume,
    requiredVolume: required,
    remainingVolume: boxVolume - required,
    boxIsLargeEnough: boxVolume - required >= 0,
    notes:
        'Each device yoke counts as two conductors. Internal clamps count once. '
        'Equipment grounding conductors count once at the largest ground size.',
  );
}
