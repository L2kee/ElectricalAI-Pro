import 'tables.dart';

class WireAmpacityResult {
  const WireAmpacityResult({
    required this.ampacity,
    required this.typicalBranchOcpdAmps,
    required this.notes,
  });

  final int ampacity;
  final int? typicalBranchOcpdAmps;
  final String notes;
}

WireAmpacityResult calculateWireAmpacity({
  required String wireSize,
  required String temperatureRating,
  required String material,
}) {
  final metal = material.toLowerCase();
  final table = metal == 'copper'
      ? ElectricalTables.copperAmpacity
      : metal == 'aluminum'
          ? ElectricalTables.aluminumAmpacity
          : null;
  if (table == null) {
    throw CalculatorException('Material must be copper or aluminum.');
  }

  final row = table[wireSize];
  if (row == null) {
    throw CalculatorException('Unsupported $metal wire size: $wireSize');
  }

  final rating = temperatureRating.replaceAll('°C', '').replaceAll('C', '').trim();
  final ampacity = row[rating];
  if (ampacity == null) {
    throw CalculatorException('Temperature rating must be 60, 75, or 90.');
  }

  final ocpd = ElectricalTables.smallConductorOcpd['$metal|$wireSize'];
  final notes = StringBuffer(
    'Lookup is for 3 or fewer current-carrying conductors in a raceway or cable, 30°C ambient. '
    'Apply ambient and bundling adjustments before selecting overcurrent protection.',
  );
  if (ocpd != null) {
    notes.write(
      ' Small-conductor overcurrent is commonly limited to $ocpd A for $metal $wireSize '
      'on typical branch circuits unless an exception applies.',
    );
  }

  return WireAmpacityResult(
    ampacity: ampacity,
    typicalBranchOcpdAmps: ocpd,
    notes: notes.toString(),
  );
}
