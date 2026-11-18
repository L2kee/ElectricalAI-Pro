import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// The base surface every card, form, and result block sits on. Drawn by
/// AppTheme.panel: a hairline glass panel in EVOGENCY, a shadowed card in
/// Classic.
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

/// A glass panel with a small uppercase header bar ("INPUTS .... 3 FIELDS").
/// The title is a heading for screen readers, so people can jump between
/// the Inputs and Output panels the way sighted users scan them.
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
                  child: Semantics(
                    header: true,
                    headingLevel: 2,
                    child: Text(
                      title.toUpperCase(),
                      semanticsLabel: title,
                      style: AppTheme.monoLabel(color: AppColors.muted),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(trailing!, style: AppTheme.monoLabel()),
              ],
            ),
          ),
          // A transparent Material so list tiles, switches, and ink inside
          // the panel can paint their focus highlight and ripple. Without
          // it a keyboard user tabbing onto a switch sees nothing.
          Material(
            type: MaterialType.transparency,
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

/// A screen's title in the top bar, exposed as its one level 1 heading.
/// (Flutter marks every heading level 2 unless told otherwise, which left
/// screen reader users with a flat outline.)
class PageTitle extends StatelessWidget {
  const PageTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Semantics(headingLevel: 1, child: Text(text));
  }
}

/// Small uppercase label. Screen readers get the normal-case text, so an
/// all-caps "AWG" style label isn't spelled out letter by letter.
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {super.key, this.color, this.size = 11});

  final String text;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      semanticsLabel: text,
      style: AppTheme.monoLabel(color: color, size: size),
    );
  }
}

/// The slow-breathing signal dot used on "live" status pills. Purely
/// decorative, and it holds still when the device asks for reduced motion.
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
    value: 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 1;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.35, end: 1).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        ),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(color: AppColors.signal, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// Rounded status pill: pulse dot + label ("NEC TABLES · RUNS OFFLINE").
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

/// Tinted status strip, e.g. "Within 3% · common branch target".
/// [color] overrides the signal tint for pass/warn/fail states, and [icon]
/// adds a shape so the state never rides on color alone.
class SignalTag extends StatelessWidget {
  const SignalTag(this.text, {super.key, this.color, this.icon});

  final String text;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppColors.signal;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: tint.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: icon != null
                ? Icon(icon, size: 16, color: tint)
                : Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontFamily: AppTheme.mono, fontSize: 13, color: tint, height: 1.4, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// The product mark: a bolt in a faceted, signal-tinted tile. Decorative;
/// whatever it sits next to carries the name.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 32, this.icon = Icons.bolt});

  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: ShapeDecoration(
          color: AppColors.signalSoft,
          shape: AppTheme.facet(cut: size * 0.28, side: BorderSide(color: AppColors.signalRing)),
        ),
        child: Icon(icon, size: size * 0.6, color: AppColors.signal),
      ),
    );
  }
}

/// The EVOGENCY lotus, from the site's logo. Decorative here; the link it
/// sits in carries the accessible name.
class EvogencyLotus extends StatelessWidget {
  const EvogencyLotus({super.key, this.height = 22});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset('assets/brand/evogency-lotus.png', height: height, filterQuality: FilterQuality.medium),
    );
  }
}

/// Text painted with the brand's olive gradient, like the site's `.hero-accent`.
/// Classic has no gradient, so it paints in the plain signal color.
class GradientText extends StatelessWidget {
  const GradientText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (AppColors.isClassic) {
      return Text(text, style: style.copyWith(color: AppColors.signal));
    }
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppColors.signalGradient.createShader(bounds),
      child: Text(text, style: style.copyWith(color: AppColors.signal)),
    );
  }
}

/// Glass icon button (the info/settings buttons in the header): a 48px
/// target, the tooltip as its accessible name, and a visible focus ring.
class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.child,
    this.link,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  /// Replaces the icon (the EVOGENCY lotus).
  final Widget? child;

  /// When set, screen readers get a real link to this address.
  final Uri? link;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        onFocusChange: (value) => setState(() => _focused = value),
        child: Ink(
          width: 48,
          height: 48,
          // Flat in both themes: Ink paints a drop shadow unclipped,
          // which showed square corners behind Classic's rounded button.
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focused ? AppColors.focus : AppColors.line,
              width: _focused ? 2.5 : 1,
            ),
          ),
          child: Center(
            child: widget.child ??
                Icon(widget.icon, size: 22, color: AppColors.isClassic ? AppColors.signal : AppColors.muted),
          ),
        ),
      ),
    );
    if (widget.link == null) {
      return Tooltip(message: widget.tooltip, child: button);
    }
    // Same node as the InkWell, so its keyboard focus still reaches
    // Flutter; the link role and real URL make the web build render an
    // <a href> that people can open in a new tab.
    return Tooltip(
      message: widget.tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        link: true,
        linkUrl: widget.link,
        label: widget.tooltip,
        child: button,
      ),
    );
  }
}

/// Striped data table with an uppercase header row, used for the
/// comparison and quick-reference tables. Built from rows and cells that
/// carry the table, row, column header, and cell roles, so a screen reader
/// announces "row 3 of 12, column Drop" instead of a loose run of text.
class MonoTable extends StatelessWidget {
  const MonoTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.caption,
    this.flex,
  });

  final List<String> headers;
  final List<List<Widget>> rows;
  final List<int>? flex;

  /// What the table is, read before its rows ("Voltage drop by wire size").
  final String caption;

  @override
  Widget build(BuildContext context) {
    Widget cell(Widget child, int i, {required bool header}) => Expanded(
          flex: flex?[i] ?? 1,
          child: Semantics(
            role: header ? SemanticsRole.columnHeader : SemanticsRole.cell,
            container: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: child,
            ),
          ),
        );

    Widget row(List<Widget> children, {required bool header, Color? color}) => Semantics(
          role: SemanticsRole.row,
          container: true,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: header ? Border(bottom: BorderSide(color: AppColors.line)) : null,
            ),
            child: Row(
              children: [for (var i = 0; i < children.length; i++) cell(children[i], i, header: header)],
            ),
          ),
        );

    return Semantics(
      role: SemanticsRole.table,
      label: caption,
      container: true,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(fontFamily: AppTheme.mono, fontSize: 14, color: AppColors.text, fontFeatures: AppTheme.numeric),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              row([for (final h in headers) MonoLabel(h)], header: true, color: AppColors.surfaceSunken),
              for (var r = 0; r < rows.length; r++)
                row(
                  rows[r],
                  header: false,
                  color: r.isOdd ? AppColors.surfaceSunken.withValues(alpha: 0.5) : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
