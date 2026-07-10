import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // FastAPI backend
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<String> askAI(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "message": message,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Your FastAPI server returns:
      // { "answer": "..." }

      if (data["answer"] != null) {
        return data["answer"].toString();
      } else {
        throw Exception("Backend returned no answer.");
      }
    } else {
      throw Exception(
        "Server error ${response.statusCode}: ${response.body}",
      );
    }
  }
}