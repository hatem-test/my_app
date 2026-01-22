import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class N8nService {
  static const String _baseUrl =
      'https://ahmed-alhatem.app.n8n.cloud/webhook/chat';
  static const String _apiToken = 'n8n_supa_secure_998877';

  Future<Map<String, dynamic>> sendMessage({
    required String message,
    String? userId,
    String? userEmail,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'kanaf-secret-token': _apiToken,
        },
        body: jsonEncode({
          'chatInput': message, // Standard n8n chat input
          'userId': userId,
          'userEmail': userEmail,
        }),
      );

      if (response.statusCode == 200) {
        // Parse the expected response format:
        // {{ { "answer": $json.output, "child_name": $('Get Child Context').item.json.child_name, "timestamp": new Date().toISOString() } }}
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending message to n8n: $e');
      rethrow;
    }
  }
}