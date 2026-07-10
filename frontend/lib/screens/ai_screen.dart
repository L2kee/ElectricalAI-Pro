import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final TextEditingController _controller = TextEditingController();
  final AIService _aiService = AIService();

  String _response = "";
  bool _loading = false;

  Future<void> _askAI() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _response = "";
    });

    try {
      final answer = await _aiService.askAI(_controller.text.trim());

      setState(() {
        _response = answer;
      });
    } catch (e) {
      setState(() {
        _response = "Error: $e";
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Ask a question",
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _askAI,
                child: const Text("Ask AI"),
              ),
            ),

            const SizedBox(height: 30),

            if (_loading)
              const CircularProgressIndicator(),

            if (!_loading)
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _response,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}