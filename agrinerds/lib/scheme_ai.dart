import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'models/ai_response.dart';

class SchemeAIPage extends StatefulWidget {
  const SchemeAIPage({super.key});

  @override
  State<SchemeAIPage> createState() => _SchemeAIPageState();
}

class _SchemeAIPageState extends State<SchemeAIPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _flutterTts = FlutterTts();
  final SpeechToText _speechToText = SpeechToText();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _speechAvailable = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _initSpeech() async {
    _speechAvailable = await _speechToText.initialize();
      if (!_speechAvailable) {
        setState(() {
        _error = 'Speech recognition not available';
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      setState(() {
        _error = 'Speech recognition not available';
      });
      return;
    }

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _error = null;
      });
      
        await _speechToText.listen(
          onResult: (result) {
            setState(() {
            _messageController.text = result.recognizedWords;
            });
          },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.confirmation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } else {
      setState(() => _isListening = false);
      await _speechToText.stop();
    }
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
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _messages.add(ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _messageController.clear();
    });

    try {
      // TODO: Implement API call based on input type
      // For text input:
      // - Endpoint: /api/chat/text
      // - Input: { "message": message }
      // - Expected output: AIResponse object with recommendation and analysis
      
      // For audio input:
      // - Endpoint: /api/chat/audio
      // - Input: { "audio_file": audioFile }
      // - Expected output: AIResponse object with recommendation and analysis

      // Mock response for now
      await Future.delayed(const Duration(seconds: 1));
      final response = AIResponse(
        recommendation: 'This is a test response for: $message',
        analysis: {
          'type': 'test',
          'details': 'Mock analysis data',
        },
        confidence: 0.95,
        supportingFactors: [
          'Factor 1: Test data',
          'Factor 2: Mock analysis',
        ],
        timestamp: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: response.recommendation,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
      });

      // Speak the response
      await _speak(response.recommendation);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Column(
          children: [
            if (_messages.isEmpty)
              Expanded(
              child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                          'Type or speak your queries to get schemes relevant for you',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                            ),
                        const SizedBox(height: 20),
                        if (!_speechAvailable)
                            Text(
                            'Note: Speech recognition is not available on this device',
                            textAlign: TextAlign.center,
                              style: TextStyle(
                              fontSize: 14,
                              color: Colors.red,
                                ),
                              ),
                            ],
                    ),
                        ),
                      ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  message.content,
                                style: TextStyle(
                                    color: message.isUser
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (!message.isUser)
                                IconButton(
                                  icon: Icon(
                                    _isSpeaking ? Icons.stop : Icons.volume_up,
                                    color: message.isUser
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.primary,
                                    size: 20,
                                ),
                                  onPressed: () => _speak(message.content),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
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
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about government schemes...',
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
                  if (_isListening)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                    )
                  else
                    IconButton(
                      onPressed: _isLoading ? null : _startListening,
                      icon: Icon(
                        Icons.mic,
                        color: _speechAvailable
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
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
      ),
    );
  }
}

class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
} 