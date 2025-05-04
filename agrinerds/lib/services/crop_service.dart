import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/crop.dart';
import 'ai_service.dart';

class CropService {
  final String baseUrl;
  final http.Client _client = http.Client();
  late final AIService _aiService;

  CropService({required this.baseUrl}) {
    SharedPreferences.getInstance().then((prefs) {
      _aiService = AIService(prefs);
    });
  }

  Future<List<Crop>> getCrops() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/crops'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Crop.fromJson(json)).toList();
      }
      throw Exception('Failed to load crops');
    } catch (e) {
      // Fallback to mock data if API fails
      return [
        Crop(
          id: '1',
          name: 'Wheat',
          description: 'Winter wheat crop',
          createdAt: DateTime.now(),
        ),
        Crop(
          id: '2',
          name: 'Rice',
          description: 'Basmati rice crop',
          createdAt: DateTime.now(),
        ),
      ];
    }
  }

  Future<Crop> createCrop(String name, String description) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/crops'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'description': description,
        }),
      );
      if (response.statusCode == 201) {
        return Crop.fromJson(jsonDecode(response.body));
      }
      throw Exception('Failed to create crop');
    } catch (e) {
      // Fallback to mock data if API fails
      return Crop(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        createdAt: DateTime.now(),
      );
    }
  }

  Stream<String> sendMessage(
    String cropId,
    String message, {
    String? imageUrl,
  }) async* {
    try {
      final prompt = '''
        Crop ID: $cropId
        Message: $message
        ${imageUrl != null ? 'Image URL: $imageUrl' : ''}
        
        Please provide a detailed response about this crop-related query.
      ''';

      yield* _aiService.getAIResponse(prompt);
    } catch (e) {
      yield 'Error: Failed to get AI response';
    }
  }

  Future<void> updateCropChatHistory(String cropId, ChatMessage message) async {
    try {
      await _client.post(
        Uri.parse('$baseUrl/crops/$cropId/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(message.toJson()),
      );
    } catch (e) {
      // Silently fail for now, could be implemented with local storage as fallback
    }
  }

  void dispose() {
    _client.close();
  }
} 