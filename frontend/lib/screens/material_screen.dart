import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MaterialScreen extends StatefulWidget {
  const MaterialScreen({super.key});

  @override
  State<MaterialScreen> createState() => _MaterialScreenState();
}

class _MaterialScreenState extends State<MaterialScreen> {
  final TextEditingController _projectController = TextEditingController();
  bool _loading = false;
  String _result = '';

  Future<void> _generateMaterialList() async {
    final description = _projectController.text.trim();
    if (description.isEmpty) {
      setState(() {
        _result = 'Please describe the project first.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/material-list'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'project_description': description}),
      );

      if (response.statusCode != 200) {
        throw Exception('Server Error ${response.statusCode}');
      }

      final body = jsonDecode(response.body);
      setState(() {
        _result = (body['materials'] as String).trim();
      });
    } catch (e) {
      setState(() {
        _result = 'Unable to generate materials right now.\n$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
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
              'Describe your electrical project and generate a practical material list.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _projectController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Example: 3-light branch circuit, 20A breaker, 1-gang box, 12 AWG wire',
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
            const SizedBox(height: 24),
            if (_result.isNotEmpty)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _projectController.dispose();
    super.dispose();
  }
}