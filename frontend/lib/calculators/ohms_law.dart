import 'tables.dart';

class OhmsLawResult {
  const OhmsLawResult({required this.label, required this.value, required this.unit});

  final String label;
  final double value;
  final String unit;
}

OhmsLawResult calculateOhmsLaw({
  double? voltage,
  double? current,
  double? resistance,
}) {
  final provided = [voltage, current, resistance].where((v) => v != null).length;
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

  check('Voltage', voltage);
  check('Current', current);
  check('Resistance', resistance);

  if (voltage == null) {
    return OhmsLawResult(label: 'Voltage', value: current! * resistance!, unit: 'V');
  }
  if (current == null) {
    return OhmsLawResult(label: 'Current', value: voltage / resistance!, unit: 'A');
  }
  return OhmsLawResult(label: 'Resistance', value: voltage / current, unit: 'Ω');
}
