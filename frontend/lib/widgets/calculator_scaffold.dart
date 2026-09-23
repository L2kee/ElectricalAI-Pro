import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'disclaimer_banner.dart';
import 'glass.dart';

class CalculatorScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.signalSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.signalRing),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.signal),
                ),
                const SizedBox(width: 12),
                MonoLabel('Calculator', color: AppColors.signal),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.1,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            const DisclaimerBanner(compact: true),
            const SizedBox(height: 20),
            GlassWindow(
              title: 'Inputs',
              trailing: '${fields.length} fields',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...fields,
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: loading ? null : onCalculate,
                    child: loading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onSignal,
                            ),
                          )
                        : const Text('Calculate'),
                  ),
                ],
              ),
            ),
            if (statusMessage.isNotEmpty || result != null) ...[
              const SizedBox(height: 16),
              GlassWindow(
                title: 'Output',
                live: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // A result carries its own verdict line, so the status
                    // message only shows on its own (validation errors).
                    if (result != null) result! else StatusTag(statusMessage),
                  ],
                ),
              ),
            ],
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Renders a calculator status line ("✓ Within fill limit", "✖ Over...",
/// or a plain validation message) as a tinted tag: the theme's pass color
/// for success, red for a failing check, amber for input problems.
class StatusTag extends StatelessWidget {
  const StatusTag(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final trimmed = message.trim();
    final passed = trimmed.startsWith('✓') || trimmed.startsWith('✔');
    final failed = trimmed.startsWith('✖');
    final warned = trimmed.startsWith('⚠');
    final text = (passed || failed || warned) ? trimmed.substring(1).trim() : trimmed;
    final color = passed
        ? AppColors.pass
        : failed
            ? AppColors.danger
            : AppColors.warning;
    return SignalTag(text, color: color);
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
      child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5)),
    );
  }
}

class CalculatorField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(label, color: AppColors.muted),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(fontFamily: AppTheme.mono, fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonoLabel(label, color: AppColors.muted),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            initialValue: value,
            dropdownColor: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(Icons.expand_more, color: AppColors.muted),
            style: TextStyle(fontFamily: AppTheme.mono, fontSize: 15, color: AppColors.text),
            items: items
                .map(
                  (item) => DropdownMenuItem<T>(
                    value: item,
                    child: Text(itemLabel?.call(item) ?? item.toString()),
                  ),
                )
                .toList(),
            onChanged: (next) {
              if (next != null) onChanged(next);
            },
          ),
        ],
      ),
    );
  }
}

/// One result line in the output panel: mono label on the left, the value
/// on the right, hairline underneath - the "Conductor ampacity .... 30 A"
/// row from the design's verification card.
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.muted)),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: AppTheme.mono,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.text,
            ),
          ),
        ],
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
