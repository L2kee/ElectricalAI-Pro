import 'tables.dart';
import 'voltage_drop.dart';

class VoltageDropComparisonRow {
  const VoltageDropComparisonRow({
    required this.wireSize,
    required this.voltageDrop,
    required this.percentDrop,
    required this.within3Percent,
    required this.within5Percent,
  });

  final String wireSize;
  final double voltageDrop;
  final double percentDrop;
  final bool within3Percent;
  final bool within5Percent;
}

class VoltageDropComparisonResult {
  const VoltageDropComparisonResult({
    required this.results,
    required this.smallestSizeWithin3Percent,
    required this.smallestSizeWithin5Percent,
  });

  final List<VoltageDropComparisonRow> results;
  final String? smallestSizeWithin3Percent;
  final String? smallestSizeWithin5Percent;
}

VoltageDropComparisonResult compareVoltageDrop({
  required double current,
  required double lengthFt,
  required String material,
  required double voltage,
  required String phase,
}) {
  final results = ElectricalTables.voltageDropWireSizes.map((wireSize) {
    final row = calculateVoltageDrop(
      current: current,
      wireSize: wireSize,
      lengthFt: lengthFt,
      material: material,
      voltage: voltage,
      phase: phase,
    );
    return VoltageDropComparisonRow(
      wireSize: wireSize,
      voltageDrop: row.voltageDrop,
      percentDrop: row.percentDrop,
      within3Percent: row.within3Percent,
      within5Percent: row.within5Percent,
    );
  }).toList();

  String? firstWhere3Or5(bool Function(VoltageDropComparisonRow) test) {
    for (final row in results) {
      if (test(row)) return row.wireSize;
    }
    return null;
  }

  return VoltageDropComparisonResult(
    results: results,
    smallestSizeWithin3Percent: firstWhere3Or5((r) => r.within3Percent),
    smallestSizeWithin5Percent: firstWhere3Or5((r) => r.within5Percent),
  );
}
