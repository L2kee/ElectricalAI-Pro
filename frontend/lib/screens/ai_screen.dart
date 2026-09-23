import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/ai_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/disclaimer_banner.dart';
import '../widgets/glass.dart';

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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const DisclaimerBanner(compact: true),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: AppTheme.panel(),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.line)),
                      ),
                      child: Row(
                        children: [
                          const PulseDot(size: 7),
                          const SizedBox(width: 8),
                          Expanded(child: MonoLabel('Code assistant', color: AppColors.muted)),
                          const MonoLabel('NEC'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _messages.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Ask an electrical question.\nThe assistant remembers this conversation until you leave the screen.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.5),
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scroll,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) => _Bubble(turn: _messages[index]),
                            ),
                    ),
                    if (_loading) const LinearProgressIndicator(minHeight: 2),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: AppColors.line)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Focus(
                              // TextField's own onSubmitted doesn't fire on Enter once
                              // maxLines > 1 - Flutter treats Enter as "insert a newline"
                              // for multi-line fields by default. Intercept it here so
                              // Enter always sends, matching the actual request (a
                              // modifier-aware Shift+Enter-for-newline variant was tried
                              // first but couldn't be verified reliably and wasn't asked
                              // for, so dropped rather than shipped half-checked).
                              onKeyEvent: (node, event) {
                                final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
                                    event.logicalKey == LogicalKeyboardKey.numpadEnter;
                                if (event is KeyDownEvent && isEnter) {
                                  _askAI();
                                  return KeyEventResult.handled;
                                }
                                return KeyEventResult.ignored;
                              },
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (_) => _askAI(),
                                decoration: const InputDecoration(
                                  hintText: 'Ask a question',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _loading ? null : _askAI,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 50),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                            ),
                            child: const Text('Ask AI'),
                          ),
                        ],
                      ),
                    ),
                  ],
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

/// Chat bubble in the design's assistant-card style: the user's turn is a
/// signal-tinted bubble on the right, the assistant's a recessed panel on
/// the left, each with one squared-off corner pointing at its speaker.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.turn});

  final _ChatTurn turn;

  @override
  Widget build(BuildContext context) {
    final isUser = turn.role == 'user';
    const r = Radius.circular(16);
    const tight = Radius.circular(4);
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Container(
          margin: EdgeInsets.only(bottom: 12, left: isUser ? 40 : 0, right: isUser ? 0 : 24),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? AppColors.signalSoft : AppColors.surfaceSunken,
            borderRadius: BorderRadius.only(
              topLeft: isUser ? r : tight,
              topRight: isUser ? tight : r,
              bottomLeft: r,
              bottomRight: r,
            ),
            border: Border.all(color: isUser ? AppColors.signalRing : AppColors.line),
          ),
          child: SelectableText(
            turn.text,
            style: TextStyle(
              fontSize: 15,
              color: isUser ? AppColors.text : AppColors.muted,
              height: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
