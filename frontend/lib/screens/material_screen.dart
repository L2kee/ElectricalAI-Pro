import 'package:flutter/material.dart';

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
  final _aiService = AIService();
  bool _loading = false;
  String _error = '';
  MaterialListResult? _result;

  Future<void> _generateMaterialList() async {
    final description = _projectController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _error = 'Please describe the project first.';
        _result = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final result = await _aiService.generateMaterials(description);
      setState(() => _result = result);
    } catch (e) {
      setState(() {
        _result = null;
        _error = 'Unable to generate materials. Check your connection and try again in a moment.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Material List')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MonoLabel('(b) Takeoff', color: AppColors.signal),
            const SizedBox(height: 12),
            Text(
              'Material list generator',
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
                    maxLines: 6,
                    decoration: const InputDecoration(
                      hintText:
                          'Example: 3-light branch circuit, 20A breaker, 1-gang boxes, 12 AWG NM, 50 ft run',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : _generateMaterialList,
                    child: _loading
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.onSignal),
                          )
                        : const Text('Generate material list'),
                  ),
                ],
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              SignalTag(_error, color: AppColors.danger),
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
                      Container(
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
                              style: TextStyle(fontFamily: AppTheme.mono, fontSize: 14, color: AppColors.signal),
                            ),
                          ],
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
                                  width: 4,
                                  height: 4,
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
    super.dispose();
  }
}
