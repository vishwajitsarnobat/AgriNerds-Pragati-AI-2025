import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/ai_response.dart';

class AIService {
  final String baseUrl = Config.apiBaseUrl;
  final String apiKey = Config.apiKey;

  Future<AIResponse> getAIRecommendation({
    required String crop,
    required String location,
    required Map<String, dynamic> weatherData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/recommendation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'crop': crop,
          'location': location,
          'weather_data': weatherData,
        }),
      );

      if (response.statusCode == 200) {
        return AIResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get AI recommendation');
      }
    } catch (e) {
      throw Exception('Error getting AI recommendation: $e');
    }
  }

  Future<AIResponse> getAIAnalysis({
    required String crop,
    required Map<String, dynamic> marketData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ai/analysis'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'crop': crop,
          'market_data': marketData,
        }),
      );

      if (response.statusCode == 200) {
        return AIResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to get AI analysis');
      }
    } catch (e) {
      throw Exception('Error getting AI analysis: $e');
    }
  }
} 