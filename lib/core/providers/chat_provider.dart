import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chat_message.dart';
import '../../services/n8n_service.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final N8nService _n8nService = N8nService();

  ChatProvider() {
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text:
          'مرحباً! أنا مساعدك الذكي الخاص بطفلك. اسأليني عن يومه أو وجباته وسأجيبك.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;

      final response = await _n8nService.sendMessage(
        message: text,
        userId: user?.id,
        userEmail: user?.email,
      );

      // Extract answer from response
      final String answer = response['answer'] ?? 'عذراً، لم أستطع فهم الرد.';

      _messages.add(ChatMessage(
        text: answer,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      // In case of error (like 404/500), we show a user friendly message
      _messages.add(ChatMessage(
        text: 'عذراً، حدث خطأ في الاتصال. يرجى المحاولة لاحقاً.',
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
