import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'disclaimer_banner.dart';
import 'glass.dart';

/// The shell every calculator screen uses: title, Inputs panel, Calculate
/// button, and Output panel.
///
/// Accessibility (2026-11-17, WCAG 2.2 AA):
/// - The screen title is a heading, and every field has a real label.
/// - After Calculate, a result is read out (each result line plus any
///   pass/fail verdict). Screen reader users would otherwise have to go
///   hunting for the Output panel.
/// - After a failed Calculate, the error is read out assertively and focus
///   moves to the first field that needs fixing: one holding something
///   that isn't a number (marked invalid), or else the first empty one.
class CalculatorScaffold extends StatefulWidget {
  const CalculatorScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitle,
    required this.fields,
    required this.onCalculate,
    required this.loading,
    this.statusMessage = '',
    this.result,
    this.footer,
  });

  final String title;
  final IconData icon;
  final String subtitle;
  final List<Widget> fields;
  final VoidCallback? onCalculate;
  final bool loading;
  final String statusMessage;
  final Widget? result;
  final Widget? footer;

  @override
  State<CalculatorScaffold> createState() => _CalculatorScaffoldState();
}

class _CalculatorScaffoldState extends State<CalculatorScaffold> {
  final _fields = <_CalculatorFieldState>[];
  final _outputKey = GlobalKey();

  void _register(_CalculatorFieldState field) => _fields.add(field);
  void _unregister(_CalculatorFieldState field) => _fields.remove(field);

  void _handleCalculate() {
    for (final field in _fields) {
      field.setInvalid(false);
    }
    widget.onCalculate?.call();
    // The screen's setState lands on the next frame; read the outcome then.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final view = View.of(context);
      if (widget.result == null && widget.statusMessage.isNotEmpty) {
        final notNumbers = _fields.where((f) => f.holdsNonNumber).toList();
        for (final field in notNumbers) {
          field.setInvalid(true);
        }
        final target = notNumbers.isNotEmpty
            ? notNumbers.first
            : _fields.where((f) => f.isEmpty).firstOrNull;
        target?.focus();
        SemanticsService.sendAnnouncement(
          view,
          StatusTag.plain(widget.statusMessage),
          TextDirection.ltr,
          assertiveness: Assertiveness.assertive,
        );
      } else if (widget.result != null) {
        final summary = _readOutput();
        if (summary.isNotEmpty) {
          SemanticsService.sendAnnouncement(view, 'Result. $summary', TextDirection.ltr);
        }
      }
    });
  }

  /// The words a sighted user reads in the Output panel, in order.
  String _readOutput() {
    final parts = <String>[];
    void visit(Element element) {
      final w = element.widget;
      if (w is ResultMetric) {
        parts.add('${w.label}, ${w.value}.');
        return;
      }
      if (w is StatusTag) {
        parts.add('${StatusTag.plain(w.message)}.');
        return;
      }
      if (w is MonoTable) {
        parts.add('${w.caption}, a table of ${w.rows.length} rows, follows.');
        return;
      }
      element.visitChildElements(visit);
    }

    _outputKey.currentContext?.visitChildElements(visit);
    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final widget = this.widget;
    return _FieldRegistry(
      state: this,
      child: Scaffold(
        appBar: AppBar(title: PageTitle(widget.title)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Row(
                  children: [
                    BrandMark(size: 36, icon: widget.icon),
                    const SizedBox(width: 12),
                    MonoLabel('Calculator', color: AppColors.signal),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // The top bar already carries this title as the page's h1, so
              // the big on-page copy is left out instead of read twice.
              ExcludeSemantics(
                child: Text(widget.title, style: AppTheme.heading(size: 28)),
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              const DisclaimerBanner(compact: true),
              const SizedBox(height: 20),
              GlassWindow(
                title: 'Inputs',
                trailing: '${widget.fields.length} fields',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...widget.fields,
                    const SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: widget.loading || widget.onCalculate == null ? null : _handleCalculate,
                      child: widget.loading
                          ? Semantics(
                              label: 'Calculating',
                              child: SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.onSignal,
                                ),
                              ),
                            )
                          : const Text('Calculate'),
                    ),
                  ],
                ),
              ),
              if (widget.statusMessage.isNotEmpty || widget.result != null) ...[
                const SizedBox(height: 16),
                GlassWindow(
                  key: _outputKey,
                  title: 'Output',
                  live: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // A result carries its own verdict line, so the status
                      // message only shows on its own (validation errors).
                      if (widget.result != null) widget.result! else StatusTag(widget.statusMessage),
                    ],
                  ),
                ),
              ],
              if (widget.footer != null) ...[
                const SizedBox(height: 16),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldRegistry extends InheritedWidget {
  const _FieldRegistry({required this.state, required super.child});

  final _CalculatorScaffoldState state;

  static _CalculatorScaffoldState? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_FieldRegistry>()?.state;

  @override
  bool updateShouldNotify(_FieldRegistry oldWidget) => false;
}

/// Renders a calculator status line ("✓ Within fill limit", "✖ Over...",
/// or a plain validation message) as a tinted tag with a matching icon:
/// the theme's pass color for success, red for a failing check, amber for
/// input problems. The icon means the state never rides on color alone.
class StatusTag extends StatelessWidget {
  const StatusTag(this.message, {super.key});

  final String message;

  static bool _isMark(String s) => s.startsWith('✓') || s.startsWith('✔') || s.startsWith('✖') || s.startsWith('⚠');

  /// The message without its leading ✓/✖/⚠ mark, which screen readers
  /// would otherwise read as "heavy check mark".
  static String plain(String message) {
    final trimmed = message.trim();
    return _isMark(trimmed) ? trimmed.substring(1).trim() : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = message.trim();
    final passed = trimmed.startsWith('✓') || trimmed.startsWith('✔');
    final failed = trimmed.startsWith('✖');
    final warned = trimmed.startsWith('⚠');
    final color = passed
        ? AppColors.pass
        : failed
            ? AppColors.danger
            : AppColors.warning;
    final icon = passed
        ? Icons.check_circle_outline
        : failed
            ? Icons.cancel_outlined
            : warned
                ? Icons.warning_amber_rounded
                : Icons.info_outline;
    return SignalTag(plain(message), color: color, icon: icon);
  }
}

/// Explanatory note under a result (table assumptions, derating hints).
class ResultNote extends StatelessWidget {
  const ResultNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(text, style: TextStyle(fontSize: 13.5, color: AppColors.muted, height: 1.5)),
    );
  }
}

