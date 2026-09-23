import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The base surface every card, form, and result block sits on. Drawn by
/// AppTheme.panel: a hairline glass panel in Kinetic glass, a shadowed
/// card in Classic.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 16,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: AppTheme.panel(color: color, radius: radius, borderColor: borderColor),
      child: child,
    );
  }
}

/// A glass panel with a mono header bar ("CODE ASSISTANT ........ NEC"),
/// the same shape as the assistant and verification cards in the design.
class GlassWindow extends StatelessWidget {
  const GlassWindow({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.live = false,
    this.padding = const EdgeInsets.all(20),
  });

  final String title;
  final String? trailing;
  final bool live;
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppTheme.panel(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.line)),
            ),
            child: Row(
              children: [
                if (live) ...[
                  const PulseDot(),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: AppTheme.monoLabel(color: AppColors.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (trailing != null)
                  Text(trailing!, style: AppTheme.monoLabel()),
              ],
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Small uppercase mono label.
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color, this.size = 11});

  final String text;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AppTheme.monoLabel(color: color, size: size));
  }
}

/// The slow-breathing signal dot used on "live" status pills.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.size = 6});

  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: AppColors.signal, shape: BoxShape.circle),
      ),
    );
  }
}

/// Rounded status pill: pulse dot + mono text ("NEC TABLES · RUNS OFFLINE").
class StatusPill extends StatelessWidget {
  const StatusPill(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const PulseDot(),
          const SizedBox(width: 8),
          Flexible(child: MonoLabel(text, color: AppColors.muted)),
        ],
      ),
    );
  }
}

/// Signal-tinted mono strip, e.g. "Within 3% · common branch target".
/// [color] overrides the signal tint for pass/warn/fail states.
class SignalTag extends StatelessWidget {
  const SignalTag(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.signal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontFamily: AppTheme.mono, fontSize: 12, color: tint, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// The product mark: a bolt in a signal-tinted tile.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.signalSoft,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(color: AppColors.signalRing),
      ),
      child: Icon(Icons.bolt, size: size * 0.6, color: AppColors.signal),
    );
  }
}

/// Glass icon button (the info/settings buttons in the header).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Ink(
            width: 40,
            height: 40,
            // Flat in both themes: Ink paints a drop shadow unclipped,
            // which showed square corners behind Classic's rounded button.
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Icon(icon, size: 20, color: AppColors.isClassic ? AppColors.signal : AppColors.muted),
          ),
        ),
      ),
    );
  }
}

/// Striped data table in mono type with a mono uppercase header row, used
/// for the comparison and quick-reference tables.
class MonoTable extends StatelessWidget {
  const MonoTable({
    super.key,
    required this.headers,
    required this.rows,
    this.flex,
  });

  final List<String> headers;
  final List<List<Widget>> rows;
  final List<int>? flex;

  @override
  Widget build(BuildContext context) {
    final widths = <int, TableColumnWidth>{
      for (var i = 0; i < headers.length; i++) i: FlexColumnWidth((flex?[i] ?? 1).toDouble()),
    };
    Widget cell(Widget child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: child,
        );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: AppTheme.mono, fontSize: 13, color: AppColors.text),
        child: Table(
          columnWidths: widths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: AppColors.surfaceSunken,
                border: Border(bottom: BorderSide(color: AppColors.line)),
              ),
              children: [for (final h in headers) cell(MonoLabel(h))],
            ),
            for (var r = 0; r < rows.length; r++)
              TableRow(
                decoration: BoxDecoration(
                  color: r.isOdd ? AppColors.surfaceSunken.withValues(alpha: 0.5) : null,
                ),
                children: [for (final c in rows[r]) cell(c)],
              ),
          ],
        ),
      ),
    );
  }
}
