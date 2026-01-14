import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // TODO: Secure API Key handling usually expected
  // Using a placeholder or public instruction for now as I don't have user's key
  // The user will need to replace this or set via env
  static const String _apiKey = 'AIzaSyA4DEW35vbzCr0FkhZjjB2B2KghXz8oKi0';
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ChatProvider() {
    _initModel();
  }

  void _initModel() {
    // Safety fallback if key is not set
    try {
      _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
      _chat = _model.startChat();

      // Add initial welcome message
      _messages.add(ChatMessage(
        text: 'مرحباً! أنا مساعدك الذكي. كيف يمكنني مساعدتك اليوم؟',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      debugPrint('Error initializing Gemini: $e');
    }
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText != null) {
        _messages.add(ChatMessage(
          text: responseText,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'عذراً، حدث خطأ أثناء الاتصال بالخادم. يرجى التأكد من مفتاح API.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      debugPrint('Error sending message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
