import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../calculators/tables.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/glass.dart';

class NecReferenceScreen extends StatelessWidget {
  const NecReferenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const PageTitle('NEC Quick Reference'),
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
        Semantics(
          header: true,
          headingLevel: 2,
          child: Text('Standard overcurrent device ratings (breakers and fuses)', style: AppTheme.heading(size: 19)),
        ),
        const SizedBox(height: 12),
        // Reference values, not choices: a plain list. (As Chips, Flutter
        // exposed each one as a checkbox.)
        Semantics(
          role: SemanticsRole.list,
          container: true,
          explicitChildNodes: true,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final amps in ElectricalTables.standardBreakers)
                Semantics(
                  role: SemanticsRole.listItem,
                  container: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSunken,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      '$amps A',
                      semanticsLabel: '$amps amps',
                      style: TextStyle(fontFamily: AppTheme.mono, fontSize: 14, color: AppColors.text, fontFeatures: AppTheme.numeric),
                    ),
                  ),
                ),
            ],
          ),
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
        Semantics(
          header: true,
          headingLevel: 2,
          child: Text('Standard box volumes', style: AppTheme.heading(size: 19)),
        ),
        const SizedBox(height: 8),
        Text(
          'Use with the Box Fill calculator\'s "Box volume" field.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        MonoTable(
          caption: 'Standard box volumes',
          headers: const ['Box type', 'cu. in.'],
          flex: const [3, 1],
          rows: [
            for (final entry in ElectricalTables.necBoxVolumesCuIn.entries)
              [Text(entry.key), Text(entry.value.toStringAsFixed(1))],
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
        Semantics(
          header: true,
          headingLevel: 2,
          child: Text('Minimum conduit and tubing bend radius', style: AppTheme.heading(size: 19)),
        ),
        const SizedBox(height: 8),
        Text(
          'One shot (full shoe) covers machine benders. Other bends covers hand and hickey benders.',
          style: TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        MonoTable(
          caption: 'Minimum conduit and tubing bend radius',
          headers: const ['Trade size', 'One shot (in)', 'Other bends (in)'],
          rows: [
            for (final entry in ElectricalTables.necConduitBendRadiusIn.entries)
              [
                Text(entry.key),
                Text(entry.value['oneShot']!.toStringAsFixed(2)),
                Text(entry.value['otherBends']!.toStringAsFixed(2)),
              ],
          ],
        ),
      ],
    );
  }
}
