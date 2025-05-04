import 'package:http/http.dart' as http;
import '../models/crop.dart';

class CropService {
  final String baseUrl;
  final http.Client _client = http.Client();

  CropService({required this.baseUrl});

  Future<List<Crop>> getCrops() async {
    // TODO: Implement actual API call
    // For now, return mock data
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

  Future<Crop> createCrop(String name, String description) async {
    // TODO: Implement actual API call
    return Crop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
  }

  Future<ChatMessage> sendMessage(
    String cropId,
    String message, {
    String? imageUrl,
  }) async {
    // TODO: Implement actual AI API call
    // For now, return a mock response
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'Test output for: $message',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  Future<void> updateCropChatHistory(String cropId, ChatMessage message) async {
    // TODO: Implement actual API call to update chat history
  }

  void dispose() {
    _client.close();
  }
} 