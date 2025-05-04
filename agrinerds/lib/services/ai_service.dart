import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/config.dart';
import '../models/ai_response.dart';

class AIService {
  final SharedPreferences _prefs;
  
  AIService(this._prefs);

  // Store conversation context
  Future<void> _storeContext(String role, String content) async {
    final context = {
      'role': role,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final contexts = _prefs.getStringList('ai_contexts') ?? [];
    contexts.add(jsonEncode(context));
    await _prefs.setStringList('ai_contexts', contexts);
  }

  // Get conversation history
  Future<List<Map<String, dynamic>>> getContextHistory() async {
    final contexts = _prefs.getStringList('ai_contexts') ?? [];
    return contexts.map((context) => jsonDecode(context) as Map<String, dynamic>).toList();
  }

  // Clear conversation history
  Future<void> clearContext() async {
    await _prefs.remove('ai_contexts');
  }

  // Stream response from AI
  Stream<String> getAIResponse(String prompt) async* {
    try {
      final response = await http.post(
        Uri.parse('${Config.aiBaseUrl}/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.aiApiKey}',
        },
        body: jsonEncode({
          'model': 'llama_4_scout_17b_16e_instruct',
          'messages': [
            {"role": "user", "content": prompt}
          ],
          'temperature': 0.5,
          'max_tokens': 1024,
          'top_p': 1,
          'frequency_penalty': 0,
          'presence_penalty': 1,
          'stream': true,
        }),
      );

      if (response.statusCode == 200) {
        // Store the user's prompt
        await _storeContext('user', prompt);
        
        // Process the streamed response
        final lines = response.body.split('\n');
        String fullResponse = '';
        
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            
            try {
              final json = jsonDecode(data);
              final content = json['choices'][0]['delta']['content'];
              if (content != null) {
                fullResponse += content;
                yield content;
              }
            } catch (e) {
              // Skip invalid JSON
              continue;
            }
          }
        }
        
        // Store the AI's response
        await _storeContext('assistant', fullResponse);
      } else {
        throw Exception('Failed to get AI response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error in AI service: $e');
    }
  }

  Future<AIResponse> getAIRecommendation({
    required String crop,
    required String location,
    required Map<String, dynamic> weatherData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.aiBaseUrl}/ai/recommendation'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.aiApiKey}',
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
        Uri.parse('${Config.aiBaseUrl}/ai/analysis'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.aiApiKey}',
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