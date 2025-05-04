import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/crop.dart';
import '../services/crop_service.dart';
import '../services/image_storage_service.dart';
import 'dart:io';

class CropChatScreen extends StatefulWidget {
  final Crop crop;
  final CropService cropService;

  const CropChatScreen({
    super.key,
    required this.crop,
    required this.cropService,
  });

  @override
  State<CropChatScreen> createState() => _CropChatScreenState();
}

class _CropChatScreenState extends State<CropChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  final ImageStorageService _imageStorageService = ImageStorageService();
  bool _isLoading = false;
  bool _isSpeaking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (!_isSpeaking) {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(text);
      await _flutterTts.awaitSpeakCompletion(true);
      setState(() => _isSpeaking = false);
    } else {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _sendMessage({String? imageUrl}) async {
    final message = _messageController.text.trim();
    if (message.isEmpty && imageUrl == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
      widget.crop.chatHistory = [
        ...widget.crop.chatHistory,
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: message,
          isUser: true,
          timestamp: DateTime.now(),
          imageUrl: imageUrl,
        ),
      ];
      _messageController.clear();
    });

    try {
      final responseStream = widget.cropService.sendMessage(
        widget.crop.id,
        message,
        imageUrl: imageUrl,
      );

      String fullResponse = '';
      final responseId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Add empty response message to chat history
      setState(() {
        widget.crop.chatHistory = [
          ...widget.crop.chatHistory,
          ChatMessage(
            id: responseId,
            content: '',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
      });

      await for (final chunk in responseStream) {
        if (!mounted) return;
        
        setState(() {
          fullResponse += chunk;
          final index = widget.crop.chatHistory.indexWhere((m) => m.id == responseId);
          if (index != -1) {
            widget.crop.chatHistory[index] = ChatMessage(
              id: responseId,
              content: fullResponse,
              isUser: false,
              timestamp: DateTime.now(),
            );
          }
        });
      }

      setState(() => _isLoading = false);
      await _speak(fullResponse);

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File imageFile = File(image.path);
      final String imagePath = await _imageStorageService.storeImage(imageFile);
      await _sendMessage(imageUrl: imagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crop.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withAlpha(26),
                    Colors.white,
                  ],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: widget.crop.chatHistory.length,
                itemBuilder: (context, index) {
                  final message = widget.crop.chatHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (message.imageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    message.imageUrl!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Text(
                                    message.content,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (!message.isUser)
                                  IconButton(
                                    icon: Icon(
                                      _isSpeaking ? Icons.stop : Icons.volume_up,
                                      color: Theme.of(context).colorScheme.primary,
                                      size: 20,
                                    ),
                                    onPressed: () => _speak(message.content),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isLoading ? null : _pickImage,
                  icon: Icon(
                    Icons.image,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about your crop...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    enabled: !_isLoading,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        )
                      : Icon(
                          Icons.send,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 