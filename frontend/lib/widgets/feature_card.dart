import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Numbered module card: "01 ........ AWG" header, title, one-line
/// description, then a hairline and a footer with a signal arrow.
/// [highlighted] gives the signal-tinted "more" variant.
///
/// For screen readers the whole card is one button named by its title and
/// description. The number, tag, footer, and arrow are decoration and are
/// left out, so the card reads "Wire ampacity. Allowable ampacity by...",
/// not "03 AWG Wire ampacity ... Table 310.16 basis".
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
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final signal = AppColors.signal;
    final highlighted = widget.highlighted;
    final calm = MediaQuery.of(context).disableAnimations;
    final borderColor = _focused
        ? AppColors.focus
        : highlighted
            ? signal.withValues(alpha: 0.45)
            : _hovered
                ? signal.withValues(alpha: 0.5)
                : AppColors.line;
    final metaColor = highlighted ? signal : AppColors.faint;

    // One node: the InkWell inside contributes the tap and keyboard focus
    // (so a browser Tab reaches Flutter and the focus ring draws), and the
    // card's content is hidden behind this label.
    return Semantics(
      container: true,
      button: true,
      label: '${widget.title}. ${widget.subtitle}',
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onFocusChange: (value) => setState(() => _focused = value),
            child: ExcludeSemantics(
              child: AnimatedContainer(
              duration: calm ? Duration.zero : const Duration(milliseconds: 180),
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.panel(
                color: highlighted ? signal.withValues(alpha: 0.06) : AppColors.surface,
                // Classic cards are borderless (shadow only) unless they're
                // highlighted, hovered, or focused.
                borderColor: AppColors.isClassic && !highlighted && !_hovered && !_focused ? null : borderColor,
                borderWidth: _focused ? 2.5 : 1,
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
                  Text(widget.title, style: AppTheme.heading(size: 19, height: 1.15)),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: highlighted ? signal.withValues(alpha: 0.25) : AppColors.line,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.footer,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontFamily: AppTheme.mono, fontSize: 12.5, color: metaColor),
                          ),
                        ),
                        AnimatedSlide(
                          duration: calm ? Duration.zero : const Duration(milliseconds: 180),
                          offset: Offset(_hovered && !calm ? 0.3 : 0, 0),
                          child: Icon(Icons.arrow_forward, size: 16, color: signal),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
        // Large text (200% zoom) needs the full width per card.
        final scale = MediaQuery.textScalerOf(context).scale(1);
        if (constraints.maxWidth < twoColumnMinWidth * scale.clamp(1, 2)) {
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
