import 'dart:convert';

import 'package:http/http.dart' as http;

class CalculatorService {
  static const String baseUrl = "http://127.0.0.1:8000";

  Future<Map<String, dynamic>> calculateOhmsLaw({
    double? voltage,
    double? current,
    double? resistance,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ohms-law"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "voltage": voltage,
        "current": current,
        "resistance": resistance,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Server Error ${response.statusCode}\n${response.body}",
      );
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> calculateVoltageDrop({
    required double current,
    required double resistance,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/voltage-drop"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "current": current,
        "resistance": resistance,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Server Error ${response.statusCode}\n${response.body}",
      );
    }

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> calculateWireAmpacity({
    required String wireSize,
    required String temperatureRating,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/wire-ampacity"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "wire_size": wireSize,
        "temperature_rating": temperatureRating,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        "Server Error ${response.statusCode}\n${response.body}",
      );
    }

    return jsonDecode(response.body);
  }
}