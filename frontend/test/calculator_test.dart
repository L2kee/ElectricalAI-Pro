import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/calculators/box_fill.dart';
import 'package:frontend/calculators/circuit_load.dart';
import 'package:frontend/calculators/conduit_fill.dart';
import 'package:frontend/calculators/motor_flc.dart';
import 'package:frontend/calculators/ohms_law.dart';
import 'package:frontend/calculators/tables.dart';
import 'package:frontend/calculators/transformer_sizing.dart';
import 'package:frontend/calculators/voltage_drop.dart';
import 'package:frontend/calculators/wire_ampacity.dart';

void main() {
  test('Ohm’s law solves voltage', () {
    final result = calculateOhmsLaw(current: 10, resistance: 12);
    expect(result.value, 120);
    expect(result.unit, 'V');
  });

  test('voltage drop 12 AWG 75 ft 16 A', () {
    final result = calculateVoltageDrop(
      current: 16,
      wireSize: '12 AWG',
      lengthFt: 75,
      material: 'copper',
      voltage: 120,
      phase: 'single',
    );
    expect(result.voltageDrop, closeTo(4.632, 0.01));
    expect(result.within3Percent, isFalse);
    expect(result.within5Percent, isTrue);
  });

  test('box fill counts yokes as two and grounds once', () {
    final result = calculateBoxFill(
      boxVolume: 18,
      conductorSize: '12 AWG',
      conductorCount: 4,
      deviceCount: 1,
      clampCount: 2,
      equipmentGroundCount: 3,
    );
    expect(result.requiredVolume, 18);
    expect(result.boxIsLargeEnough, isTrue);
  });

  test('conduit fill three 12 AWG in 1/2 EMT', () {
    final result = calculateConduitFill(
      conduitType: 'EMT',
      tradeSize: '1/2',
      wireSize: '12 AWG',
      wireCount: 3,
    );
    expect(result.percentFill, closeTo(13.13, 0.05));
    expect(result.withinLimit, isTrue);
  });

  test('ampacity copper 12 AWG 75C', () {
    final result = calculateWireAmpacity(
      wireSize: '12 AWG',
      temperatureRating: '75',
      material: 'copper',
    );
    expect(result.ampacity, 25);
    expect(result.typicalBranchOcpdAmps, 20);
  });

  test('circuit load continuous 125 percent', () {
    final result = calculateCircuitLoad(power: 1920, voltage: 120, continuous: true);
    expect(result.current, 16);
    expect(result.designCurrent, 20);
    expect(result.suggestedBreakerAmps, 20);
  });

  test('rejects zero current', () {
    expect(
      () => calculateOhmsLaw(voltage: 120, current: 0),
      throwsA(isA<CalculatorException>()),
    );
  });

  test('motor FLC three-phase 10 HP 230V', () {
    final result = calculateMotorFlc(horsepower: '10', voltage: '230', phase: 'three');
    expect(result.fullLoadCurrent, 28.0);
    expect(result.minConductorAmpacityAmps, 35.0);
  });

  test('motor FLC single-phase 5 HP 115V', () {
    final result = calculateMotorFlc(horsepower: '5', voltage: '115', phase: 'single');
    expect(result.fullLoadCurrent, 56.0);
  });

  test('motor FLC rejects unsupported voltage', () {
    expect(
      () => calculateMotorFlc(horsepower: '10', voltage: '120', phase: 'three'),
      throwsA(isA<CalculatorException>()),
    );
  });

  test('transformer sizing three-phase 75kVA 480 to 208', () {
    final result = calculateTransformerSizing(
      kva: 75,
      primaryVoltage: 480,
      secondaryVoltage: 208,
      phase: 'three',
    );
    expect(result.primaryFla, 90.21);
    expect(result.secondaryFla, 208.19);
  });

  test('transformer sizing single-phase 25kVA 240 to 120', () {
    final result = calculateTransformerSizing(
      kva: 25,
      primaryVoltage: 240,
      secondaryVoltage: 120,
      phase: 'single',
    );
    expect(result.primaryFla, 104.17);
    expect(result.secondaryFla, 208.33);
  });

  test('transformer sizing rejects zero kVA', () {
    expect(
      () => calculateTransformerSizing(kva: 0, primaryVoltage: 480, secondaryVoltage: 208),
      throwsA(isA<CalculatorException>()),
    );
  });
}
