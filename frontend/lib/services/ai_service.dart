import 'dart:convert';

import 'package:http/http.dart' as http;

class AIService {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  String? conversationId;

  Future<String> askAI(String message) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            if (conversationId != null) 'conversation_id': conversationId,
          }),
        )
        .timeout(const Duration(seconds: 60));

    final body = _decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Server error ${response.statusCode}');
    }

    conversationId = body['conversation_id'] as String? ?? conversationId;
    final answer = body['answer'];
    if (answer == null) {
      throw Exception('Backend returned no answer.');
    }
    return answer.toString();
  }

  Future<MaterialListResult> generateMaterials(String description) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/material-list'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'project_description': description}),
        )
        .timeout(const Duration(seconds: 60));

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Server error ${response.statusCode}');
    }

    final items = <MaterialItem>[];
    for (final row in (body['items'] as List? ?? const [])) {
      if (row is! Map) continue;
      items.add(
        MaterialItem(
          item: '${row['item'] ?? ''}',
          qty: (row['qty'] as num?)?.toDouble() ?? 0,
          unit: '${row['unit'] ?? 'ea'}',
          notes: '${row['notes'] ?? ''}',
        ),
      );
    }

    return MaterialListResult(
      items: items,
      assumptions: [
        for (final item in (body['assumptions'] as List? ?? const [])) item.toString(),
      ],
    );
  }

  Map<String, dynamic> _decode(String raw) {
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return {'error': raw};
    }
  }
}

class MaterialListResult {
  const MaterialListResult({required this.items, required this.assumptions});

  final List<MaterialItem> items;
  final List<String> assumptions;
}

class MaterialItem {
  const MaterialItem({
    required this.item,
    required this.qty,
    required this.unit,
    required this.notes,
  });

  final String item;
  final double qty;
  final String unit;
  final String notes;
}
