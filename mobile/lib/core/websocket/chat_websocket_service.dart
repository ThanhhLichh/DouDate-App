import 'dart:async';
import 'dart:convert';
import '../../../core/config/api_config.dart';
import '../../features/chat/models/chat_models.dart';
import 'base_websocket_manager.dart';

class ChatWebSocketService extends BaseWebSocketManager {
  final _messageController = StreamController<Message>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;

  @override
  String getWebSocketUrl(dynamic params) {
    final data = params as Map<String, dynamic>;
    final coupleId = data['coupleId'] as int;
    final token = data['token'] as String;
    final wsUrl = ApiConfig.wsUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    return '$wsUrl/ws/chat/$coupleId?token=$token';
  }

  @override
  void onMessage(dynamic data) {
    try {
      final json = jsonDecode(data);
      final message = Message.fromJson(json);
      _messageController.add(message);
    } catch (e) {
      print('Error parsing chat message: $e');
    }
  }

  @override
  void onConnectionStateChanged(bool isConnected) {
    print('Chat WebSocket connection state: $isConnected');
  }

  void sendMessage(String content) {
    if (isConnected) {
      sendData(jsonEncode({'content': content}));
    }
  }

  @override
  void dispose() {
    _messageController.close();
    super.dispose();
  }
}
