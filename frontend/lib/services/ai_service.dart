import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
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

    print("=================================");
    print("STATUS CODE: ${response.statusCode}");
    print("RAW BODY:");
    print(response.body);
    print("=================================");

    final data = jsonDecode(response.body);

    print("DECODED JSON:");
    print(data);

    if (data["answer"] != null) {
      return data["answer"].toString();
    }

    throw Exception("No 'answer' field found in response.");
  }
}