import 'package:flutter/material.dart';

import '../calculators/tables.dart';
import '../widgets/disclaimer_banner.dart';

class NecReferenceScreen extends StatelessWidget {
  const NecReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NEC Quick Reference'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Breaker Sizes'),
              Tab(text: 'Box Volumes'),
              Tab(text: 'Bend Radius'),
            ],
          ),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DisclaimerBanner(compact: true),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _BreakerSizesTab(),
                  _BoxVolumesTab(),
                  _BendRadiusTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakerSizesTab extends StatelessWidget {
  const _BreakerSizesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Standard overcurrent device ratings (breakers and fuses)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final amps in ElectricalTables.standardBreakers)
              Chip(label: Text('$amps A')),
          ],
        ),
      ],
    );
  }
}

class _BoxVolumesTab extends StatelessWidget {
  const _BoxVolumesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Standard box volumes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use with the Box Fill calculator\'s "Box volume" field.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1)},
          children: [
            const TableRow(
              children: [
                Padding(padding: EdgeInsets.all(6), child: Text('Box type', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(6), child: Text('cu. in.', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            for (final entry in ElectricalTables.necBoxVolumesCuIn.entries)
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(6), child: Text(entry.key)),
                  Padding(padding: const EdgeInsets.all(6), child: Text(entry.value.toStringAsFixed(1))),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _BendRadiusTab extends StatelessWidget {
  const _BendRadiusTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Minimum conduit/tubing bend radius',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'One-shot/full-shoe covers machine benders; other bends covers hand and hickey benders.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2), 2: FlexColumnWidth(2)},
          children: [
            const TableRow(
              children: [
                Padding(padding: EdgeInsets.all(6), child: Text('Trade size', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(6), child: Text('One-shot (in)', style: TextStyle(fontWeight: FontWeight.bold))),
                Padding(padding: EdgeInsets.all(6), child: Text('Other bends (in)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            for (final entry in ElectricalTables.necConduitBendRadiusIn.entries)
              TableRow(
                children: [
                  Padding(padding: const EdgeInsets.all(6), child: Text(entry.key)),
                  Padding(padding: const EdgeInsets.all(6), child: Text(entry.value['oneShot']!.toStringAsFixed(2))),
                  Padding(padding: const EdgeInsets.all(6), child: Text(entry.value['otherBends']!.toStringAsFixed(2))),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
