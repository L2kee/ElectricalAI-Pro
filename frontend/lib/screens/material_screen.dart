import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../services/ai_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/glass.dart';

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final _projectController = TextEditingController();
  final _projectFocus = FocusNode();
  final _aiService = AIService();
  bool _loading = false;
  String _error = '';
  MaterialListResult? _result;
  bool _missingDescription = false;

  void _announce(String message, {bool urgent = false}) {
    if (!mounted) return;
    SemanticsService.sendAnnouncement(
      View.of(context),
      message,
      TextDirection.ltr,
      assertiveness: urgent ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  Future<void> _generateMaterialList() async {
    final description = _projectController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _missingDescription = true;
        _error = '';
        _result = null;
      });
      _projectFocus.requestFocus();
      _announce('Describe the project first.', urgent: true);
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _missingDescription = false;
    });
    _announce('Building the material list. This can take up to a minute.');

    try {
      final result = await _aiService.generateMaterials(description);
      if (!mounted) return;
      setState(() => _result = result);
      _announce('Takeoff ready, ${result.items.length} items. ${result.items.map((i) => '${_formatQty(i.qty)} ${i.unit} ${i.item}').join('. ')}.');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _result = null;
        _error = 'Unable to generate materials. Check your connection and try again in a moment.';
      });
      _announce(_error, urgent: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const PageTitle('Material List')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(child: MonoLabel('(b) Takeoff', color: AppColors.signal)),
            const SizedBox(height: 12),
            Semantics(
              header: true,
              headingLevel: 2,
              child: Text('Material list generator', style: AppTheme.heading(size: 28)),
            ),
            const SizedBox(height: 8),
            Text(
              'Describe the job. The assistant returns a structured takeoff you can scan on site.',
              style: TextStyle(fontSize: 15, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            const DisclaimerBanner(compact: true),
            const SizedBox(height: 20),
            GlassWindow(
              title: 'Job description',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _projectController,
                    focusNode: _projectFocus,
                    maxLines: 6,
                    onChanged: (_) {
                      if (_missingDescription) setState(() => _missingDescription = false);
                    },
                    decoration: InputDecoration(
                      labelText: 'Job description',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      alignLabelWithHint: true,
                      hintText:
                          'For example, three lights on a 20A branch circuit, single gang boxes, 12 AWG NM, 50 ft run',
                      errorText: _missingDescription ? 'Describe the project first.' : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _generateMaterialList,
                    child: _loading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.onSignal,
                              semanticsLabel: 'Building the material list',
                            ),
                          )
                        : const Text('Generate material list'),
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              SignalTag(_error, color: AppColors.danger, icon: Icons.error_outline),
            ],
            if (_result != null) ...[
              const SizedBox(height: 16),
              GlassWindow(
                title: 'Takeoff',
                trailing: '${_result!.items.length} items',
                live: true,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  children: [
                    for (final item in _result!.items)
                      MergeSemantics(
                        child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: item == _result!.items.last
                                ? BorderSide.none
                                : BorderSide(color: AppColors.line),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.item,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text),
                                  ),
                                  if (item.notes.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(item.notes, style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4)),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${_formatQty(item.qty)} ${item.unit}',
                              style: TextStyle(
                                fontFamily: AppTheme.mono,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.signal,
                                fontFeatures: AppTheme.numeric,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ),
                  ],
                ),
              ),
              if (_result!.assumptions.isNotEmpty) ...[
                const SizedBox(height: 16),
                GlassWindow(
                  title: 'Assumptions',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final assumption in _result!.assumptions)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8, right: 10),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(color: AppColors.signal, shape: BoxShape.circle),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  assumption,
                                  style: TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toStringAsFixed(0);
    return qty.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _projectController.dispose();
    _projectFocus.dispose();
    super.dispose();
  }
}
