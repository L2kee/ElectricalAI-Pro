import 'tables.dart';

class CircuitLoadResult {
  const CircuitLoadResult({
    required this.power,
    required this.voltage,
    required this.current,
    required this.solved,
    required this.continuous,
    required this.designCurrent,
    required this.suggestedBreakerAmps,
    required this.notes,
  });

  final double power;
  final double voltage;
  final double current;
  final String solved;
  final bool continuous;
  final double designCurrent;
  final int? suggestedBreakerAmps;
  final String notes;
}

CircuitLoadResult calculateCircuitLoad({
  double? power,
  double? voltage,
  double? current,
  bool continuous = false,
}) {
  final provided = [power, voltage, current].where((v) => v != null).length;
  if (provided != 2) {
    throw CalculatorException(
      'Enter any TWO values. Leave the value you want calculated blank.',
    );
  }

  void check(String name, double? value) {
    if (value != null && value <= 0) {
      throw CalculatorException('$name must be greater than zero.');
    }
  }

  check('Power', power);
  check('Voltage', voltage);
  check('Current', current);

  late final String solved;
  if (power == null) {
    power = voltage! * current!;
    solved = 'power';
  } else if (voltage == null) {
    voltage = power / current!;
    solved = 'voltage';
  } else {
    current = power / voltage;
    solved = 'current';
  }

  final designCurrent = continuous ? current! * 1.25 : current!;
  int? breaker;
  for (final size in ElectricalTables.standardBreakers) {
    if (size >= designCurrent) {
      breaker = size;
      break;
    }
  }

  return CircuitLoadResult(
    power: power,
    voltage: voltage,
    current: current,
    solved: solved,
    continuous: continuous,
    designCurrent: designCurrent,
    suggestedBreakerAmps: breaker,
    notes:
        'Continuous loads are calculated at 125% of current before selecting a breaker. '
        'This is a planning aid, not a panel schedule.',
  );
}
