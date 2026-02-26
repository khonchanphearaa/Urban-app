import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/secure_storage_service.dart';

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  const AiChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

class AiChatController extends ChangeNotifier {
  final List<AiChatMessage> _messages = <AiChatMessage>[
    AiChatMessage(
      text: 'Hi! Ask me about products, prices, or categories.',
      isUser: false,
      createdAt: DateTime.now(),
    ),
  ];

  bool _isSending = false;
  bool _isClearing = false;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  bool get isClearing => _isClearing;

  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || _isSending) return;

    _messages.add(
      AiChatMessage(text: trimmed, isUser: true, createdAt: DateTime.now()),
    );
    _isSending = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      /* REST api ai chat */
      final response = await http.post(
        Uri.parse('${ApiConstants.apiBaseUrl}/ai/chat'),
        headers: headers,
        body: jsonEncode({'message': trimmed}),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to get AI response (${response.statusCode})');
      }

      final body = jsonDecode(response.body);
      final reply = body is Map<String, dynamic> ? (body['reply']?.toString() ?? 'No response from AI.') : 'Invalid AI response.';

      _messages.add(
        AiChatMessage(
          text: reply.trim(),
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
    } catch (_) {
      _messages.add(
        AiChatMessage(
          text: 'Sorry, AI chat is unavailable right now. Please try again.',
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<bool> clearChat() async {
    if (_isClearing) return false;

    _isClearing = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.readToken();
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.apiBaseUrl}/ai/chat/history'),
        headers: headers,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to clear AI chat history');
      }

      _resetToWelcomeMessage();
      return true;
    } catch (_) {
      return false;
    } finally {
      _isClearing = false;
      notifyListeners();
    }
  }

  void _resetToWelcomeMessage() {
    _messages
      ..clear()
      ..add(
        AiChatMessage(
          text: 'Hi! Ask me about products, prices, or categories.',
          isUser: false,
          createdAt: DateTime.now(),
        ),
      );
  }
}
