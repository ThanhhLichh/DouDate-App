import 'dart:async';
import 'dart:convert';
import '../../../core/config/api_config.dart';
import '../../features/chat/models/chat_models.dart';
import 'base_websocket_manager.dart';

class PresenceEvent {
  final int userId;
  final String status; // "online" hoặc "offline"

  PresenceEvent({required this.userId, required this.status});

  factory PresenceEvent.fromJson(Map<String, dynamic> json) {
    return PresenceEvent(userId: json['user_id'], status: json['status']);
  }
}

class ChatWebSocketService extends BaseWebSocketManager {
  final _messageController = StreamController<Message>.broadcast();
  final _presenceController = StreamController<PresenceEvent>.broadcast();
  final _settingsUpdateController = StreamController<void>.broadcast();
  final _reactionController = StreamController<MessageReaction>.broadcast();

  Stream<Message> get messageStream => _messageController.stream;
  Stream<PresenceEvent> get presenceStream => _presenceController.stream;
  Stream<void> get settingsUpdateStream => _settingsUpdateController.stream;
  Stream<MessageReaction> get reactionStream => _reactionController.stream;

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
      final type = json['type'] as String?;

      if (type == 'user_presence') {
        // Xử lý presence event
        final presenceEvent = PresenceEvent.fromJson(json);
        _presenceController.add(presenceEvent);
        print(
          'Presence event: User ${presenceEvent.userId} is ${presenceEvent.status}',
        );
      } else if (type == 'chat_settings_updated') {
        // Xử lý settings update event
        _settingsUpdateController.add(null);
        print('Chat settings updated by partner');
      } else if (json['type'] == 'reaction') {
        final reaction = MessageReaction.fromWebSocket(json);
        _reactionController.add(reaction);
      } else if (type == 'ping') {
        // Ignore ping messages
        return;
      } else {
        // Xử lý chat message (không có type hoặc type khác)
        final message = Message.fromJson(json);
        _messageController.add(message);
      }
    } catch (e) {
      print('Error parsing WebSocket message: $e');
    }
  }

  @override
  void onConnectionStateChanged(bool isConnected) {
    print('Chat WebSocket connection state: $isConnected');
  }

  void sendMessage(
    String content, {
    String type = 'text',
    String? imgUrl,
    String? thumbnailUrl,
  }) {
    if (isConnected) {
      final Map<String, dynamic> payload = {'type': type, 'content': content};

      if (imgUrl != null) payload['img_url'] = imgUrl;
      if (thumbnailUrl != null) payload['thumbnail_url'] = thumbnailUrl;

      sendData(jsonEncode(payload));
    }
  }

  @override
  void dispose() {
    _messageController.close();
    _presenceController.close();
    _settingsUpdateController.close();
    super.dispose();
  }
}
