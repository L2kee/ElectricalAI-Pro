import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Numbered module card from the design: "01 ........ AWG" mono header,
/// title, one-line description, then a hairline and a mono footer with a
/// signal arrow. [highlighted] gives the signal-tinted "more" variant.
class FeatureCard extends StatefulWidget {
  final String index;
  final String tag;
  final String title;
  final String subtitle;
  final String footer;
  final VoidCallback onTap;
  final bool highlighted;

  const FeatureCard({
    super.key,
    required this.index,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.footer,
    required this.onTap,
    this.highlighted = false,
  });

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final signal = AppColors.signal;
    final highlighted = widget.highlighted;
    final borderColor = highlighted
        ? signal.withValues(alpha: 0.35)
        : _hovered
            ? signal.withValues(alpha: 0.4)
            : AppColors.line;
    final metaColor = highlighted ? signal : AppColors.faint;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(18),
            decoration: AppTheme.panel(
              color: highlighted ? signal.withValues(alpha: 0.05) : AppColors.surface,
              // Classic cards are borderless (shadow only) unless they're
              // the highlighted card or being hovered.
              borderColor: AppColors.isClassic && !highlighted && !_hovered ? null : borderColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(widget.index, style: AppTheme.monoLabel(color: metaColor)),
                    const Spacer(),
                    Text(widget.tag, style: AppTheme.monoLabel(color: metaColor)),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: highlighted ? signal.withValues(alpha: 0.2) : AppColors.line,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.footer,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: AppTheme.mono, fontSize: 12, color: metaColor),
                        ),
                      ),
                      AnimatedSlide(
                        duration: const Duration(milliseconds: 180),
                        offset: Offset(_hovered ? 0.3 : 0, 0),
                        child: Icon(Icons.arrow_forward, size: 14, color: signal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays module cards out as a 2-column grid when there's room, a single
/// column on phones. Rows size to their tallest card, so nothing clips.
class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.children, this.twoColumnMinWidth = 460});

  final List<Widget> children;
  final double twoColumnMinWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 12.0;
        if (constraints.maxWidth < twoColumnMinWidth) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                children[i],
              ],
            ],
          );
        }
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          if (i > 0) rows.add(const SizedBox(height: gap));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: children[i]),
                  const SizedBox(width: gap),
                  Expanded(child: i + 1 < children.length ? children[i + 1] : const SizedBox.shrink()),
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}
