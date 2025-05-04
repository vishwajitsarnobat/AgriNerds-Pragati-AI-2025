class Crop {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  List<ChatMessage> chatHistory;

  Crop({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    this.chatHistory = const [],
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      chatHistory: (json['chatHistory'] as List?)
          ?.map((msg) => ChatMessage.fromJson(msg))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'chatHistory': chatHistory.map((msg) => msg.toJson()).toList(),
    };
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
} 