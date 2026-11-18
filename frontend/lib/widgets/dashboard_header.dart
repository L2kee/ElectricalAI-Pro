import 'package:flutter/material.dart';

import '../services/site_link.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'glass.dart';

/// Top bar: the EVOGENCY lotus (a link home on the web build, the same
/// spot as the site's nav logo), the "ElectricalAI Pro" wordmark, and the
/// info and settings buttons on the right.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key, required this.onOpenSettings});

  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (SiteLink.available)
          GlassIconButton(
            icon: Icons.home_outlined,
            tooltip: 'EVOGENCY home',
            link: SiteLink.home,
            onTap: () => SiteLink.open(SiteLink.home),
            child: const EvogencyLotus(height: 22),
          )
        else
          const BrandMark(size: 40),
        const SizedBox(width: 12),
        // Expanded, not Flexible + Spacer: those two split the free space
        // in half, which left a gap after the buttons and ellipsized the
        // wordmark on phones even though it fit.
        Expanded(
          child: Semantics(
            label: 'ElectricalAI Pro, by EVOGENCY',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'ElectricalAI '),
                      TextSpan(text: 'Pro', style: TextStyle(color: AppColors.signal)),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.heading(size: 19, height: 1.05),
                ),
                const SizedBox(height: 2),
                Text(
                  'by EVOGENCY',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.monoLabel(size: 10),
                ),
              ],
            ),
          ),
        ),
        GlassIconButton(
          icon: Icons.info_outline,
          tooltip: 'About this app',
          onTap: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('About this app'),
                content: const Text(
                  'Calculators run on your device and work offline. '
                  'The AI assistant and material lists need the AI backend. '
                  'It is hosted for the web version and started locally with the desktop app.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Got it'),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        GlassIconButton(
          icon: Icons.tune,
          tooltip: 'Settings',
          onTap: onOpenSettings,
        ),
      ],
    );
  }
}

/// The dashboard hero: status pill, headline, pitch, the two calls to
/// action, and the stats row.
class DashboardHero extends StatelessWidget {
  const DashboardHero({
    super.key,
    required this.onStartCalculating,
    required this.onAskAssistant,
    required this.moduleCount,
  });

  final VoidCallback onStartCalculating;
  final VoidCallback onAskAssistant;
  final int moduleCount;

  @override
  Widget build(BuildContext context) {
    final headline = AppTheme.heading(size: 42, height: 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const StatusPill('NEC tables · Runs offline'),
        const SizedBox(height: 22),
        // One heading for screen readers; two lines on screen so the
        // accent line can carry the site's olive gradient.
        Semantics(
          header: true,
          headingLevel: 1,
          label: 'Electrical math, jobsite ready.',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Electrical math,', style: headline),
              GradientText('jobsite ready.', style: headline.copyWith(fontStyle: FontStyle.normal)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Calculators built on NEC tables, plus an AI assistant for the '
          'questions a formula can\'t answer.',
          style: TextStyle(fontSize: 16, color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ElevatedButton(
              onPressed: onStartCalculating,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 26),
              ),
              child: const Text('Start calculating'),
            ),
            OutlinedButton(
              onPressed: onAskAssistant,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 26),
              ),
              child: const Text('Ask the assistant'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.only(top: 18),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            children: [
              Expanded(child: _Stat(label: 'Modules', value: '$moduleCount')),
              const Expanded(child: _Stat(label: 'Code basis', value: 'NEC')),
              const Expanded(child: _Stat(label: 'Calculators', value: 'Offline')),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.monoLabel(size: 10.5)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppTheme.heading(size: 26, height: 1.1)),
          ),
        ],
      ),
    );
  }
}