/// A numeric input with a real label (not a placeholder standing in for
/// one). Registers with its [CalculatorScaffold] so a failed Calculate can
/// mark it invalid and move focus to it.
class CalculatorField extends StatefulWidget {
  const CalculatorField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  State<CalculatorField> createState() => _CalculatorFieldState();
}

class _CalculatorFieldState extends State<CalculatorField> {
  final _focusNode = FocusNode();
  _CalculatorScaffoldState? _registry;
  bool _invalid = false;

  bool get isEmpty => widget.controller.text.trim().isEmpty;
  bool get holdsNonNumber => !isEmpty && double.tryParse(widget.controller.text.trim()) == null;

  void focus() => _focusNode.requestFocus();

  void setInvalid(bool value) {
    if (_invalid != value && mounted) setState(() => _invalid = value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = _FieldRegistry.of(context);
    if (registry != _registry) {
      _registry?._unregister(this);
      _registry = registry?.._register(this);
    }
  }

  @override
  void dispose() {
    _registry?._unregister(this);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      // Material's TextField shows errorText but never tells assistive tech
      // the field is invalid; this sets aria-invalid on the web build.
      child: Semantics(
        validationResult: _invalid ? SemanticsValidationResult.invalid : SemanticsValidationResult.none,
        child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // No clearing on each keystroke: on the web build, flipping the
        // field's invalid state while someone types makes the engine drop
        // the keystroke (seen 2026-11-17, "40" became "0"). The error stays
        // until the next Calculate, which re-checks every field.
        style: TextStyle(fontFamily: AppTheme.mono, fontSize: 16, color: AppColors.text, fontFeatures: AppTheme.numeric),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          errorText: _invalid ? 'Enter a number' : null,
        ),
      ),
      ),
    );
  }
}

/// A labeled dropdown. The label is part of the field itself, so screen
/// readers say "Wire size, 12 AWG" instead of a bare "12 AWG".
class CalculatorDropdown<T> extends StatelessWidget {
  const CalculatorDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T value)? itemLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        // Fills the field and shortens a long value instead of pushing past
        // the screen edge at large text sizes.
        isExpanded: true,
        dropdownColor: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(Icons.expand_more, color: AppColors.muted),
        style: TextStyle(fontFamily: AppTheme.mono, fontSize: 16, color: AppColors.text, fontFeatures: AppTheme.numeric),
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel?.call(item) ?? item.toString(), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
      ),
    );
  }
}

/// One result line in the output panel: label on the left, the value on
/// the right, hairline underneath. Read as one phrase ("Allowable
/// ampacity, 50 A") rather than two stray fragments.
class ResultMetric extends StatelessWidget {
  const ResultMetric({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line)),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: AppColors.muted)),
            Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: AppTheme.mono,
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.text,
                fontFeatures: AppTheme.numeric,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double? parseDouble(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}

int? parseInt(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return int.tryParse(trimmed);
}
