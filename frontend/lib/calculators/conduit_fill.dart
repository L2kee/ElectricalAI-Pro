import 'tables.dart';

class ConduitFillResult {
  const ConduitFillResult({
    required this.conduitArea,
    required this.wireArea,
    required this.totalWireArea,
    required this.percentFill,
    required this.fillLimitPercent,
    required this.withinLimit,
    required this.notes,
  });

  final double conduitArea;
  final double wireArea;
  final double totalWireArea;
  final double percentFill;
  final double fillLimitPercent;
  final bool withinLimit;
  final String notes;
}

ConduitFillResult calculateConduitFill({
  required String conduitType,
  required String tradeSize,
  required String wireSize,
  required int wireCount,
}) {
  if (wireCount <= 0) {
    throw CalculatorException('Wire count must be greater than zero.');
  }

  final raceway = conduitType.toUpperCase();
  final sizes = ElectricalTables.conduitAreaSqIn[raceway];
  if (sizes == null) {
    throw CalculatorException('Conduit type must be EMT, PVC-40, or RMC.');
  }

  final conduitArea = sizes[tradeSize];
  if (conduitArea == null) {
    throw CalculatorException('Unsupported $raceway trade size: $tradeSize');
  }

  final wireArea = ElectricalTables.thhnAreaSqIn[wireSize];
  if (wireArea == null) {
    throw CalculatorException('Unsupported THHN wire size: $wireSize');
  }

  late final double limit;
  late final String limitNote;
  if (wireCount == 1) {
    limit = 53;
    limitNote = '1 conductor: 53% fill';
  } else if (wireCount == 2) {
    limit = 31;
    limitNote = '2 conductors: 31% fill';
  } else {
    limit = 40;
    limitNote = '3 or more conductors: 40% fill';
  }

  final total = wireArea * wireCount;
  final percent = (total / conduitArea) * 100.0;

  return ConduitFillResult(
    conduitArea: conduitArea,
    wireArea: wireArea,
    totalWireArea: total,
    percentFill: percent,
    fillLimitPercent: limit,
    withinLimit: percent <= limit,
    notes: '$limitNote. Uses approximate THHN/THWN areas. Nipples 24 in. or less may use 60%.',
  );
}
