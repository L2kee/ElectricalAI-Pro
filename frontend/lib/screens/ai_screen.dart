import 'package:flutter/material.dart';

import '../services/ai_service.dart';
import '../theme/app_colors.dart';
import '../widgets/disclaimer_banner.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _aiService = AIService();
  final _messages = <_ChatTurn>[];
  bool _loading = false;

  Future<void> _askAI() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add(_ChatTurn(role: 'user', text: text));
      _loading = true;
    });
    _controller.clear();

    try {
      final answer = await _aiService.askAI(text);
      setState(() {
        _messages.add(_ChatTurn(role: 'assistant', text: answer));
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatTurn(
            role: 'assistant',
            text:
                'Could not reach the AI assistant. Check your connection '
                'and try again in a moment.',
          ),
        );
      });
    } finally {
      setState(() => _loading = false);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const DisclaimerBanner(compact: true),
            const SizedBox(height: 16),
            Expanded(
              child: _messages.isEmpty
                  ? const Center(
                      child: Text(
                        'Ask an electrical question.\nThe assistant remembers this conversation until you leave the screen.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      controller: _scroll,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final turn = _messages[index];
                        final isUser = turn.role == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            constraints: const BoxConstraints(maxWidth: 720),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFFC62828) : AppColors.surface,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                              ],
                            ),
                            child: SelectableText(
                              turn.text,
                              style: TextStyle(
                                fontSize: 16,
                                color: isUser ? Colors.white : AppColors.dark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => _askAI(),
              decoration: const InputDecoration(
                labelText: 'Ask a question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _askAI,
                child: const Text('Ask AI'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }
}

class _ChatTurn {
  const _ChatTurn({required this.role, required this.text});

  final String role;
  final String text;
}
