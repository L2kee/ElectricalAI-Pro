import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../widgets/disclaimer_banner.dart';

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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.list_alt, size: 70, color: Colors.green),
            const SizedBox(height: 18),
            const Text(
              'Material List Generator',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Describe the job. The assistant returns a structured takeoff you can scan on site.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const DisclaimerBanner(compact: true),
            const SizedBox(height: 24),
            TextField(
              controller: _projectController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText:
                    'Example: 3-light branch circuit, 20A breaker, 1-gang boxes, 12 AWG NM, 50 ft run',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _generateMaterialList,
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                    )
                  : const Text('Generate Material List'),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(_error, style: const TextStyle(color: Colors.red, height: 1.4)),
            ],
            if (_result != null) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      for (final item in _result!.items)
                        ListTile(
                          title: Text(item.item),
                          subtitle: item.notes.isEmpty ? null : Text(item.notes),
                          trailing: Text(
                            '${_formatQty(item.qty)} ${item.unit}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (_result!.assumptions.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Assumptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                for (final assumption in _result!.assumptions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $assumption'),
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
